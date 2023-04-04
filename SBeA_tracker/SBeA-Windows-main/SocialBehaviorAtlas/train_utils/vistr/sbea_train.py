#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  5 20:25:17 2021
train vistr for sbea
@author: yaninghan
"""
#%%
import os
import argparse
import datetime
import json
import random
import time
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader, DistributedSampler

# import SocialBehaviorAtlas.train_utils.vistr.datasets
import SocialBehaviorAtlas.train_utils.vistr.util.misc as utils
from SocialBehaviorAtlas.train_utils.vistr.datasets import build_dataset, get_coco_api_from_dataset
from SocialBehaviorAtlas.train_utils.vistr.engine import evaluate, train_one_epoch
from SocialBehaviorAtlas.train_utils.vistr.models import build_model
from ruamel.yaml import YAML
# import shutil
import wget


def get_args_parser(workroot):
    # %% load default parameters
    default_config_pathname = workroot + '/models/configs/config_vistr.yaml'
    yaml = YAML()
    yaml.allow_duplicate_keys = True
    with open(default_config_pathname, "r", encoding="utf-8") as f:
        default_config = yaml.load(f)
    #%%
    parser = argparse.ArgumentParser('Set transformer detector', add_help=False)
    parser.add_argument('--lr', default=default_config['lr'], type=float)
    parser.add_argument('--lr_backbone', default=default_config['lr_backbone'], type=float)
    parser.add_argument('--batch_size', default=default_config['batch_size'], type=int)
    parser.add_argument('--weight_decay', default=default_config['weight_decay'], type=float)
    parser.add_argument('--epochs', default=default_config['epochs'], type=int)
    parser.add_argument('--lr_drop', default=default_config['lr_drop'], type=int)
    parser.add_argument('--clip_max_norm', default=default_config['clip_max_norm'], type=float,
                        help='gradient clipping max norm')

    # Model parameters
    parser.add_argument('--pretrained_weights', type=str, default=default_config['pretrained_weights'],
                        help="Path to the pretrained model.")
    # * Backbone
    parser.add_argument('--backbone', default=default_config['backbone'], type=str,
                        help="Name of the convolutional backbone to use")
    parser.add_argument('--dilation', action='store_true',
                        help="If true, we replace stride with dilation in the last convolutional block (DC5)")
    parser.add_argument('--position_embedding', default=default_config['position_embedding'], type=str, choices=('sine', 'learned'),
                        help="Type of positional embedding to use on top of the image features")

    # * Transformer
    parser.add_argument('--enc_layers', default=default_config['enc_layers'], type=int,
                        help="Number of encoding layers in the transformer")
    parser.add_argument('--dec_layers', default=default_config['dec_layers'], type=int,
                        help="Number of decoding layers in the transformer")
    parser.add_argument('--dim_feedforward', default=default_config['dim_feedforward'], type=int,
                        help="Intermediate size of the feedforward layers in the transformer blocks")
    parser.add_argument('--hidden_dim', default=default_config['hidden_dim'], type=int,
                        help="Size of the embeddings (dimension of the transformer)")
    parser.add_argument('--dropout', default=default_config['dropout'], type=float,
                        help="Dropout applied in the transformer")
    parser.add_argument('--nheads', default=default_config['nheads'], type=int,
                        help="Number of attention heads inside the transformer's attentions")
    parser.add_argument('--num_frames', default=default_config['num_frames'], type=int,
                        help="Number of frames")
    parser.add_argument('--num_queries', default=default_config['num_queries'], type=int,
                        help="Number of query slots")
    parser.add_argument('--pre_norm', action='store_true')

    # * Segmentation
    parser.add_argument('--masks', default=default_config['masks'])
    # parser.add_argument('--masks', action='store_true',
    #                     help="Train segmentation head if the flag is provided")

    # Loss
    parser.add_argument('--no_aux_loss', dest='aux_loss', action='store_false',
                        help="Disables auxiliary decoding losses (loss at each layer)")
    # * Matcher
    parser.add_argument('--set_cost_class', default=default_config['set_cost_class'], type=float,
                        help="Class coefficient in the matching cost")
    parser.add_argument('--set_cost_bbox', default=default_config['set_cost_bbox'], type=float,
                        help="L1 box coefficient in the matching cost")
    parser.add_argument('--set_cost_giou', default=default_config['set_cost_giou'], type=float,
                        help="giou box coefficient in the matching cost")
    # * Loss coefficients
    parser.add_argument('--mask_loss_coef', default=default_config['mask_loss_coef'], type=float)
    parser.add_argument('--dice_loss_coef', default=default_config['dice_loss_coef'], type=float)
    parser.add_argument('--bbox_loss_coef', default=default_config['bbox_loss_coef'], type=float)
    parser.add_argument('--giou_loss_coef', default=default_config['giou_loss_coef'], type=float)
    parser.add_argument('--eos_coef', default=default_config['eos_coef'], type=float,
                        help="Relative classification weight of the no-object class")

    # dataset parameters
    parser.add_argument('--dataset_file', default=default_config['dataset_file'])
    parser.add_argument('--num_classes', default=default_config['num_classes'])
    parser.add_argument('--ytvos_path', type=str)
    parser.add_argument('--remove_difficult', action='store_true')

    parser.add_argument('--output_dir', default=default_config['output_dir'],
                        help='path where to save, empty for no saving')
    parser.add_argument('--device', default=default_config['device'],
                        help='device to use for training / testing')
    parser.add_argument('--seed', default=default_config['seed'], type=int)
    parser.add_argument('--resume', default=default_config['resume'], help='resume from checkpoint')
    parser.add_argument('--start_epoch', default=default_config['start_epoch'], type=int, metavar='N',
                        help='start epoch')
    parser.add_argument('--eval', action='store_true')
    parser.add_argument('--num_workers', default=default_config['num_workers'], type=int)

    # distributed training parameters
    parser.add_argument('--world_size', default=default_config['world_size'], type=int,
                        help='number of distributed processes')
    parser.add_argument('--dist_url', default=default_config['dist_url'], help='url used to set up distributed training')
    return parser
#%%
def sbea_vistr_train(dataset_info,train_info,workroot):
    #%%
    parser = argparse.ArgumentParser('VisTR training and evaluation script', parents=[get_args_parser(workroot)])
    args = parser.parse_args(args=[])
    
    
    # set our parameters
    fakepath = workroot + '/datasets/virtual_video_images'
    fakevispath = fakepath + "/test_5000_" + train_info['VIS_model'][0:-4]
    args.ytvos_path = fakevispath#'/home/dltest/vistr/data/ytvos'
    # args.ytvos_path = '/home/dltest/vistr-2/data/SBM-VIS-VIStR-12'

    args.output_dir = workroot + '/models/vistr/' + train_info['VIS_model'][0:-4]
    args.pretrained_weights = workroot + '/models/vistr/384_coco_r101.pth'
    args.epochs = train_info['VIS_epochs']
    args.num_queries = dataset_info['Mouse_Num']*args.num_frames
    args.num_out = dataset_info['Mouse_Num']
    args.num_workers = 0
    
    if args.output_dir:
        Path(args.output_dir).mkdir(parents=True, exist_ok=True)
        
    utils.init_distributed_mode(args)
    # args.distributed = True
    # args.gpu = [0,1]
    print("git:\n  {}\n".format(utils.get_sha()))


    device = torch.device(args.device)

    # fix the seed for reproducibility
    seed = args.seed + utils.get_rank()
    torch.manual_seed(seed)
    np.random.seed(seed)
    random.seed(seed)

    model, criterion, postprocessors = build_model(args)
    model.to(device)

    model_without_ddp = model
    if args.distributed:
        model = torch.nn.parallel.DistributedDataParallel(model, device_ids=[args.gpu])
        model_without_ddp = model.module
    n_parameters = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print('number of params:', n_parameters)

    param_dicts = [
        {"params": [p for n, p in model_without_ddp.named_parameters() if "backbone" not in n and p.requires_grad]},
        {
            "params": [p for n, p in model_without_ddp.named_parameters() if "backbone" in n and p.requires_grad],
            "lr": args.lr_backbone,
        },
    ]
    optimizer = torch.optim.AdamW(param_dicts, lr=args.lr,
                                  weight_decay=args.weight_decay)
    lr_scheduler = torch.optim.lr_scheduler.StepLR(optimizer, args.lr_drop)

    # no validation ground truth for ytvos dataset
    dataset_train = build_dataset(image_set='train', args=args)
    if args.distributed:
        sampler_train = DistributedSampler(dataset_train)
    else:
        sampler_train = torch.utils.data.RandomSampler(dataset_train)

    batch_sampler_train = torch.utils.data.BatchSampler(
        sampler_train, args.batch_size, drop_last=True)

    data_loader_train = DataLoader(dataset_train, batch_sampler=batch_sampler_train,
                                   collate_fn=utils.collate_fn, num_workers=args.num_workers)

    output_dir = Path(args.output_dir)
    
    # load coco pretrained weight
    if not os.path.exists(args.pretrained_weights):
        print('Download 384_coco_r101.pth......')
        url = 'https://zenodo.org/record/6568566/files/384_coco_r101.pth?download=1'
        wget.download(url, args.pretrained_weights)
    checkpoint = torch.load(args.pretrained_weights, map_location='cpu')['model']
    del checkpoint["vistr.class_embed.weight"]
    del checkpoint["vistr.class_embed.bias"]
    del checkpoint["vistr.query_embed.weight"]
    model.load_state_dict(checkpoint,strict=False)

    if args.resume:
        if args.resume.startswith('https'):
            checkpoint = torch.hub.load_state_dict_from_url(
                args.resume, map_location='cpu', check_hash=True)
        else:
            checkpoint = torch.load(args.resume, map_location='cpu')
        model_without_ddp.load_state_dict(checkpoint['model'])
        if not args.eval and 'optimizer' in checkpoint and 'lr_scheduler' in checkpoint and 'epoch' in checkpoint:
            optimizer.load_state_dict(checkpoint['optimizer'])
            lr_scheduler.load_state_dict(checkpoint['lr_scheduler'])
            args.start_epoch = checkpoint['epoch'] + 1

    print("Start training")
    start_time = time.time()
    print(args.start_epoch)
    print(args.epochs)
    for epoch in range(args.start_epoch, args.epochs):
        if args.distributed:
            sampler_train.set_epoch(epoch)
        train_stats = train_one_epoch(
            model, criterion, data_loader_train, optimizer, device, epoch,
            args.clip_max_norm)
        lr_scheduler.step()
        if args.output_dir:
            checkpoint_paths = [output_dir / 'checkpoint.pth']
            # extra checkpoint before LR drop and every epochs
            if (epoch + 1) % args.lr_drop == 0 or (epoch + 1) % 1 == 0:
                checkpoint_paths.append(output_dir / f'checkpoint{epoch:04}.pth')
            for checkpoint_path in checkpoint_paths:
                utils.save_on_master({
                    'model': model_without_ddp.state_dict(),
                    'optimizer': optimizer.state_dict(),
                    'lr_scheduler': lr_scheduler.state_dict(),
                    'epoch': epoch,
                    'args': args,
                }, checkpoint_path)


    total_time = time.time() - start_time
    total_time_str = str(datetime.timedelta(seconds=int(total_time)))
    print('Training time {}'.format(total_time_str))




























