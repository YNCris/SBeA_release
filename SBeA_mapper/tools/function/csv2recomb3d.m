function sort_recomb_cell = csv2recomb3d(csv_cell,sel_frame_idx,camnum,cam_mat)
sel_csv_cell = csv_cell;
for k = 1:size(sel_csv_cell,1)
    sel_csv_cell{k,2} = csv_cell{k,2}(sel_frame_idx,:);
end
tempcomb = nchoosek(sel_csv_cell(:,1),camnum);
% delete redundancy
newcomb = {};
for k = 1:size(tempcomb,1)
    tempcomblist = tempcomb(k,:);
    idxlist = zeros(size(tempcomblist));
    for m = 1:size(idxlist,2)
        tempsplname = split(tempcomblist{1,m},'-');
        idxlist(1,m) = str2double(tempsplname{5});
    end
    if length(unique(idxlist)) == length(idxlist)
        newcomb = [newcomb;tempcomblist];
    end
end
% 3d reconstruction of all the conditions
rec3d_cell = cell(size(newcomb,1),2);
for k = 1:size(rec3d_cell,1)
    %
    tempcombname = newcomb(k,:);
    % select data
    seldata = cell(size(tempcombname,2),1);
    for m = 1:size(seldata,1)
        tempcell = sel_csv_cell(strcmp(tempcombname{1,m},sel_csv_cell(:,1)),:);
        seldata{m,1} = tempcell{1,2};
    end
    % 3d reconstruction
    seldatamat = cell2mat(seldata);
    rec3d_pos = zeros(3,size(seldatamat,2)/2);
    rec3d_err = zeros(4,size(seldatamat,2)/2);
    for m = 1:size(rec3d_pos,2)
        points = seldatamat(:,((m-1)*2+1):(m*2))';
        [X,reprojErr] = temp_triangulate(points,cam_mat,4);
        rec3d_pos(:,m) = X;
        rec3d_err(:,m) = reprojErr;
    end
    %
    rec3d_cell{k,1} = rec3d_pos;
    rec3d_cell{k,2} = rec3d_err;
end
%
mean_err = cell2mat(cellfun(@(x) mean(x(:)),...
    rec3d_cell(:,2),'UniformOutput',false));
% find complementation
comp_list = zeros(size(newcomb,1),1);
for k = 1:size(newcomb,1)
    % first compare
    tempnamelist = newcomb(k,:);
    refnamelist = sel_csv_cell(:,1)';
    temp_comp_list = zeros(size(refnamelist));
    % compare
    for m = 1:length(refnamelist)
        for n = 1:length(tempnamelist)
            if strcmp(refnamelist{m},tempnamelist{n})
                temp_comp_list(m) = 1;
            end
        end
    end
    % compare complementation name
    comp_name_list = refnamelist(temp_comp_list==0);
    for m = 1:size(newcomb,1)
        allname = [comp_name_list,newcomb(m,:)];
        unique_name = unique(allname);
%         disp(length(unique_name))
        if (length(unique_name) == length(allname)) | ...
                (length(unique_name) == length(allname)/2)
            comp_list(m,1) = k;
        end
    end
end
% recombination 2 mice
unique_seq = unique(comp_list);
recomb_cell = cell(size(unique_seq,1),4);
for k = 1:size(unique_seq,1)
    sel_pos = comp_list==unique_seq(k,1);
    recomb_cell(k,1) = {newcomb(sel_pos,:)};
    recomb_cell(k,2) = {rec3d_cell(sel_pos,1)};
    recomb_cell{k,3} = mean(mean_err(sel_pos));
end
sort_recomb_cell = sortrows(recomb_cell,3,'descend');
% fit ground
foot_idx = [9,10,11,12];
for k = 1:size(sort_recomb_cell,1)
    %
    skl = sort_recomb_cell{k,2};
    planeData = [];
    for m = 1:size(skl,1)
        planeData = [planeData,;skl{m,1}(:,foot_idx)'];
    end
    %
    xyz0=mean(planeData,1);
    centeredPlane=bsxfun(@minus,planeData,xyz0);
    [U,S,V]=svd(centeredPlane);
    % norm vec [a,b,c]
    a=V(1,3);
    b=V(2,3);
    c=V(3,3);
    d=-dot([a b c],xyz0);
    % rot angle
    raw_z_vec = [0,0,1];
    A = raw_z_vec';
    B = [a,b,c]';
    C = cross(B, A);
    theta = acos((A'*B) / ( norm(A)*norm(B) ));
    Rv = C / norm(C) * theta;
    rot_mat = rodrigues(Rv);
    % calculate rotskl
    rotskl = skl;
    for m = 1:size(skl,1)
        tempskl = skl{m,1};
        for n = 1:size(tempskl,2)
            rotskl{m,1}(:,n) = rot_mat*tempskl(:,n);
        end
    end
    sort_recomb_cell{k,4} = rotskl;
%     %% temp show
%     %%
%     skl = rotskl;
%     planeData = [];
%     for m = 1:size(skl,1)
%         planeData = [planeData,;skl{m,1}(:,foot_idx)'];
%     end
%     %
%     xyz0=mean(planeData,1);
%     centeredPlane=bsxfun(@minus,planeData,xyz0);
%     [U,S,V]=svd(centeredPlane);
%     % norm vec [a,b,c]
%     a=V(1,3);
%     b=V(2,3);
%     c=V(3,3);
%     d=-dot([a b c],xyz0);
%     figure
%     scatter3(planeData(:,1),planeData(:,2),planeData(:,3),'filled')
%     hold on
%     xfit = min(planeData(:,1)):0.1:max(planeData(:,1));
%     yfit = min(planeData(:,2)):0.1:max(planeData(:,2));
%     [XFIT,YFIT]= meshgrid (xfit,yfit);
%     ZFIT = -(d + a * XFIT + b * YFIT)/c;
%     
%     mesh(XFIT,YFIT,ZFIT);
end
% %% temp show
% for k = 1:size(sort_recomb_cell,1)
%     figure(k+10)
%     plotstr = 'r';
%     linestr = 'k';
%     skl1 = sort_recomb_cell{k,4}{1,1};
%     skl1_x = skl1(1,:)';
%     skl1_y = skl1(2,:)';
%     skl1_z = skl1(3,:)';
%     plot_skl(skl1_x,skl1_y,skl1_z,plotstr,linestr)
%     hold on
%     plotstr = 'b';
%     linestr = 'k';
%     skl2 = sort_recomb_cell{k,4}{2,1};
%     skl2_x = skl2(1,:)';
%     skl2_y = skl2(2,:)';
%     skl2_z = skl2(3,:)';
%     plot_skl(skl2_x,skl2_y,skl2_z,plotstr,linestr)
%     hold off
%     title(sort_recomb_cell{k,3})
% end