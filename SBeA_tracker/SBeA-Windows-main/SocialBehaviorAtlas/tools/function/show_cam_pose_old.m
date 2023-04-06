function show_cam_pose_old(caliParams,cam_size)
% cam_size = 50;
cam_frame = [0,0;-1,-1;-1,1;1,-1;1,1]*cam_size;
XYZ_cell = cell(size(caliParams.cam_mat_all,1),1);
norm_cell = cell(size(XYZ_cell));
for k = 1:size(XYZ_cell,1)
    if isempty(caliParams.rotation{k,1}) ~= 1
        R = caliParams.rotation{k,1};
        T = caliParams.translation{k,1};
        campos = [cam_frame,zeros(size(cam_frame,1),1)]';
        XYZ_cell{k,1} = cam2world(R,T,campos);
        line1 = XYZ_cell{k,1}(:,2)-XYZ_cell{k,1}(:,1);
        line2 = XYZ_cell{k,1}(:,4)-XYZ_cell{k,1}(:,3);
        line1 = line1/norm(line1);
        line2 = line2/norm(line2);
        norm_cell{k,1} = cross(line1,line2);
    end
end
colorlist = jet(size(XYZ_cell,1));
for k = 1:size(XYZ_cell,1)
    if isempty(XYZ_cell{k,1}) ~= 1
        plot3(XYZ_cell{k,1}(1,:),XYZ_cell{k,1}(2,:),XYZ_cell{k,1}(3,:),'LineWidth',2,'color',colorlist(k,:))
        hold on
        norm_vec = [XYZ_cell{k,1}(:,1),norm_cell{k,1}*cam_size];
        plot3(norm_vec(1,:),norm_vec(2,:),norm_vec(3,:),'LineWidth',2,'color',colorlist(k,:))
        hold on
        text(norm_vec(1,1),norm_vec(2,1),norm_vec(3,1),num2str(k),'FontSize',cam_size)
        hold on
    end
end
hold off
grid on