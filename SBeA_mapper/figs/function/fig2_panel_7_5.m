function fig2_panel_7_5(rootpath,mouse1_c,mouse2_c)
h75 = subplot('Position',[0.66,0.732,0.1,0.1*480/640]);
sel_name = 'zone_3_16_19_0';
sel_frame_num = 12;
imgname = [rootpath,'\panel_7\',sel_name,'\',num2str(sel_frame_num),'.jpg'];
jsonname = [rootpath,'\panel_7\instances_valid_sub.json'];
jsontext = fileread(jsonname);
jsonvalue = jsondecode(jsontext);
img = imread(imgname);
for k = 1:size(jsonvalue.videos,1)
    %%
    tempnamecell = jsonvalue.videos(k).file_names;
    for m = 1:size(tempnamecell,1)
        %%
        tempname = tempnamecell{m,1};
        splname = split(tempname,'/');
        if strcmp(splname{1},sel_name)
            sel_num = k;
            break
        end
    end
end
sel_anno_idx = [jsonvalue.annotations.video_id]==sel_num;
anno_cell = jsonvalue.annotations(sel_anno_idx);
mask_traj_1 = [anno_cell(1).bboxes(:,1)+anno_cell(1).bboxes(:,3)/2,...
    anno_cell(1).bboxes(:,2)+anno_cell(1).bboxes(:,4)/2];
mask_traj_2 = [anno_cell(2).bboxes(:,1)+anno_cell(2).bboxes(:,3)/2,...
    anno_cell(2).bboxes(:,2)+anno_cell(2).bboxes(:,4)/2];

img_anno_1 = anno_cell(1).segmentations(sel_frame_num);
img_anno_2 = anno_cell(2).segmentations(sel_frame_num);
masks_1 = MaskApi.decode(img_anno_1);
masks_2 = MaskApi.decode(img_anno_2);
show_mask = double(masks_1)+2*double(masks_2);
imagesc(show_mask)
start_x = 350;
end_x = 550;
start_y = 250;
end_y = start_y+(end_x-start_x)*(480/640);
axis([start_x,end_x,start_y,end_y])
% axis equal
% axis off
box on
set(gca,'XTick',[])
set(gca,'YTick',[])
title('Synthetic Label','Color','blue')

colormap(h75,[1,1,1;...
        mouse1_c;...
        mouse2_c])