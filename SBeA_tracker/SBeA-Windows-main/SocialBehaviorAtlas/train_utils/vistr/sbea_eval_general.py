#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 25 16:55:08 2021

@author: yaninghan
"""
#%%
import argparse
import datetime
import json
import random
import time
from pathlib import Path

import numpy as np
import multiprocessing
import torch
from torch.utils.data import DataLoader, DistributedSampler

import SocialBehaviorAtlas.train_utils.vistr.datasets
import SocialBehaviorAtlas.train_utils.vistr.util.misc as utils
from SocialBehaviorAtlas.train_utils.vistr.datasets import build_dataset, get_coco_api_from_dataset
from SocialBehaviorAtlas.train_utils.vistr.engine import evaluate, train_one_epoch
from SocialBehaviorAtlas.train_utils.vistr.models import build_model
import torchvision.transforms as T
import matplotlib.pyplot as plt
import os
from PIL import Image
from PIL import ImageDraw
import math
import torch.nn.functional as F
import json
from scipy.optimize import linear_sum_assignment
import pycocotools.mask as mask_util
import cv2
import copy
from tqdm import tqdm
from scipy.cluster import hierarchy
from scipy.spatial.distance import squareform
from imantics import Polygons, Mask
from torchvision import models
import torch.nn as nn
from skimage import metrics
from scipy.spatial.distance import cdist
from scipy.optimize import linear_sum_assignment
from scipy.ndimage import gaussian_filter


#% define functions
def get_args_parser():
    parser = argparse.ArgumentParser('Set transformer detector', add_help=False)
    parser.add_argument('--lr', default=1e-4, type=float)
    parser.add_argument('--lr_backbone', default=1e-5, type=float)
    parser.add_argument('--batch_size', default=2, type=int)
    parser.add_argument('--weight_decay', default=1e-4, type=float)
    parser.add_argument('--epochs', default=150, type=int)
    parser.add_argument('--lr_drop', default=100, type=int)
    parser.add_argument('--clip_max_norm', default=0.1, type=float,
                        help='gradient clipping max norm')

    # Model parameters
    parser.add_argument('--model_path', type=str, default=None,
                        help="Path to the model weights.")
    # * Backbone
    parser.add_argument('--backbone', default='resnet101', type=str,
                        help="Name of the convolutional backbone to use")
    parser.add_argument('--dilation', action='store_true',
                        help="If true, we replace stride with dilation in the last convolutional block (DC5)")
    parser.add_argument('--position_embedding', default='sine', type=str, choices=('sine', 'learned'),
                        help="Type of positional embedding to use on top of the image features")

    # * Transformer
    parser.add_argument('--enc_layers', default=6, type=int,
                        help="Number of encoding layers in the transformer")
    parser.add_argument('--dec_layers', default=6, type=int,
                        help="Number of decoding layers in the transformer")
    parser.add_argument('--dim_feedforward', default=2048, type=int,
                        help="Intermediate size of the feedforward layers in the transformer blocks")
    parser.add_argument('--hidden_dim', default=384, type=int,
                        help="Size of the embeddings (dimension of the transformer)")
    parser.add_argument('--dropout', default=0.1, type=float,
                        help="Dropout applied in the transformer")
    parser.add_argument('--nheads', default=8, type=int,
                        help="Number of attention heads inside the transformer's attentions")
    parser.add_argument('--num_frames', default=9, type=int,
                        help="Number of frames")
    parser.add_argument('--num_ins', default=10, type=int,
                        help="Number of instances")#10
    parser.add_argument('--num_queries', default=18, type=int,
                        help="Number of query slots")
    parser.add_argument('--pre_norm', action='store_true')
    parser.add_argument('--num_classes', default=2)

    # * Segmentation
    parser.add_argument('--masks', default=True)
    # parser.add_argument('--masks', action='store_true',
    #                     help="Train segmentation head if the flag is provided")

    # Loss
    parser.add_argument('--no_aux_loss', dest='aux_loss', action='store_false',
                        help="Disables auxiliary decoding losses (loss at each layer)")
    # * Matcher
    parser.add_argument('--set_cost_class', default=1, type=float,
                        help="Class coefficient in the matching cost")
    parser.add_argument('--set_cost_bbox', default=5, type=float,
                        help="L1 box coefficient in the matching cost")
    parser.add_argument('--set_cost_giou', default=2, type=float,
                        help="giou box coefficient in the matching cost")
    # * Loss coefficients
    parser.add_argument('--mask_loss_coef', default=1, type=float)
    parser.add_argument('--dice_loss_coef', default=1, type=float)
    parser.add_argument('--bbox_loss_coef', default=5, type=float)
    parser.add_argument('--giou_loss_coef', default=2, type=float)
    parser.add_argument('--eos_coef', default=0.1, type=float,
                        help="Relative classification weight of the no-object class")

    # dataset parameters
    parser.add_argument('--img_path', default='data/ytvos/valid/JPEGImages/')
    parser.add_argument('--ann_path', default='data/ytvos/annotations/instances_val_sub.json')
    parser.add_argument('--save_path', default='results.json')
    parser.add_argument('--dataset_file', default='ytvos')
    parser.add_argument('--coco_path', type=str)
    parser.add_argument('--coco_panoptic_path', type=str)
    parser.add_argument('--remove_difficult', action='store_true')

    parser.add_argument('--output_dir', default='output_ytvos',
                        help='path where to save, empty for no saving')
    parser.add_argument('--device', default='cuda',
                        help='device to use for training / testing')
    parser.add_argument('--seed', default=42, type=int)
    parser.add_argument('--resume', default='', help='resume from checkpoint')
    parser.add_argument('--start_epoch', default=0, type=int, metavar='N',
                        help='start epoch')
    #parser.add_argument('--eval', action='store_true')
    parser.add_argument('--eval', action='store_false')
    parser.add_argument('--num_workers', default=0, type=int)

    # distributed training parameters
    parser.add_argument('--world_size', default=1, type=int,
                        help='number of distributed processes')
    parser.add_argument('--dist_url', default='env://', help='url used to set up distributed training')
    return parser

CLASSES=['person','giant_panda','lizard','parrot','skateboard','sedan','ape',
         'dog','snake','monkey','hand','rabbit','duck','cat','cow','fish',
         'train','horse','turtle','bear','motorbike','giraffe','leopard',
         'fox','deer','owl','surfboard','airplane','truck','zebra','tiger',
         'elephant','snowboard','boat','shark','mouse','frog','eagle','earless_seal',
         'tennis_racket']
COLORS = [[0.000, 0.447, 0.741], [0.850, 0.325, 0.098], [0.929, 0.694, 0.125],
          [0.494, 0.184, 0.556], [0.466, 0.674, 0.188], [0.301, 0.745, 0.933],
          [0.494, 0.000, 0.556], [0.494, 0.000, 0.000], [0.000, 0.745, 0.000],
          [0.700, 0.300, 0.600]]
transform = T.Compose([
    T.Resize(300),
    T.ToTensor(),
    T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])
transform_pret = T.Compose([      
 T.Resize(256),              
 T.CenterCrop(224),            
 T.ToTensor(),               
 T.Normalize(                 
 mean=[0.485, 0.456, 0.406],    
 std=[0.229, 0.224, 0.225]     
 )])


# for output bounding box post-processing
def box_cxcywh_to_xyxy(x):
    x_c, y_c, w, h = x.unbind(1)
    b = [(x_c - 0.5 * w), (y_c - 0.5 * h),
         (x_c + 0.5 * w), (y_c + 0.5 * h)]
    return torch.stack(b, dim=1)

def rescale_bboxes(out_bbox, size):
    img_w, img_h = size
    b = box_cxcywh_to_xyxy(out_bbox)
    b = b.cpu() * torch.tensor([img_w, img_h, img_w, img_h], dtype=torch.float32)
    return b

def get_files(filepath,fileformat) -> list:
    file_list = os.listdir(filepath) 
    
    for file in file_list[::-1]:  
        if file.endswith(fileformat): 
            continue
        file_list.remove(file)  
    
    return file_list 

def img2videos(imgpath):
    imgnamelist = get_files(imgpath,'png')
    video_name_list = []
    for tempimg in imgnamelist:
        imgname = tempimg   
        namelist = imgname.split('_')
        video_name_list.append(namelist[0] + '_' + namelist[1])
    video_name_list = list(set(video_name_list))
    video_dict = {}
    seq_dict = {}
    for tempvidname in video_name_list:
        video_dict[tempvidname] = {'name':[],'id':[]}
        seq_dict[tempvidname] = []
        count = 1
        for tempimg in imgnamelist:
            imgname = tempimg
            namelist = imgname.split('_')
            if imgname[0:len(tempvidname)] == tempvidname:
                video_dict[tempvidname]['name'].append(imgname)
                video_dict[tempvidname]['id'].append(namelist[2])
                count += 1
                seq_dict[tempvidname].append(int(namelist[2]))
        keydict1 = dict(zip(video_dict[tempvidname]['name'], seq_dict[tempvidname]))
        keydict2 = dict(zip(video_dict[tempvidname]['id'], seq_dict[tempvidname]))
        video_dict[tempvidname]['name'].sort(key=keydict1.get)
        video_dict[tempvidname]['id'].sort(key=keydict2.get)
    
    return video_name_list,video_dict

def greedy_dist(templist1,templist2):
    greedy_mat = np.zeros([len(templist1),len(templist2)])
    for m in range(0,len(templist1)):
        for n in range(0,len(templist2)):
            greedy_mat[m,n] = np.sum(templist1[m]^templist2[n])
    return greedy_mat

def idx2savelist(idxlist):
    nplist = np.int32(np.array(idxlist))
    difflist = np.diff(nplist)
    startdifflist = np.hstack([1,np.abs(difflist)])
    startlist = np.where(startdifflist==1)
    enddifflist = np.hstack([np.abs(difflist),1])
    endlist = np.where(enddifflist==1)
    valuelist = nplist[startlist]
    savelist = np.hstack([startlist[0].reshape(-1,1),endlist[0].reshape(-1,1),valuelist.reshape(-1,1)])
    return savelist

def rle2mask(rawmasksrles):
    rawbwmasks = []
    for rawmasksrle in rawmasksrles:
        rawmasksrle["counts"] = rawmasksrle["counts"].encode('utf-8')
        tempmask = mask_util.decode(rawmasksrle)
        rawbwmasks.append(tempmask)
    return rawbwmasks

def rle2polygon(rawmasksrles):
    rawbwmasks = []
    for rawmasksrle in rawmasksrles:
        rawmasksrle["counts"] = rawmasksrle["counts"].encode('utf-8')
        tempmask = mask_util.decode(rawmasksrle)
        polygons = Mask(tempmask).polygons()
        rawbwmasks.append(np.vstack(polygons.points))
    return rawbwmasks

def mask2polygon(rawmasksrles):
    rawbwmasks = []
    for tempmask in rawmasksrles:
        polygons = Mask(tempmask).polygons()
        rawbwmasks.append(np.vstack(polygons.points))
    return rawbwmasks

def polygon2mask(img_shape, temppolygons):
    masklist = []
    for polygons in temppolygons:
        mask = np.zeros(img_shape, dtype=np.uint8)
        mask = Image.fromarray(mask)
        xy = list(map(tuple, polygons))
        ImageDraw.Draw(mask).polygon(xy=xy, outline=1, fill=1)
        masklist.append(np.array(mask, dtype=bool))
    return masklist

def mask2rle(rawmasks):
    rawmasksrles = []
    for rawmask in rawmasks:
        rawmasksrle = mask_util.encode(np.asfortranarray(rawmask))
        rawmasksrle["counts"] = rawmasksrle["counts"].decode('utf-8')
        rawmasksrles.append(rawmasksrle)
    return rawmasksrles

def savelist2idx(savelist,length):
    idxlist = np.zeros([length,1])
    for m in range(np.size(savelist,axis=0)):
        idxlist[np.int32(savelist[m,0]):np.int32(savelist[m,1]+1),0] = 1         
    return idxlist

def cross_match_min(distmat):
    maxvalue = np.max(distmat)
    assignmentlist = np.zeros([np.size(distmat,axis=0),2])
    tempdistmat = distmat.copy()
    for k in range(np.size(distmat,axis=0)):
        temppos = np.argwhere(tempdistmat==np.min(tempdistmat))
        assignmentlist[k,:] = temppos[0,:]
        tempdistmat[temppos[0][0],:] = maxvalue
        tempdistmat[:,temppos[0][1]] = maxvalue
    assignmentlist = assignmentlist[assignmentlist[:,0].argsort(),:]
    return np.int32(assignmentlist)
    
def correct_video_masks(result,dataset_info):
    #%
    corrected_result = copy.deepcopy(result)
    # select annotations
    selanno = copy.deepcopy(result['annotations'][0])
    #% 1. find good masks from all frame [higher score, multi aim, larger distance, good greedy]
    prebwmasks = []
    score_list = []
    aim_list = []
    dist_list = []
    
    vidobj = cv2.VideoCapture(result['videos'][0]['name'])
    frame_num = int(vidobj.get(7))
    
    grelistforward = np.zeros([frame_num,dataset_info['Mouse_Num']**2])#[greedy dist,swapidx]
    
    for k in range(len(selanno['segmentations'])):
        rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
        
        score_list.append(np.mean(selanno['score'][k]))
        
        rawbwmasks = []
        cent_list = []
        tempaimlist = []
        for rawmasksrle in rawmasksrles:
            rawmasksrle["counts"] = rawmasksrle["counts"].encode('utf-8')
            tempmask = mask_util.decode(rawmasksrle)
            rawbwmasks.append(tempmask)
            
            tempcontour,temp = cv2.findContours(tempmask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
            
            
            if len(tempcontour) == 0 or len(tempcontour) != (dataset_info['Mouse_Num']/len(rawmasksrles)):
                tempaimlist.append(0)
                cent_list.append(0)
            else:
                tempaimlist.append(1)
                maxlength = 0
                count = 0
                maxidx = 0
                for tempc in list(tempcontour):
                    if np.size(tempc,axis=0)>maxlength:
                        maxidx = count
                    count += 1
                
                temppos = tempcontour[maxidx]
            
                cent_list.append(np.round(np.mean(temppos.reshape(-1,2),axis=0)).reshape(1,-1))
            
        aim_list.append(np.mean(tempaimlist))        
        # calculate dist
        tempdist = []
        for m in range(len(cent_list)):
            for n in range(len(cent_list)):
                if m != n:
                    tempdist.append(np.sum(np.sqrt((np.abs(cent_list[m]-cent_list[n]))**2)))
                    
        dist_list.append(np.mean(tempdist))
                
        # correct frames
        if k > 0:
            greedy_mat = greedy_dist(rawbwmasks,prebwmasks).reshape(1,-1)
            grelistforward[k,0:4] = np.sort(greedy_mat)
            
        prebwmasks = rawbwmasks.copy()
        
    # clustering
    temppdist = squareform(hierarchy.distance.pdist(grelistforward, metric='seuclidean'))
    linkage = hierarchy.linkage(temppdist, method='ward')
    p1 = hierarchy.fcluster(linkage,2, criterion='maxclust')
    peaksub = grelistforward[:,3] - grelistforward[:,0]
    p11 = np.sum(peaksub[p1==1])
    p12 = np.sum(peaksub[p1==2])
    newp1 = p1.copy()
    # select 1
    if p11 > p12:
        newp1[p1==1] = 1
        newp1[p1==2] = 0
    else:
        newp1[p1==1] = 0
        newp1[p1==2] = 1
        
    # binarize all list
    bw_score_list = np.array(score_list)==1
    bw_aim_list = np.array(aim_list)==1
    bw_dist_list = np.array(dist_list)>(np.mean(np.array(dist_list))/10)
    bw_greedy_list = newp1==1
    
    allgoodlist = bw_score_list & bw_aim_list & bw_dist_list & bw_greedy_list
    
    #% 2. start from good masks and search other good masks by pretrained resnet
    savelist = idx2savelist(allgoodlist)
    predlist = savelist[savelist[:,2]==0]
    predlist[:,2] = predlist[:,0] - 1
    if predlist[0,1] == 0:
        predlist[0,2] = 1 
    #% import pretrained network
    random.seed(10)
    #%
    block_size = 15
    
    for k in tqdm(range(np.size(predlist,axis=0))):
        #% get good polygons and frame
        goodidx = predlist[k,2]
        goodmasksrles = copy.deepcopy(selanno['segmentations'][goodidx])
        goodpolygons = rle2polygon(goodmasksrles)
        vidobj.set(cv2.CAP_PROP_POS_FRAMES,goodidx)
        a,goodframe = vidobj.read()
        # (b, g, r) = cv2.split(goodframe)
        # bH = cv2.equalizeHist(b)
        # gH = cv2.equalizeHist(g)
        # rH = cv2.equalizeHist(r)
        # goodframe = cv2.merge((bH, gH, rH))
        goodidxlist = []
        count = 0
        for goodpolygon in goodpolygons:
            goodidxlist += np.size(goodpolygon,axis=0)*[count]
            count += 1
        goodpolygonlist = np.vstack(goodpolygons)
        goodselthres = 100000
        if np.size(goodpolygonlist,axis=0) > goodselthres:
            selidx = np.sort(random.sample(range(0,np.size(goodpolygonlist,axis=0)),goodselthres)).tolist()
            goodpolygonlist = goodpolygonlist[selidx,:]
            goodidxlist = np.array(goodidxlist)[selidx].tolist()
            
        goodidxlist = np.array(goodidxlist)
        
        templist = np.transpose(np.vstack([goodpolygonlist[:,0]-block_size,goodpolygonlist[:,0]+block_size,\
                             goodpolygonlist[:,1]-block_size,goodpolygonlist[:,1]+block_size]))
        templist[templist[:,3]>=np.size(goodframe,axis=0),3] = np.size(goodframe,axis=0)-1
        templist[templist[:,1]>=np.size(goodframe,axis=1),1] = np.size(goodframe,axis=1)-1
        
        goodkcflist = []    
        showgoodlist = []
        for count in range(np.size(templist,axis=0)):
            gTracker = cv2.legacy.TrackerCSRT_create() #CSRT BEST
            gTracker.init(goodframe,[templist[count,0],templist[count,2],\
                                     templist[count,1]-templist[count,0],templist[count,3]-templist[count,2]])
            goodkcflist.append(gTracker)
            showgoodlist.append([templist[count,0]+block_size,templist[count,2]+block_size])
            count += 1
            
        showgoodlist = np.array(showgoodlist)
        
        
        #% feature extraction of bad frames
        for m in range(predlist[k,0],predlist[k,1]+1):
            vidobj.set(cv2.CAP_PROP_POS_FRAMES,m)
            a,badframe = vidobj.read()
            # (b, g, r) = cv2.split(badframe)
            # bH = cv2.equalizeHist(b)
            # gH = cv2.equalizeHist(g)
            # rH = cv2.equalizeHist(r)
            # badframe = cv2.merge((bH, gH, rH))
    
            #% CSRT
            badposlist = []      
            for gTracker in goodkcflist:
                tempitem = gTracker.update(badframe)
                badposlist.append([tempitem[1][0]+block_size,tempitem[1][1]+block_size])
            badposlist = np.array(badposlist)
            
            #% smooth
            smo_win = 1
            smoothbadposlist = []
            count = 0
            for count in range(np.max(goodidxlist)+1):
                tempbadlist = badposlist[goodidxlist==count,:]
                tempsmo = np.vstack([tempbadlist[-1*smo_win:,:],tempbadlist,tempbadlist[0:smo_win,:]])
                # plt.plot(tempsmo[:,0],tempsmo[:,1])
                # plt.show()
                tempsmo = np.round(np.transpose(np.vstack(\
                            [gaussian_filter(tempsmo[:,0],smo_win),gaussian_filter(tempsmo[:,1],smo_win)])))
                tempsmo = tempsmo[(smo_win-1):(-1*smo_win-1),:]
                # plt.plot(tempsmo[:,0],tempsmo[:,1])
                # plt.show()
                
                smoothbadposlist.append(tempsmo)
                
            #% resample
            tempmasks = polygon2mask([np.size(goodframe,axis=0),np.size(goodframe,axis=1)], smoothbadposlist)
            smoothbadposlist = mask2polygon(tempmasks)
            
            
            
            
            
            
            # plt.subplot(121)
            # plt.imshow(goodframe)
            # plt.title(m)
            # plt.plot(showgoodlist[goodidxlist==0,0],showgoodlist[goodidxlist==0,1],'r')
            # plt.plot(showgoodlist[goodidxlist==1,0],showgoodlist[goodidxlist==1,1],'g')
            
            #% change good result
            # print(tempmasks)
            corrected_result['annotations'][0]['segmentations'][m] = mask2rle(tempmasks)
            
            #% update
            showgoodlist = badposlist.copy()
            goodframe = badframe.copy()
            goodidxlist = []
            count = 0
            for goodpolygon in smoothbadposlist:
                goodidxlist += np.size(goodpolygon,axis=0)*[count]
                count += 1
            badposlist = np.vstack(smoothbadposlist)
            goodselthres = 100000
            if np.size(badposlist,axis=0) > goodselthres:
                selidx = np.sort(random.sample(range(0,np.size(badposlist,axis=0)),goodselthres)).tolist()
                badposlist = badposlist[selidx,:]
                goodidxlist = np.array(goodidxlist)[selidx].tolist()
                
            goodidxlist = np.array(goodidxlist)
            # showbadlist = badposlist.copy()
            
            
            
            templist = np.transpose(np.vstack([badposlist[:,0]-block_size,badposlist[:,0]+block_size,\
                                 badposlist[:,1]-block_size,badposlist[:,1]+block_size]))
            templist[templist[:,3]>=np.size(goodframe,axis=0),3] = np.size(goodframe,axis=0)-1
            templist[templist[:,1]>=np.size(goodframe,axis=1),1] = np.size(goodframe,axis=1)-1
            
            goodkcflist = []    
            showgoodlist = []
            for count in range(np.size(badposlist,axis=0)):
                gTracker = cv2.legacy.TrackerCSRT_create() #CSRT BEST
                gTracker.init(goodframe,[templist[count,0],templist[count,2],\
                                         templist[count,1]-templist[count,0],templist[count,3]-templist[count,2]])
                goodkcflist.append(gTracker)
                showgoodlist.append([templist[count,0]+block_size,templist[count,2]+block_size])
                count += 1
                
            showgoodlist = np.array(showgoodlist)  
            
            # plt.subplot(122)
            # plt.imshow(badframe)
            # plt.plot(showbadlist[goodidxlist==0,0],showbadlist[goodidxlist==0,1],'r')
            # plt.plot(showbadlist[goodidxlist==1,0],showbadlist[goodidxlist==1,1],'g')
            # plt.show()           
            
            # print(m)
            
    
    #%
    return corrected_result

def correct_masks(result,dataset_info):
    #%
    corrected_result = {'categories':copy.deepcopy(result['categories']),'annotations':[],'videos':copy.deepcopy(result['videos'])}
    # select annotations
    selanno = copy.deepcopy(result['annotations'][0])
    #% 1. find good masks from all frame [higher score, multi aim, larger distance, good greedy]
    prebwmasks = []
    score_list = []
    aim_list = []
    dist_list = []
    
    vidobj = cv2.VideoCapture(result['videos'][0]['name'])
    frame_num = int(vidobj.get(7))
    
    grelistforward = np.zeros([frame_num,dataset_info['Mouse_Num']**2])#[greedy dist,swapidx]
    
    for k in range(len(selanno['segmentations'])):
        rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
        
        score_list.append(np.mean(selanno['score'][k]))
        
        rawbwmasks = []
        cent_list = []
        tempaimlist = []
        for rawmasksrle in rawmasksrles:
            rawmasksrle["counts"] = rawmasksrle["counts"].encode('utf-8')
            tempmask = mask_util.decode(rawmasksrle)
            rawbwmasks.append(tempmask)
            
            tempcontour,temp = cv2.findContours(tempmask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
            
            
            if len(tempcontour) == 0 or len(tempcontour) != (dataset_info['Mouse_Num']/len(rawmasksrles)):
                tempaimlist.append(0)
                cent_list.append(0)
            else:
                tempaimlist.append(1)
                maxlength = 0
                count = 0
                maxidx = 0
                for tempc in list(tempcontour):
                    if np.size(tempc,axis=0)>maxlength:
                        maxidx = count
                    count += 1
                
                temppos = tempcontour[maxidx]
            
                cent_list.append(np.round(np.mean(temppos.reshape(-1,2),axis=0)).reshape(1,-1))
            
        aim_list.append(np.mean(tempaimlist))        
        # calculate dist
        tempdist = []
        for m in range(len(cent_list)):
            for n in range(len(cent_list)):
                if m != n:
                    tempdist.append(np.sum(np.sqrt((np.abs(cent_list[m]-cent_list[n]))**2)))
                    
        dist_list.append(np.mean(tempdist))
                
        # correct frames
        if k > 0:
            greedy_mat = greedy_dist(rawbwmasks,prebwmasks).reshape(1,-1)
            grelistforward[k,0:4] = np.sort(greedy_mat)
            
        prebwmasks = rawbwmasks.copy()
        
    # clustering            
    temppdist = squareform(hierarchy.distance.pdist(grelistforward, metric='seuclidean'))
    linkage = hierarchy.linkage(temppdist, method='ward')
    p1 = hierarchy.fcluster(linkage,2, criterion='maxclust')
    peaksub = grelistforward[:,3] - grelistforward[:,0]
    p11 = np.sum(peaksub[p1==1])
    p12 = np.sum(peaksub[p1==2])
    newp1 = p1.copy()
    # select 1
    if p11 > p12:
        newp1[p1==1] = 1
        newp1[p1==2] = 0
    else:
        newp1[p1==1] = 0
        newp1[p1==2] = 1
        
    # binarize all list
    bw_score_list = np.array(score_list)==1
    bw_aim_list = np.array(aim_list)==1
    bw_dist_list = np.array(dist_list)>(np.mean(np.array(dist_list))/3)
    bw_greedy_list = newp1==1
    
    allgoodlist = bw_score_list & bw_aim_list & bw_dist_list & bw_greedy_list
    
    #% 2. start from good masks and search other good masks
    savelist = idx2savelist(allgoodlist)
    selsavelist = savelist[savelist[:,2]==1]
    forwardlist = selsavelist[:,1].tolist()
    backwardlist = selsavelist[:,0].tolist()
    sensitive_idx = 0#control error
    
    for k in range(np.size(selsavelist,axis=0)):
        #% forward search
        start_cursor = selsavelist[k,1]
        if k == (np.size(selsavelist,axis=0)-1):
            end_cursor = len(allgoodlist)
        else:
            end_cursor = selsavelist[k+1,0]
            
        premasks = []   
        for m in range(start_cursor,end_cursor):                
            rawmasksrles = copy.deepcopy(selanno['segmentations'][m])
            rawmasks = rle2mask(rawmasksrles)
            if m > start_cursor:
                greedymat = greedy_dist(rawmasks,premasks)
                sortgreedy = np.diff(np.diff(np.sort(np.diff(np.sort(greedymat.reshape(-1,1),axis=0),\
                                                             axis=0),axis=0),axis=0),axis=0)
                if sortgreedy < 0:
                    forwardlist[k] = m-1
                    break
                elif m == (end_cursor-1):
                    forwardlist[k] = m
                    break
                # plt.subplot(131)
                # plt.plot(sortgreedy)
                # plt.title(m)
                # plt.subplot(132)
                # plt.imshow(rawmasks[0])
                # plt.title(np.mean(greedymat))
                # plt.subplot(133)
                # plt.imshow(premasks[0])
                # plt.title(np.std(greedymat))
                # plt.show()
            premasks = rawmasks.copy()
            
        #% backward search
        start_cursor = selsavelist[k,0]
        if start_cursor == 0:
            backwardlist[k] = 0
                       
        else:
            if k == 0:
                end_cursor = -1
                # print(1)
                # print(start_cursor)
            else:
                end_cursor = selsavelist[k-1,1]
            
            premasks = []   
            for m in range(start_cursor,end_cursor,-1):    
                rawmasksrles = copy.deepcopy(selanno['segmentations'][m])
                rawmasks = rle2mask(rawmasksrles)
                if m < start_cursor:
                    greedymat = greedy_dist(rawmasks,premasks)
                    sortgreedy = np.diff(np.diff(np.sort(np.diff(np.sort(greedymat.reshape(-1,1),axis=0),\
                                                                 axis=0),axis=0),axis=0),axis=0)
                    if sortgreedy < 0:
                        backwardlist[k] = m+1
                        break
                    elif m == (end_cursor+1):
                        backwardlist[k] = m
                        break
                    # plt.subplot(231)
                    # plt.plot(sortgreedy)
                    # plt.title(m)
                    # plt.subplot(232)
                    # plt.imshow(rawmasks[0])
                    # plt.title(np.mean(greedymat))
                    # plt.subplot(233)
                    # plt.imshow(premasks[0])
                    # plt.title(np.std(greedymat))
                    # plt.subplot(235)
                    # plt.imshow(rawmasks[1])
                    # plt.subplot(236)
                    # plt.imshow(premasks[1])
                    # plt.show()
                premasks = rawmasks.copy()
    
    searchsavelist = np.hstack([(np.array(backwardlist)+sensitive_idx).reshape(-1,1),\
                                (np.array(forwardlist)-sensitive_idx).reshape(-1,1),\
                                    np.ones(len(forwardlist)).reshape(-1,1)])
    searchgoodlist = savelist2idx(searchsavelist,len(allgoodlist))
         
    #% 3. create good masks list and correct the masks by greedy 
    hard_thres = 0.5
    premasks = []
    newanno = {'category_id':copy.deepcopy(selanno['category_id']),'score':copy.deepcopy(selanno['score']),\
               'segmentations':[],'video_id':copy.deepcopy(selanno['video_id']),'searchgoodlist':searchgoodlist.tolist()}
    for k in range(len(selanno['category_id'])):              
        rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
        rawmasks = rle2mask(rawmasksrles)
        
        
        
        if k > 0:
            greedymat = greedy_dist(rawmasks,premasks)
            trace1 = np.trace(greedymat)
            trace2 = np.trace(np.fliplr(greedymat))
            if trace1 > trace2:
                rawmasks.reverse()  
                
            #% hard threshold check
            
            if np.abs(trace1-trace2)/(trace1+trace2) < hard_thres:
                searchgoodlist[k] = [0.0]
        
                           
            # plt.subplot(231)
            # plt.imshow(greedymat)
            # plt.subplot(232)
            # plt.imshow(premasks[0])
            # plt.subplot(233)
            # plt.imshow(premasks[1])
            # plt.subplot(235)
            # plt.imshow(rawmasks[0])
            # plt.subplot(236)
            # plt.imshow(rawmasks[1])
            # plt.show()
        
        rawmasksrles = mask2rle(rawmasks)     
        newanno['segmentations'].append(rawmasksrles)                
        premasks = rawmasks.copy()
    newanno['searchgoodlist'] = searchgoodlist.tolist().copy()
    allgoodlist = savelist2idx(selsavelist,len(allgoodlist))
    newanno['allgoodlist'] = allgoodlist.tolist().copy()
    corrected_result['annotations'].append(newanno)           
    #%
    return corrected_result
#%%
def thread_correct_by_cont(param_list):

    tempname = param_list[0]
    result = param_list[1]
    folder = param_list[2]

    print('correct ' + tempname[0:-15] + ', please waiting......')
    corrected_result = {'categories': copy.deepcopy(result['categories']), \
                        'annotations': copy.deepcopy(result['annotations']), \
                        'videos': copy.deepcopy(result['videos'])}
    # select annotations
    selanno = corrected_result['annotations'][0]
    # process
    refmasks = rle2mask(copy.deepcopy(selanno['segmentations'][0]))

    for k in tqdm(range(1, len(selanno['segmentations']))):
        rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
        rawmasks = rle2mask(rawmasksrles)
        greedy_mat = greedy_dist(rawmasks, refmasks)
        invari_err = greedy_mat[0, 0] + greedy_mat[1, 1]
        change_err = greedy_mat[1, 0] + greedy_mat[0, 1]
        if change_err < invari_err:
            corrected_result['annotations'][0]['segmentations'][k].reverse()

    with open(folder + '/' + tempname[0:-15] + '-correctedresult.json', 'w', encoding='utf-8') as f:
        json.dump(corrected_result, f, indent=4)

    print('correct finished!')
#%%
def sbea_eval_general(workroot,vismodelpath,evalmodelname,dataset_info,train_info,newvideopath):
    #%%
    parser = argparse.ArgumentParser('VisTR inference script', parents=[get_args_parser()])
    args = parser.parse_args()
    
    args.model_path = vismodelpath + '/' + evalmodelname
    args.num_ins = dataset_info['Mouse_Num']
    args.img_path = newvideopath
    args.num_out = args.num_ins
    # args.num_classes = 41
    # args.ann_path = 
    fakepath = workroot + '/datasets/virtual_video_images'
    fakevispath = fakepath + "/test_5000_" + train_info['VIS_model'][0:-4]
    validjsonpath = fakevispath + '/annotations/instances_valid_sub.json'
    with open(validjsonpath, 'r') as f:
        validjson = json.load(f)
    
    
    # args.save_path = evaloutpath + '/result.json'
    
    device = torch.device(args.device)

    # fix the seed for reproducibility
    seed = args.seed + utils.get_rank()
    torch.manual_seed(seed)
    np.random.seed(seed)
    random.seed(seed)
    num_frames = args.num_frames
    num_ins = args.num_ins
    folder = args.img_path
    #%%
    with torch.no_grad():
        model, criterion, postprocessors = build_model(args)
        model.to(device)
        state_dict = torch.load(args.model_path)['model']
        model.load_state_dict(state_dict)
        
        
        videos = get_files(folder,'.avi')
        
        vis_num = len(videos)
        for i in range(vis_num):
            print("Process video: ",videos[i])
            result = {'categories':validjson['categories'],'videos':[],'annotations':[]} 
            id_ = 1
            tempvideo = {'name':folder + '/' + videos[i],'id':id_}
            result['videos'].append(tempvideo)
            # load videos, bug is here, 不是整数需要单独处理
            vidobj = cv2.VideoCapture(folder + '/' + videos[i])
            frame_num = int(vidobj.get(7))
            length = frame_num
            instance = {'video_id':id_,'score':[], 'category_id':[],'segmentations':[]}
            start_list = np.arange(0,frame_num-num_frames+1,num_frames).tolist()
            if start_list[-1] + num_frames < frame_num:
                start_list.append(frame_num - num_frames)
            p_1 = -1*num_frames
            for p in tqdm(start_list):
                # print(p_1)
                # print(p)
                img_set=[]
                for k in range(p,p+num_frames):
                    vidobj.set(cv2.CAP_PROP_POS_FRAMES,k)
                    a,tempim = vidobj.read()
                    im = Image.fromarray(tempim)
                    img_set.append(transform(im).unsqueeze(0).cuda())
                img=torch.cat(img_set,0)
                # inference time is calculated for this operation
                outputs = model(img)
                # end of model inference
                logits, boxes, masks = outputs['pred_logits'].softmax(-1)[0,:,:-1], outputs['pred_boxes'][0], outputs['pred_masks'][0]
                pred_masks =F.interpolate(masks.reshape(num_frames,num_ins,masks.shape[-2],masks.shape[-1]),\
                                          (im.size[1],im.size[0]),mode="bilinear").sigmoid().cpu().detach().numpy()>0.5
                pred_logits = logits.reshape(num_frames,num_ins,logits.shape[-1]).cpu().detach().numpy()
                pred_masks = pred_masks[:length]
                pred_logits = pred_logits[:length]
                pred_scores = np.max(pred_logits,axis=-1)
                pred_logits = np.argmax(pred_logits,axis=-1)

                if p-p_1 < num_frames:
                    save_n = np.arange(0, num_frames)
                    add_num = -1*(frame_num-(p_1+num_frames))
                    save_n = save_n[add_num::].tolist()
                else:
                    save_n = np.arange(0, num_frames).tolist()
                # print(save_n)

                for n in save_n:
                    segmentation = []
                    tempscore = []
                    tempcat = []
                    for m in range(num_ins):
                        score = pred_scores[:,m].mean()
                        category_id = np.argmax(np.bincount(pred_logits[:,m]))
                        tempscore.append(float(score))
                        tempcat.append(int(category_id))
                        if pred_scores[n,m]<0.001:
                            # segmentation.append(None)
                            instance['segmentations'].append(None)
                            # print('None')
                        else:
                            mask = (pred_masks[n,m]).astype(np.uint8)
                            rle = mask_util.encode(np.array(mask[:,:,np.newaxis], order='F'))[0]
                            rle["counts"] = rle["counts"].decode("utf-8")
                            segmentation.append(rle)
                    instance['segmentations'].append(segmentation)
                    instance['score'].append(tempscore)
                    instance['category_id'].append(tempcat)
                p_1 = p
            #%%
            result['annotations'].append(instance)
            with open(folder + '/' + videos[i][0:-4] + '-rawresult.json', 'w', encoding='utf-8') as f:
                json.dump(result,f,indent=4)

        # %% check by correct mask continuous
        # % reload json
        jsonnamelist = get_files(folder, 'rawresult.json')
        all_result_list = []
        for tempname in jsonnamelist:
            with open(folder + '/' + tempname, 'r') as f:
                result = json.load(f)
            all_result_list.append(result)

        # %% correct mask continuous
        print('correct masks......')
        param_list = []
        for result,tempname in zip(all_result_list,jsonnamelist):
            param_list.append((tempname, result, folder))

        count_pool = 40
        pool = multiprocessing.Pool(count_pool)
        pool.map(thread_correct_by_cont, param_list)

        print('correct masks finished!')


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    