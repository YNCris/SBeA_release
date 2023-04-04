#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  8 12:30:11 2021
eval vis model
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

# r
def img2videos(imgpath):
    imgnamelist = get_files(imgpath,'png')
    video_name_list = []
    for tempimg in imgnamelist:
        imgname = tempimg   
        namelist = imgname.split('_')
        video_name_list.append(namelist[0])
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

def mask2rle(rawmasks):
    rawmasksrles = []
    for rawmask in rawmasks:
        rawmasksrle = mask_util.encode(rawmask)
        rawmasksrle["counts"] = rawmasksrle["counts"].decode('utf-8')
        rawmasksrles.append(rawmasksrle)
    return rawmasksrles

def savelist2idx(savelist,length):
    idxlist = np.zeros([length,1])
    for m in range(np.size(savelist,axis=0)):
        idxlist[np.int32(savelist[m,0]):np.int32(savelist[m,1]+1),0] = 1         
    return idxlist

def correct_masks(result,dataset_info):
    #%
    corrected_result = {'categories':copy.deepcopy(result['categories']),'annotations':[],'videos':copy.deepcopy(result['videos'])}
    for tempvideo in result['videos']:
        # select annotations
        for tempanno in result['annotations']:
            if tempvideo['id'] == tempanno['video_id']:
                selanno = copy.deepcopy(tempanno)
        #% 1. find good masks from all frame [higher score, multi aim, larger distance, good greedy]
        prebwmasks = []
        score_list = []
        aim_list = []
        dist_list = []
        
        grelistforward = np.zeros([len(tempvideo['file_names']),dataset_info['Mouse_Num']**2])#[greedy dist,swapidx]
        for k in range(len(tempvideo['file_names'])):
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
                
                
                if len(tempcontour) == 0:
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
        for k in range(len(tempvideo['file_names'])):              
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
def sbea_eval(workroot,vismodelpath,evalmodelname,evaloutpath,dataset_info,train_info):
    #%%
    parser = argparse.ArgumentParser('VisTR inference script', parents=[get_args_parser()])
    args = parser.parse_args()
    
    args.model_path = vismodelpath + '/' + evalmodelname
    args.num_ins = dataset_info['Mouse_Num']
    args.img_path = workroot + '/datasets/raw_video_images'
    args.num_out = args.num_ins
    # args.num_classes = 41
    # args.ann_path = 
    fakepath = workroot + '/datasets/virtual_video_images'
    predpath = workroot + '/datasets/raw_video_preds'
    fakevispath = fakepath + "/test_5000_" + train_info['VIS_model'][0:-4]
    validjsonpath = fakevispath + '/annotations/instances_valid_sub.json'
    with open(validjsonpath, 'r') as f:
        validjson = json.load(f)
    
    
    args.save_path = evaloutpath + '/result.json'
    args.save_correct_path = evaloutpath + '/corrected_result.json'
    
    device = torch.device(args.device)

    # fix the seed for reproducibility
    seed = args.seed + utils.get_rank()
    torch.manual_seed(seed)
    np.random.seed(seed)
    random.seed(seed)
    num_frames = args.num_frames
    num_ins = args.num_ins
    #%%
    with torch.no_grad():
        model, criterion, postprocessors = build_model(args)
        model.to(device)
        state_dict = torch.load(args.model_path)['model']
        model.load_state_dict(state_dict)
        folder = args.img_path
        videos,video_dict = img2videos(folder)
        
        # videos = json.load(open(args.ann_path,'rb'))['videos']
        
        vis_num = len(videos)
        result = {'categories':validjson['categories'],'videos':[],'annotations':[]} 
        for i in range(vis_num):
            print("Process video: ",videos[i])
            id_ = i+1
            # id_ = videos[i]['id']
            file_names = video_dict[videos[i]]['name']
            videonamedict = {'file_names':[],'id':[]}
            videonamedict['file_names'] = file_names.copy()
            for k in range(len(videonamedict['file_names'])):
                videonamedict['file_names'][k] = videos[i] + '/' + videonamedict['file_names'][k]
            videonamedict['id'] = id_
            length = len(file_names)
            clip_num = math.ceil(length/num_frames)
            instance = {'video_id':id_,'score':[], 'category_id':[],'segmentations':[]}
            for p in range(0,len(file_names)-num_frames+1,num_frames):
                # print(p)
                clip_names = file_names[p:(p+num_frames)]
                img_set=[]
                for k in range(num_frames):
                    im = Image.open(os.path.join(folder,clip_names[k]))
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
                for n in range(np.size(pred_scores,axis=0)):
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
            result['annotations'].append(instance)
            result['videos'].append(videonamedict)
    #%% save to json file
    with open(args.save_path, 'w', encoding='utf-8') as f:
        json.dump(result,f,indent=4)
    with open(predpath + '/result.json', 'w', encoding='utf-8') as f:
        json.dump(result,f,indent=4)
    #%% json to videos
    with open(args.save_path, 'r') as f:
        result = json.load(f)
    #
    print('Export raw vistr results......')
    for tempvideo in result['videos']:
        tempname = tempvideo['file_names'][0].split('/')
        savevideopath = evaloutpath + '/' + tempname[0] + '_raw_vistr.avi'
        # select annotations
        for tempanno in result['annotations']:
            if tempvideo['id'] == tempanno['video_id']:
                selanno = copy.deepcopy(tempanno)
        #%
        vidobj = cv2.VideoWriter(savevideopath, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), 30, \
                                 selanno['segmentations'][0][0]['size'][::-1])
        print('Exporting: ' + savevideopath)
        for k in tqdm(range(len(tempvideo['file_names']))):
            tempimgname = tempvideo['file_names'][k].split('/')
            rawframe = cv2.imread(args.img_path + '/' + tempimgname[1])
            rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
            rawmasks = []
            count = 0
            for rawmasksrle in rawmasksrles:
                rawmasksrle["counts"] = rawmasksrle["counts"].encode('utf-8')
                tempmask = mask_util.decode(rawmasksrle)
                img = np.ones( (tempmask.shape[0], tempmask.shape[1], 3) )
                color_mask = COLORS[count]
                for i in range(3):
                    img[:,:,i] = color_mask[i]
                rawmasks.append(np.dstack((img, tempmask*0.5)))
                count += 1
            # AlphaBlend
            maskimg3 = rawframe.copy()
            for rawmask in rawmasks:
                for i in range(3):
                    maskimg3[:,:,i] = maskimg3[:,:,i] *(1-rawmask[:,:,3])+127*rawmask[:,:,i]*rawmask[:,:,3]
                    
            vidobj.write(maskimg3)
        vidobj.release()
        print(savevideopath + ' finished!')
            # plt.imshow(maskimg3)
            # plt.show()
    
    
    #%% plot corrected videos
    print('Correct results......')
    #% correct results
    corrected_result = correct_masks(result,dataset_info)
    with open(args.save_correct_path, 'w', encoding='utf-8') as f:
        json.dump(corrected_result,f,indent=4)
    #%%
    print('Export corrected results......')
    
    for tempvideo in corrected_result['videos']:
        tempname = tempvideo['file_names'][0].split('/')
        savevideopath = evaloutpath + '/' + tempname[0] + '_corrected.avi'

        # select annotations
        for tempanno in corrected_result['annotations']:
            if tempvideo['id'] == tempanno['video_id']:
                selanno = copy.deepcopy(tempanno)
        #%
        vidobj = cv2.VideoWriter(savevideopath, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), 30, \
                                 selanno['segmentations'][0][0]['size'][::-1])
        lastgood = 0
        segcount = 0
        print('Exporting: ' + savevideopath)
        for k in tqdm(range(len(tempvideo['file_names']))):
            tempimgname = tempvideo['file_names'][k].split('/')
            rawframe = cv2.imread(args.img_path + '/' + tempimgname[1])
            rawmasksrles = copy.deepcopy(selanno['segmentations'][k])
            tempgood = selanno['searchgoodlist'][k]
            
                
            rawmasks = rle2mask(rawmasksrles)
            
            count = 0
            colormasks = []
            for rawmask in rawmasks:
                img = np.ones( (rawmask.shape[0], rawmask.shape[1], 3) )
                color_mask = COLORS[count]
                count += 1
                for i in range(3):
                    img[:,:,i] = color_mask[i]
                colormasks.append(np.dstack((img, rawmask*0.5)))
            
            # AlphaBlend
            maskimg3 = rawframe.copy()
            for rawmask in colormasks:
                for i in range(3):
                    maskimg3[:,:,i] = maskimg3[:,:,i] *(1-rawmask[:,:,3])+127*rawmask[:,:,i]*rawmask[:,:,3]
            
            # insert informations on frames[good/bad,segmentation numbers]
            if lastgood == [0.0] and tempgood == [1.0]:
                segcount += 1
            if tempgood == [1.0]:               
                    temptext = '[good, seg NO. ' + str(segcount) + ', frame:' + str(k) + ']'
            else:
                temptext = '[bad' + ', frame:' + str(k) + ']'
                
            if k > 0:
                lastgood = tempgood
            cv2.putText(maskimg3, temptext, (10,40), cv2.FONT_HERSHEY_SIMPLEX, 1, \
                        [255,255,255], thickness=2, lineType=None, bottomLeftOrigin=None)
            # plt.imshow(maskimg3)
            # plt.title(str(k) + ' ' + str(tempgood))
            # plt.show()
            vidobj.write(maskimg3)
        vidobj.release()
        print(savevideopath + ' finished!')
        
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
