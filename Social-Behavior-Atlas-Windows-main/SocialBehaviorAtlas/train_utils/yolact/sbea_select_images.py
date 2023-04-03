#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep 17 09:24:43 2021
select images for self-training
@author: yaninghan
"""
#%%
import json
from pycocotools import mask
import matplotlib.pyplot as plt
import numpy as np
import time
from scipy.cluster import hierarchy
from scipy.spatial.distance import squareform
from sklearn.cluster import KMeans
from pycocotools.coco import COCO
from skimage import io
# from SocialBehaviorAtlas.train_utils.yolact.data import *
#%% 
def greedy_dist(templist1,templist2):
    greedy_mat = np.zeros([len(templist1),len(templist2)])
    for m in range(0,len(templist1)):
        for n in range(0,len(templist2)):
            greedy_mat[m,n] = np.sum(templist1[m]^templist2[n])
    return greedy_mat
def mask2box(mask):
    # np.where(mask==1)
    index = np.argwhere(mask == 1)
    rows = index[:, 0]
    clos = index[:, 1]
    left_top_r = np.min(rows)  # y
    left_top_c = np.min(clos)  # x

    right_bottom_r = np.max(rows)
    right_bottom_c = np.max(clos)

    # return [(left_top_r,left_top_c),(right_bottom_r,right_bottom_c)]
    # return [(left_top_c, left_top_r), (right_bottom_c, right_bottom_r)]
    # return [left_top_c, left_top_r, right_bottom_c, right_bottom_r]  # [x1,y1,x2,y2]
    return [left_top_c, left_top_r, right_bottom_c - left_top_c,
            right_bottom_r - left_top_r]  # [x1,y1,w,h]
#%% 
# def check_json(cocojson):
#     #%%
#     dataset = COCODetection(image_path='/home/dltest/sbeaTestEnv/sbea_20210901/datasets/raw_video_images',
#                                 info_file='/home/dltest/sbeaTestEnv/sbea_20210901/datasets/pesudo_IS_labels/IS_default/sel_mask.json')
#     #%% check annotation image id 
#     tempimgid = []
#     for tempanno in cocojson['annotations']:
#         tempimgid.append(tempanno['image_id'])
#     #%% get image id
#     images_id = []
#     for tempimg in cocojson['images']:
#         images_id.append(tempimg['id'])
#     #%%
#     return 1
#%%
def sbea_select_images(dataset_info,train_info,workroot):
    #%% load mask label json
    with open(workroot + '/datasets/pesudo_IS_labels/' + train_info['Data_generate_model'][0:-4] + '/all_mask.json', 'r') as f:
        sbeacocojson = json.load(f)
    #%% transform to each video
    video_name_list = []
    for tempimg in sbeacocojson['images']:
        imgname = tempimg['file_name']
        namelist = imgname.split('_')
        video_name_list.append(namelist[0])
    video_name_list = list(set(video_name_list))
    video_dict = {}
    seq_dict = {}
    for tempvidname in video_name_list:
        video_dict[tempvidname] = {'name':[],'id':[]}
        seq_dict[tempvidname] = []
        for tempimg in sbeacocojson['images']:
            imgname = tempimg['file_name']
            namelist = imgname.split('_')
            if imgname[0:len(tempvidname)] == tempvidname:
                video_dict[tempvidname]['name'].append(imgname)
                video_dict[tempvidname]['id'].append(tempimg['id'])
                # change view number, not the raw name format
                # past code: seq_dict[tempvidname].append(int(namelist[2]))
                seq_dict[tempvidname].append(int(namelist[1]))
        keydict1 = dict(zip(video_dict[tempvidname]['name'], seq_dict[tempvidname]))
        keydict2 = dict(zip(video_dict[tempvidname]['id'], seq_dict[tempvidname]))
        video_dict[tempvidname]['name'].sort(key=keydict1.get)
        video_dict[tempvidname]['id'].sort(key=keydict2.get)
    # greedy mask-matching with score to select good masks
    print('select good masks from each video...')
    sel_list = []
    img_id_list = []
    anno_id = 1
    for tempvidname in video_name_list:
        # sel_dict[tempvidname] = []
        # imgnamelist = video_dict[tempvidname]['name']
        imgidlist = video_dict[tempvidname]['id']
        # calculate mask-matching
        grelistforward = np.zeros([len(imgidlist),dataset_info['Mouse_Num']**2])#[greedy dist,swapidx]
        last_anno_list = []
        count = 0
        for tempid in imgidlist:
            # find rle
            anno_list = []
            for tempanno in sbeacocojson['annotations']:
                if tempanno['image_id'] == tempid:
                    # rle2mask
                    if not isinstance(tempanno['segmentation']['counts'], bytes):
                        tempmask = tempanno['segmentation'].copy()
                        tempmask['counts'] = tempmask['counts'].encode('utf-8')
                    anno_list.append(mask.decode(tempmask))
            # check length and pad
            if len(anno_list) < dataset_info['Mouse_Num']:
                for m in range(len(anno_list),dataset_info['Mouse_Num']):
                    anno_list.append(anno_list[-1])
            # calculate greedy dist
            if count > 0:
                greedy_mat = greedy_dist(anno_list,last_anno_list).reshape(1,-1)
                grelistforward[count,0:4] = np.sort(greedy_mat)
            last_anno_list = anno_list
            count += 1
        # clustering
        if np.size(grelistforward, axis=0) == 0:
            grelistforward = np.zeros([len(imgidlist),dataset_info['Mouse_Num']**2])
            print('empty grelistforward')

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
        # hierarchy.dendrogram(linkage)
        # plt.show()
        # append selected annotations
        count = 0
        for tempid in imgidlist:
            if newp1[count] == 1:
                temptempanno = []
                for tempanno in sbeacocojson['annotations']:
                    if tempanno['image_id'] == tempid and tempanno['category_id'] != 0:
                        tempanno.pop('score')
                        temptempanno.append(tempanno)
                if len(temptempanno) == dataset_info['Mouse_Num']:  
                    for temptemptempanno in temptempanno:
                        temptemptempanno['id'] = anno_id
                        sel_list.append(temptemptempanno)
                        img_id_list.append(temptemptempanno['image_id'])
                        anno_id += 1
            count += 1
        # print
        print(tempvidname + ' finished!')
    #%% generate sel_mask.json
    sel_mask_json = sbeacocojson.copy()
    sel_mask_json['annotations'] = sel_list.copy()
    # delete redundancy images
    save_img_id_list = list(set(img_id_list))
    tempimgdict = sbeacocojson['images'].copy()
    sel_mask_json['images'] = []
    new_img_id = 1
    old_img_id_list = []
    new_img_id_list = []
    for tempimg in tempimgdict:
        for tempid in save_img_id_list:
            if tempimg['id'] == tempid:
                sel_mask_json['images'].append(tempimg)
                old_img_id_list.append(tempimg['id'])
                sel_mask_json['images'][new_img_id-1]['id'] = new_img_id
                new_img_id_list.append(new_img_id)
                new_img_id += 1
                break
    #
    for m in range(0,len(sel_mask_json['annotations'])):
        for n in range(0,len(old_img_id_list)):
            if sel_mask_json['annotations'][m]['image_id'] == old_img_id_list[n]:
                sel_mask_json['annotations'][m]['image_id'] = new_img_id_list[n]
    with open(workroot + '/datasets/pesudo_IS_labels/' + train_info['Data_generate_model'][0:-4] + '/sel_mask.json', 'w') as f:
        json.dump(sel_mask_json,f)
    print('select good masks finished!')
    # #%%
    # imgpath = '/home/dltest/sbeaTestEnv/sbea_20210901/datasets/raw_video_images'
    # coco = COCO(workroot + '/datasets/pesudo_IS_labels/' + train_info['Data_generate_model'][0:-4] + '/sel_mask.json')
    # catIds = coco.getCatIds('mouse')    
    # imgIds = coco.getImgIds(catIds=catIds)
    # for k in range(11116,12213):
    #     img = coco.loadImgs(k)
    #     image = io.imread(imgpath + '/' + img[0]['file_name'])
    #     annIds = coco.getAnnIds(imgIds=img[0]['id'],catIds=catIds)
    #     anns = coco.loadAnns(annIds)
    #     plt.imshow(image)
    #     coco.showAnns(anns,draw_bbox=True)
    #     plt.title(img[0]['id'])
    #     plt.show()
    #     print(annIds)
    #     # input()















