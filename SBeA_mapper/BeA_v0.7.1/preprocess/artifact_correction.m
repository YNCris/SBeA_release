function artifact_correction(method, WinWD)
% data artifact correction
%
% Input
%   method    -  string varible, decide which method to use
%   WinWD     -  1 x 1 double, time window width of filtering
%
% Output
%   global BeA.PreproData
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-02-2020
%   modify  -  Yaning Han  (yn.han@siat.ac.cn), 07-16-2020

global BeA
fs = BeA.DataInfo.VideoInfo.FrameRate;

switch method
    case 'median filtering'
        AC = ac_method1_mf(WinWD);% median filtering
    case 'adaptive median filtering'
        AC = ac_method2_amf(WinWD);% adaptive median filtering
end

ac_lh_flag = AC.LH.Flag;
ac_lh_seq = AC.LH.Seq;
ac_lh_thres = AC.LH.Param.Thres;
ac_mp_flag = AC.MP.Flag;
ac_mp_seq = AC.MP.Seq;
ac_mp_mint = AC.MP.Param.MinThres;
ac_mp_maxt = AC.MP.Param.MaxThres;
ac_mf_flag = AC.MF.Flag;
ac_mf_seq = AC.MF.Seq;
ac_mf_winw = round(AC.MF.Param.WinWD/fs/2);
ac_nmf_flag = AC.NMF.Flag;
ac_nmf_seq = AC.NMF.Seq;
ac_nmf_winw = round(AC.NMF.Param.WinWD/fs);
ac_amf_flag = AC.AMF.Flag;
ac_amf_seq = AC.AMF.Seq;
ac_amf_winw = round(AC.AMF.Param.WinWD/fs);

ac_X = BeA.RawData.X;
ac_Y = BeA.RawData.Y;
ac_Z = BeA.RawData.Z;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% data crop
%     X_thres = 400;
%     ac_X(ac_X<X_thres) = 0;
%     ac_Y(ac_X<X_thres) = 0;
%     ac_Z(ac_Y<X_thres) = 0;
%% save ac
raw_ac_X = ac_X;
raw_ac_Y = ac_Y;
raw_ac_Z = ac_Z;

%%find nd
nd_x = zeros(size(ac_X));
nd_y = zeros(size(ac_Y));
nd_z = zeros(size(ac_Z));
nd = zeros(size(ac_X));
[nd_x_x,nd_x_y] = find(isnan(BeA.RawData.X));
[nd_y_x,nd_y_y] = find(isnan(BeA.RawData.Y));
[nd_z_x,nd_z_y] = find(isnan(BeA.RawData.Z));
for m = 1:size(ac_X,1)
    for n = 1:size(ac_X,2)
        for i = 1:size(nd_x_x,1)
            if nd_x_x(i,1) == m &&  nd_x_y(i,1) == n
                nd_x(m,n) = 1;
            end
        end
    end
end
for m = 1:size(ac_Y,1)
    for n = 1:size(ac_Y,2)
        for i = 1:size(nd_y_x,1)
            if nd_y_x(i,1) == m &&  nd_y_y(i,1) == n
                nd_y(m,n) = 1;
            end
        end
    end
end
for m = 1:size(ac_Z,1)
    for n = 1:size(ac_Z,2)
        for i = 1:size(nd_z_x,1)
            if nd_z_x(i,1) == m &&  nd_z_y(i,1) == n
                nd_z(m,n) = 1;
            end
        end
    end
end

winw = ac_nmf_winw ;
out_X = BeA.RawData.X;
out_Y = BeA.RawData.Y;
out_Z = BeA.RawData.Z;

% noise median filtering
nd = nd_x;
for m = round((winw-1)/2+1):round(size(nd,1)-(winw-1)/2-1)
    for n = 1:size(nd,2)
        if nd(m,n) == 1
            startwin = m-round((winw-1)/2);
            endwin = m+round((winw-1)/2);
            out_X(m,n) = median(ac_X(startwin:endwin,n),'omitnan');
        end
    end
end
nd = nd_y;
for m = round((winw-1)/2+1):round(size(nd,1)-(winw-1)/2-1)
    for n = 1:size(nd,2)
        if nd(m,n) == 1
            startwin = m-round((winw-1)/2);
            endwin = m+round((winw-1)/2);
            out_Y(m,n) = median(ac_Y(startwin:endwin,n),'omitnan');
        end
    end
end
nd = nd_z;
for m = round((winw-1)/2+1):round(size(nd,1)-(winw-1)/2-1)
    for n = 1:size(nd,2)
        if nd(m,n) == 1
            startwin = m-round((winw-1)/2);
            endwin = m+round((winw-1)/2);
            out_Z(m,n) = median(ac_Z(startwin:endwin,n),'omitnan');
        end
    end
end


%global medfilt filter
finall_out_X = out_X;
finall_out_Y = out_Y;
finall_out_Z = out_Z;
for k = 1:size(out_X,2)
    finall_out_X(:,k) = medfilt1(out_X(:,k),ac_mf_winw);
    finall_out_Y(:,k) = medfilt1(out_Y(:,k),ac_mf_winw);
    finall_out_Z(:,k) = medfilt1(out_Z(:,k),ac_mf_winw);
end

%% quality controlling
ac_X = finall_out_X; ac_Y = finall_out_Y; ac_Z = finall_out_Z;

Eng_noise = (sum(sum((raw_ac_X-ac_X).^2))+sum(sum((raw_ac_Y-ac_Y).^2))+sum(sum((raw_ac_Z-ac_Z).^2)))/...
    (length(raw_ac_X(:))+length(raw_ac_Y(:))++length(raw_ac_Z(:)));
Eng_all = (sum(sum(raw_ac_X.^2))+sum(sum(raw_ac_Y.^2))+sum(sum(raw_ac_Z.^2)))/...
    (length(raw_ac_X(:))+length(raw_ac_Y(:))+length(raw_ac_Z(:)));
Eng_effect = (sum(sum(ac_X.^2))+sum(sum(ac_Y.^2))+sum(sum(ac_Z.^2)))/(length(raw_ac_X(:))+length(raw_ac_Y(:))+length(raw_ac_Z(:)));

%% varible - store
BeA.PreproInfo.QC = Eng_effect/Eng_all;
BeA.PreproData.X = finall_out_X;
BeA.PreproData.Y = finall_out_Y;
BeA.PreproData.Z = finall_out_Z;
BeA.PreproInfo.AC = AC;
BeA.PreproInfo.Eng.Noise = Eng_noise;
BeA.PreproInfo.Eng.All = Eng_all;
BeA.PreproInfo.Eng.Effect = Eng_effect;












