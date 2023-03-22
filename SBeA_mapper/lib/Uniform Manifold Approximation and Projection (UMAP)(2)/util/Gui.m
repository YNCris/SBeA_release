%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%

classdef Gui
    properties(Constant)
        ERROR_COLOR=java.awt.Color(1, 0,0);
        WARNING_COLOR=java.awt.Color(1, 1, .5);
        LIGHT_YELLOW_COLOR=java.awt.Color(.97, .97, .90);
        LIGHT_GREEN_COLOR=java.awt.Color(.94, .99, .96);
        
        BLACK_COLOR=java.awt.Color(0,0,0);
        LIGHT_GRAY_COLOR=java.awt.Color(.8820, .8820, .87920);
        BLUE_COLOR=java.awt.Color(0,0,1);
        CYAN_COLOR=java.awt.Color(0,1,1);
        BROWN_COLOR=java.awt.Color(.21, .31, 0);
        GREEN_COLOR=java.awt.Color(0,0,1);
        RED_COLOR=Gui.ERROR_COLOR;
        WHITE_COLOR=java.awt.Color(1,1,1);
        YELLOW_COLOR=Gui.WARNING_COLOR;
            
        PROP_SAME_SCR1='OpenOnSameScreen';
        PROP_SAME_SCR2='MainWindowFigure';
        PROP_FONT_NAME='FontNameC2';
        PROP_FONT_SIZE='fontSizeV2';
        DEBUG_POINT=false;
        DEBUGGING=false;
        UST_LEGEND1='UST clssified subsets (# found, f+/f-/fm)';
        UST_LEGEND2='UST classifed samples';
        MARKERS={'o', '+', '*', '.', 'x', 'square', 'diamond', 'd', '^',...
            'v', '>', '<', 'pentagram', 'p', 'hexagram', 'h', 'none'}
    end
    
    methods (Static)
        
        
        function [H,J]=JavaComponentAt(cmp, whereOrXy, fig)
            if nargin<3
                fig=figure;
            end
            if isnumeric(whereOrXy)
                pos=whereOrXy;
            else
                pos=[0 0 0 0];
            end
            d=cmp.getPreferredSize;
            pos(3)=d.width;
            pos(4)=d.height;
            [J, H]=javacomponent(cmp, pos, fig);
            if ischar(whereOrXy)
                Gui.LocateItem(H, fig,whereOrXy);
            end
        end
        
        function ok=HasMeehanMetaSpaceJars
            try
                com.MeehanMetaSpace.swing.PopupBasics.gui;
                ok=true;
            catch
                ok=false;
            end
        end
        
        function [J, H]=NewAutoCombo(strs, pos, fig)
            if nargin<1
                strs = {'This','is','test1','test2'};
            end
            strList = java.util.ArrayList;
            for idx = 1 : length(strs),  strList.add(strs{idx});  end
            J=com.mathworks.widgets.AutoCompletionList(strList,'');
            if nargout>1
                if nargin<3
                    fig=gcf;
                    if nargin<2
                        pos=[10,10,200,100];
                    end
                end
                H=javacomponent(J.getComponent, pos, fig);
            end
        end
        
        function SetDefaultButton(btn)
            try
                w=Gui.WindowAncestor(btn);
                w.getRootPane.setDefaultButton(btn);
            catch ex
                ex.getReport
            end
        end
        
        function SetSingleSelection(cmp)
            try
                cmp.setSelectionMode(...
                    javax.swing.DefaultListSelectionModel.SINGLE_SELECTION);
            catch
            end
        end
        
        function [pnl, jList, jtf, H]...
                =NewListSearch(items, hint, dflts, tip, callback,  pos, fig)
            if nargin<7
                fig=get(0, 'CurrentFigure');
                if nargin<6
                    pos=[];
                    if nargin<5
                        callback=[];
                        if nargin<4
                            tip='Search/select items in list';
                            if nargin<3
                                hint='Enter list search value...';
                                if nargin<2
                                    dflts=[];
                                end
                            end
                        end
                    end
                end
            end
            nItems=length(items);
            [jtf, normalFont, app]=Gui.NewTextField('', 15, tip, ...
                [],[], @(txt,jtf,event)search(txt, event), hint);
            jj=handle(jtf, 'CallbackProperties');
            set(jj, 'ActionPerformedCallback', @(h,e)actionPerformed());
            [jList, scroll]=Gui.NewList(items,dflts, @select);
            jList.setToolTipText(tip);
            pnl=Gui.BorderPanel([],2,5, 'North', jtf, 'South', scroll);
            if ~isempty(pos)
                if length(pos)==2
                    d=pnl.getPreferredSize;
                    pos(3)=d.width;
                    pos(4)=d.height;
                end
                H=javacomponent(pnl, pos, fig);
            end
            
            function select(h,e)
                jtf.setText('');
                Gui.SetHint(jtf, hint, '', false, normalFont, app, false);
                if ~isempty(callback)
                    feval(callback, h, e);
                end
            end

            function actionPerformed
                search(char(jtf.getText));
            end
            function complaint=search(txt,event)
                complaint='';
                found=0;
                almost=0;
                almostCnt=0;
                for i=1:nItems
                    item=items{i};
                    if isnumeric(item)
                        if isequal(str2double(txt), item)
                            found=i;
                            break;
                        end
                    else
                        if strcmpi(txt, item)
                            found=i;
                            break;
                        elseif startsWith(lower(item), lower(txt))
                            almostCnt=almostCnt+1;
                            if almost==0 
                                almost=i;
                                almostItem=item;
                            end
                        end
                    end
                end
                if found>0
                    idx=found-1;
                    jList.ensureIndexIsVisible(idx);
                    jList.addSelectionInterval(idx, idx);
                    if ~isempty(callback)
                        feval(callback, jList, []);
                    end
                else
                    if almost>0
                        if nargin==1 || event.getExtendedKeyCode ~= java.awt.event.KeyEvent.VK_BACK_SPACE
                            jtf.setText(almostItem);
                            jtf.select(length(txt), length(almostItem));
                        end
                        jList.ensureIndexIsVisible(almost-1);
                        complaint={[num2str(almostCnt) ' match(s)'], ...
                            Gui.BROWN_COLOR, ...
                            Gui.LIGHT_GREEN_COLOR};
                    else
                        complaint='No possible match!';
                    end
                end
            end
        end
        
        function MsgException(ex, ttl, secs, app)
            if nargin<3
                secs=8;
                if nargin<2
                    ttl='Argument error...';
                end
            end
            ex.getReport
            if nargin<4
                app=BasicMap.Global;
            end            
            htmlEx=Html.Exception(ex, app);
            msgError([ Html.WrapTable(Html.WrapBoldSmall(...
                String.ToHtml( ex.message) ),4, 4.5, '0', 'center', 'in', app)...
                '<hr>' htmlEx ], secs, 'center', ttl);
        end
        
        function [xy, xRange_, yRange_]=Normalize(ax_, xyIn)
            xl_=xlim(ax_);
            yl_=ylim(ax_);
            yRange_=yl_(2)-yl_(1);
            xRange_=xl_(2)-xl_(1);
            xy=(xyIn-[xl_(1) yl_(1)])./[xRange_ yRange_];
        end

        function SetFigButtons(fig, btnDone, btnCancel)
            wnd=Gui.JWindow(fig);
            if ~isempty(wnd)
                root=wnd.getRootPane;
                root.setDefaultButton(btnDone);
                if nargin>2
                    Gui.RegisterEscape(root, btnCancel);
                end
            end
        end
        function StretchUpper(ax, limFnc, nudge)
            l=feval(limFnc, ax);
            r=l(2)-l(1);
            p=r*nudge;
            feval(limFnc, ax, [l(1) l(2)+ceil(p)]);
        end
        function wasStretched=StretchLims(ax_, HsOrData, nudge)
            if nargin<3
                nudge=.015;
            end
            if size(HsOrData, 1)==1 || size(HsOrData,2)==1% handles
                if ~ishandle(HsOrData(1))
                    wasStretched=false;
                    return
                end
                if HsOrData(1)==0
                    wasStretched=false;
                    return;
                end
                [xl, yl]=Gui.GetXyLim(HsOrData);
            else %actual X/Y data;
                mn=min(HsOrData);
                mx=max(HsOrData);
                xl=[mn(1) mx(1)];
                yl=[mn(2) mx(2)];
                if length(mx)>2
                    zl=[mn(3) mx(3)];
                end
            end
            if ~isempty(xl)
                stretchX=tryAx(1, xl);
                stretchY=tryAx(2, yl);
                if exist('zl', 'var')
                    stretchZ=tryAx(3, zl);
                    wasStretched=stretchX || stretchY || stretchZ;
                else
                    wasStretched=stretchX || stretchY;
                end
            else
                wasStretched=false;
            end
            function yes=tryAx(axis_, l)
                if axis_==1
                    f=@xlim;
                elseif axis_==3
                    f=@zlim;
                else
                    f=@ylim;
                end
                l_=feval(f, ax_);
                r=l_(2)-l_(1);
                n=nudge*r;
                yes=false;
                if l_(1)>l(1) || abs(l_(1)-l(1))<n 
                    yes=true;
                    l_(1)=min([l_(1) l(1)]);
                end
                if l_(2)<l(2) || abs(l_(2)-l(2))<n
                    yes=true;
                    l_(2)=max([l_(2) l(2)]);
                end
                if yes
                    if axis_==1
                        Gui.Lim(ax_, l_, true, nudge);
                    elseif axis_==3
                        Gui.LimZ(ax_, l_, nudge);
                    else
                        Gui.Lim(ax_, l_, false, nudge);
                    end
                end
            end
        end
        
        function [xLim, yLim]=GetXyLim(Hs)
            N=length(Hs);
            xd=[];
            yd=[];
            for i=1:N
                xd=[xd get(Hs(i), 'XData')];
                yd=[yd get(Hs(i), 'YData')];
            end
            if isempty(xd)
                xLim=[];
                yLim=[];
            else
                xLim=[min(xd) max(xd)];
                yLim=[min(yd) max(yd)];
            end
        end
        
        function Lim(ax, minMax, xAxis, nudge)
            r=abs(minMax(1)-minMax(2));
            p=nudge*r;
            minMax(1)=minMax(1)-p;
            minMax(2)=minMax(2)+p;
            if xAxis
                xlim(ax, minMax);
            else
                ylim(ax, minMax);
            end
        end
        
        function LimZ(ax, minMax, nudge)
            r=abs(minMax(1)-minMax(2));
            p=nudge*r;
            minMax(1)=minMax(1)-p;
            minMax(2)=minMax(2)+p;
            zlim(ax, minMax);
        end
        
        function yes=IsVisible(H)
            yes=~isempty(H) && ishandle(H) && isequal('on', get(H, 'visible'));
        end
        
        function PlotNeighDist3D(ax, data, n_neighbors)
            [~, dists]=knnsearch(data, data, 'k', n_neighbors);
            avgDists=mean(dists, 2);
            nRanks=32;
            clrs=flip(jet(nRanks));
            ranks=MatBasics.RankForStdDev(avgDists, nRanks);
            cla(ax, 'reset');
            hold(ax, 'on');
            mns=min(data);
            mxs=max(data);
            xlim(ax, [mns(1) mxs(1)]);
            ylim(ax, [mns(2) mxs(2)])
            zlim(ax, [mns(3) mxs(3)])
            view(ax, 3);
            for i=1:nRanks
                l=ranks==i;
                plot3(ax, data(l,1), data(l,2), data(l,3), '.', ...
                    'markerSize', 3, 'lineStyle', 'none', ...
                    'markerEdgeColor', clrs(i,:), ...
                    'markerFaceColor', clrs(i,:));
            end
        end
      
        function PlotDensity3D(ax, data, nBins, display, ...
            xLabel, yLabel, zLabel, args)
            if nargin<4
                display='plot';
                if nargin<3
                    nBins=64;
                end
            end
            marker='.';
            marker_size=1;
            if nargin > 7 && ~isempty(args)
                if isfield(args, 'marker_size')
                    marker_size=args.marker_size;
                end
                if isfield(args, 'marker')
                    marker=args.marker;
                end
            end

            if isempty(nBins)
                nBins=64;
            end
            if isempty(display)
                display='plot';
            end
            [R,C]=size(data);
            [D, weight, I, bCoords]=Density.Get3D(data,nBins);
            if isequal(display, 'plot')
                jets=jet;
                cla(ax, 'reset');
                hold(ax, 'on');
                
                nClrs=size(jets,1);
                maxD=max(D(D(:)>0));
                minD=min(D(D(:)>0));
                rangeD=maxD-minD;
                d=zeros(1, R);
                for j=1:R
                    d(j)=D(I(j,1), I(j,2), I(j,3));
                end
                ratios=(d-minD)./rangeD;
                denominator=25;
                for j=1:denominator
                    ratio=j/denominator;
                    l=ratios<ratio & ratios>=(j-1)/denominator;
                    clrIdx=floor(ratio*nClrs);
                    clr2=jets(clrIdx,:);
                    plot3(ax, data(l,1), data(l,2), data(l,3), marker, ...
                        'markerSize', marker_size, 'lineStyle', 'none', ...
                        'markerEdgeColor', clr2, ...
                        'markerFaceColor', clr2);
                end
                view(ax, 3);
                grid(ax, 'on');
                set(ax, 'plotboxaspectratio', [1 1 1])        
            elseif isequal(display, 'iso')
                cla(ax, 'reset');
                hold(ax, 'on');
                colormap(ax, jet);
                patch(ax, isocaps(bCoords(:,1), bCoords(:,2), bCoords(:,3), D,.5),...
                    'FaceColor','interp','EdgeColor','none');
                p1 = patch(ax, isosurface(bCoords(:,1), bCoords(:,2), bCoords(:,3), D,.5),...
                    'FaceColor',[0 .20 1],'EdgeColor','none');
                isonormals(bCoords(:,1), bCoords(:,2), bCoords(:,3), D,p1);
                view(ax, 3);
                axis(ax, 'vis3d');
                axis(ax, 'tight')
                camlight headlight;
                lighting(ax, 'gouraud');
                grid(ax, 'on');
                %MatBasics.ScaleBins(ax, nBins, data)
                set(ax, 'plotboxaspectratio', [1 1 1])
            else
                sliceomatic(weight);
            end
            if nargin>4
                if ~isempty(xLabel)
                    xlabel(ax, xLabel);
                end
                if nargin>5
                    if ~isempty(xLabel)
                        ylabel(ax, yLabel)
                    end
                    if nargin>6
                        if ~isempty(zLabel)
                            if C>2
                                zlabel(ax, zLabel);
                            end
                        end
                    end
                end
            end

        end
        
        function [fig,tb,javaWindow]=NewFigure(basic, visible, removeZoomPan)
            if nargin<2
                visible='on';
            end
            if nargin<1 || basic
                fig=figure('toolbar', 'none', 'NumberTitle', 'off', ...
                    'Menubar', 'none', 'DockControls', 'off', ...
                    'Visible', visible);
            else
                fig=figure('Visible', visible);
            end
            if nargout>1
                if nargin<3
                    removeZoomPan=true;
                end
                tb=ToolBar.New(fig, true, removeZoomPan, ...
                    removeZoomPan, removeZoomPan);
                if nargout>2
                    javaWindow=Gui.JWindow(fig);
                end
            end
        end
        
        function [idxs_, N]=SetAllChb(allChb, allMsg, checkBoxes)
            [idxs_, N]=Gui.GetSelectedChbIdxs(checkBoxes);
            if String.StartsWith(allMsg, '<html><b>All</b>')
                strCnt=[ ' (<b>' num2str(length(idxs_)) '</b>/' ...
                    num2str(N) ')'];
                % case like heat map
                allChb.setText([allMsg(1:16) strCnt allMsg(17:end)]);
            elseif ~isempty(allChb)
                if strcmpi(allMsg, 'all')
                    allChb.setText([ '<html>All (<b>' num2str(length(idxs_)) ...
                        '</b>/' num2str(N) ')</html>']);
                else
                    strCnt=[ ' (' num2str(length(idxs_)) '/' ...
                        num2str(N) ')'];
                    allChb.setText(String.AddSuffix(allMsg, strCnt));
                end
            end
        end
        
        function [idxs_, N]=GetSelectedChbIdxs(checkBoxes)
            idxs_=[];
            N=checkBoxes.size;
            for ii=1:N
                cb_=checkBoxes.get(ii-1);
                if cb_.isSelected
                    idxs_(end+1)=ii;
                end
            end
            if Gui.DEBUGGING
                idxs_
            end
        end

        function cmps=GetJavaComponents(cmp)
            priorCnt=cmp.getComponentCount;
            cmps=cell(1,priorCnt);
            for i=1:priorCnt
                cmps{i}=cmp.getComponent(i-1);
            end
        end
        
        function [J, H]=NewLabelCentered(yNormalized, str, fig, bgColor)
            if nargin<4
                bgColor=[1 1 .93];
                if nargin<3
                    fig=figure;%gcf;
                    if nargin<2
                        str='';
                        if nargin<1
                            yNormalized=.8;% assume title
                        end
                    end
                end
            end
            str=['<html><table cellspacing="6"><tr><td><center>' ...
                Html.remove(str) '</center></td></tr></table></html>'];
            [J, H]=javacomponent('javax.swing.JLabel',...
                [1, 1, 15, 11], fig);
            J.setBackground(java.awt.Color(bgColor(1), bgColor(2), bgColor(3)));
            J.setOpaque(false);
            
            J.setText(str);
            set(H, 'BackgroundColor', bgColor);
            
            try
                J.getParent.setOpaque(true);
                J.getParent.getParent.setOpaque(true);
            catch
            end
            app=BasicMap.Global;
            resize;
            set(fig, 'resizeFcn', @(h,e)resize);
            function resize
                
                sz=J.getPreferredSize;
                if app.toolBarFactor>1
                    %fprintf('before %d after %d\n', sz.width, floor(sz.width/app.toolBarFactor*1.4));
                    sz.width=sz.width/app.toolBarFactor*1.4;
                    sz.height=sz.height/app.toolBarFactor*1.4;
                end
                fpp=Gui.GetPixels(fig);
                xNormalized=(fpp(3)-sz.width)/fpp(3)*.5;
                w=sz.width/fpp(3);
                h=sz.height/fpp(4);
                if yNormalized>=1
                    yNormalized=1-h;
                end
                if  xNormalized>0 && h>0
                    u=get(H, 'units');
                    set(H, 'units', 'normalized');
                    set(H,  'position', [xNormalized yNormalized w h]);
                    set(H, 'units', u);
                end
            end
        end
        
        
        function [J, H]=NewLbl(str, icon, bgColor, ...
                fig, xNormalized, yNormalized)
            if nargin<6
                yNormalized=0;
                if nargin<5
                    xNormalized=0;
                    if nargin<4
                        fig=[];
                        if nargin<3
                            bgColor=[];
                            if nargin<2
                                icon=[];
                            end
                        end
                    end
                end
            end
            if isempty(bgColor)
                bgColor=fig.Color;
            end
            J=javaObjectEDT('javax.swing.JLabel', str);
            J.setOpaque(false);
            J.setText(str);
            if ~isempty(icon)
                J.setIcon(Gui.Icon(icon));
            end
            try
                J.getParent.setOpaque(true);
                J.getParent.getParent.setOpaque(true);
            catch
            end
            if nargout>1
                H=Gui.SetJavaInFig(xNormalized, ...
                    yNormalized, J, bgColor, fig, BasicMap.Global, false);
            end
        end
        
        function [J, H]=NewLabel(xNormalized, ...
                yNormalized, str, fig, bgColor, icon)
            % older JLabel creator that ONLY thought about 
            % placement in figure
            if nargin<6
                icon=[];
                if nargin<5
                    bgColor=[];
                    if nargin<4
                        fig=[];
                    end
                end
            end
            [J, H]=Gui.NewLbl(str, icon, bgColor, fig, ...
                xNormalized, yNormalized);
        end

        function H=SetJavaInFig(xNormalized, yNormalized, ...
                J, bgColor, fig, app, adjustFig)
            if isa(bgColor, 'java.awt.Color')
                J.setBackground(bgColor);
                bgColor=[bgColor.getRed/256 ...
                    bgColor.getGreen/256 bgColor.getBlue/256];
            elseif ~isempty(bgColor)
                J.setBackground(java.awt.Color(...
                    bgColor(1), bgColor(2), bgColor(3)));
            end
            if nargin<6
                app=BasicMap.Global;
            end
            if nargin <5 || isempty(fig)
                H=[];
                return;
            end
            [J, H]=javacomponent(J,...
                [1, 1, 15, 11], fig);
            
            try
                resize;
            catch
            end
            
            if adjustFig
                pos=fig.Position;
                was=H.Units;
                H.Units='pixels';
                pos2=H.Position;
                nudge=floor((floor(xNormalized)*pos(3)));
                pos(3)=nudge+pos2(3)+nudge;
                nudge=floor(floor(yNormalized)*pos(4));
                pos(4)=nudge+pos2(4)+nudge;
                fig.Position=pos;
                H.Units=was;
                resize;
            end
            set(fig, 'resizeFcn', @(h,e)resize);
            
            function resize                
                sz=J.getPreferredSize;
                if app.toolBarFactor>1
                    %fprintf('before %d after %d\n', sz.width, floor(sz.width/app.toolBarFactor*1.4));
                    sz.width=sz.width*.5;
                    sz.height=sz.height*.5;
                end
                fpp=Gui.GetPixels(fig);
                if fpp(3)<1
                    fpp(3)=215;
                end
                w=sz.width/fpp(3);
                if fpp(4)<1
                    fpp(4)=45;
                    Gui.SetPixels(fig, fpp);
                end
                h=sz.height/fpp(4);
                if yNormalized>=1
                    yNormalized=1-h;
                end
                if  xNormalized>0 && h>0
                    u=get(H, 'units');
                    set(H, 'units', 'normalized');
                    set(H,  'position', [xNormalized yNormalized w h]);
                    set(H, 'units', u);
                end
            end
        end

                    
        function SavePng(fig, fp, sz)
            if nargin<3
                sz=300;
            end
            try
                F=getframe(fig);
                savepng(F.cdata, fp, 0, sz);
            catch
                saveas(fig, fp);
            end
        end
        
        function [topFig, I]=GetTopFig(figs)
            ff=get(0, 'children');
            N=length(figs);
            idxs=zeros(1,N);
            for i=1:N
                idxs(i)=find(ff==figs{i});
            end
            [~,I]=min(idxs);
            topFig=figs{I};
        end
        
        
        function fMnu=FontMenu(jMenu, fig, property, doSubMenu, props)
            if nargin<5
                props=BasicMap.Global;
                if nargin < 4
                    doSubMenu=true;
                end
            end
            if doSubMenu
                fMnu=Gui.NewMenu(jMenu, 'Font preferences');
                word=' ';
            else
                fMnu=jMenu;
                word=' font ';
            end
            Gui.NewMenuItem(fMnu, 'Alter font name', ...
                @(h,e)Gui.UpdateFontName(fig, property, props, true), ...
                'tool_data_cursor.gif');
            Gui.NewMenuItem(fMnu, ['Increase' word 'size'], ...
                @(h,e)Gui.UpdateFontSize(fig, property, props, 1), ...
                'upArrow.png');
            Gui.NewMenuItem(fMnu, ['Decrease' word 'size'], ...
                @(h,e)Gui.UpdateFontSize(fig, property, props, -1), ...
                'downArrow.png');

        end
        
        function UpdateFontName(fig,  property, props, ask)
            if nargin<4
                ask=false;
                if nargin<3
                    props=BasicMap.Global;
                end
            end
            txtObjs=findall(fig, 'type', 'text');
            nTxtObjs=length(txtObjs);
            if nTxtObjs==0
                return;
            end
            if ask
                fontName=get(txtObjs(1), 'FontName');
                fontName=autoCompleteDlg(listfonts, 'Enter a font name',...
                    'Confirm...', fontName, 'center', true);
                if isempty(fontName)
                    return;
                end
                prop=[property '.' Gui.PROP_FONT_NAME];
                props.set(prop, fontName);
            else
                prop=[property '.' Gui.PROP_FONT_NAME];
                fontName=props.get(prop, 'Arial');
                if isempty(fontName)
                    return;
                end
            end
            txtObjs=findall(fig, 'type', 'text');
            nTxtObjs=length(txtObjs);
            for i=1:nTxtObjs
                txtObj=txtObjs(i);
                set(txtObj, 'FontName', fontName);
            end
            lgObjs=findall(fig, 'type', 'legend');
            nLgObjs=length(lgObjs);
            for i=1:nLgObjs
                lgObj=lgObjs(i);
                set(lgObj, 'FontName', fontName);
            end
        end
        
        function UpdateFontSize(fig, property, props, num)
            if nargin<4
                ask=false;
                if nargin<3
                    props=BasicMap.Global;
                end
            end
            prop=[property '.' Gui.PROP_FONT_SIZE];
            priorNum=props.getNumeric(prop, 0);
            if nargin>=4
                props.set(prop, num2str(priorNum+num));
            else
                num=priorNum;
            end
            transformN(findall(fig, 'type', 'text'));
            transformN(findall(fig, 'type', 'legend'));

            function transformN(txtObjs)
                nTxtObjs=length(txtObjs);
                for i=1:nTxtObjs
                    txtObj=txtObjs(i);
                    fs=get(txtObj, 'FontSize');
                    set(txtObj, 'FontSize', fs+num);
                    txt=get(txtObj, 'String');
                    if iscell(txt)
                        nTxts=length(txt);
                        newTxt=cell(nTxts, 1);
                        for j=1:nTxts
                            newTxt{j}=transform(txt{j}, num);
                        end
                    else
                        newTxt=transform(txt, num);
                    end
                    if ~isequal(txt, newTxt)
                        set(txtObj, 'String', newTxt);
                    end
                end
            end
            function out=transform(in, num)
                expr='\\fontsize\{(?<fs>\d+)\}';
                [strus, idxs]=regexp(in,expr,'names');
                nIdxs=length(idxs);
                newFs=cell(1, nIdxs);
                for k=1:nIdxs
                    newFs{k}=num2str(str2double(strus(k).fs)+num);
                end
                try
                    out=String.SubField(in, strus, idxs, 9, 'fs', newFs);
                catch ex
                    ex.getReport
                end
            end
        end
        
        function UpdateAndAdjustFontSize(fig, property, props, num)
            if nargin<4
                ask=false;
                if nargin<3
                    props=BasicMap.Global;
                end
            end
            prop=[property '.' Gui.PROP_FONT_SIZE];
            priorNum=props.getNumeric(prop, 0);
            num=priorNum+num;
            transformN(findall(fig, 'type', 'text'));
            transformN(findall(fig, 'type', 'legend'));

            function transformN(txtObjs)
                nTxtObjs=length(txtObjs);
                for i=1:nTxtObjs
                    txtObj=txtObjs(i);
                    fs=get(txtObj, 'FontSize');
                    set(txtObj, 'FontSize', fs+num);
                    txt=get(txtObj, 'String');
                    if iscell(txt)
                        nTxts=length(txt);
                        newTxt=cell(nTxts, 1);
                        for j=1:nTxts
                            newTxt{j}=transform(txt{j}, num);
                        end
                    else
                        newTxt=transform(txt, num);
                    end
                    if ~isequal(txt, newTxt)
                        set(txtObj, 'String', newTxt);
                    end
                end
            end
            function out=transform(in, num)
                expr='\\fontsize\{(?<fs>\d+)\}';
                [strus, idxs]=regexp(in,expr,'names');
                nIdxs=length(idxs);
                newFs=cell(1, nIdxs);
                for k=1:nIdxs
                    newFs{k}=num2str(str2double(strus(k).fs)+num);
                end
                try
                    out=String.SubField(in, strus, idxs, 9, 'fs', newFs);
                catch ex
                    ex.getReport
                end
            end
        end
        
        function Cascade(jObj, idx, cnt)
            if cnt>0 && idx<cnt
                p=jObj.getLocationOnScreen;
                p2=java.awt.Point(p.x-((cnt-idx)*25), p.y-((cnt-idx)*40));
                jObj.setLocation(p2);
            end
        end
        
        function CascadeFromNorth(jObj, idx)
            p=jObj.getLocationOnScreen;
            p2=java.awt.Point(p.x+((idx-1)*25), p.y+((idx-1)*40));
            jObj.setLocation(p2);
        end
        
        function CascadeFigFromNorth(fig, idx, top)
            p=get(fig, 'OuterPosition');
            p(1)=p(1)+((idx-1)*25);
            drop=((idx-1)*33);
            if nargin<3
                %top=p(2)+p(4);
                p(2)=p(2)-drop;
            else
                p(2)=top-drop-p(4);
            end
            set(fig, 'OuterPosition', p);
        end
        

        function pnl=AddToPanel(pnl, varargin)
            if ~isempty(varargin)
                for i=1:length(varargin)
                    cmp=varargin{i};
                    if ischar(cmp)
                        cmp=javax.swing.JLabel(cmp);
                    end
                    pnl.add(cmp);
                end
            end
        end

        function pnl=Panel(varargin)
            pnl=javaObjectEDT('javax.swing.JPanel');
            pnl.setOpaque(false);
            Gui.AddToPanel(pnl, varargin{:});
        end
        
        function pnl=FlowPanelCenter(hGap, vGap, varargin)
            if nargin<2
                vGap=0;
                if nargin<1
                    hGap=0;
                end
            end
            if BasicMap.Global.highDef
                if hGap>0
                    hGap=hGap+4;
                end
                if vGap>0
                    vGap=vGap+4;
                end
            end
            fl=java.awt.FlowLayout(java.awt.FlowLayout.CENTER, hGap, vGap);
            pnl=javaObjectEDT('javax.swing.JPanel', fl);
            pnl.setOpaque(false);
            Gui.AddToPanel(pnl, varargin{:});
        end
        
        function pnl=FlowLeftPanel(hGap, vGap, varargin)
            if nargin<2
                vGap=0;
                if nargin<1
                    hGap=0;
                end
            end
            if BasicMap.Global.highDef
                if hGap>0
                    hGap=hGap+4;
                end
                if vGap>0
                    vGap=vGap+4;
                end
            end
            fl=java.awt.FlowLayout(java.awt.FlowLayout.LEFT, hGap, vGap);
            pnl=javaObjectEDT('javax.swing.JPanel', fl);
            pnl.setOpaque(false);
            Gui.AddToPanel(pnl, varargin{:});
        end

        function pnl=FlowRightPanel(hGap, vGap, varargin)
            if nargin<2
                vGap=0;
                if nargin<1
                    hGap=0;
                end
            end
            if BasicMap.Global.highDef
                if hGap>0
                    hGap=hGap+4;
                end
                if vGap>0
                    vGap=vGap+4;
                end
            end
            fl=java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, hGap, vGap);
            pnl=javaObjectEDT('javax.swing.JPanel', fl);
            pnl.setOpaque(false);
            Gui.AddToPanel(pnl, varargin{:});
        end
        function pnl=FlowPanel(flow, hGap, vGap, varargin)
            if nargin<3
                vGap=0;
                if nargin<2
                    hGap=0;
                    if nargin<1
                        flow=[];
                    end
                end
            end
            if BasicMap.Global.highDef
                if hGap>0
                    hGap=hGap+4;
                end
                if vGap>0
                    vGap=vGap+4;
                end
            end
            if isempty(flow)
                flow=java.awt.FlowLayout.LEFT;
            end
            fl=java.awt.FlowLayout(flow, hGap, vGap);
            pnl=javaObjectEDT('javax.swing.JPanel', fl);
            pnl.setOpaque(false);
            Gui.AddToPanel(pnl,varargin{:});
        end
        
        function pnl=GridPanel(pnl, rows, cols, varargin)
            if nargin==0
                pnl=javaObjectEDT('javax.swing.JPanel', ...
                    javaObjectEDT('java.awt.GridLayout', 1,1));
            elseif nargin==1
                pnl.setLayout(javaObjectEDT('java.awt.GridLayout'));
            else
                if isempty(pnl)
                    pnl=javaObjectEDT('javax.swing.JPanel');
                end
                if nargin>=3
                    pnl.setLayout(javaObjectEDT('java.awt.GridLayout',...
                        rows, cols));
                    Gui.AddToPanel(pnl, varargin{:});
                elseif nargin==2
                    pnl=javaObjectEDT('javax.swing.JPanel', ...
                        javaObjectEDT('java.awt.GridLayout', 1, rows));
                end
            end
            pnl.setOpaque(false);
        end
        
        function jp=BorderPanel(priorPnl, hGap, vGap, varargin)
            if nargin==0
                if BasicMap.Global.highDef
                    hGap=4;
                    vGap=4;
                else
                    hGap=1;
                    vGap=1;
                end
                jp=javaObjectEDT('javax.swing.JPanel', ...
                    javaObjectEDT('java.awt.BorderLayout', hGap, vGap));
            elseif nargin==1
                priorPnl.setLayout(javaObjectEDT('java.awt.BorderLayout'));
                jp=priorPnl;
            elseif nargin>=3
                if BasicMap.Global.highDef
                    if hGap>0
                        hGap=hGap+4;
                    end
                    if vGap>0
                        vGap=vGap+4;
                    end
                end
                if isempty(priorPnl)
                    jp=javaObjectEDT('javax.swing.JPanel', ...
                        javaObjectEDT('java.awt.BorderLayout', hGap, vGap));
                else
                    priorPnl.setLayout(javaObjectEDT('java.awt.BorderLayout',...
                        hGap, vGap));
                    jp=priorPnl;
                end
                if ~isempty(varargin)
                    N=length(varargin);
                    if N==1
                        cmp=varargin{1};
                        if ischar(cmp)
                            cmp=javax.swing.JLabel(cmp);
                        end
                        jp.add(cmp, 'Center');
                    else
                        for i=1:2:N
                            cmp=varargin{i+1};
                            if ischar(cmp)
                                cmp=javax.swing.JLabel(cmp);
                            end
                            jp.add(cmp, varargin{i});
                        end
                    end
                end
            elseif nargin==2
                if BasicMap.Global.highDef
                    if hGap>0
                        hGap=hGap+4;
                    end
                    if priorPnl>0
                        priorPnl=priorPnl+4;
                    end
                end
                jp=javaObjectEDT('javax.swing.JPanel', ...
                    javaObjectEDT('java.awt.BorderLayout', priorPnl, hGap));
            end
            jp.setOpaque(false);
        end
        
        function wnd=WindowAncestor(h)
            wnd=javaMethodEDT('getWindowAncestor', ...
                        'javax.swing.SwingUtilities', h);
        end
        
        function TipMenu2(app, jMenu, img2)
            if nargin<3
                img2=[];
            end
            dtl=Gui.TipDetail(app);
            tMenu=Gui.NewMenu(jMenu, 'Tool tip detail', [], img2);
            Gui.NewCheckBoxMenuItem(tMenu, 'No subset info', ...
                @(h,e)Gui.TipDetail(app, 1), [],'', dtl==1);
            Gui.NewCheckBoxMenuItem(tMenu, 'Subset info', ...
                @(h,e)Gui.TipDetail(app, 2), [],'', dtl==2);
            Gui.NewCheckBoxMenuItem(tMenu, 'Subset info & options', ...
                @(h,e)Gui.TipDetail(app, 3), [],'', dtl==3);
            Gui.NewCheckBoxMenuItem(tMenu, ...
                'Subset info, options & 1D PathFinder', ...
                @(h,e)Gui.TipDetail(app, 4), [],'', dtl==4);
            jMenu.addSeparator;
        end
        
        function dtl=TipDetail(props, op)
            prop='tipDetails';
            dtl=props.getNumeric(prop, 2);
            if nargin>1
                if op==0
                    if dtl<4
                        props.set(prop, num2str(dtl+1));
                    else
                        props.set(prop, '1');
                    end
                elseif op<0
                    if dtl==1
                        props.set(prop, '4');
                    else
                        props.set(prop, num2str(dtl-1));
                    end
                elseif op<5
                    props.set(prop, num2str(op));
                end
            end
        end

        function bp=AddTipImgCheckBox(props, btnPnl, refresh, ...
                btnWhere, tipWhere, westCmp)
            if nargin<6
                westCmp=[];
                if nargin<5
                    tipWhere='South';
                    if nargin<4
                        btnWhere='North';
                        if nargin<3
                            refresh=[];
                            if nargin<2
                                btnPnl=[];
                            end
                        end
                    end
                end
            end
            dtl=Gui.TipDetail(props);
            if ~isempty(btnPnl)
                bp=Gui.BorderPanel(2,9);
                bp.add(btnPnl, btnWhere);
                btnPnl.setOpaque(false);
            else
                bp=Gui.BorderPanel(0,0);
            end
            if ispc
                prfx='';
                sfx='';
            else
                prfx='';
                sfx='';
            end
            [~, btnLess]=Gui.ImageLabel(Html.WrapSmall([prfx ...
                '&lt;&lt;Less' sfx]), [],'', @(h,e)tipFlip(h, -1));
            btnLess.setOpaque(false);
            jp=Gui.Panel;
            if ~isempty(westCmp)
                if ischar(westCmp)
                    lbl=Gui.Label(Html.WrapSmall(westCmp));
                else
                    lbl=Gui.Label(Html.WrapSmall('Subset info: '));
                    jp.add(westCmp);
                end
            else
                if dtl==2
                    lbl=[];
                else
                    lbl=Gui.Label(Html.WrapSmall('Subset info: '));
                end
            end
            if dtl>1
                if ~isempty(lbl)
                    jp.add(lbl);
                end
                jp.add(btnLess);
                moreTxt=[prfx '&nbsp;&nbsp; More &gt;&gt;' sfx];
            else
                moreTxt='&nbsp;&nbsp; More &gt;&gt;';
            end
            [~, btnMore]=Gui.ImageLabel(Html.WrapSmall(moreTxt), ...
                [],'', @(h,e)tipFlip(h, 0));
            btnMore.setOpaque(false);
            if dtl<4
                jp.add(btnMore);
            end
            jp.setOpaque(false);
            btns=Gui.BorderPanel(0,0);
            btns.add(jp, 'East');
            btns.setOpaque(false);
            bp.add(btns, tipWhere);
            
            function tipFlip(h, op)
                Gui.TipDetail(BasicMap.Global, op)
                if ~isempty(refresh)
                    feval(refresh);
                else
                    BasicMap.Global.closeToolTip;
                end
            end
        end
        
        function [lst, scroll]=NewList(items, dflts, callback)
            lst=javaObjectEDT('javax.swing.JList', items);
            lst.setBorder(javax.swing.BorderFactory.createEmptyBorder(4, 10, 4, 8));
            % Define the mouse-click callback function
            scroll=javaObjectEDT('javax.swing.JScrollPane', lst);
            d=lst.getPreferredSize;
            
            if d.width>650
                d.width=650;
                lst.setPreferredSize(d);
            end
            if nargin>1
                if ~isempty(dflts)
                    lst.setSelectedIndices(dflts);
                end
                if nargin>2 && ~isempty(callback)
                    set(handle(lst, 'CallbackProperties'), ...
                        'MousePressedCallback', callback);
                end
            end
        end
        
        function pnl=GridBagPanel(rows, cols, anchors, varargin)
            pnl=javaObjectEDT('javax.swing.JPanel', java.awt.GridBagLayout);
            if nargin==0
                return;
            end
            gbc=javaObjectEDT('java.awt.GridBagConstraints');
            if ~(nargin>3)
                warning('function needs components!');
            end
            if isempty(anchors)
                anchors=zeros(1,cols);
                for i=1:cols
                    anchors(i)=gbc.WEST;
                end
            end
            nAnchors=length(anchors);
            gbc.fill=0;
            gbc.ipadx=10;
            nCmps=length(varargin);
            row=1;
            col=1;
            for i=1:nCmps
                gbc.gridy=row-1;
                gbc.gridx=col-1;
                if col<=nAnchors
                    gbc.anchor=anchors(col);
                end
                cmp=varargin{i};
                if ischar(cmp)
                    cmp=javax.swing.JLabel(cmp);
                end
                pnl.add(cmp, gbc);
                col=col+1;
                if col>cols
                    col=1;
                    row=row+1;
                    if rows>0 && row>rows
                        break;
                    end
                end
            end
        end
        
        function jcb=Combo(items, dflt, property, props, ...
                fnc, tip, prototypeDisplayValue)
            if nargin<6
                tip=[];
                if nargin<5
                    fnc=[];
                    if nargin<4
                        props=BasicMap.Global;
                        if nargin<3
                            property=[];
                            if nargin<2
                                dflt=1;
                            end
                        end
                    end
                end
            end
            rememberIndex=isnumeric(dflt);
            jcb=javaObjectEDT('javax.swing.JComboBox', items);
            if nargin>1
                if ~isempty(property)
                    if nargin<4 || isempty(props)
                        props=BasicMap.Global;
                    end
                    if rememberIndex
                        selIdx=props.getNumeric(property, dflt)-1;
                    else
                        item=props.get(property, dflt);
                        selIdx=StringArray.IndexOf(items, item)-1;
                        if selIdx<0
                            % give this a try
                            try
                                selIdx=CellBasics.IndexOf(items, ...
                                    str2double(item))-1;
                            catch
                            end
                        end
                    end
                    if selIdx>=0
                        jcb.setSelectedIndex(selIdx);
                    end
                else
                    jcb.setSelectedIndex(dflt-1);
                end
                if nargin>4 && ~isempty(fnc) && isempty(property)
                    set(handle(jcb, 'CallbackProperties'), ...
                        'ActionPerformedCallback', fnc);
                elseif ~isempty(property)
                    set(handle(jcb, 'CallbackProperties'), ...
                        'ActionPerformedCallback', @store);
                end
                if nargin>5
                    jcb.setToolTipText(tip);
                    if nargin>6
                        len=length(prototypeDisplayValue);
                        mx=0;
                        N=length(items);
                        for i=1:N
                            it=items{i};
                            if ischar(it)
                                len2=length(it);
                                if len2>mx && len2<len
                                    mx=len2;
                                    prototypeDisplayValue=it;
                                end
                            end  
                        end
                        jcb.setPrototypeDisplayValue(prototypeDisplayValue);
                    end
                end
            end
            
            
            function store(h,e)
                if rememberIndex
                    props.set(property, num2str(jcb.getSelectedIndex+1));
                else
                    item=jcb.getSelectedItem;
                    if isnumeric(item)
                        props.set(property, num2str(item));
                    else
                        props.set(property, char(item));
                    end
                end
                if ~isempty(fnc) 
                    feval(fnc, h, e);
                end
            end
        end
        
        
        function jcb=CheckBox(label, dflt, props, prop, ...
                fnc, tip, storeAndCall)
            if nargin<7
                storeAndCall=false;
                if nargin<4
                    prop='';
                    if nargin<3
                        props=[];
                        if nargin<2
                            dflt=true;
                        end
                    end
                end
            end
            if ~isempty(prop) && isempty(props)
                props=BasicMap.Global;
            end
            jcb=javaObjectEDT('javax.swing.JCheckBox', label);
            if nargin>1
                if ~isempty(props)
                    jcb.setSelected(props.is(prop, dflt));
                else
                    jcb.setSelected(dflt);
                end
                if nargin>4 && ~isempty(fnc)
                    if storeAndCall && ~isempty(props)
                        set(handle(jcb, 'CallbackProperties'), ...
                            'ActionPerformedCallback', @store2);
                    else
                        set(handle(jcb, 'CallbackProperties'), ...
                            'ActionPerformedCallback', fnc);
                    end
                elseif ~isempty(props)
                    set(handle(jcb, 'CallbackProperties'), ...
                        'ActionPerformedCallback', @(h,e)store);
                end
                if nargin>5
                    jcb.setToolTipText(tip);
                end
            end
            
            function store
                if jcb.isSelected
                    props.set(prop, 'true');
                else
                    props.set(prop, 'false');
                end
            end
            
            function store2(h,e)
                store;
                feval(fnc, h,e);
            end

        end
        
        function setItems(comboBox,strs)
            comboBox=javaObjectEDT(comboBox);
            comboBox.removeAllItems();
            for i=1:length(strs)
                comboBox.addItem(strs{i});
            end
        end
        function ChangeWidth(H, percent, parentFig, parentFigPercent)
            if nargin<3
                parentFig=[];
            end
            u=get(H, 'units');
            set(H, 'units', 'normalized');
            P=get(H, 'position');
            if ~isempty(parentFig)
                P2=get(parentFig, 'position');
                set(parentFig, 'position', [P2(1) P2(2) P2(3)*(1+parentFigPercent) P2(4)]);
            end
            X=P(1)-percent;
            if X<=0
                X=.01;
            elseif X>=1
                X=.99;
            end
            W=P(3)+percent;
            if W<=0
                W=.01;
            elseif W>=1
                W=.99;
            end
            set(H, 'position', [X P(2) W P(4)]);
            set(H, 'units', u);
        end
        
        function where=PickWhere(num, modulus)
            if nargin<2
                modulus=15;
            end
            where='Center';
            if ischar(num)
                num=str2double(num);
            end
            if isnumeric(num) && ~isnan(num)
                pick=mod(num,modulus);
                switch(pick)
                    case 1
                        where='south';
                    case 2
                        where='west';
                    case 3
                        where='north';
                    case 4
                        where='east';
                    case 5
                        where='south west';
                    case 6
                        where='south east';
                    case 7
                        where='north west';
                    case 8
                        where='north east';
                    case 9
                        where='south west++';
                    case 10
                        where='south east++';
                    case 11
                        where='north west++';
                    case 12
                        where='north east++';
                    case 13
                        where='west++';
                    case 14
                        where='east++';
                end
            end
        end
        
        function SetTransparent(cmp, bckGrd)
            if nargin>1
                try
                    cmp.setBackground(bckGrd);
                    cmp.getParent.getParent.setBackground(bckGrd);
                    cmp.getParent.getParent.getParent.setBackground(bckGrd);
                catch ex
                    disp(ex.getReport);
                end
            end
            try
                cmp.setOpaque(false);
                cmp.getParent.setOpaque(false);
                cmp.getParent.getParent.setOpaque(false);
                cmp.getParent.getParent.getParent.setOpaque(false);
                cmp.getParent.getParent.repaint;
            catch ex
                %disp(ex.getReport);
            end
            drawnow;
        end

        function SetTransparent2(cmp)
            cmp.setOpaque(false);
            cmp.getParent.setOpaque(false);
            cmp.getParent.getParent.setOpaque(false);
            cmp.getParent.getParent.getParent.setOpaque(false);
            cmp.getParent.getParent.repaint;
        end

        function [ok, n]=SetNumberField(jtf, props, prop, low, high, ...
                noun, clearIfEmpty, suffix)
            if nargin<8
                suffix='';
                if nargin<6
                    noun='value';
                end
            end
            s=char(jtf.getText);
            if isempty(s)
                if nargin>6 && clearIfEmpty
                    if ~isempty(props)
                        props.remove(prop);
                    end
                    n=[];
                    ok=true;
                    return;
                end
            end
            n=str2double(s);
            ok=false;
            if isnan(n)
                msg(Html.WrapHr([noun ' must be a number ' suffix]));
                return;
            end
            if nargin>3
                highWhine=Gui.CheckTooHigh(n, high);
                if ~isempty(highWhine)
                    msg(Html.WrapHr([noun highWhine suffix]));
                    return;
                end
                lowWhine=Gui.CheckTooLow(n, low);
                if ~isempty(lowWhine)
                    msg(Html.WrapHr([noun lowWhine suffix]));
                    return;
                end
            end
            if ~isempty(props)
                props.set(prop, s);
            end
            ok=true;
        end
        
        function DlgDone(msg_, title, icon, modal, where, lbl)
            if nargin<6
                lbl='Done';
                if nargin<5
                    where='north++';
                    if nargin<4
                        modal=false;
                        if nargin<3
                            icon=[];
                            if nargin<2
                                title='Note...';
                            end
                        end
                    end
                end
            end
            if ischar(msg_)
                [~, msg_]=Gui.Label(msg_);
            end
            msg.msg=msg_;
            msg.modal=modal;
            msg.where=where;
            if ~isempty(icon)
                msg.icon=icon;
            end
            questDlg(msg, title, lbl, lbl);
        end
        function cancelled=DlgOk(Msg, Title)
            [~,~,cancelled]=questDlg(Msg, Title, 'Cancel', 'Ok', 'Ok');
        end
            
        function whine=CheckTooHigh(num, fncOrNum)
            whine=[];
            if isa(fncOrNum, 'function_handle')
                [tooHigh, explanation]=feval(fncOrNum, num);
                if ~isempty(tooHigh)
                    whine=[' must be &lt;= ' num2str(tooHigh) explanation];
                end
            elseif ~isempty(fncOrNum) && num>fncOrNum
                whine=[ ' must be &lt;= ' num2str(fncOrNum)];
            end
        end
        
        function whine=CheckTooLow(num, fncOrNum)
            whine=[];
            if isa(fncOrNum, 'function_handle')
                [tooHigh, explanation]=feval(fncOrNum, num);
                if ~isempty(tooHigh)
                    whine=[' must be &gt;= ' num2str(tooHigh) explanation];
                end
            elseif ~isempty(fncOrNum) && num<fncOrNum
                whine=[ ' must be &gt;= ' num2str(fncOrNum)];
            end
        end
        
        function [priorText,done]...
                =SetLabelsInPanel(jp, text, tip, ifTextContains, howMany)
            if nargin<5
                howMany=1;
                if nargin<4
                    ifTextContains='';
                    if nargin<3
                        tip='';
                    end
                end
            end
            if ~isempty(tip)
                jp.setToolTipText(tip);
            end
            priorText='';
            done=0;
            while ~strcmp(jp.getClass.getName, 'javax.swing.JPanel')
                jp=jp.getParent;
                if isempty(jp)
                    return;
                end
            end
            N=jp.getComponentCount;
            for i=0:N-1
                c=jp.getComponent(i);
                if strcmp(c.getClass.getName, 'javax.swing.JLabel')
                    t=char(c.getText);
                    if nargin<3 || contains(t, ifTextContains)
                        priorText=t;
                        c.setText(text);
                        if ~isempty(tip)
                            c.setToolTipText(tip);
                        end
                        done=done+1;
                        if done==howMany
                            return;
                        end
                    end
                end
            end
        end
        
        
        function was=SetParentVisible(cmp, visible)
            p=cmp.getParent;
            was=p.isVisible;
            p.setVisible(nargin<2||visible);
        end
        
        function [txt, turnedOn]=SetHint(jtf, hint, latestKeyChar, ...
                firstHint, normalFont, app, wasJustTurnedOn)
            if nargin<6
                app=BasicMap.Global;
                if nargin<5
                    normalFont=javax.swing.UIManager.getFont('Label.font');
                    if nargin<4
                        firstHint=false;
                        if nargin<3
                            latestKeyChar='';
                        end
                    end
                end
            end
            turnedOn=false;
            app.closeToolTip;
            txt=char(jtf.getText);     
            if ~isempty(hint)
                if wasJustTurnedOn && ~isempty(latestKeyChar)
                    jtf.setText(latestKeyChar)
                    txt=latestKeyChar;
                elseif isempty(txt) || strcmpi(txt, hint)
                    turnedOn=true;
                    jtf.setForeground(Gui.BLUE_COLOR);
                    jtf.setBackground(Gui.LIGHT_GRAY_COLOR);
                    jtf.setSelectedTextColor(Gui.GREEN_COLOR);
                    jtf.setSelectionColor(Gui.LIGHT_YELLOW_COLOR);
                    jtf.setText(hint);
                    jtf.setFont(java.awt.Font(normalFont.getName, ...
                        java.awt.Font.ITALIC, normalFont.getSize));
                    jtf.requestFocus;
                    if ~firstHint
                        app.showToolTip(jtf);
                        MatBasics.DoLater(@(h,e)focus, .22);
                    else
                        MatBasics.DoLater(@(h,e)clearHint, .22);
                    end
                    return;
                end
            end
            jtf.setFont(normalFont)
            jtf.setForeground(Gui.BLACK_COLOR);
            jtf.setBackground(Gui.WHITE_COLOR);
            jtf.setSelectedTextColor(Gui.WHITE_COLOR);
            jtf.setSelectionColor(Gui.BLUE_COLOR);
            
            function focus
                drawnow;
                jtf.select(0, jtf.getText.length);
                drawnow;
            end
            
            function clearHint
                jtf.setText('');
                app.showToolTip(jtf, hint);
                Gui.SetHint(jtf, hint, '', false, normalFont, app, true);
            end
        end
        
        function [jtf, normalFont, app]=NewTextField(dflt, cols, ...
                tip, props, prop, fncCheck, hint)
            if nargin<7
                hint='';
            end
            app=BasicMap.Global;                        
            firstHint=true;
            jtf=javaObjectEDT('javax.swing.JTextField', dflt);
            normalFont=jtf.getFont;
            if nargin>1
                jtf.setColumns(cols)
                if nargin>2
                    jtf.setToolTipText(tip);
                    if nargin>4
                        if isempty(props)
                            v=dflt;
                        else
                            v=props.get(prop, dflt);
                            if ~isempty(v)
                                jtf.setText(v);
                            end
                        end
                        if nargin>5 
                            if ~isempty(fncCheck) || ~isempty(hint)
                                jj=handle(jtf, 'CallbackProperties');
                                set(jj, 'KeyTypedCallback', @(h,e)check(e));
                                wasJustTurnedOn=true;
                                setHint('');
                            end
                        end
                    end
                end
            end
            function [txt, hintNowOn]=setHint(latestKeyChar)
                [txt, hintNowOn]=Gui.SetHint(jtf, hint, ...
                    latestKeyChar, firstHint, normalFont, app, wasJustTurnedOn);
                firstHint=false;
            end                
            
            function check(e)
                [txt, wasJustTurnedOn]=setHint(e.getKeyChar);
                if ~isempty(txt)
                    if ~isempty(fncCheck)
                        argOut=feval(fncCheck, txt, jtf, e);
                        if iscell(argOut) 
                            complaint=argOut{1};
                        else
                            complaint=argOut;
                        end
                        if ~isempty(complaint)
                            if iscell(argOut) && length(argOut)==3
                                jtf.setForeground(argOut{2});
                                jtf.setBackground(argOut{3});
                            else
                                jtf.setForeground(Gui.ERROR_COLOR);
                                jtf.setBackground(Gui.WARNING_COLOR);
                            end
                            jtf.setFont(java.awt.Font(normalFont.getName, ...
                                java.awt.Font.BOLD, normalFont.getSize));
                            app.showToolTip(jtf, ['<html>' complaint '</html>']);
                        end
                    end
                end
            end
        end
        
        function [strs, bad]=GetTextFieldStrs(cmp, badForeground)
            if nargin<2
                badForeground=[];
            elseif islogical(badForeground) && badForeground
                badForeground=Gui.ERROR_COLOR;
            end
            bad=0;
            if isa(cmp, 'javax.swing.JPanel')
                N=cmp.getComponentCount;
                strs=cell(1,N);
                for i=1:N
                    getStr(cmp.getComponent(i-1), i);
                end
            else
                strs=cell(1,1);
                getStr(cmp,1);
            end 
            
            function getStr(cmp, i)
                try
                    if isempty(badForeground) ...
                            || ~isequal(cmp.getForeground, badForeground)
                        strs{i}=char(cmp.getText);
                    else
                        bad=bad+1;
                    end
                catch
                    bad=bad+1;
                end 
            end
        end
        
        function [nums, bad]=GetTextFieldNums(cmp, badForeground)
            if nargin<2
                badForeground=[];
            elseif islogical(badForeground) && badForeground
                badForeground=Gui.ERROR_COLOR;
            end
            bad=0;
            if isa(cmp, 'javax.swing.JPanel')
                N=cmp.getComponentCount;
                nums=nan(1,N);
                for i=1:N
                    getNum(cmp.getComponent(i-1), i);
                end
            else
                nums=nan;
                getNum(cmp,1);
            end 
            
            function getNum(cmp, i)
                try
                    if isempty(badForeground) ...
                            || ~isequal(cmp.getForeground, badForeground)
                        txt=char(cmp.getText);
                        nums(i)=str2double(txt);
                    else
                        bad=bad+1;
                    end
                catch
                    bad=bad+1;
                end 
            end
        end
        
        function n=SetNumberField2(jtf, props, property)
            badLimit=isequal(jtf.getForeground, Gui.ERROR_COLOR);
            if ~badLimit
                s=char(jtf.getText);
                props.set(property, s);
                n=str2double(s);
            else
                n=nan;
            end
        end

        function [jtf, jl, pnl]=AddNumberField(label, cols, dfltValue, ...
                props, prop, pnl, toolTip, low, high, saveImmediately, ...
                fncFmt, specialNum, specialMeaning)
            if nargin<13
                if nargin==12
                    specialMeaning=[' (or ' num2str(specialNum) ' for ' ...
                    'unlimited)'];
                else
                    specialMeaning='';
                end
            else
                specialMeaning=[' (or ' num2str(specialNum) ' for ' ...
                    specialMeaning ')'];
            end
            if nargin<12
                specialNum=[];
                if nargin<11
                    fncFmt=[];
                    if nargin<10
                        saveImmediately=false;
                        if nargin<9
                            high=[];
                            if nargin<8
                                low=[];
                                if nargin<7
                                    toolTip=[];
                                end
                            end
                        end
                    end
                end
            end
            jl=javaObjectEDT('javax.swing.JLabel', label);
            if isempty(dfltValue) 
                v='';
            else
                if isempty(props)
                    v=dfltValue;
                else
                    v=props.get(prop, dfltValue);
                    n=str2double(v);
                    if isnan(n)
                        v=dfltValue;
                        if isnumeric(v)
                            n=v;
                        elseif ischar(v)
                            n=str2double(v);
                        end
                    end
                end
            end
            forceInt=false;
            if isempty(fncFmt)
                if isempty(v)
                    strVal='';
                elseif ischar(v)
                    if isempty(v)
                        strVal='';
                    else
                        strVal=String.encodeRounded(...
                            str2double(v), 2, true);
                    end
                else
                    strVal=String.encodeRounded(v, 4, true);
                end
            else
                if strcmpi(fncFmt, 'int')
                    forceInt=true;
                    fncFmt=@String.encodeInteger;
                end 
                if ischar(v)
                    if isempty(v)
                        strVal='';
                    else
                        strVal=fncFmt(str2double(v));
                    end
                else
                    strVal=fncFmt(v);
                end
            end
            jtf=javaObjectEDT('javax.swing.JTextField', strVal);    
            jtf.setColumns(cols)
            jtf.setHorizontalAlignment(jtf.RIGHT);
            jj=handle(jtf, 'CallbackProperties');
            set(jj, 'KeyTypedCallback', @(h,e)check());
            if nargin>5 && ~isempty(pnl)
                pnl.add(Gui.FlowLeftPanel(5,5, jl, jtf));
            elseif nargout>2
                pnl=Gui.FlowLeftPanel(5,5, jl, jtf);
            end
            app=BasicMap.Global;
            black=java.awt.Color(0,0,0);
            red=Gui.ERROR_COLOR;
            white=java.awt.Color(1,1,1);
            yellow=Gui.WARNING_COLOR;
            if ~isempty(toolTip)
                jtf.setToolTipText(toolTip);
                jl.setToolTipText(toolTip);
            end
            
            function check()
                s=char(jtf.getText);
                if isequal(s, '-') ...
                        || (~forceInt && isequal(s, '.')) ...
                        || isequal(s, '-.')
                    return;
                end
                if isempty(s)
                    jtf.setForeground(black);
                    jtf.setBackground(white);
                    return;
                end
                if forceInt && contains(s,'.')
                    whine='Please enter an integer!';
                else
                    n=str2double(s);
                    highWhine=Gui.CheckTooHigh(n, high);
                    lowWhine=Gui.CheckTooLow(n, low);
                    if isnan(n)
                        whine=['<html>"' s '" is <font color="red"><b>not</b>'...
                            ' a number!?</font></html>'];
                    elseif ~isempty(specialNum) && specialNum==n
                        whine=[];
                    elseif ~isempty(lowWhine)
                        whine=lowWhine;
                    elseif ~isempty(highWhine)
                        whine=highWhine;
                    else
                        whine=[];
                    end
                end
                if isempty(whine)
                    jtf.setForeground(black);
                    jtf.setBackground(white);
                    app.closeToolTip;
                    if saveImmediately && ~isempty(props)
                        props.set(prop, num2str(n));
                    end
                else
                    jtf.setForeground(red);
                    jtf.setBackground(yellow);
                    app.showToolTip(jtf, ['<html>' whine specialMeaning '</html>']);
                end
            end
        end
        
        function [jcb, jf]=CheckBoxPopUp(text, where, property, delaySecs,...
                properties, fncYes, fncNo)
            if nargin<7
                fncNo=[];
                if nargin<6
                    fncYes=[];
                    if nargin<5
                        properties=BasicMap.Global;
                        if nargin<4
                            delaySecs=7;
                            if nargin<3
                                property='';
                                if nargin<2
                                    where='north east';
                                end
                            end
                        end
                    end
                end
            end
                        
            jcb=javaObjectEDT('javax.swing.JCheckBox', text);
            jp=javaObjectEDT('javax.swing.JPanel');
            jp.add(jcb);
            set(handle(jcb, 'CallbackProperties'), ...
                'ActionPerformedCallback', @click);
            jf=javaObjectEDT('javax.swing.JFrame');
            jf.getContentPane.add(jp);
            jf.pack;
            if ~isempty(property)
                if isempty(properties)
                    properties=BasicMap.Global;
                end
                if properties.is(property)
                    jcb.setSelected(true);
                end
            end
            jf.setVisible(true)
            Gui.LocateJava(jf, [], where);
            if delaySecs>0
                tmr=timer;
                tmr.StartDelay=delaySecs;
                tmr.TimerFcn=@(h,e)jf.dispose;
                start(tmr);
            end
           % h.setEnabled(true);
            function click(h,e)
                yes=jcb.isSelected;
                if ~isempty(property)
                    if yes
                        properties.set(property, 'true');
                    else
                        properties.set(property, 'false');
                    end
                end
                if yes
                    if ~isempty(fncYes)
                        feval(fncYes, h, e);
                    end
                else
                    if ~isempty(fncNo)
                        feval(fncNo, h, e);
                    end
                end
            end
        end
        
        function [ok, dropFig, dropObj]=IsDroppedOn(dragObj, dragFig, objName, fnc)
            ok=false;
            dropFig=[];
            dropObj=[];
            [inCurrent, atPos]=Gui.InCurrentFig(dragFig);
            if ~inCurrent
                [objs, figs_, N]=Figures.Find(objName, atPos);
                if N>0
                    figs={};
                    for i=1:N
                        if ~isequal(objs{i}, dragObj)
                            figs{end+1}=figs_{i};
                        end
                    end
                    if isempty(figs)
                        return;
                    end
                    ok=true;
                    [dropFig, i]=Gui.GetTopFig(figs);
                    dropObj=objs{i};
                    if nargin>2 && ~isempty(fnc)
                        feval(fnc, dragObj, dragFig, dropObj, dropFig);
                    end
                end
            end
        end
        
        function [ok, atPos, px]=InCurrentFig(fig)
            atPos=get(0,'PointerLocation');
            px=Gui.GetPixels(fig);
            ok=false;
           if atPos(1) > px(1) && atPos(1)<px(1)+px(3)
               if atPos(2) > px(2) && atPos(2)<px(2)+px(4)
                   ok=true;
               end
           end
        end
        
        function UnderConstruction(feature, reconstruction, where, howManyTimes)
            if nargin<4
                howManyTimes=1;
            end
            if BasicMap.Global.Tally(feature)>howManyTimes
                return;
            end
            if nargin<3
                where='south west++';
            end
            if nargin<2 || ~reconstruction
                msg(['<html><b>' feature '</b> is under construction.' ...
                    '<ul><li>&nbsp;&nbsp;Initial programming isn''t complete.'...
                    '<li>&nbsp;&nbsp;Quality control has not started.</ul>' ...
                    '<hr><br><i><b>Thank you for your help and '...
                    '<font color="red">patience</font>...</b></i></html>'], ...
                    7, where, 'Under construction...', 'underConstruction.png');
            else
                msg(['<html><b>' feature '</b> is under <font color="red">RE-</font>construction.' ...
                    '<ul><li>&nbsp;&nbsp;Refactor programming isn''t complete.'...
                    '<li>&nbsp;&nbsp;Quality control has recently started.</ul>' ...
                    '<hr><br><i><b>Thank you for your help and '...
                    '<font color="red">patience</font>...</b></i></html>'], ...
                    7, where, 'Under RE-construction...', 'underReConstruction.png');
            end
        end
        
        function [tabFig, tb, pnlUpper, jlPreview, jlTitle, ...
                pnlPreview, pnlTitle]=TableFig(parentFig, figHeight, ...
                figWidth, previewHeightPerc, titleHeightPerc, ...
                useTextPane, previewLabel)
            if nargin<7
                previewLabel='Details...';
                if nargin<6
                    useTextPane=false;
                    if nargin<5
                        titleHeightPerc= .07;
                        if nargin<4
                            previewHeightPerc=.46;
                            if nargin<3
                                figWidth=85;
                                if nargin<2
                                    figHeight=50;
                                end
                            end
                        end
                    end
                end
            end
            previewY=.01;
            bodyHeightPerc=1-(titleHeightPerc+.02); % .02 for 2 margins
            tableHeightPerc=bodyHeightPerc-previewHeightPerc;
            tableY=previewY+previewHeightPerc+.01;
            titleY=tableY+tableHeightPerc;
            pos=Gui.GetPosition(parentFig, 'Characters');
            tabFig=figure('units', 'Characters', 'position', ...
                [pos(1)+(figWidth/2)-5 pos(2)-figHeight figWidth figHeight], ...
                'Menubar', 'none', 'DockControls', 'off', ...
                'NumberTitle', 'off', 'Color', 'white', 'Visible', 'off');
            tb=ToolBar.New(tabFig, true, true);
            pnlUpper=uipanel(tabFig, 'units', 'normalized', 'position', ...
                [.01 tableY, .98 tableHeightPerc]);
            pnlPreview=uipanel(tabFig, 'units', 'normalized', 'position', ...
                [.01 previewY .98 previewHeightPerc], 'Title', previewLabel);
            if useTextPane
                jlPreview=javaObjectEDT('edu.stanford.facs.swing.BrowserPane');
            else
                jlPreview=javaObjectEDT('javax.swing.JLabel');
                jlPreview.setHorizontalAlignment(javax.swing.JLabel.CENTER);
            end
            js=javaObjectEDT('javax.swing.JScrollPane', jlPreview);
            [~, H]=javacomponent(js);
            set(H, 'Parent', pnlPreview, 'units', 'normalized', 'position', ...
                [.01, .01, .98 .98])
            if titleHeightPerc>0
                pnlTitle=uipanel(tabFig, 'units', 'normalized', 'position', ...
                    [.01 titleY, .98 titleHeightPerc]);
                jlTitle=javaObjectEDT('javax.swing.JLabel');
                [~, H]=javacomponent(jlTitle);
                set(H, 'Parent', pnlTitle, 'units', 'normalized', 'position', ...
                    [.01, .01, .98 .98])
            else
                pnlTitle=[];
                jlTitle=[];
            end
        end
        
        function [answer, cancelled, strAnswer]=Ask(msg, allLabels, ...
                property, ttl, dflt, southWestButtons, singleOnly)
            if nargin<7
                singleOnly=true;
                if nargin<6
                    southWestButtons=[];
                    if nargin<5
                        dflt=1;
                        if nargin<4
                            ttl='Confirm....';
                            if nargin<3
                                property=[];
                            end
                        end
                    end
                end
            end
            if ~singleOnly
                dflt=dflt-1;
            end
            if isempty(property)
                [answer, cancelled]=mnuMultiDlg(...
                    msg, ttl, allLabels, dflt, singleOnly, ...
                    true, southWestButtons, ...
                    'south west buttons');
            else
                if isstruct(msg)
                    msg.property=property;
                    msg.properties=BasicMap.Global;
                else
                    msg=struct('msg', msg, ...
                    'properties', BasicMap.Global, 'property', property);
                end
                [answer, cancelled]=mnuMultiDlg(...
                    msg, ttl, allLabels, ...
                    dflt, singleOnly, true, ...
                    southWestButtons, 'south west buttons');
            end
            if nargout>2
                if cancelled || any(answer<1)
                    strAnswer=[];
                else
                    if length(answer)>1
                        strAnswer=allLabels(answer);
                    else
                        strAnswer=allLabels{answer};
                    end
                end
            end
        end
        
        function collection=Gather(javaC, javaClass, collection)
            if nargin<3
                collection=java.util.ArrayList;
            end
            gather(javaC);
            function gather(jc)
                if javaClass.isInstance(jc)
                    collection.add(jc);                    
                end
                N=jc.getComponentCount;
                for i=0:N-1
                    jc2=jc.getComponent(i);
                    gather(jc2);
                end
            end
        end

        function component=FindFirst(javaC, javaClass, txt)
            if nargin<3
                txt='';
                if nargin<3
                    javaClass=[];
                end
            end
            if isempty(javaClass)
                btn=javaObjectEDT('javax.swing.JButton');
                javaClass=btn.getClass;
            end
            component=findComponent(javaC);
            if ~isempty(component)
                component=javaObjectEDT(component);
            end
            function btn=findComponent(jc)
                if javaClass.isInstance(jc)
                    if isempty(txt) || strcmpi(txt, char(jc.getText))
                        btn=jc;
                        return;
                    end
                end
                N=jc.getComponentCount;
                for i=0:N-1
                    jc2=jc.getComponent(i);
                    btn=findComponent(jc2);
                    if ~isempty(btn)
                        return;
                    end
                end
                btn=[];
            end
        end
        
        function ToFront(fig)
            jf=getjframe(fig);
            if ~isempty(jf)
                jf.toFront;
            end
        end
        function wnd=Wnd(cmp)
            wnd=javaMethodEDT('getWindowAncestor', ...
                'javax.swing.SwingUtilities', cmp);
        end
        
        function WriteImg(file, folder, saveFolder, fPos, aPos, clr, X, Y)
            cdata=Gui.imReadAndSet(file, folder, fPos, aPos, clr, X, Y);
            imwrite(cdata,fullfile(saveFolder, file));
        end

        function cdata=GetImg1(file, oldColor, newColor, app)
            folder=app.contentFolder;
            if app.toolBarFactor>0
                file=edu.stanford.facs.swing.Basics.GetResizedImg(...
                    java.io.File(fullfile(folder, file)), ...
                    app.toolBarFactor, ...
                    java.io.File(app.appFolder));
                [folder, f1, f2]=fileparts(file);
                file=[f1 f2];
                cdata=Gui.imReadAndReColor(file, folder,...
                    oldColor, newColor);
            else
                cdata=Gui.imReadAndReColor(file, folder,...
                    oldColor, newColor);
            end
        end

        function cdata=GetImg2(file, oldColor1, newColor1, ...
                oldColor2, newColor2, app)
            folder=app.contentFolder;
            if app.toolBarFactor>0
                file=edu.stanford.facs.swing.Basics.GetResizedImg(...
                    java.io.File(fullfile(folder, file)), ...
                    app.toolBarFactor, ...
                    java.io.File(app.appFolder));
                [folder, f1, f2]=fileparts(file);
                file=[f1 f2];
                cdata=Gui.imReadAndReColor(file, folder,...
                    oldColor1, newColor1, oldColor2, newColor2);
            else
                cdata=Gui.imReadAndReColor(file, folder,...
                    oldColor1, newColor1, oldColor2, newColor2);
            end
        end

        function [folder, file, scale]=ImgPath(folder, file)
            if BasicMap.Global.toolBarFactor>0
                file=edu.stanford.facs.swing.Basics.GetResizedImg(...
                    java.io.File(fullfile(folder, file)), ...
                    BasicMap.Global.toolBarFactor, ...
                    java.io.File(BasicMap.Global.appFolder));
                [folder, f1, f2]=fileparts(file);
                file=[f1 f2];
                scale=2;
            else
                scale=1;
            end
        end
        
        function SetIcon1(javaObj, file, oldColor, newColor, app)
            if nargin<5
                app=BasicMap.Global;
            end
            icon=javax.swing.ImageIcon(im2java(...
                Gui.GetImg1(file, oldColor, newColor, app)));
            javaObj.setIcon(icon);
        end

        function SetIcon2(javaObj, file, oldColor1, newColor1, ...
                oldColor2, newColor2, app)
            if nargin<7
                app=BasicMap.Global;
            end
            icon=javax.swing.ImageIcon(im2java(...
                Gui.GetImg2(file, oldColor1, newColor1, ...
                oldColor2, newColor2, app)));
            javaObj.setIcon(icon);
        end

        function FireActionListener(cmp)
            feval(get(handle(cmp, 'CallbackProperties'), ...
                'ActionPerformedCallback'), cmp,'')
        end
        
        function [H, J, H2, btnWidth]=NewBtn(txt, cb, tip, iconPath, ...
                fig, X, Y, rightAlign, visibility, app)
            J=javaObjectEDT('javax.swing.JButton', txt);
            H=handle(J, 'CallbackProperties');
            if nargin>1
                set(H, 'ActionPerformedCallback', cb);
            end
            if nargin>2 
                J.setToolTipText(tip);
                if nargin>3 && ~isempty(iconPath)
                    if isjava(iconPath)
                        J.setIcon(iconPath);
                    else
                        J.setIcon(Gui.Icon(iconPath));
                    end
                end
            end
            if nargout>3
                if nargin<10
                    app=BasicMap.Global;
                    if nargin<9
                        visibility='off';
                        if nargin<8
                            rightAlign=true;
                            if nargin<7
                                Y=1;
                                if nargin<6
                                    X=1;
                                    if nargin<5
                                        fig=gcf;
                                    end
                                end
                            end
                        end
                    end
                end
                [d, resized]=resizeJavaPrefs(app, J);
                btnWidth=d.width;
                h=d.height;
                if rightAlign
                    if resized
                        X=X-(d.width+16);
                    else
                        X=X-(d.width+4);
                    end
                end
                [~,H2]=javacomponent(J,[X Y d.width d.height]);
                set(H2, 'parent', fig, 'visible', visibility);
            end
        end
        
        function [H, ps, J]=AlignLeft(figOrPnl, J, Y, X, normalize)
            if nargin<5
                normalize=false;
                if nargin<4
                    X=2;
                end
            end
            ps=J.getPreferredSize;
            d=resizeJavaPrefs(BasicMap.Global, J);
            if isempty(Y) % top
                pos=Gui.GetPixels(figOrPnl);
                Y=pos(4)-(d.height+2);
            end
            [J,H]=javacomponent(J);
            Gui.SetTransparent(J);            
            pos2=[X Y d.width+2 d.height];
            set(H, 'parent', figOrPnl, 'units', 'pixels', 'position', pos2);
            if normalize
                set(H, 'units', 'normalized');
            end
        end
        
        function [H, ps, J]=AlignRight(fig, J, Y, normalize)
            ps=J.getPreferredSize;
            [d, resized]=resizeJavaPrefs(BasicMap.Global, J);
            pos=Gui.GetPixels(fig);
            X=pos(3);
            if resized
                X=X-(d.width+16);
            else
                X=X-(d.width+11);
            end
            [J,H]=javacomponent(J);
            Gui.SetTransparent(J);            
            pos2=[X Y d.width+2 d.height];
            set(H, 'parent', fig, 'units', 'pixels', 'position', pos2);
            if nargin>3 && normalize
                set(H, 'units', 'normalized');
            end
        end

        function [H, ps, J]=AlignCenter(fig, J, Y, normalize)
            ps=J.getPreferredSize;
            [d, resized]=resizeJavaPrefs(BasicMap.Global, J);
            pos=Gui.GetPixels(fig);
            X=pos(3);
            if resized
                X=X/2-(d.width+16)/2;
            else
                X=X/2-(d.width+11)/2;
            end
            [J,H]=javacomponent(J);
            Gui.SetTransparent(J);            
            pos2=[X Y d.width+2 d.height];
            set(H, 'parent', fig, 'units', 'pixels', 'position', pos2);
            if nargin>3 && normalize
                set(H, 'units', 'normalized');
            end
        end

        function [H, J]=NewBtn2(txt, cb, tip, iconPath, ...
                fig, X, Y)
            J=javaObjectEDT('javax.swing.JButton', txt);
            if nargin>2 
                J.setToolTipText(tip);
                if nargin>3 && ~isempty(iconPath)
                    J.setIcon(Gui.Icon(iconPath));
                end
            end
            if nargin<7
                Y=1;
                if nargin<6
                    X=1;
                    if nargin<5
                        fig=gcf;
                    end
                end
            end
            d=resizeJavaPrefs(BasicMap.Global, J);
            H=javacomponent(J,[X Y d.width d.height], fig);
            set(H, 'ActionPerformedCallback', cb);
        end
        
        function ShowToolTipHere(tip, cmp, ax, fig, app, dismissSecs, ...
                bottomCmp, hideCancelBtn, xOffset, yOffset, cp)
            if nargin < 10
                yOffset=0;
                if nargin<9
                    xOffset=0;
                    if nargin<8
                        hideCancelBtn=true;
                        if nargin<7
                            bottomCmp=[];
                            if nargin<5
                                dismissSecs=4;
                                if nargin<5
                                    app=BasicMap.Global;
                                    if nargin<4
                                        fig=gcf;
                                        if nargin<3
                                            ax=gca;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if nargin<11
                [X, Y]=Gui.GetCurrentXY(ax, fig, cmp);
            else
                [X, Y]=Gui.GetCurrentXY(ax, fig, cmp, cp);
                %fprintf('CP equals X=%s Y=%s\n', String.encodeNumber(cp(1)),...
                %    String.encodeNumber(cp(2)));
            end
            app.showToolTip(cmp, tip, X+xOffset, Y+yOffset, dismissSecs, ...
                bottomCmp, hideCancelBtn);
        end
        
        function ShrinkNormalized(obj, widthPercent, heightPercent)
            u=get(obj, 'units');
            set(obj, 'units', 'normalized');
            P=get(obj, 'position');
            if widthPercent>0
                P(1)=P(1)+(widthPercent/2);
                P(3)=P(3)-widthPercent;
            end
            if heightPercent>0
                P(2)=P(2)+(heightPercent/2);
                P(4)=P(4)-heightPercent;
            end
            set(obj, 'position', P);
            set(obj, 'units', u);
        end
        
        function Grow(obj, widthPercent, heightPercent)
            P=get(obj, 'outerposition');
            g=P(3)*widthPercent;
            P(1)=P(1)-g/2;
            P(3)=P(3)+g;
            g=P(4)*heightPercent;
            P(2)=P(2)-g/2;
            P(4)=P(4)+g;
            set(obj, 'outerposition', P);
        end
        
        function [X, Y]=GetCurrentXY(ax, fig, cmp, cp)
            if nargin<4
                pm=Gui.GetCurrentPointPixels(ax, fig);
            else
                pm=Gui.GetCurrentPointPixels(ax, fig, cp);
            end
            [X,Y]=Gui.SwingOffset(pm, cmp);
            %fprintf('pm=%d/%d; X=%d, Y=%d]\n', pm(1), pm(2), X, Y);
            app=BasicMap.Global;
            if app.highDef
                X=X*1.5;%app.toolBarFactor;
                Y=Y*1.45;%app.toolBarFactor;
            end
        end

        function ShowMenuHere(fig,ax,cmp,menu)
            pm=Gui.GetCurrentPointPixels(ax, fig);
            [X,Y]=Gui.SwingOffset(pm, cmp);
            menu.show(cmp, X, Y);
        end
        
        function icon=IconAnimated(file)
            [path, f]=fileparts(file);
            if isempty(path)
                file=fullfile(BasicMap.Global.contentFolder, file);
            end
            icon=javax.swing.ImageIcon(file);
        end        
        
        function icon=Icon(file, app)
            if nargin<2
                app=BasicMap.Global;
            end
            if app.urlMap.map.isKey(file)
                icon=app.urlMap.map(file);
                return;
            end
            key=file;
            if isempty(fileparts(file))
                file=fullfile(app.contentFolder, file);
            else
                if ispc
                    % drive letters NOT supported by javax.swing.ImageIcon
                    idx=strfind(file, ':');
                    if ~isempty(idx)
                        file=file(idx+1:end);
                    end
                end
            end
            if app.toolBarFactor>0
                if length(file)<7 || ~strcmp('facs.gif', file(end-7:end))
                    try
                        file=edu.stanford.facs.swing.Basics.GetResizedImg(...
                            java.io.File(file), BasicMap.Global.toolBarFactor, ...
                            java.io.File(BasicMap.Global.appFolder));
                    catch ex
                        disp(ex);
                    end
                end
            end
            icon=javax.swing.ImageIcon(file);
            app.urlMap.map(key)=icon;
        end

        function icon=IconApp(file, app)
            if nargin<2
                app=BasicMap.Global;
            end
            icon=app.urlMap.get(file);
            if ~isempty(icon)
                return;
            end
            path=fileparts(file);
            key=file;
            if isempty(fileparts(file))
                file=fullfile(app.appFolder, file);
            end
            if app.toolBarFactor>0
                if length(file)<7 || ~strcmp('facs.gif', file(end-7:end))
                    file=edu.stanford.facs.swing.Basics.GetResizedImg(...
                        java.io.File(file), app.toolBarFactor, ...
                        java.io.File(app.appFolder));
                end
            end
            icon=javax.swing.ImageIcon(file);
            app.urlMap.setObject(key, icon);
        end

        function out=RGB(r,g,b)
            out=[r/255, g/255, b/255];            
        end
        
        function [backGround, foreGround]=JavaColor(javaObj)
            if isa(javaObj, 'java.awt.Color')
                backGround=calc(javaObj);
                foreGround=backGround;
            else
                backGround=calc(javaObj.getBackground);
                foreGround=calc(javaObj.getForeground);
            end
            function out=calc(clr)
                out=[clr.getRed/255 clr.getGreen/255 clr.getBlue/255];
            end
        end
        
        function s=HtmlColor(ml)
            ml=floor(ml*255);
            try
                s=sprintf('color="rgb(%.0f, %.0f, %.0f)"', ml(1), ml(2), ml(3));
            catch
                s='color="black"';
            end
        end
        
        function rgb=HslColor(idx,N)
            hue=idx/N;
            if mod(idx,2)==0
                saturation=.6;
                light=.99;
            else
                saturation=.8;
                light=.9;
            end
            clr=java.awt.Color.getHSBColor(hue, saturation, light);
            rgb=[clr.getRed/255, clr.getGreen/255, clr.getBlue/255];
            %rgb=hsl2rgb([hue saturation light]);
        end

        function str=HtmlColorScale(pk, J, bg)
            c=J(floor(pk*size(J,1)),:);
            str=['<font ' bg ' ' Gui.HtmlHexColor(c) '>' ...
                String.encodePercent(pk, 1) '</font>'];
        end

        function jl=TextPane
            jl=javaObjectEDT('edu.stanford.facs.swing.BrowserPane');
            jl.setContentType('text/html');
            jl.setEditable(false);
            jl.setOpaque(false);
        end
        
        function str=HtmlBgColor(c, str)
            str=['<font  bg' Gui.HtmlHexColor(c) '>' ...
                str '</font>'];
        end
        function str=HtmlBgColorScale(pk, J, str)
            c=J(floor(pk*size(J,1)),:);
            str=['<font  bg' Gui.HtmlHexColor(c) '>' ...
                str '</font>'];
        end

        function [s, ml, ml2]=HtmlHexColor(ml)
            ml(ml>1)=ml(ml>1)/255;
            ml(ml>1)=1;
            ml(ml<0)=0;
            ml2=ml*255;
            ml=floor(ml2);
            try
                s=sprintf('color="#%s%s%s"', hex(ml(1)), ...
                    hex(ml(2)), hex(ml(3)));
            catch
                s='color="black"';
            end
            function c=hex(c)
                c=dec2hex(c);
                if length(c)==1
                    c=['0' c];
                end
            end
        end
        
        function [s, ml, ml2]=HexColor(ml)
            ml(ml>1)=ml(ml>1)/255;
            ml(ml>1)=1;
            ml(ml<0)=0;
            ml2=ml*255;
            ml=floor(ml2);
            try
                s=sprintf('#%s%s%s', hex(ml(1)), ...
                    hex(ml(2)), hex(ml(3)));
            catch
                s='#000000';
            end
            function c=hex(c)
                c=dec2hex(c);
                if length(c)==1
                    c=['0' c];
                end
            end
        end

        function setFontName(figure, name)
            set(findall(figure,'Style','text'), 'FontName',name);
            set(findall(figure,'Style','pushbutton'), 'FontName', name);
            set(findall(figure,'Style','checkbox'), 'FontName', name);
            set(findall(figure,'Style','popupmenu'), 'FontName', name);
            set(findall(figure,'Style','radiobutton'), 'FontName', name);
            set(findall(figure,'Style','edit'), 'FontName', name);
            set(findall(figure,'type','uipanel'), 'FontName', name);
        end
        
        function perc=GetFigureOverlap(p1, p2)
            perc=Gui.GetPositionOverlap(Gui.GetOuterPixels(p1),...
                Gui.GetOuterPixels(p2));
        end
        
        function perc=GetPositionOverlap(p1, p2)
            xo=intersect( floor(p1(1):(p1(1)+p1(3)-1)), ...
                floor(p2(1):(p2(1)+p2(3)-1)));
            xp=length(xo)/p1(3);
            yo=intersect(floor(p1(2):(p1(2)+p1(4)-1)), ...
                floor(p2(2):(p2(2)+p2(4)-1)));
            yp=length(yo)/p1(4);
            perc=xp*yp;
        end
        
        function CascadeFigs(figs, lastOnly, topLeft, margin, ...
                topMargin, makeVisible, runLater, scrFig, firstTopMargin)
            if nargin<9
                firstTopMargin=0;
                if nargin<8
                    scrFig=get(0, 'currentFig');
                    if nargin<7
                        runLater=true;
                        if nargin<6
                            makeVisible=false;
                            if nargin<4
                                margin=15;
                                if nargin<3
                                    topLeft=true;
                                    if nargin<2
                                        lastOnly=false;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if nargin<5 || isempty(topMargin)
                topMargin=margin;
            end
            N=length(figs);
            if N>1 || nargin>4 %% if > 1 or invoker is interested in top margin 
                if topLeft
                    
                    [scrNum, ~, scrPos]=Gui.FindScreen(scrFig);
                    if Gui.DEBUGGING
                        disp(['GCF name on screen #' num2str(scrNum)]);
                        get(scrFig, 'name')
                    end
                    if isjava(figs{1})
                        pe=Gui.GetJavaScreenBounds(scrNum);
                        topX=pe.x+topMargin+firstTopMargin;
                        topY=pe.y+topMargin;
                        figs{1}.setLocation(topX, topY)
                    else
                        topX=scrPos(1)+topMargin+firstTopMargin;
                        topY=scrPos(2)+scrPos(4)-topMargin;
                        top=Gui.OuterPositionArg(figs{1});
                        top(1)=topX;
                        top(2)=topY-top(4);
                        Gui.SetOuterPixels(figs{1}, top);
                        if makeVisible
                            set(figs{1}, 'visible', 'on');
                            if ismac
                                %trick Mac multiple screen issue
                                if 2==size(get(0, 'MonitorPositions'), 1)
                                    drawnow;
                                    Gui.SetOuterPixels(figs{1}, top);
                                end
                            end
                        end
                    end
                else
                    if isjava(figs{1})
                        topY=figs{1}.getY;
                    else
                        top=Gui.OuterPositionArg(figs{1});
                        topY=top(2)+top(4);
                    end
                end
                if runLater
                    MatBasics.RunLater(@(h,e)seeFig(), .15);
                else
                    seeFig;
                end
            else
                if isjava(figs{1})
                    figs{1}.toFront;
                else
                    figure(figs{1});
                end
            end
            
            function seeFig
                if lastOnly
                    start=N;
                else
                    start=2;
                    if isjava(figs{1})
                        figs{1}.toFront;
                    else
                        figure(figs{1});
                    end
                end
                for i=start:N
                    nudgeX=(i-1)*margin/2;
                    nudgeY=topMargin+((i-1)*margin)+(margin*.31);
                    if isjava(figs{i})
                        figs{i}.setLocation(topX+nudgeX, topY+nudgeY);
                        figs{i}.toFront;
                    else
                        op=Gui.OuterPositionArg(figs{i});
                        Gui.SetOuterPixels(figs{i}, [(topX+nudgeX)...
                            (topY-op(4)-nudgeY) op(3) op(4)]);
                        if makeVisible || Gui.IsVisible(figs{i})
                            figure(figs{i});
                            if ismac
                                %trick Mac multiple screen issue
                                if 2==size(get(0, 'MonitorPositions'), 1)
                                    drawnow;
                                    Gui.SetOuterPixels(figs{i}, [(topX+nudgeX)...
                                        (topY-op(4)-nudgeY) op(3) op(4)]);
                                end
                            end
                        end
                    end
                end
            end
        end
        
        function SetFigVisible(fig, alwaysOnTop, doSameScreen)
            if nargin<3
                doSameScreen=true;
                if nargin<2
                    alwaysOnTop=false;
                end
            end
            oldOp=Gui.GetPosition(fig, 'pixels', true);
            if doSameScreen
                oldOp=Gui.RepositionOnSameScreenIfRequired(oldOp);
                Gui.SetPosition(fig, 'pixels', oldOp, true);
            else
                Gui.FitFigToScreen(fig);
            end
            if ispc || 1==size(get(0, 'MonitorPositions'), 1)
                set(fig, 'visible', 'on');
                if alwaysOnTop
                    drawnow;
                    javaMethodEDT('setAlwaysOnTop',Gui.JWindow(fig), true);
                end
                return;
            end
            set(fig, 'visible', 'on');
            newOp=Gui.GetPosition(fig, 'pixels', true);
            if ~isequal(oldOp(3:end), newOp(3:end))
                %stop growing windows!
                newOp(3)=oldOp(3);
                newOp(4)=oldOp(4);
                Gui.SetPosition(fig, 'pixels', oldOp, true);
            end
            if verLessThan('matlab', '9.2')
                drawnow;
                MatBasics.RunLater(@(h,e)fixPosition(), .15);
            end
            function fixPosition
                try
                    op=oldOp;
                    newOp=Gui.GetOuterPixels(fig);
                    drawnow;
                    if ~isequal(oldOp, newOp)
                        Gui.SetPixels(fig, oldOp, 'outerPosition')
                        drawnow;
                    end
                    if alwaysOnTop
                        javaMethodEDT('setAlwaysOnTop',Gui.JWindow(fig), true);
                    end
                catch 
                    
                end
            end
        end
        
        function [newFigPos, newScrPos, refitToScr]=...
                RepositionOnSameScreenIfRequired(...
                oldFigPos, isProp, mainFigProp)
            if nargin<3
                mainFigProp=Gui.PROP_SAME_SCR2;
                if nargin<2
                    isProp=Gui.PROP_SAME_SCR1;
                end
            end
            if ~isnumeric(oldFigPos) || length(oldFigPos) ~= 4
                fig_=oldFigPos;
                oldFigPos=get(oldFigPos, 'OuterPosition');
            else
                fig_=[];
            end
            app=BasicMap.Global;
            changedScreens=false;
            newFigPos=oldFigPos;
            if app.is(isProp, false)
                mainFig=str2double(app.get( mainFigProp));
                if ishandle(mainFig)
                    [num1,~,otherFigScrPos]=Gui.FindScreen(oldFigPos);
                    mainFigPos=get(mainFig, 'OuterPosition');
                    [num2, ~, mainFigScreen]=Gui.FindScreen(mainFigPos);
                    if num1 ~= num2
                        xDif=oldFigPos(1)-otherFigScrPos(1);
                        yDif=oldFigPos(2)-otherFigScrPos(2);
                        tempPos=[mainFigScreen(1)+xDif, mainFigScreen(2)+yDif, ...
                            oldFigPos(3), oldFigPos(4)];
                        num1=Gui.FindScreen(tempPos);
                        if num1== num2
                            newFigPos=tempPos;
                        else
                            newFigPos=[mainFigScreen(1),...
                                mainFigScreen(2), oldFigPos(3), ...
                                oldFigPos(4)];
                        end
                        changedScreens=true;
                    end
                end
            end
            [ok, ~, ~, scrPos, isDefault]=Gui.OnScreen(newFigPos);
            if ispc
                bottomMargin=60;
                topMargin=90;
            else
                bottomMargin=100;
                topMargin=50;
            end
            if ~isDefault % not on screen with dock on bottom
                bottomMargin=2;
            end
            if ok
                posY=newFigPos(2);
                highEnough=scrPos(2)+(scrPos(4)-(topMargin+newFigPos(4)));
                if ispc  % sticky top maximizer is more 
                         % dangerous than dock bottom
                    if posY>highEnough
                        posY=highEnough;
                    elseif posY<scrPos(2)+bottomMargin
                        posY=scrPos(2)+bottomMargin;
                    end
                else
                    if posY<scrPos(2)+bottomMargin
                        posY=scrPos(2)+bottomMargin;
                    elseif posY>highEnough
                        posY=highEnough;
                    end
                end
                newFigPos=[newFigPos(1), posY, newFigPos(3), newFigPos(4)];
            else
                newFigPos=[10, bottomMargin, newFigPos(3), newFigPos(4)];
            end
            [newFigPos, refitToScr, scrPos]=Gui.FitToScreen(newFigPos);
            if changedScreens
                newScrPos=scrPos;
            else
                newScrPos=[];
            end
            if ~isequal(oldFigPos, newFigPos)
                if ~isempty(fig_)
                    set(fig_, 'OuterPosition', newFigPos);
                end
            end
        end
        
        function op=OuterPositionArg(op)
            if ischar(op)
                op=str2num(op);
            elseif ~isnumeric(op)
                u=get(op,'units');
                set(op,'units','pixels');
                fg=op;
                op=get(op, 'OuterPosition');
                set(fg,'units',u);
            end
        end
        
        function figs=CloseFigs(figs, instance)
            N=length(figs);
            for i=1:N
                try
                    if nargin<2
                        if ishandle(figs{i})
                            close(figs{i});
                            delete(figs{i});
                        end
                    else
                        if isequal(instance, figs{i})
                            figs(i)=[];
                            if ishandle(instance)
                                close(figs{i});
                                delete(instance);
                            end
                            return;
                        end
                    end
                catch ex
                    disp(ex);
                end
            end
        end
        
        function [num, percentOnScreen, scrPos, isDefault, quadrant]=...
                FindScreen(fig_, useJavaIdx)
            if nargin<2
                useJavaIdx=false;
                if nargin<1
                    fig_=[];
                end
            end
            screens=get(0, 'MonitorPositions');
            percentOnScreen=0;
            if isempty(fig_)
                num=1;
                scrPos=screens(1,:);
                isDefault=true;
                quadrant=[];
                return;
            end
            p1=Gui.OuterPositionArg(fig_);
            num=0;
            scrPos=[];
            defaultIdx=1;
            sz=size(screens);
            N=sz(1);
            if isempty(p1)
                isDefault=false;
                scrPos=screens(1,:);
                quadrant={};
                return;
            end
            if N>1
                for i=1:N
                    if screens(1, 1)==1 && screens(1,2)==1
                        defaultIdx=i;
                        break;
                    end
                end
                idx=0;
                for i=N:-1:1
                    idx=idx+1;
                    p2=screens(i,:);
                    o=Gui.GetPositionOverlap(p1,p2);
                    if o>percentOnScreen
                        percentOnScreen=o;
                        if ~useJavaIdx
                            num=i;
                        else
                            num=i-1;
                        end
                        scrPos=p2;
                        isDefault=i==defaultIdx;
                    end
                end
            end
            if isempty(scrPos)
                scrPos=screens(defaultIdx,:);
                percentOnScreen=Gui.GetPositionOverlap(p1,scrPos);
                isDefault=true;
                if percentOnScreen>.4
                    if ~useJavaIdx
                        num=defaultIdx;
                    else
                        num=defaultIdx-1;
                    end
                end
            end
            if nargout>4
               quadrant=Gui.GetQuadrant(fig_, scrPos);
            end
        end

        function quadrant=GetQuadrant(op, scrPos)
            p1=Gui.OuterPositionArg(op);
            q=cell(4,2);
            corners=zeros(4,4);
            width=scrPos(3)/2;
            height=scrPos(4)/2;
            corners(1,:)=[scrPos(1) scrPos(2) width height];
            q{1,1}='south';
            q{1,2}='west';
            corners(2,:)=[scrPos(1) scrPos(2)+height width height];
            q{2, 1}='north';
            q{2, 2}='west';
            corners(3,:)=[scrPos(1)+width scrPos(2) width height];
            q{3,1}='south';
            q{3,2}='east';
            corners(4,:)=[scrPos(1)+width scrPos(2)+height width height];
            q{4, 1}='north';
            q{4, 2}='east';
            percentInCorner=0;
            idx=0;
            for i=1:4
                p2=corners(i,:);
                o=Gui.GetPositionOverlap(p1,p2);
                if o>percentInCorner
                    percentInCorner=o;
                    idx=i;
                end
            end
            if idx>0
                quadrant=q(idx,:);
            else
                quadrant={};
            end
        end
        
        function ok=IsOnDefaultScreen(javaWnd)
            ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
            physicalScreens=ge.getScreenDevices;
            N=length(physicalScreens);
            if N==1
                ok=true;
            else
                ok=false;
                for i=1:N
                    pe=physicalScreens(i).getDefaultConfiguration.getBounds;
                    if pe.y==0 && pe.x==0
                        x=javaWnd.getX;
                        if x>=0 && x<=pe.width
                            y=javaWnd.getY;
                            if y>=0 && y<=pe.height
                                ok=true;
                            end
                        end
                    end
                end
            end
        end
        
        function [idx, perc, N, scrJava, scrMl]=FindJavaScreenForJavaWnd(javaWnd)
            ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
            physicalScreens=ge.getScreenDevices;
            N=length(physicalScreens);
            idx=1;
            perc=100;
            if N>1
                xy=javaWnd.getLocation;
                sz=javaWnd.getSize;
                p1=[xy.x xy.y sz.width sz.height];
                percs=zeros(1,N);
                for i=1:N
                    pe=physicalScreens(i).getDefaultConfiguration.getBounds;
                    p2=[pe.x pe.y pe.width pe.height];
                    percs(i)=Gui.GetPositionOverlap(p1, p2);
                end
                [perc,idx]=max(percs);
            end
            scrJava=physicalScreens(idx).getDefaultConfiguration.getBounds;
            scrMls=get(0, 'MonitorPositions');
            if idx>size(scrMls, 1)
                scrMl=scrMls(1,:);
            else
                scrMl=scrMls(idx, :);
            end
        end
        
        function b=GetJavaScreenBounds(idx)
            ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
            physicalScreens=ge.getScreenDevices;
            b=physicalScreens(idx).getDefaultConfiguration.getBounds;
        end
        
        function op=GetJavaWndBounds(J)
           op=[J.getX J.getY J.getWidth javaWind.GetHeight];
        end
        
        function AskYesOrNoNonModal(question, ...
                fncCheck, pauseSecs, where, parentWindow, ...
                title_, defaultIsYes, property, rememberId)
            if nargin<9
                rememberId=[];
                if nargin<8
                    property=[];
                    if nargin<7
                        defaultIsYes=true;
                        if nargin<6
                            title_='Confirm...';
                            if nargin<5
                                parentWindow=gca;
                            if nargin<4
                                where='Center';
                                if nargin<3
                                    pauseSecs=0;
                                    if nargin<2
                                        checkFnc=[];
                                    end
                                end
                            end
                        end
                    end
                end
                end
            end
            if Gui.IsFigure(parentWindow)
                try
                    parentWindow=Gui.JFrame(parentWindow);
                catch ex
                    ex.getReport
                end
            end
            if isempty(fncCheck)
                fncCheck=@check;
            end
            askYesOrNo(struct(...
                'javaWindow', parentWindow,...
                'pauseSecs', pauseSecs,...
                'msg', question, 'modal', false, ...
                'checkFnc', fncCheck), title_, where, ...
                defaultIsYes, rememberId, property);
            function ok=check(jd, answ)
                fprintf('TestMisc.checkFnc got "%s"\n\tfrom window titled "%s"\n',...
                    answ, char(jd.getTitle));
                ok=true;
            end
        
        end
        function jd=MsgAtTopScreen(ttl, pauseSecs)
            if nargin<2
                pauseSecs=8;
            end
            if startsWith(ttl, 'Specify ')
                jd=msg(ttl, pauseSecs, 'North east++',...
                    ttl(9:end));
            else
                jd=msg(ttl, pauseSecs, 'North east++');
            end
            jd.setAlwaysOnTop(true);
            fig=get(0, 'currentFigure');
            if ~isempty(fig)
                [~,~,~,~,pe]=Gui.FindJavaScreen(fig);
            else
                pe=Gui.GetDefaultJavaScreen;
            end
            jd.setLocation(pe.x+(pe.width/2)-100, pe.y);
        end
        
        function pe=GetDefaultJavaScreen
                        ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
            physicalScreens=ge.getScreenDevices;
            pe=physicalScreens(1).getDefaultConfiguration.getBounds;
        end
        
        function [num, percentOnScr, scrMl, isDefault, scrJava]=...
                FindJavaScreen(fig, useJavaIdx)
            if nargin<2
                useJavaIdx=false;
            end
            scrJava=[];
            num=0;
            scrMl=[];
            if ischar(fig)
                fig=str2num(fig);
            end
            if length(fig)~=4
                u=get(fig,'units');
                set(fig,'units','pixels');
                p1=get(fig, 'OuterPosition');
                set(fig,'units',u);
            else
                p1=fig;
            end
            ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
            physicalScreens=ge.getScreenDevices;
            percentOnScr=0;
            N=length(physicalScreens);            
            for i=1:N
                pe=physicalScreens(i).getDefaultConfiguration.getBounds;
                if pe.y==0 && pe.x==0
                    defaultIdx=i;
                    defaultPe=pe;
                    break;
                end
            end
            idx=0;
            for i=N:-1:1
                idx=idx+1;
                if i==defaultIdx
                    pe=defaultPe;
                    p2=[pe.x, pe.y, pe.width, pe.height];                    
                else
                    pe=physicalScreens(i).getDefaultConfiguration.getBounds;
                    if pe.y<0
                        y=defaultPe.height-(pe.height+pe.y);
                    else
                        y=(defaultPe.height-pe.y)-pe.height;
                    end
                    p2=[pe.x, y, pe.width, pe.height];
                end
                o=Gui.GetPositionOverlap(p1,p2);
                if o>percentOnScr
                    scrJava=pe;
                    percentOnScr=o;
                    if ~useJavaIdx
                        num=i;
                    else
                        num=i-1;
                    end
                    scrMl=p2;
                    isDefault=i==defaultIdx;
                end
            end
            if isempty(scrMl)
                scrMl=[1, 1, defaultPe.width,defaultPe.height];
                percentOnScr=Gui.GetPositionOverlap(p1, scrMl);
                isDefault=true;
                scrJava=pe;
            end
        end
        
        function [hasHighDef, accepted]=hasPcHighDefinitionAProblem(...
                maxWidth, maxHeight, tellUser)
            if nargin<2
                maxHeight=2000;
                if nargin<1
                    maxWidth=2500;
                end
            end
            accepted=true;
            hasHighDef=false;
            if ispc
                matLabScreenss=get(0, 'MonitorPositions');
                ge=java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment;
                physicalScreens=ge.getScreenDevices;
                percentOnScreen=0;
                N=length(physicalScreens);
                for i=1:N
                    pe=physicalScreens(i).getDefaultConfiguration.getBounds;
                    if pe.height >maxHeight || pe.width>maxWidth
                        hasHighDef=true;
                        if nargin<3 || tellUser
                        msg([...
                            '<html>The high definition '...
                            'display feature on Microsoft  <br>'...
                            'Windows is <b>not optimal</b> for AutoGate.  In fact,'...
                            '<br><i>many</i> software products provide '...
                            'no support <br>for it:  e.g. FlowJo .. even '...
                            'Microsoft''s Internet  <br>Explorer (believe '...
                            'it or not) !!<br>'...
                            '<br>So some of AutoGate may be less easy to read '...
                            ' <br>unless you use Microsoft''s control panel'...
                            ' to <br>'...
                            'lower the resolution to 1920x1200 using 125%'...
                            '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>'...
                            'text size.<br><br>If you continue you may have problems' ...
                            '<hr><br></html>'],20,  'east');
                        end
                        break;
                    end
                end
            end
        end
        
        function [ok, percentOnScr, scrNum, scrPos, isDefault]=OnScreen(fig)
            [scrNum, percentOnScr,scrPos, isDefault]=Gui.FindScreen(fig);
            if percentOnScr<.11
                ok=false;
            else
                ok=scrNum>0;
            end
        end
        
        function [op2, changed]=FitFigToScreen(fig)
            t=get(fig, 'units');
            set(fig, 'units', 'pixels');
            op1=get(fig,'outerposition');
            [op2,changed]=Gui.FitToScreen(op1);
            if changed
                set(fig,'outerposition', op2);
            end
            set(fig, 'units', t);
        end

        function FitJavaChildWndToParentWndScreen(parent, child)
            [scrIdx, percentOnScr, numScreens, scrJava, scrMl]=...
                Gui.FindJavaScreenForJavaWnd(parent);
            size=child.getSize;
            x=child.getX;
            y=child.getY;
            mlY=javaPointToMatLab(x,y);
            pos=[floor(x) (floor(mlY-size.height)) size.width size.height];
            percentOnScr=Gui.GetPositionOverlap(pos, scrMl);
            if (percentOnScr<.98)
                if x+size.width>scrJava.x+scrJava.width
                    x=(scrJava.x+scrJava.width)-size.width;
                elseif x<scrJava.x
                    x=scrJava.x;
                end
                if y<scrJava.y
                    y=scrJava.y;
                elseif y+size.height>scrJava.y+scrJava.height
                    y=(scrJava.y+scrJava.height)-(size.height+10);
                end
                child.setLocation(x, y);
            end
            if x<scrJava.x && size.width>scrJava.width
                child.setLocation(scrJava.x+8, y);
                pw=child.getPreferredSize;
                pw.width=scrJava.width-17;
                child.setPreferredSize(pw);
                child.setSize(pw);
            end
        end
        function FitJavaWnd(wnd, parentWnd)
            childRect=wnd.getBounds;
            if nargin<2 || isempty(parentWnd)
                parentRect=wnd.getParent.getBounds;
            else
                parentRect=parentWnd.getBounds;
            end
            [x,y]=Gui.FitJava(parentRect, childRect);
            p=java.awt.Point(x,y);
            wnd.setLocation(p);
        end
        
        function [x,y]=FitJava(parentRect, childRect)
            x=childRect.x;
            y=childRect.y;
            pW=parentRect.x+parentRect.width;
            cW=x+childRect.width;
            pH=parentRect.y+parentRect.height;
            cH=y+childRect.height;
            if cW>pW
                x=x-(cW-pW);
            end
            if x<parentRect.x
                x=parentRect.x;
            end
            if cH>pH
                y=y-(cH-pH);
            end
            if y<parentRect.y
                y=parentRect.y;
            end
        end

        function [pos, changed, scrPos]=FitToScreen(figPos)
            [~, percentOnScr,scrPos]=Gui.FindScreen(figPos);
            pos=figPos;
            if percentOnScr<.98
                if figPos(1)<scrPos(1)
                    pos(1)=scrPos(1);
                elseif figPos(1)+figPos(3)>scrPos(1)+scrPos(3)
                    pos(1)=scrPos(3)-figPos(3)+scrPos(1);
                end
                if figPos(2)<scrPos(2)
                    pos(2)=scrPos(2);
                elseif figPos(2)+figPos(4)>scrPos(2)+scrPos(4)
                    pos(2)=scrPos(4)-figPos(4)+scrPos(2);
                end                
                changed=true;
            else
                changed=false;
            end
        end
        
        function setCheckbox(chb, yes)
            if yes
                val = get(chb,'Max');
            else
                val = get(chb,'Min');
            end
            set(chb, 'Value', val);
        end
        
        function ok=isVisible(cntrl)
            ok=strcmp(get(cntrl,'Visible'), 'on');
        end

        function ok=areAllVisible(obj)
            ok=Gui.isVisible(obj);
            while(ok)
                obj=get(obj, 'Parent');
                if isempty(obj)
                    break;
                end
                ok=Gui.isVisible(obj);
            end
        end

        function ok=isChecked(chb)
            ok=get(chb,'Value') == get(chb, 'Max');
        end
        
        function changeWidth(figure, newPosition, designProps)
            c=Gui.denormalize(figure);
            if nargin==3
                Gui.resizeWidth(figure, newPosition, designProps);
            else
                Gui.resizeWidth(figure, newPosition);
            end
            Gui.normalize(c);
        end
        
        function FixWidthHeight(containee,container, widthPixels, ...
                heightPixels, adjustX, adjustY)
            tunits=get(containee, 'units');
            if ~strcmp('normalized', tunits)
                set(containee, 'units', 'normalized');
            end
            p1=get(containee, 'position');
            p2=Gui.GetPixels(container);
            if p1(3)*p2(3)~=widthPixels
                if adjustX
                    dif=floor(widthPixels-(p1(3)*p2(3)));
                    lefter=dif/widthPixels/2;
                    if ispc
                        lefter=lefter/2;
                    end
                    p1(1)=p1(1)-lefter;
                end
                p1(3)=widthPixels/p2(3);
                set(containee, 'position', p1);
            end
            if p1(4)*p2(4)~=heightPixels
                if adjustY
                    dif=floor(heightPixels-(p1(4)*p2(4)));
                    lower=dif/heightPixels/2;
                    p1(2)=p1(2)-lower;
                end
                p1(4)=heightPixels/p2(4);
                set(containee, 'position', p1);
            end
            if ~strcmp('normalized', tunits)
                set(containee, 'units', tunits);
            end
        end
        function resizeWidth(figure, newPosition, ...
                designProps)
            p=get(figure, 'Position');
            if nargin>2
                designedPosName=Gui.DesignPositionName;
                designedPos=designProps.get(designedPosName);
                % set new Position as n
%                designed position
                designProps.set(designedPosName, newPosition);
                wFactor=p(3)/designedPos(3);
                width=wFactor*newPosition(3);
                designProps.set('manualResizing', 'false');
            else
                width=newPosition(3);
            end
            set(figure, 'Position', [p(1) p(2) width p(4)] );
            if nargin>2
                drawnow;
                designProps.set('manualResizing', 'true');
            end
        end
        
        function [wFactor, hFactor]=getResizeFactors(refObj, ...
                designProps)
            designedPosName=Gui.DesignPositionName;
            designedPos=designProps.get(designedPosName);
            refP=get(refObj, 'Position');
            wFactor=refP(3)/designedPos(3);
            hFactor=refP(4)/designedPos(4);
        end

        function highlightStep(steps, step, hideHigherSteps, refocus)
            for i=1:step-1
                set(steps(i).obj, 'Visible', 'On');
                set(steps(i).obj, 'ForegroundColor', 'Black');
                set(steps(i).obj, 'FontWeight', 'n');
                set(steps(i).obj, 'UserData', false);
            end
            set(steps(step).obj, 'Visible', 'On');
            set(steps(step).obj, 'ForegroundColor', 'Blue');
            set(steps(step).obj, 'UserData', true);
            set(steps(step).obj, 'FontWeight', 'b');
            for i=step+1:length(steps)
                if hideHigherSteps
                    set(steps(i).obj, 'Visible', 'Off');
                else
                    set(steps(i).obj, 'ForegroundColor', 'Black');
                end
                set(steps(i).obj, 'UserData', false);
            end
            if nargin<4 || refocus
                if steps(step).focus ~= 0 && ...
                        Gui.areAllVisible(steps(step).focus)
                    uicontrol( steps(step).focus );
                end
            end
        end
        
        function CloseFig(fig)
            if ~isempty(fig)
                if ishandle(fig)
                    if Gui.IsVisible(fig)
                        close(fig);
                    end
                    delete(fig);
                end
            end
        end
        
        function windowCloser(hObject, eventData, ~)
            [ok,key]=Gui.HeardTheCloseKey(eventData);
            if ok
                disp(['Closing window because the user pressed ' key]);
                delete(hObject);
            end
        end
        
        function [ok,key]=HeardTheCloseKey(eventData)
            ok=false;
            if length(eventData.Modifier)==1
                key=[eventData.Modifier{1} '-' eventData.Key ];
                if strcmpi(eventData.Modifier{1},'command')
                    if eventData.Key=='w'
                        ok=true;
                    end                    
                elseif strcmpi(eventData.Modifier{1}, 'alt')
                    if strcmpi(eventData.Key, 'F4')
                        ok=true;
                    end
                end
            elseif strcmpi(eventData.Key, 'escape')
                %ok=true;                
                key=[eventData.Key ];
            else
                key='';
            end
        end
        
        function hWait=ProgressBar(name, allowUserToCancel)
            p2=[];
            associatedWindow=get(0,'currentFigure');
            if ~isempty(associatedWindow)
                units=get(associatedWindow, 'units');
                set(associatedWindow, 'units', 'pixels');
                p1=get(associatedWindow, 'position');
                set(associatedWindow, 'units', units);
                width=length(name)*10;
                if width<360
                    width=360;
                end
                p2=[floor(p1(1)+(p1(3)/3)), p1(2), width, 75];
            end
            if nargin==1 || ~allowUserToCancel 
                if isempty(p2)
                    hWait=waitbar(0, '', 'Name', name);
                else
                    hWait=waitbar(0, '', 'Name', name, 'units', 'pixels', 'Position', p2);
                    set(hWait, 'position', p2);
                end
            else
                if isempty(p2)
                    hWait=waitbar(0, '', 'Name', name,...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
                else
                    hWait=waitbar(0, '', 'Name', name, 'units', 'pixels', ...
                        'Position', p2,...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
                    set(hWait, 'position', p2);
                end
                setappdata(hWait,'canceling',0);            
            end
            hw=findobj(hWait,'Type','Patch');
            set(hw,'EdgeColor',[0 1 0],'FaceColor',[0 1 0]);
        end
        
        function c=denormalize(figure)
            c=findall(figure, 'Units', 'normalized');
            N=length(c);
            for i=1:N
                obj=c(i);
                set(obj, 'Units', 'pixels');
            end
        end
        
        function normalize(c)
            N=length(c);
            for i=1:N
                obj=c(i);
                if ishandle(obj)
                    set(obj, 'Units', 'normalized');
                end
            end
        end
        
        function position=normalized2Data(theAxes, ...
                normalizedPosition, stretch)
            p=normalizedPosition;
            xlim=get(theAxes, 'xlim');
            xR=xlim(2)-xlim(1);
            ylim=get(theAxes, 'ylim');
            yR=ylim(2)-ylim(1);
            x=xlim(1)+(p(1)*xR);
            y=ylim(1)+(p(2)*yR);
            w=p(3)*xR;
            h=p(4)*yR;
            if nargin>2
                x=x*stretch(1);
                y=y*stretch(2);
                w=w*stretch(3);
                h=h*stretch(4);
            end
            position=[x, y, w, h];
        end
        
        function [ax,fig]=Axes(fig)
            [ax, fig]=Gui.GetOrCreateAxes(fig);
        end
        
        function [ax,fig]=GetOrCreateAxes(fig)
            if nargin<1
                fig=[];
            end
            if isempty(fig)
                fig=get(0, 'currentFigure');
                if isempty(fig)
                    fig=figure;
                end
            end
            ax=get(fig, 'CurrentAxes');
            if isempty(ax)
                ax=axes('parent', fig);
            end
        end
        
        function hide(axes, varargin)
            objs2=get(axes,'Children');
            for i=1:length(objs2)
                t=get(objs2(i), 'type');
                if strcmp(t, 'uipanel')
                    Gui.hide(objs2(i));
                else
                    set(t, 'visible', 'off');
                end
            end
            set(axes,'visible', 'off');
            for i=1:length(varargin)
                obj=varargin{i};
                set(obj, 'visible', 'off');
            end
        end
        
        function show(axes, varargin)
            if nargin>1
                objs1=cell2mat(varargin);
            else
                objs1=[];
            end
            objs2=get(axes,'Children');
            for i=1:length(objs2)
                t=get(objs2(i), 'type');
                if strcmp(t, 'uipanel')
                    Gui.show(objs2(i));
                end
            end
            hs = [axes, objs1, objs2'];
            set(hs,'visible', 'on');
        end
        
        function removeToolbarExcess(figure, removeRotate3D, removeEdit)
            if nargin<3
                removeEdit=true;
                if nargin<2
                    removeRotate3D=true;
                end
            end
            Gui.removeForTooltip(figure, 'Save Figure');
            if removeRotate3D
                Gui.removeForTooltip(figure, 'Rotate 3D');
            end
            if removeEdit
                Gui.removeForTooltip(figure, 'Edit Plot');
            end
            set(figure, 'DockControls', 'off');
            Gui.removeForTooltip(figure, 'Data Cursor');
            Gui.removeForTooltip(figure, 'New Figure');
            Gui.removeForTooltip(figure, 'Open File');
            Gui.removeForTooltip(figure, 'Link Plot');
            Gui.removeForTooltip(figure, 'Insert Legend');
            Gui.removeForTooltip(figure, 'Brush/Select Data');
            Gui.removeForTooltip(figure, 'Insert Colorbar');
            Gui.removeForTooltip(figure, 'Hide Plot Tools');
            Gui.removeForTooltip(figure, 'Show Plot Tools and Dock Figure');
            Gui.removeForTooltip(figure, 'Link/Unlink Plot');
            Gui.removeForTooltip(figure, 'Open Property Inspector');            
        end
        function setVisiblePrint2Pan(fig, ok)
            if ok
                o='on';
            else
                o='off';
            end
            set(findall(fig, 'Tag', 'Standard.PrintFigure'), 'visible', o);
            set(findall(fig, 'Tag', 'Exploration.ZoomIn'), 'visible', o);
            set(findall(fig, 'Tag', 'Exploration.ZoomOut'), 'visible', o);
            set(findall(fig, 'Tag', 'Exploration.Pan'), 'visible', o);
        end
        function removeForTooltip(figure, tooltip)
            button = findall(figure,'ToolTipString', tooltip);
            set(button, 'separator', 'off');
            %set(button,'Visible','Off');
            delete(button);
        end

        function [fnc, mnu]=GetMenuCallback(f, tag)
            %get all tags with this command
            %get(findall(f), 'tag')
            if nargin<2
                %tag='figWinMenuMoreWindows';
                tag='figMenuFileSaveAs';
            end
            mnu=findall(f, 'tag', tag);
            if ~isempty(mnu)
                fnc=get(mnu, 'Callback');
            else
                fnc=[];
            end
        end
        
        function [fnc, button]=GetCallback(figure, tip)
            if nargin<2
                tip='Print Figure';
            end
            button = findall(figure,'ToolTipString', tip);
            if ~isempty(button)
                fnc=get(button, 'ClickedCallback');
            else
                button=[];
                fnc=[];
            end
        end
        
        function FollowWindow(follower, followed, where, closeToo)
            if iscell(followed)
                if length(followed)>2
                    closeToo=followed{3};
                end
                where=followed{2};
                followed=followed{1};
            end
            if isempty(followed) || isempty(follower) ...
                    || ~ishandle(followed) || ~ishandle(follower)
                return;
            end
            Gui.Locate (follower, followed, where);
            jw=Gui.JWindow(followed);
            set(jw, 'ComponentMovedCallback',@(h,e)moved());
            if closeToo
                priorCloseFollowed=get(followed, 'CloseRequestFcn');
                set(followed, 'CloseRequestFcn', @hushFollowed);
            end
            priorCloseFollower=get(follower, 'CloseRequestFcn');
            set(follower, 'CloseRequestFcn', @hushFollower);
            
            function hushFollower(h,e)
                try
                    if isa(priorCloseFollower, 'function_handle')
                        feval(priorCloseFollower, h,e);
                    elseif ischar(priorCloseFollower)
                        feval(priorCloseFollower);
                    end
                catch ex
                    ex.getReport
                end
                if ishandle(followed)
                    figure(followed);
                end
            end
            
            function hushFollowed(h,e)
                if ishandle(follower) 
                    %set(follower, 'CloseRequestFcn', priorCloseFollower);
                    close(follower);
                end
                try
                    if isa(priorCloseFollowed, 'function_handle')
                        feval(priorCloseFollowed, h,e);
                    elseif ischar(priorCloseFollowed)
                        feval(priorCloseFollowed);
                    end
                catch ex
                    ex.getReport
                end
                if ishandle(followed) && isvalid(followed)
                    delete(followed);
                end
            end
            
            function moved()
                if ishandle(follower)
                    spot=get(followed, 'position');
                    MatBasics.RunLater(@(h,e)relocate(spot), .25);
                end
            end
            
            function relocate(spot)
                if ishandle(follower)
                    pos=get(followed, 'position');
                    if isequal(pos, spot)
                        Gui.Locate(follower, followed, where);
                        figure(follower);
                        figure(followed);
                    else
                        %disp('still moving');
                    end
                end
            end
                        
        end
        
        function fnc=SetCallback(figure, newFnc, tip)
            if nargin<3
                tip='Print Figure';
            end
            button = findall(figure,'ToolTipString', tip);
            if ~isempty(button)
                fnc=get(button, 'ClickedCallback');
                if ~isempty(fnc)
                    set(button, 'ClickedCallback', newFnc);
                end
            else
                fnc=[];
            end
        end
        
        function value=Get(hObject)
            style=get(hObject, 'style');
            if strcmp(style, 'edit')
                value=get(hObject, 'String');                
            else
                if strcmp(style, 'slider') || strcmp(style, 'popupmenu')
                    value=get(hObject,'value');
                elseif strcmp(style, 'checkbox')
                    value=Gui.isChecked(hObject);
                end
            end
        end
        
        
        function SetToRight(leftFig, rightFig, leftMustMove,...
                ifGreaterThan)
            if isempty(leftFig) || isempty(rightFig)
                return;
            end
            if Gui.isVisible(leftFig) && ~Gui.isVisible(rightFig)
                leftMustMove=false;
            elseif Gui.isVisible(rightFig) && ~Gui.isVisible(leftFig)
                leftMustMove=true;
            end
            
            leftUnits=get(leftFig, 'Units');
            set(leftFig, 'Units', 'pixels');
            leftPos=get(leftFig, 'OuterPosition');
            rightUnits=get(rightFig, 'units');
            set(rightFig, 'units', 'pixels');
            rightPos=get(rightFig, 'OuterPosition');
            if ~leftMustMove
                [~, ~, ~, leftScreen]=Gui.OnScreen(leftFig);
                rightSideOfLeftScreen=leftScreen(1)+leftScreen(3);
                old=rightPos;
                if leftPos(1)+leftPos(3)+rightPos(3)<=rightSideOfLeftScreen
                    rightPos(1)=leftPos(1)+leftPos(3)+11;
                else
                    rightPos(1)=rightSideOfLeftScreen-rightPos(3);
                end
                if leftPos(2)+leftPos(4)<rightPos(4)
                    rightPos(2)=leftScreen(2)+2;
                else
                    rightPos(2)=leftPos(2)+leftPos(4)-rightPos(4);
                end
                if abs(old(1)-rightPos(1))>ifGreaterThan ...
                        ||abs(old(2)-rightPos(2))>ifGreaterThan
                    rightPos2=Gui.FitToScreen(rightPos);
                    set(rightFig, 'OuterPosition', rightPos2);
                end
            else
                [~, ~, ~, rightScreen]=Gui.OnScreen(rightFig);
                old=leftPos;
                if rightPos(1)-leftPos(3)>0
                    leftPos(1)=rightPos(1)-leftPos(3);
                else
                    leftPos(1)=rightScreen(1);
                end
                if rightPos(2)+rightPos(4)<leftPos(4)
                    leftPos(2)=rightScreen(2)+39;
                else
                    leftPos(2)=rightPos(2)+rightPos(4)-leftPos(4);
                end
                if leftPos(2) < rightScreen(2)+39
                    leftPos(2)=rightScreen(2)+39;
                end
                if abs(old(1)-leftPos(1))>ifGreaterThan ...
                        ||abs(old(2)-leftPos(2))>ifGreaterThan 
                    set(leftFig, 'OuterPosition', leftPos);
                end
            end
            set(leftFig, 'units', leftUnits);
            set(rightFig, 'units', rightUnits);
        end
        
        function SetToScreenCorner(figure, corner)
            set(0,'units','pixels');
            screenSize=get(0,'ScreenSize');
            units=get(figure, 'Units');
            set(figure, 'Units', 'pixels');
            pos=get(figure, 'Position');
            if strcmpi(corner, 'topLeft') || strcmpi(corner, 'topRight')
                if pos(4)>screenSize(4)
                    pos(2)=0;
                else
                    pos(2)=screenSize(4)-pos(4);
                end
            else
                pos(2)=0;
            end
            if strcmpi(corner, 'topRight') || strcmpi(corner, 'bottomRight')
                if pos(3)>screenSize(3)
                    pos(1)=0;
                else
                    pos(1)=screenSize(3)-pos(3);
                end
            else
                pos(1)=0;
            end
            set(figure, 'Position', pos);
            set(figure, 'units', units);
        end
        
        function icon=setIconWhiteBlackAs(javaObj, file, folder, ...
                asWhite, asBlack)
            cdata=Gui.imReadWhiteBlackAs(file, folder, asWhite, asBlack);
            icon=javax.swing.ImageIcon(im2java(cdata));
            if ~isempty(javaObj)
                javaObj.setIcon(icon);
            end            
        end
        
        function cdata=imReadWhiteBlackAs(file, folder, asWhite, asBlack, white, black)
            if nargin>1 && ~isempty(folder)
                file=fullfile(folder,file);
            end
            if nargin<6
                black=[0 0 0];
                if nargin<5
                    white=[1 1 1];
                    if nargin<3
                        asWhite=[NaN NaN  NaN];
                    end
                end
            end
            try
            [cdata, map]=imread(file);
            if ~isempty(map)
                N=size(map,2);
                for i=1:N
                    map(map(:,i)==white(i),i)=asWhite(i);
                    if ~isempty(asBlack)
                        map(map(:,i)==black(i),i)=asBlack(i);
                    end
                end
                cdata = ind2rgb(cdata,map);
            else
                if isempty(asBlack)
                    cdata=Gui.ConvertColors(im2double(cdata),white,asWhite);
                else
                    cdata=Gui.ConvertColors(im2double(cdata), white, ...
                        asWhite, black, asBlack);
                end
            end
            catch e
                disp(e.message);
                cdata=[];
            end
        end
        function cdata=ConvertColors(cdata, varargin)
            nArgs=length(varargin);
            for arg=1:2:nArgs
                white=varargin{arg};
                asWhite=varargin{arg+1};
                N=size(cdata,3);
                for i=1:N
                    tmp2=cdata(:,:,i);
                    tmp2(find(tmp2==white(i)))=asWhite(i);
                    cdata(:,:,i)=tmp2;
                end
            end
        end
        
        function cdata=imReadAndReColor(file, folder, varargin)
            file=fullfile(folder,file);
            try
                cdata=Gui.ConvertColors2(im2double(imread(file)), varargin{:});
            catch e
                disp(e.message);
                cdata=[];
            end
        end

        function cdata=ConvertColors2(cdata, varargin)
            R=size(cdata,1);
            C=size(cdata, 2);
            nArgs=length(varargin);
            red=cdata(:,:,1);
            green=cdata(:,:,2);
            blue=cdata(:,:,3);
            for arg=1:2:nArgs
                oldClr=varargin{arg};
                newClr=varargin{arg+1};
                l=red(:)==oldClr(1) & ...
                    green(:)==oldClr(2) & ...
                    blue(:)==oldClr(3);
                red(l)=newClr(1);
                green(l)=newClr(2);
                blue(l)=newClr(3);                 
            end
            cdata(:,:,1)=red;
            cdata(:,:,2)=green;
            cdata(:,:,3)=blue;
        end


        function cdata=imReadAndSet(file, folder, fPos, aPos, clr, X, Y)
            file=fullfile(folder,file);
            try
                cdata=imread(file);
                cdata=Gui.SetImg(im2double(cdata), fPos, aPos, clr, X, Y);
            catch e
                disp(e.message);
                cdata=[];
            end
        end
        
        function cdata=SetImg(cdata, fPos, aPos1, clr, X1, Y1)
            R=size(cdata,1);
            C=size(cdata, 2);
            xfactor=C/fPos(3);
            yfactor=R/fPos(4);
            aPos=aPos1*xfactor;
            bottomLeftX=aPos(1)+.001*C;
            topLeftY=R-(aPos(2)+aPos(4));
            bottomLeftY=topLeftY+aPos(4)+.0065*R;
            COLS=round(bottomLeftX+(X1*xfactor));
            ROWS=round(bottomLeftY-(Y1*yfactor));
            red=cdata(:,:,1);
            green=cdata(:,:,2);
            blue=cdata(:,:,3);
            l=unique(sub2ind([R, C], ROWS, COLS));
            black=red(:)<.04 & green(:)<.04 & blue(:)<.22;
            red(l)=clr(1);
            green(l)=clr(2);
            blue(l)=clr(3);
            if xfactor>1.5 || yfactor>1.5
                try
                    xf=round(xfactor)-1;
                    yf=round(yfactor)-1;
                    for c=-xf:xf
                        for r=-yf:yf
                            if r==0 && c==0
                                continue;
                            end
                            COLS=round(bottomLeftX+((X1+c)*xfactor));
                            ROWS=round(bottomLeftY-((Y1+r)*yfactor));
                            l=unique(sub2ind([R, C], ROWS, COLS));
                            red(l)=clr(1);
                            green(l)=clr(2);
                            blue(l)=clr(3);
                        end
                    end
                catch ex
                end
            end
            if any(black)
                red(black)=0;
                green(black)=0;
                blue(black)=0;
            end
            cdata(:,:,1)=red;
            cdata(:,:,2)=green;
            cdata(:,:,3)=blue;
        end

        function cdata=imReadWhiteAs(file,folder, asWhat, white)
            if nargin>1 && ~isempty(folder)
                file=fullfile(folder,file);
            end
            if nargin<4
                white=[1 1 1];
                if nargin<3
                    asWhat=[NaN NaN  NaN];
                end
            end
            try
            [cdata, map]=imread(file);
            if ~isempty(map)
                N=size(map,2);
                for i=1:N
                    map(map(:,i)==white(i),i)=asWhat(i);
                end
                cdata = ind2rgb(cdata,map);
            else
                cdata=im2double(cdata);
                red=cdata(:,:,1);
                green=cdata(:,:,2);
                blue=cdata(:,:,3);
                l=red(:)==white(1) & ...
                    green(:)==white(2) & ...
                    blue(:)==white(3);
                red(l)=asWhat(1);
                green(l)=asWhat(2);
                blue(l)=asWhat(3);
                cdata(:,:,1)=red;
                cdata(:,:,2)=green;
                cdata(:,:,3)=blue;
            end
            catch e
                disp(e.message);
                cdata=[];
            end
        end
        
        function pos=DesignPositionName
            pos='dpos';
        end
        
        function jObj=JBusy(msg, ImgSize)
            if nargin<2
                ImgSize=2;
                if nargin<1
                    msg='Busy';
                end
            end
            iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
            iconsSizeEnums = javaMethodEDT('values',iconsClassName);
            
            SIZE_32x32=iconsSizeEnums(ImgSize); % (1)=16x16
            
            jObj=javaObjectEDT('com.mathworks.widgets.BusyAffordance',...
                SIZE_32x32, msg);
            jObj.setPaintsWhenStopped(true);
        end
        
        function [busy, hObj]=Busy(figure, position, msg, transparent)
            busy=Gui.JBusy(msg);
            [~, hObj]=javacomponent(busy.getComponent,position,figure);
            if nargin>3 && transparent
                drawnow;
                Gui.SetTransparent(busy.getComponent);
            end
        end
        
        function [jl, jsc]=Label(txt, maxW, maxH, forceHeight, forceWidth)
            if nargin==0
                txt='';
            end
            jl=javaObjectEDT('javax.swing.JLabel', txt);
            if nargout>1
                if nargin<3
                    maxH=500;
                    if nargin<2
                        maxW=700;
                    end
                end
                sz=jl.getPreferredSize;
                needed=sz.width>maxW*.99||sz.height>maxH*.99;
                if needed
                    if sz.width>maxW || nargin>4 && forceWidth
                        W=maxW;
                    else
                        W=sz.width;
                    end
                    if sz.height>maxH 
                        H=maxH;
                    else
                        if nargin>3 && forceHeight
                            H=maxH;
                        else
                            H=sz.height;
                        end
                    end
                    jsc=javaObjectEDT('javax.swing.JScrollPane', jl);
                    jsc.setPreferredSize(java.awt.Dimension(W, H))
                else
                    jsc=jl;
                end
            end
        end
            
        function [jScroll, jLbl]=HtmlScrollLabel(html, width, height, app)
            if nargin<4
                app=BasicMap.Global;
                if nargin<3
                    height=400;
                    if nargin<2
                        width=600;
                    end
                end
            end
            if ~startsWith(html, '<html>');
                jLbl=Gui.Label(['<html><body bgcolor="white">' html '</body></html>']);
            else
                jLbl=Gui.Label(html);
            end
            jScroll=Gui.Scroll(jLbl, width, height, app); 
        end
        
        function jScroll=Scroll(cmp, width, height, app)
            jScroll=javaObjectEDT('javax.swing.JScrollPane', cmp);
            if nargin>1
                dim=jScroll.getPreferredSize;
                if nargin<4
                    app=BasicMap.Global;
                end
                if app.highDef
                    width=width*app.toolBarFactor;
                    height=height*app.toolBarFactor;
                end
                if dim.width>width || dim.height > height
                    if dim.width<width
                        width=dim.width;
                    end
                    if dim.height<height
                        height=dim.height;
                    end
                    jScroll.setPreferredSize(java.awt.Dimension(width, height));
                end
            end
        end
        
        function [jl, jpH, jp]=JLabel(fig, center, fl)
                if nargin<2
                    center=true;
                end
            if center
                jAlign=0;
                pAlign=1;
            else
                jAlign=2;
                pAlign=0;
            end
            if nargin<3
                fl=javaObjectEDT('java.awt.FlowLayout', pAlign,2,0);
                fl.setAlignOnBaseline(false);
            end
            jp=javaObjectEDT('javax.swing.JPanel', fl);
            jl=javaObjectEDT('javax.swing.JLabel');
            if nargin<3
                jp.add(jl);
            end
            jl.setHorizontalAlignment(jAlign);
            [jp, jpH]=javacomponent(jp, [0,0,1,1]);
            set(jpH, 'parent', fig);
            figBg=get(fig, 'Color');
            jp.setBackground(java.awt.Color(figBg(1), figBg(2), figBg(3)));
            jl.setBackground(java.awt.Color(figBg(1), figBg(2), figBg(3)));
            font=jl.getFont;
            if ispc
                if BasicMap.Global.toolBarFactor>0
                    jl.setFont(java.awt.Font(ClusterPlotter.FONT, font.getStyle, 20));
                else
                    jl.setFont(java.awt.Font(ClusterPlotter.FONT, font.getStyle, 14));
                end
            else
                jl.setFont(java.awt.Font(ClusterPlotter.FONT, font.getStyle, 12));
            end
            jl.setForeground(java.awt.Color.BLUE);
        end
        
        function [pb, H, J]=ImageButton(iconFile, tip, callBack, fig, ...
                x, y, backGround)
            H=[];
            if isempty(fileparts(iconFile))
                J=javaObjectEDT('edu.stanford.facs.swing.ImageButton', ...
                    fullfile(BasicMap.Global.contentFolder, iconFile), tip);
            else
                J=javaObjectEDT('edu.stanford.facs.swing.ImageButton', ...
                    iconFile, tip);
            end
            pb=handle(J,'CallbackProperties');
            if ~isempty(callBack)
                set(pb, 'ActionPerformedCallback',callBack)
            end
            if nargin>3
                if nargin<5
                    x=1;
                    y=1;
                end
                [~, H]=javacomponent(pb, [x,y,16,20]);
                set(H, 'parent', fig);
                if nargin>6
                    J.setBackground(backGround);
                end
            end
        end
        
        function [H, J]=ImageLabel(lbl, iconFile, tip,...
                callBack, fig, x, y, drawNow)
            if nargin<6
                x=0;
                y=0;
            end
            H=[];            
            J=javaObjectEDT('javax.swing.JLabel');
            J.setForeground(java.awt.Color.BLUE);
            if ~isempty(iconFile)
                if isjava(iconFile)
                    J.setIcon(iconFile);
                    icon=iconFile;
                else
                    icon=Gui.Icon(iconFile);
                    J.setIcon(icon);
                end
            end
            J.setText(lbl);
            if ~isempty(tip)
                J.setToolTipText(tip);
            end
            J.setCursor(java.awt.Cursor.getPredefinedCursor(...
                java.awt.Cursor.HAND_CURSOR));
            pb=handle(J,'CallbackProperties');
            if nargin>3 && ~isempty(callBack)
                set(pb, 'MousePressedCallback',callBack)
            end
            J.setOpaque(false);
            if nargin>4
                if isempty(lbl) && ~isempty(iconFile)
                    [~, H]=javacomponent(pb, [x,y,icon.getIconWidth+2,icon.getIconHeight+2]);
                else
                    d=J.getPreferredSize;
                    [~, H]=javacomponent(pb, [x,y,d.width+2,d.height+2]);
                end
                if nargin<8 || drawNow
                    clr=get(fig, 'Color');
                    set(H, 'parent', fig, 'background', clr);
                    drawnow;
                    c=java.awt.Color(clr(1), clr(2), clr(3));
                    J.setBackground(c);
                    J.getParent.setBackground(c);
                end
            end
        end
        
        function FinishImageLabels(fig, lbls)
            N=length(lbls);
            drawnow;
            clr=get(fig, 'Color');
            c=java.awt.Color(clr(1), clr(2), clr(3));
            for i=1:N
                H=lbls{i};
                bg=get(H, 'background');
                if ~isequal(bg, clr)
                    set(H, 'parent', fig, 'background', clr);
                    J=get(H, 'JavaPeer');
                    J.setBackground(c);
                    J.getParent.setBackground(c);
                end
            end
        end
        
        function PlaceAbove(thisItem, lowerItem, ...
                margin, height, units)
            if ~isempty(thisItem) && ~isempty(lowerItem) && ...
                    thisItem ~= 0 && lowerItem ~= 0 
                if nargin<5
                    units='normalized';
                end
                unitsLowerItem=get(lowerItem, 'Units');
                set(lowerItem, 'Units', units);
                p=get(lowerItem, 'position');
                unitsItem=get(thisItem, 'Units');
                set(thisItem, 'Units', units);
                if BasicMap.Global.highDef
                    set(thisItem, 'position',...
                        [p(1), p(2)+p(4)+margin, p(3)*1.4, height*1.4]);
                else
                    set(thisItem, 'position',...
                        [p(1), p(2)+p(4)+margin, p(3), height]);
                end
                set(thisItem, 'units', unitsItem);
                set(lowerItem, 'Units', unitsLowerItem);
            end
        end
        
        function jWindow=JWindow(fig)
            if ~isempty(fig)
                if isjava(fig) 
                    if isa(fig, 'java.awt.Window')
                        jWindow=fig;
                        return;
                    end
                    error('Java object argued that is no a java.awt.Window')
                end
                if ~ishandle(fig)
                    jWindow=[];
                else
                    jFigPeer=get(handle(fig),'JavaFrame');
                    jWindow=jFigPeer.fHG2Client.getWindow;
                    if ~isempty(jWindow)
                        jWindow=javaObjectEDT(jWindow);
                    end
                end
            else
                jWindow=[];
            end
        end
        
        function ok=isEnabled(fig)
            ok=false;
            jWindow=Gui.JWindow(fig);
            if ~isempty(jWindow)
                ok=jWindow.isEnabled;
            end
        end
        
        
        function wasChanged=setEnabled(figures, on, requestFocus)
            %disp('CHANGING enabled');
            wasChanged=[];
            N=length(figures);
            for i=1:N
                fig=figures(i);
                try
                    jWindow=Gui.JWindow(fig);
                catch ex
                    ex.getReport
                    jWindow=[];
                end
                if ~isempty(jWindow)
                    wasOn=jWindow.isEnabled;
                    if ~on
                        if wasOn
                            wasChanged(end+1)=fig;
                        end
                    else
                        if ~wasOn
                            wasChanged(end+1)=fig;
                        end
                    end
                    if ~on
                        if wasOn
                            jWindow.setEnabled(false);  % or true
                        end
                    else
                        if ~wasOn
                            jWindow.setEnabled(true);
                        end
                        if nargin>2 && i==N && requestFocus
                            jWindow.requestFocus;
                        end
                    end
                end
            end
        end
        
        function exportedImgPath=exportToMcr(imgName, parent)
            img=imread(imgName);
            exportedImgPath=fullfile(parent, imgName);
            imwrite(img, exportedImgPath);
        end

        function pos=GetCharacters(h)
            units=get(h,'units');
            set(h, 'units', 'characters');
            pos=get(h, 'position');
            set(h,'units',units);
        end

        function pos=GetPixels(h)
            units=get(h,'units');
            set(h, 'units', 'pixels');
            pos=get(h, 'position');
            set(h,'units',units);
        end

        function cb2=AddBorder(jCmp)
            bevel=javax.swing.BorderFactory.createBevelBorder(1);
            emptyBorder=javax.swing.BorderFactory.createEmptyBorder(2,3,2, 2);
            cb=javax.swing.BorderFactory.createCompoundBorder(bevel, emptyBorder);
            lb=javax.swing.BorderFactory.createLineBorder(...
                java.awt.Color.RED, 2);
            cb2=javax.swing.BorderFactory.createCompoundBorder(lb, cb);
            jCmp.setBorder(cb2);
        end
        
        function pos=GetNormalized(h)
            units=get(h,'units');
            set(h, 'units', 'normalized');
            pos=get(h, 'position');
            set(h,'units',units);
        end

        function pos=GetOuterPixels(fig)
            units=get(fig,'units');
            set(fig, 'units', 'pixels');
            pos=get(fig, 'outerposition');
            set(fig,'units',units);
        end
        function SetOuterPixels(fig, pixelPosition)
            units=get(fig,'units');
            set(fig, 'units', 'pixels');
            set(fig, 'outerposition', pixelPosition);
            set(fig,'units',units);
        end

        function pos=GetPosition(H, units, outer)
            if nargin<3 || ~outer
                prop='position';
            else
                prop='OuterPosition';
            end
            u=get(H,'units');
            set(H, 'units', units);
            pos=get(H, prop);
            set(H,'units',u);
        end

        function SetPosition(H, units, position, outer)
            if nargin<4 || ~outer
                prop='position';
            else
                prop='OuterPosition';
            end
            u=get(H,'units');
            set(H, 'units', units);
            set(H, prop, position);
            set(H,'units',u);
        end

        function SetPixels(h, pos, property)
            if nargin<3
                property='position';
            end
            units=get(h,'units');
            set(h, 'units', 'pixels');
            set(h, property, pos);
            set(h,'units',units);
        end
        
        function ok=IsOverExtent(h, x, y)
            ok=false;
            if ~isempty(h)
                if h~=0 && ishandle(h)
                    set(h,'Units','data');
                    e=get(h,'Extent');
                    if y<=e(2)+e(4) && y>=e(2);
                        if x>e(1) && x<= e(1)+e(3)
                            ok=true;
                        end
                    end
                end
            end
        end
        
        function amts=AmtOverExtent(h, x, y, xPad, yPad)
            amts=zeros(1,3);
            if ~isempty(h)
                if h~=0 && ishandle(h)
                    set(h,'Units','data');
                    e=get(h,'Extent');
                    if y<=e(2)+yPad*e(4) && y>=e(2);
                        if x>xPad*e(1) && x<= e(1)+e(3)
                            %disp( ['***' x e(1) e(3) ])
                            amts(1)=1;
                            amts(2)=(x-e(1))/e(3);
                            amts(3)=(y-e(2))/e(4);
                        else
                            %disp( ['<' x e(1) e(3) ])
                        end
                    end
                end
            end
        end
        
        function ok=IsOverFigureObject(h, x, y)
            ok=false;
            if h~=0 && ishandle(h)
                p=get(h,'Position');
                if length(p)<4
                    p=get(h, 'extent');
                end
                if y<=p(2)+p(4) && y>=p(2);
                    if x>p(1) && x<= p(1)+p(3)
                        ok=true;
                    end
                end
            end
        end
        
        function SetJavaVisible(jd, useGcf)
            if isdeployed || ~ismac || 1==size(get(0, 'MonitorPositions'), 1)
                jd.setVisible(true);
                return;
            end
            try
                if verLessThan('matlab', '9.2')
                    if ismac
                        old=jd.getLocation;
                        MatBasics.RunLater(@(h,e)handleMac, .3);
                    end
                end
                jd.setVisible(true);
                drawnow;
            catch
            end
            function handleMac
                 %weird issue with Java 7 and Mac 2 physical screens
                if ~old.equals(jd.getLocation)
                    if Gui.DEBUGGING
                        jd.getLocation
                        jd.setLocation(old);
                        disp('A D J U S T I N G');
                        old
                    else
                        jd.setLocation(old);
                    end
                end
            end
        end
        
        function [x,y]=LocateJava(javaComponent, reference, where)
            size=javaComponent.getSize;
            if size.width==0 || size.height==0
                size=javaComponent.getPreferredSize;
            end
            
            if nargin<3
                where='center';
                if nargin<2
                    reference=[];
                end
            end
            if isempty(reference)
                reference=Gui.ParentFrame;
            end
            if isempty(reference)
                p=get(0, 'ScreenSize');
                where=strrep(where,'-', '');
                where=strrep(where,'+','');
                [x, y]=Gui.LocateWidthHeight(true, ...
                    size.width, size.height, p(1), ...
                    p(2), p(3), p(4), where);
                %p=Gui.FitToScreen([x y size.width size.height]);
            else
                refXy=reference.getLocation;
                refSize=reference.getSize;
                %fprintf('%s %s\n', refXy.toString, refSize.toString);
                %try
                %    fprintf('DUDE   %s\n', reference.getTitle);
                %catch
                %end
                [x, y]=Gui.LocateWidthHeight(true, size.width, ...
                    size.height, refXy.x, refXy.y, refSize.width, ...
                    refSize.height, where);
                if ~isempty(find(where=='+', 1, 'last'))
                    [scrIdx, percentOnScr, numScreens, scrJava, scrMl]=...
                        Gui.FindJavaScreenForJavaWnd(reference);
                    mlY=javaPointToMatLab(x,y);
                    pos=[floor(x) (floor(mlY-size.height)) size.width size.height];
                    percentOnScr=Gui.GetPositionOverlap(pos, scrMl);
                    if (percentOnScr<.98)
                        if x+size.width>scrJava.x+scrJava.width
                            x=(scrJava.x+scrJava.width)-size.width;
                        elseif x<scrJava.x
                            x=scrJava.x;
                        end
                        if y<scrJava.y
                            y=scrJava.y;
                        elseif y+size.height>scrJava.y+scrJava.height
                            y=(scrJava.y+scrJava.height)-(size.height+10);
                        end
                    end
                    if x<scrJava.x && size.width>scrJava.width
                        javaComponent.setLocation(scrJava.x+8, y);
                        pw=javaComponent.getPreferredSize;
                        pw.width=scrJava.width-17;
                        javaComponent.setPreferredSize(pw);
                        javaComponent.setSize(pw);
                    end
                end
                %[x, y]=Gui.FitJava(scrJava, javaComponent.getBounds);
                %fprintf('ref XY=%d/%d and XY=%d/%d\n\n', refXy.x, ...
                %    refXy.y, int64(x), int64(y));
            end
            drawnow;
            javaComponent.setLocation(x, y);
        end
        
        function [x,y]=Locate(figOrControl, reference, where, ...
                follow, closeToo)
            p1=get(figOrControl, 'OuterPosition');
            if nargin<2 || isempty(reference)
                reference=get(0,'currentFigure');
            end
            if nargin<3
                where='center';
            end
            p2=Gui.GetOuterPixels(reference);
            [x, y]=Gui.LocateWidthHeight(false, p1(3), p1(4),...
                p2(1), p2(2), p2(3), p2(4), where);
            figPos=[x y p1(3) p1(4)];
            if ~isempty(find(where=='+', 1, 'last'))
                [~, ~, scrPos]=Gui.FindScreen(p2);
                percentOnScr=Gui.GetPositionOverlap(figPos, scrPos);
                if percentOnScr<.98
                    if figPos(1)<scrPos(1)
                        figPos(1)=scrPos(1);
                    elseif figPos(1)+figPos(3)>scrPos(1)+scrPos(3)
                        figPos(1)=scrPos(3)-figPos(3)+scrPos(1);
                    end
                    if figPos(2)<scrPos(2)
                        figPos(2)=scrPos(2);
                    elseif figPos(2)+figPos(4)>scrPos(2)+scrPos(4)
                        figPos(2)=scrPos(4)-figPos(4)+scrPos(2);
                    end
                    x=figPos(1);
                    y=figPos(2);
                end
            end
            set(figOrControl, 'OuterPosition', figPos);
            if nargin>3
                hush=nargin>4 && closeToo;
                if follow  
                    Gui.FollowWindow(figOrControl, reference, where, hush);
                elseif hush
                    set(figOrControl, 'CloseRequestFcn', @(h, e)quiet());
                end
            end

            function quiet()
                if ishandle(reference)
                    figure(reference);
                end
                delete(figOrControl);
            end

        end
        
        function p1=LocatePosition(p1, p2, where)
            if nargin<2 || isempty(p2)
                p2=get(0,'currentFigure');
            end
            if nargin<3
                where='center';
            end
            if ~isnumeric(p2)
                p2=get(p2, 'OuterPosition');
            end
            [x, y]=Gui.LocateWidthHeight(false, p1(3), p1(4),...
                p2(1), p2(2), p2(3), p2(4), where);
            p1=[x y p1(3) p1(4)];
            if ~isempty(find(where=='+', 1, 'last'))
                [~, ~, scrPos]=Gui.FindScreen(p2);
                percentOnScr=Gui.GetPositionOverlap(p1, scrPos);
                if percentOnScr<.98
                    if p1(1)<scrPos(1)
                        p1(1)=scrPos(1);
                    elseif p1(1)+p1(3)>scrPos(1)+scrPos(3)
                        p1(1)=scrPos(3)-p1(3)+scrPos(1);
                    end
                    if p1(2)<scrPos(2)
                        p1(2)=scrPos(2);
                    elseif p1(2)+p1(4)>scrPos(2)+scrPos(4)
                        p1(2)=scrPos(4)-p1(4)+scrPos(2);
                    end
                end
            end            
        end
        
        function LocateWithin(fig, screenPos, where)
            pos=get(fig, 'outerposition');
            [x, y]=Gui.LocateWidthHeight(false, pos(3), pos(4),...
                screenPos(1), screenPos(2), screenPos(3), screenPos(4),...
                where);
            pos(1)=x;
            pos(2)=y;
            set(fig, 'outerposition',pos);
        end
        
        function LocateItem(item, container, where, margin)
            if nargin<4
                margin=0;
            end
            posInner=Gui.GetPixels(item);
            posOuter=Gui.GetPixels(container);
            [x, y]=Gui.LocateWidthHeight(false, ...
                posInner(3), posInner(4),...
                margin, margin, ...
                posOuter(3)-margin*2, posOuter(4)-margin*2,...
                where);
            posInner(1)=x;
            posInner(2)=y;
            set(item, 'position',posInner);
        end
        
        
        function jFrame=JFrame(fig)
            if nargin<1
                fig=get(0, 'currentFigure');
            end
            if isempty(fig)
                jFrame=[];
            else
                jFrame=javaObjectEDT(getjframe(fig));
            end
        end
        function [midRight, d, w]=GetCenterRightLocation(jw, pnl)
            w=jw.getWidth;
            d=pnl.getPreferredSize;
            midRight=w/2+(d.width*.8);
        end
        
        
        function [jFrame, p, none]=ParentFrame(app)
            try
                none=false;
                p=[];
                if nargin<1
                    app=BasicMap.Global;
                end
                if nargout==1 && isjava(app.currentJavaWindow)
                    jFrame=app.currentJavaWindow;
                    return;
                elseif strcmpi('none', BasicMap.Global.currentJavaWindow)% HACK!
                    jFrame=[]; % no parent!
                    none=true;
                    return;
                end
            catch
                %disp('Must be initializing before Java is loaded!')
            end
            figs=get(0, 'Children');
            if isempty(figs)
                jFrame=[];
                p=get(0, 'ScreenSize');
            else
                cf=get(0, 'currentFigure');
                if ~isempty(cf) && Gui.isVisible(cf)
                    jFrame=javaObjectEDT(getjframe(cf));
                    p=get(cf,'position');
                else
                    jFrame=[];
                    p=get(0, 'ScreenSize');
                end
            end
        end
        
        function imgFile=GetResizedImageFile(imgFile, factor, app)
            if isempty(fileparts(imgFile))
                imgFile=fullfile(BasicMap.Global.contentFolder, imgFile);
            end
            if nargin>2 
                if app.highDef
                    factor=1.1*factor;
                end
            end
            imgFile=edu.stanford.facs.swing.Basics.GetResizedImg(...
                java.io.File(imgFile), factor, ...
                java.io.File(BasicMap.Global.appFolder));
        end
        
        function resized=ResizeImage(original, widthFactor, heightFactor)
            newWidth = int32(original.getWidth * widthFactor);
            newHeight = int32(original.getHeight * heightFactor);
            resized = javaObject('java.awt.image.BufferedImage', ...
                newWidth, newHeight, original.getType);
            g = resized.createGraphics();
            g.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION, ...
                java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.drawImage(original, 0, 0, newWidth, newHeight, 0, 0,...
                original.getWidth, original.getHeight, []);
            g.dispose();
        end
        
        function menuObjs=GetMenuItems(fig)
            menuObjs=findall(fig, '-regexp', 'tag','.*Menu.*$');
        end
        
        function Copy2Clipboard(fig, suppressPopup)
            if nargin<2
                suppressPopup=false;
            end
            was=Gui.setEnabled(fig, false);
            if ~suppressPopup
                pu=PopUp('Copying image to clipboard', 'south east');
            end
            if ispc
                print(fig, '-clipboard', '-dmeta');
            else
                print(fig, '-clipboard', '-dbitmap');
            end
            Gui.setEnabled(was, true);
            if ~suppressPopup
                pu.close;
            end

        end

        function [newAxes, newFig]=CopyAxes(fig, ...
                visibleFigure)
            if nargin<2 || ~visibleFigure
                on='off';
            else
                on='on';
            end
            h=findobj(fig,'type','axes'); % Find the axes object in the GUI
            newFig=figure('visible', on); % Open a new figure with handle f1
            s=copyobj(h,newFig); % Copy axes object h into figure f1
            set(h, 'color', 'none');
            newAxes=findobj(newFig,'type','axes');
        end

        function [fig, tb, personalized, pos]=Figure(removeZoomPan, ...
                property, propertyFile, where1stTime, doToolBar)
            if nargin<1
                removeZoomPan=true;
            end
            fig=figure('toolbar', 'none', 'NumberTitle', 'off', ...
                'Menubar', 'none', 'DockControls', 'off', 'visible', 'off');
            if nargin<5 || doToolBar
                tb=ToolBar.New(fig, true, removeZoomPan, removeZoomPan, ...
                    removeZoomPan);
            else
                tb=[];
            end
            personalized=false;
            if nargout>3
                pos=get(fig, 'outerposition');
            end
            if nargin>1
                if nargin<3
                    propertyFile=[];
                end
                try
                    pos=[];
                    if ~isempty(propertyFile)
                        props=File.ReadProperties(propertyFile, true); 
                        pos=char(props.getProperty(property));
                        if ~isempty(pos)
                            pos=str2num(pos);
                            personalized=true;
                        end
                    end
                    if isempty(pos) 
                        if ~isempty(property)
                            pos=BasicMap.Global.get(property);
                        else
                            pos=[];
                        end
                        if isempty(pos)
                            if nargin>3
                                movegui(fig, where1stTime);
                                pos=get(fig, 'outerposition');
                            end
                        else
                            pos=str2num(pos);
                            personalized=true;
                        end
                    end
                    if ~isempty(pos)
                        set(fig, 'OuterPosition', pos);
                    end
                catch 
                end
                priorCloseFcn=get(fig, 'CloseRequestFcn');
                set(fig, 'CloseRequestFcn', @hush);
            end
            
            function hush(h,e)
                pos=num2str(get(h,'OuterPosition'));
                if ~isempty(propertyFile)
                    props=File.ReadProperties(propertyFile, true);
                    props.setProperty(property, pos);
                    try
                        File.SaveProperties2(propertyFile, props);
                    catch
                        ex.getReport
                    end
                end
                BasicMap.Global.set(property, pos);
                if isa(priorCloseFcn, 'function_handle')
                    feval(priorCloseFcn, h,e);
                end
                if ishandle(h) && isvalid(h)
                    delete(h);
                end
            end

        end

        function ScreenShot(h, fileName, toClipBoard, percents)
            [cdata,a]=getscreen(h);            
            imwrite(cdata, fileName);
            if toClipBoard
                edu.stanford.facs.swing.ClipboardImage.write(...
                    fileName);
            end
            if nargin>=4
                for i=1:length(percents)
                    Gui.ScaleImage(fileName, percents(i), cdata);
                end
            end
        end
        
        function newFile=ScaleImage(file, scale, cdata, newFileName)
            [p,n,e]=fileparts(file);
            if scale~=1 && scale > .1
                if nargin<4
                    s=num2str(int32(scale*100));
                    [newFile, preExists]=BasicMap.Global.getCached(...
                        fullfile(p, [n '_' s e]));
                    create=~preExists;
                else
                    newFile=fullfile(p, newFileName);
                    create=true;
                end
                try
                    if create
                        if nargin<3 || isempty(cdata)
                            cdata=imread(file);
                        end
                        subX=imresize(cdata, scale);
                        imwrite(subX, newFile);
                    end
                catch ex
                    disp(ex.message);
                end
            else
                newFile=file;
            end
        end
        
        function SetMetaAccelerator(mi, keyboardChar)
            mi.setAccelerator(...
                javax.swing.KeyStroke.getKeyStroke(...
                java.lang.Character(keyboardChar), ...
                java.awt.event.InputEvent.META_DOWN_MASK));
        end
        
        function SetMetaShiftAccelerator(mi, keyboardChar)
            mi.setAccelerator(...
                javax.swing.KeyStroke.getKeyStroke(...
                java.lang.Character(keyboardChar), ...
                java.awt.event.InputEvent.SHIFT_DOWN_MASK + ...
                java.awt.event.InputEvent.META_DOWN_MASK));
        end
        
        function SetAccelerator(mi, osSpecificKs)
            if ~isempty(osSpecificKs)
                if osSpecificKs(1)== ' '
                    if ispc
                        ks=['ctrl' osSpecificKs];
                    else
                        ks=['meta' osSpecificKs];
                    end
                else
                    ks=osSpecificKs;
                end
                ks=javax.swing.KeyStroke.getKeyStroke(ks);
                mi.setAccelerator(ks);
            end
        end
        
        
        function mi=NewCheckBoxMenuItem(jMenu, txt, fnc, osSpecificKs,...
                toolTip, selected)
            mi=javaObjectEDT('javax.swing.JCheckBoxMenuItem', txt);
            jMenu.add(mi);
            mi=handle(mi,'CallbackProperties');
            if nargin>2 && ~isempty(fnc)
                set(mi,'ActionPerformedCallback', fnc);
            end
            if nargin>3
                if ~isempty(osSpecificKs)
                    Gui.SetAccelerator(mi, osSpecificKs);
                end
                if nargin>4
                    if ~isempty(toolTip)
                        mi.setToolTipText(toolTip);
                    end
                    if nargin>5
                        mi.setSelected(selected);
                    end
                end
            end
            mi.setFont(jMenu.getFont);
            jMenu.add(mi);
        end        
        
        function mi=NewMenuItem(jMenu, txt, fnc, iconPath, ...
                osSpecificKs, enabled, toolTip, app)
            if nargin<7
                toolTip=[];
                if nargin<6
                    enabled=true;
                    if nargin<5
                        osSpecificKs=[];
                        if nargin<4
                            iconPath=[];
                            if nargin<3
                                fnc=[];
                            end
                        end
                    end
                end
            end
                            
            mi=handle(javaObjectEDT('javax.swing.JMenuItem', txt),...
                'CallbackProperties');
            if ~isempty(fnc)
                set(mi,'ActionPerformedCallback', fnc);
            end
            jMenu.add(mi);
            if ~isempty(iconPath)
                if nargin<8
                    nargin
                    app=BasicMap.Global;
                end
                mi.setIcon(Gui.Icon(iconPath, app));
            end
            if ~isempty(osSpecificKs)
                Gui.SetAccelerator(mi, osSpecificKs);
            end
            if ~isempty(toolTip)
                mi.setToolTipText(toolTip);
            end
            mi.setFont(jMenu.getFont);
            mi.setEnabled(enabled);
        end
        
        function yes=Enable(obj, yes, msgIfDisabled)
            obj.setEnabled(yes);
            if ~yes
                obj.setToolTipText(msgIfDisabled);
            end
        end

        function mi=NewMenuLabel(jMenu, txt, addSeparator, toolTip, icon)
            if nargin>2 && addSeparator
                jMenu.addSeparator
            end
            mi=Gui.Label(['<html><font color="#121199">' txt ...
                '</font></html>']);
            invalid=java.awt.Cursor.getSystemCustomCursor(...
                    'Invalid.32x32');
            %mi.setCursor(invalid);
            mi.setBackground(java.awt.Color(.6, .6, 1));
            f=jMenu.getFont;
            mi.setFont(java.awt.Font(f.getName, f.getStyle, f.getSize));
            if nargin>3
                mi.setToolTipText(toolTip);
                if nargin>4
                    jImage = Gui.Icon(icon);
                    mi.setIcon(jImage);
                end
            end
            jp=Gui.BorderPanel;
            jp.setCursor(invalid);
            jp.add(Gui.Label(' '), 'West');
            jp.add(mi, 'Center');
            jp.add(Gui.Label(' '), 'East');
            jp.setOpaque(false);
            jMenu.add(jp);
        end
        
        function mnu=NewMenu(jMenu, txt, callBack, icon, ...
                forAutoComplete, tip, app)
            mnu=javaObjectEDT('javax.swing.JMenu', txt);
            mnu.setFont(jMenu.getFont);
            jMenu.add(mnu);
            if nargin>2
                if nargin<6
                    tip='';
                    if nargin<5
                        forAutoComplete=false;
                        if nargin<4
                            icon=[];
                        end
                    end
                end
                if ~isempty(callBack)
                    mnuH=handle(mnu,'CallbackProperties');
                    set(mnuH, 'StateChangedCallback', callBack);
                    if forAutoComplete
                        feval(callBack, mnu,[]);
                    end
                end
                if ~isempty(icon)
                    if nargin<7
                        nargin
                        app=BasicMap.Global;
                    end
                    mnu.setIcon(Gui.Icon(icon, app));
                end
                if ~isempty(tip)
                    mnu.setToolTipText(tip);
                end
            end
        end
        
        function SetIfNot0(h, property, state)
            if h~=0
                set(h, property, state);
            end
        end
       
        function [pixelsMatLab, pixelsJava, yMargins]=...
                GetCurrentPointPixels(ax,fig, cp)
            posA=floor(Gui.GetPixels(ax));
            posAN=Gui.GetNormalized(ax);
            if nargin<3
                cp=get(ax, 'CurrentPoint');
            end
            xl=get(ax, 'xlim');
            if isequal(get(ax, 'XDir'), 'reverse')
                xMx=1;
                xMn=2;
            else
                xMx=2;
                xMn=1;
            end
            yl=get(ax, 'ylim');
            if isequal(get(ax, 'YDir'), 'reverse')
                yMx=1;
                yMn=2;
            else
                yMx=2;
                yMn=1;
            end
            x=posA(1)+floor(( (cp(1,1)-xl(xMn))/(xl(xMx)-xl(xMn)))*posA(3));
            y=posA(2)+floor((( cp(1,2)-yl(yMn))/(yl(yMx)-yl(yMn)))*posA(4));
            if Gui.DEBUG_POINT
                fprintf('Dir %s/%s cp=%s/%s; xl=%s/%s, yl=%s/%s--->%s/%s\n', ...
                    get(ax, 'XDir'), get(ax, 'YDir'),...
                    String.encodeRounded(cp(1,1)), ...
                    String.encodeRounded(cp(1,2)), String.encodeRounded(xl(1)), ...
                    String.encodeRounded(xl(2)), String.encodeRounded(yl(1)), ...
                    String.encodeRounded(yl(2)), ...
                    String.encodeRounded(x), ...
                    String.encodeRounded(y));
            end
            pixelsMatLab=[x y];
            pixelsJava=[x posA(4)-y];
            if nargout>2 && nargin>1
                posF=Gui.GetPixels(fig);
                ty=posF(4)-posA(4)-posA(2);
                tx=posF(3)-posA(3)-posA(1);
                yMargins=[posA(1) tx posA(2) ty];
            end
        end
        
        function [X, Y, ml]=GetCurrentPointFromMatLabObj(ax, fig, javaObjH)
             [ml,pj, m]=Gui.GetCurrentPointPixels(ax, fig);
             posF=Gui.GetPixels(fig);
             try
                 posJ=Gui.GetPixels(javaObjH);
             catch
                 posJ=get(javaObjH, 'position');
             end
             x=pj(1)+m(1);
             y=pj(2)+m(4);
             X=x-posJ(1);
             yJ=posF(4)-posJ(2)-posJ(4);
             Y=y-yJ;
        end
        
        function [posJ, posF]=GetJavaPosition(fig, javaObj)
            posF=Gui.GetOuterPixels(fig);
            [~,~,scr]=Gui.FindJavaScreen(fig);
            locJ=javaObj.getLocationOnScreen;
            szJ=javaObj.getSize;
            if BasicMap.Global.toolBarFactor>0
                tf=BasicMap.Global.toolBarFactor;
                scr=scr/tf;
                locJ.x=locJ.x/tf;
                locJ.y=locJ.y/tf;
                szJ.width=szJ.width/tf;
                szJ.height=szJ.height/tf;
            end
            x=(locJ.x+1)-posF(1);
            y=scr(4)-(locJ.y);
            y=y-posF(2);
            y=y-(szJ.height-1);
            posJ=[x y szJ.width szJ.height];
        end
        
        function [X, Y, ml]=GetCurrentPointFromJavaObj(ax, fig, ...
                javaObjOrPos, posF)
             [ml,pj, m]=Gui.GetCurrentPointPixels(ax, fig);
             if isnumeric(javaObjOrPos)
                 posJ=javaObjOrPos;
             else
                 [posJ, posF]=Gui.GetJavaPosition(fig, javaObjOrPos);
             end
             x=pj(1)+m(1);
             y=pj(2)+m(4);
             X=x-posJ(1);
             yJ=posF(4)-posJ(2)-posJ(4);
             Y=y-yJ;
             if BasicMap.Global.toolBarFactor>0
                 X=BasicMap.Global.toolBarFactor*X;
                 Y=BasicMap.Global.toolBarFactor*Y;
             end
                 
        end

        function w=GetCharacterWidth(fig)
            units=get(fig, 'units');
            set(fig, 'units', 'characters');
            pos=get(fig, 'position');
            set(fig, 'units', units);
            w=pos(3);
        end
        
        function fpp=GetFigPixelPosition(fig, ax, obj)
            funits=get(fig, 'units');
            aunits=get(ax, 'units');
            if ~isempty(obj)
                ounits=get(obj, 'units');
                set(obj, 'units', 'pixels');
            end
            set(ax, 'units', 'pixels');
            set(fig, 'units', 'pixels');
            apos=get(ax, 'position');
            if ~isempty(obj)
                if isprop(obj, 'Extent')
                    opos=get(obj, 'Extent');
                else
                    opos=get(obj, 'Position');
                end
            else
                opos=[0 0 apos(3) apos(4)];
            end
            if length(apos)>2
                jx=opos(1)+apos(1);
                jy=opos(2)+apos(2);
            else
                jx=opos(1);
                jy=opos(2);
            end
            
            fpp=[floor(jx) floor(jy) floor(opos(3)) floor(opos(4))];
            if ~isempty(obj)
                set(obj, 'units', ounits);
            end
            set(ax, 'units', aunits);
            set(fig, 'units', funits);
        end
        
        function [hObj, H]=PutJavaInFig(jobj, figOrPanel, x, y)
            if nargin<3
                x=0;
                y=0;
            end
            if isprop(figOrPanel, 'Color')
                figBg=get(figOrPanel, 'Color');
            else
                figBg=get(figOrPanel, 'BackgroundColor');
            end
            jobj.setBackground(java.awt.Color(figBg(1), figBg(2), figBg(3)));
            d=jobj.getPreferredSize;
            [~, hObj]=javacomponent(jobj, [x,y, d.width, d.height]);
            set(hObj, 'parent', figOrPanel);
            if nargout>1
                H=handle(jobj,'CallbackProperties');
            end
        end
        
        function LocateNextTo(hObj, fig, ax, obj, where, xMargin, yMargin)
            if nargin<7
                yMargin=0;
                if nargin<6
                    xMargin=0;
                    if nargin<5 %go west young man
                        where='west';
                    end
                end
            end
            jp=Gui.GetFigPixelPosition(fig, ax, obj);
            js=get(hObj, 'position');
            if length(js)<4
                js=get(hObj, 'extent');
            end
            if ~isempty(js)
                [x, y]=Gui.LocateWidthHeight(false, js(3), js(4),...
                    jp(1), jp(2), jp(3), jp(4), where);
                set(hObj, 'position', [x+xMargin y+yMargin js(3) js(4)]);
            end
        end
        
        function [x,y]=LocateJavaOnScreen(javaComponent, where)
            size=javaComponent.getSize;
            if size.width==0 || size.height==0
                size=javaComponent.getPreferredSize;
            end
            if nargin<2
                where='center';
            end
            p=get(0, 'ScreenSize');
            where=strrep(where,'-', '');
            where=strrep(where,'+','');
            [x, y]=WebDownload.LocateWidthHeight(true, ...
                size.width, size.height, p(1), ...
                p(2), p(3), p(4), where);
            javaComponent.setLocation(x, y);
        end
        
        function [x,y]=LocateWidthHeight(isTop0, width, height, ...
                refX, refY, refWidth, refHeight, where)
            if isempty(where)
                where='center';
            end
            w=String(lower(where));            
            hCenter=~w.contains('east') && ~w.contains('west');
            vCenter=~w.contains('north') && ~w.contains('south');
            centerX=refX+refWidth/2-width/2;
            centerY=refY+refHeight/2-height/2;
            east=w.contains('east');
            top=w.contains('north');
            plusPlus=w.contains('++');
            plus=~plusPlus&&w.contains('+');
            if hCenter && vCenter
                x=centerX;
                y=centerY;
            else
                if width>refWidth
                    if east
                        W=refWidth*.75;
                    else
                        W=refWidth*1.3;
                    end
                else
                    W=width;
                end
                if east
                    if plus
                        h=(refX+refWidth)-W*.4;
                    elseif plusPlus
                        h=(refX+refWidth)-W*.1;
                    else
                        h=(refX+refWidth)-W;
                    end
                else
                    if plus
                        h=refX-(W*.6);
                    elseif plusPlus
                        h=refX-(W*.9);
                    else
                        h=refX;
                    end
                end
                if (top && isTop0) || (~top && ~isTop0)
                    if plus
                        v=refY-height*.25;
                    elseif plusPlus
                        v=refY-height*.9;
                    else
                        v=refY;
                    end
                elseif (top && ~isTop0) || (~top && isTop0)
                    if plus
                        v=(refY+refHeight)-height*.66;
                    elseif plusPlus
                        v=(refY+refHeight)-height*.01;                    
                    else
                        v=(refY+refHeight)-height;
                    end
                end
                if vCenter
                    x=h;
                    y=centerY;
                elseif hCenter
                    x=centerX;
                    y=v;
                else
                    x=h;
                    y=v;
                end
            end
        end

        function [jp, border2]=SetTitledBorder(title, jp, font, color, just, pos)
            if nargin<6
                pos=javax.swing.border.TitledBorder.DEFAULT_POSITION;
                if nargin<5
                    just=javax.swing.border.TitledBorder.LEFT;
                    if nargin<4
                        color=java.awt.Color.BLUE;
                        if nargin<3
                            font=[];
                            if nargin<2
                                jp=[];
                            end
                        end
                    end
                end
            end
            lineBorder=javax.swing.BorderFactory.createLineBorder(color, 1);
            try 
                if BasicMap.Global.toolBarFactor >0
                    emptyBorder=javax.swing.BorderFactory.createEmptyBorder(6,6,6,4);
                else
                    emptyBorder=javax.swing.BorderFactory.createEmptyBorder(0,0,0,0);
                end
            catch ex
                emptyBorder=javax.swing.BorderFactory.createEmptyBorder(1,1,1,1);
            end
            compoundBorder=javax.swing.BorderFactory.createCompoundBorder(...
                lineBorder,emptyBorder);
            fontAttr=java.awt.Font.PLAIN;
            if BasicMap.Global.highDef
                fontSz=BasicMap.Global.toolBarFactor * 11;
            else
                fontSz=11;
            end
            if isequal(font, 'bold')
                fontAttr=java.awt.Font.BOLD;
                fontSz=fontSz+1;
                font=[];
            end
            if isequal(font, 'italic')
                fontAttr=java.awt.Font.ITALIC;
                fontSz=fontSz+1;
                font=[];
            end
            if isempty(font)
                if BasicMap.Global.toolBarFactor >0
                    font=java.awt.Font('Arial', fontAttr, fontSz);
                else
                    font=java.awt.Font('Arial', fontAttr, fontSz);
                end
            end
            border2=javax.swing.BorderFactory.createTitledBorder(...
                compoundBorder, title, just,pos,font,color);
            if isempty(jp)
                jp=Gui.FlowPanel;
            end
            jp.setBorder(border2);
        end
        
        function [x, y]=SwingOffset(pm, topJobj)
            pos=topJobj.getLocation;
            while pos.x==0 && pos.y==0
                topJobj=topJobj.getParent;
                if isempty(topJobj)
                    x=-1;
                    y=-1;
                    return;
                end
                pos=topJobj.getLocation;
            end
            sz=topJobj.getParent.getSize;
            wnd=Gui.Wnd(topJobj);
            if ~isempty(wnd)
                sz2=wnd.getSize;
                top=sz2.height-sz.height-25;
            else
                top=-25;
            end
            h=(sz.height-top) -pos.y;  
            y=h-pm(2);
            x=pm(1)-pos.x+75;
        end
        function pos=FigPos(props, propName, dfltX, dfltY, ...
                dfltWidthRatio, dfltHeightRatio, ...
                maxWidthRatio, maxHeightRatio)
            if nargin<8
                maxHeightRatio=dfltHeightRatio;
                if nargin<7
                    maxWidthRatio=dfltWidthRatio;
                end
            end
            priorPos=props.get(propName);
            [ok, ~, ~, scrPos]=Gui.OnScreen(priorPos);
            if ~isempty(priorPos) && ok
                pos=str2num(priorPos);                
                if pos(4)>maxHeightRatio*scrPos(4)
                    pos(4)=maxHeightRatio*scrPos(4);
                end                
                if pos(3)>maxWidthRatio*scrPos(3)
                    pos(3)=maxWidthRatio*scrPos(3);
                end
            else
                pos=[dfltX, dfltY, scrPos(3)*dfltWidthRatio,...
                    dfltHeightRatio*scrPos(4)];
            end
            [pos, newScrPos, refitToScreen]=...
                Gui.RepositionOnSameScreenIfRequired(pos, ...
                'OpenOnSameScreen', 'MainWindowFigure');
            if ~isempty(newScrPos) || refitToScreen
                if ~isempty(newScrPos)
                    scrPos=newScrPos;
                end
                if pos(4)>maxHeightRatio*scrPos(4)
                    pos(4)=maxHeightRatio*scrPos(4);
                end                
                if pos(3)>maxWidthRatio*scrPos(3)
                    pos(3)=maxWidthRatio*scrPos(3);
                end
            end
        end
        
        function clr=SetColor(jf, title, oldColor)
            if nargin<3
                oldColor=[0 0 1];
                if nargin<2
                    title='Java''s Color editor';
                    if nargin < 1
                        jf=[];
                    end
                end
            end
            BasicMap.Global.closeToolTip;
            if length(oldColor)==3
                oldC=javaObjectEDT('java.awt.Color',oldColor(1),...
                    oldColor(2), oldColor(3));
            else
                oldC=javaObjectEDT('java.awt.Color', 1, 1, 0);
            end
            clr=javaMethodEDT('showDialog', 'javax.swing.JColorChooser',...
                 jf, title, oldC);
            if ~isempty(jf)
                jf.toFront;
            end
            if ~isempty(clr)
                disp(clr);
                clr=[clr.getRed/255 clr.getGreen/255 clr.getBlue/255];
            end
        end
        
        function O=ConvertMatLabLabel(h, fig)
            [H, J]=Gui.ImageLabel([], [], '',  [],  fig, 0, 0);
            P=get(h, 'Position');
            u=get(h, 'units');
            set(H, 'units', u, 'Position', P, 'visible', 'on');
            J.setOpaque(false);
            J.getParent.setOpaque(false);
            J.getParent.getParent.setOpaque(false);
            C=get(h, 'ForegroundColor');
            J.setForeground(java.awt.Color(C(1), C(2), C(3)));
            sz=get(h, 'fontSize');
            f=J.getFont;
            J.setFont(java.awt.Font('Arial', f.getStyle, sz));
            O=struct('H', H, 'J', J);
        end
        
        function SetLabelFontSize(J, size)
            f=J.getFont;
            J.setFont(java.awt.Font(f.getName, f.getStyle, size));
        end
        
        function folder=SamusikIconFolder
            folder=BasicMap.Global.contentFolder;
        end
        
        function file=SamusikIconFile
            file='importSubset.gif';
        end
        
        function img=SamusikIconFilePath
            img=fullfile(Gui.SamusikIconFolder, Gui.SamusikIconFile);
        end
        
        function [busy, wasEnabled, lbl]=ShowBusy(wnd, title, icon, ...
                iconSize, showBusy, where, hideSecs)
            if nargin<7
                hideSecs=0;
                if nargin<6
                    where='South';
                    if nargin<5
                        showBusy=false;
                        if nargin<4
                            iconSize=.66;
                            if nargin<3
                                icon='Genie.png';
                                if nargin<2
                                    title='Busy...';
                                end
                            end
                        end
                    end
                end
            end
            if isa(wnd, 'matlab.ui.Figure')
                theFig=wnd;
                wnd=Gui.JWindow(wnd);
                if isempty(wnd)
                    busy=[];
                    wasEnabled=Gui.isEnabled(theFig);
                    lbl=[];
                    return;
                end
            end
            wasEnabled=wnd.isEnabled;
            wnd.setEnabled(false);
            gp=Gui.BorderPanel;
            if ~isempty(icon) && (exist(icon, 'file') || exist(fullfile(...
                    BasicMap.Global.contentFolder, icon), 'file'))
                if iconSize==1 %don't work
                    iconSize=.99;
                end
                if BasicMap.Global.highDef
                    iconSize=1.53*iconSize;
                end
                [p, f, e]=fileparts(icon);
                img=Html.ImgXy([f e], p, iconSize,false);
            else
                if BasicMap.Global.highDef
                    iconSize=10;
                else
                    iconSize=6.5;
                end
                img=Html.ImgXy('demoIcon.gif', ...
                    BasicMap.Global.contentFolder, ...
                    iconSize, false);
            end
            html=['<html><table border="0"><tr><td align="center">' ...
                img '</td></tr><tr><td align="center">' ...
                title '</td></tr></table><html>'];
            wnd.getGlassPane.setVisible(false);
            
            busy=Gui.JBusy([], 4);
            center=Gui.BorderPanel;
            lp=Gui.Panel;
            lbl=Gui.Label(html);
            lp.add(lbl);
            lp.setOpaque(false);
            center.add(lp, 'South');
            center.setOpaque(false);
            center.add(busy.getComponent, 'North');
            center.add(Gui.Label('<html>...</html>'), 'Center');
            gp.add(center, where);
            wnd.setGlassPane(gp);
            gp.setOpaque(false);
            gp.setVisible(true);
            if showBusy
                busy.start;
            else
                busy.getComponent.setVisible(false)
            end
            if hideSecs>0
                MatBasics.RunLater(...
                    @(h,e)Gui.HideBusy(wnd,busy, wasEnabled), hideSecs);
            end
        end
        
        function wasVisible=ToggleGlass(wnd, visible)
            if isa(wnd, 'matlab.ui.Figure')
                wnd=Gui.JWindow(wnd);
            end
            gp=wnd.getGlassPane;
            wasVisible=gp.isVisible;
            gp.setVisible(visible);
        end
        
        function s=YellowH2(txt, app)
            if nargin<2
                app=BasicMap.Global;
            end
            s=['<table cellpadding="9" border="1"><tr>'...
                '<td bgcolor="#FDFDEC" color="#666688" '...
                'align="center">' app.h2Start  '<i>' ...
                txt '</i>' app.h2End '<hr></td></tr></table>'];
        end
        
        function s=YellowH3(txt, app)
            if nargin<2
                app=BasicMap.Global;
            end
            s=['<table cellpadding="9" border="1"><tr>'...
                '<td bgcolor="#FDFDEC" color="#666688" '...
                'align="center">' app.h3Start  '<i>' ...
                txt '</i>' app.h3End '<hr></td></tr></table>'];
        end

        function s=YellowSmall(txt, app)
            if nargin<2
                app=BasicMap.Global;
            end
            s=['<table cellpadding="9" border="1"><tr>'...
                '<td bgcolor="#FDFDEC" color="#666688" '...
                'align="center"><b>' app.smallStart '<i>' ...
                txt '</i>' app.smallEnd ...
                '</b><hr></td></tr></table>'];
        end
        
        function HideBusy(wnd, busy, wasEnabled)
            if nargin>1 && ~isempty(busy)
                busy.stop;
            end
            if isa(wnd, 'matlab.ui.Figure')
                wnd=Gui.JWindow(wnd);
            end
            if ~isempty(wnd)
                wnd.getGlassPane.setVisible(false);
                if nargin<3 || wasEnabled
                    wnd.setEnabled(true);
                end
            end
        end
        
        function CloseJavaWindow(dlg)
            dlg.dispatchEvent( java.awt.event.WindowEvent(dlg, ...
                java.awt.event.WindowEvent.WINDOW_CLOSING))
        end
        
        function Resize(H, by)
            op=get(H, 'outerposition');
            set(H, 'outerposition', [op(1) op(2) op(3)*by op(4)*by]);
        end
        
        function [normX, normY, normZ]=DataToAxNorm(ax, posX, posY, posZ)
            X=xlim(ax);
            normX=(posX-X(1))/abs(X(2)-X(1));
            Y=ylim(ax);
            normY=(posY-Y(1))/abs(Y(2)-Y(1));            
            if nargout>3
                Z=zlim(ax);
                normZ=(posZ-Z(1))/abs(Z(2)-Z(1));            
            end
        end
        
        function [figNormX, figNormY]=DataToFigNorm(ax, normX, normY)
            u2=get(ax, 'units');
            set(ax, 'units', 'normalized');
            pos=get(ax, 'position');
            figNormX=pos(1)+normX*pos(3);
            figNormY=pos(2)+normY*pos(4);
            set(ax, 'units', u2);
        end
        
        function RegisterEscape(root, btn)
            keyCode=java.awt.event.KeyEvent.VK_ESCAPE;
            key=javax.swing.KeyStroke.getKeyStroke(keyCode, 0);
            when=javax.swing.JComponent.WHEN_IN_FOCUSED_WINDOW;
            al=btn.getActionListeners;
            root.registerKeyboardAction(al(1), key, when)
        end
        
        function tipH=ShowTip(ax,  tipHandleOrText, secs, fsz, x, y)            
            if nargin<6
                x=[];
                y=[];
                if nargin<4
                    secs=4;
                    if nargin<3
                        fsz=10;
                    end
                end
            end
            if ~isvalid(ax)
                return;
            end
            if nargin<3 || isempty(x)
                cp=get(ax, 'CurrentPoint');
                if isempty(cp)
                    return;
                end
                x=cp(1,1);
                y=cp(1,2);
                [x, y]=Gui.DataToAxNorm(ax, x, y);
            end
            createTextHandle=ischar(tipHandleOrText) ...
                || iscell(tipHandleOrText);
            if createTextHandle
                tipH=text(x+.03, y+.03, tipHandleOrText, ...
                    'fontSize', fsz, 'color', [0 0 .5], 'EdgeColor',...
                    'red', 'FontName', 'Arial', 'parent', ax, ...
                     'units', 'normalized',...
                    'backgroundColor', [1 1 .9]);
            else
                tipH=tipHandleOrText;
                set(tipH, 'UserData', []);
                if nargin>4
                    set(tipH, 'Position', [x y 0]);
                end
            end
            set(tipH, 'ButtonDownFcn', @(h,e)freeze());
            if secs>0
                MatBasics.RunLater(@(h,e)closeTip, secs);
            else
                freeze(tipH);
            end
            
            function freeze()
                if isempty(get(tipH, 'UserData'))
                    set(tipH, 'UserData', true);
                    set(tipH, 'FontSize', fsz-2);
                    set(tipH, 'FontAngle', 'normal');
                else 
                    removeTip;
                end
            end
            
            function closeTip
                if isempty(get(tipH, 'UserData'))
                    removeTip
                end
            end
            function removeTip
                if createTextHandle
                    delete(tipH);
                else
                    set(tipH, 'visible', 'off');
                end
            end
        end
        
        
        function CloseAll(force)
            if nargin>0 && force
                close all force;
            else
                close all;
            end
            Gui.DisposeAllJavaWindows;
            BasicMap.Global.sw.clear;
        end
        
        function DisposeAllJavaWindows(prefixes)
            if nargin<1 || isempty(prefixes) || isempty(prefixes{1})
                prefixes={'Dissimilarity ', 'QF dissimilarity ',...
                    'Overlap (F-measure)', 'UMAP on', 'UstTest: '};
            end
            doze=java.awt.Window.getWindows;
            N=length(doze);
            for i=1:N
                window=doze(i);
                if ~window.isValid
                    %continue
                end
                try
                    ttl=char(window.getTitle);
                    %disp(ttl);
                    if ~isempty(ttl)
                        if isequal(ttl, 'Note ....')
                            window.dispose;
                        elseif isequal(ttl, 'Testing...')
                            window.dispose;
                        elseif isequal(ttl, 'Note...')
                            window.dispose;
                        elseif isequal(ttl, Gui.UST_LEGEND1)
                            window.dispose;
                        elseif isequal(ttl, Gui.UST_LEGEND2)
                            window.dispose;
                        elseif isequal('Legend', ttl)
                            window.dispose;
                        else
                            found=StringArray.StartsWith(prefixes, ttl);
                            if ~isempty(found)
                                window.dispose;
                            end
                        end
                    end
                catch ex
                    %disp(ex);
                end
            end
        end
        
        function [a,fig]=TextBox(strings, fig, varargin)
            if nargin<2 || isempty(fig)
                fig=figure;
            end
            if ispc
                fs=11;
            else
                fs=13;
            end
            vis=Args.Get('visible', varargin{:});
            a=annotation(fig, 'textbox', ...
                'String', strings, ...
                'FontSize', fs, ...
                'units', 'normalized', ...
                'fontName',  'Arial', ...
                'BackgroundColor', [.99 .99 .93], ...
                'Color', 'blue', ...
                'HorizontalAlignment', 'center', ...
                varargin{:}, ...
                'visible', 'off'); %figure out sizing with visible OFF
                
            if isempty(Args.Get('position', varargin{:}))
                u=get(fig, 'units');
                set(fig, 'units', 'normalized');
                drawnow;
                p=get(a, 'position');
                if BasicMap.Global.highDef
                    w=p(3)*.45;
                else
                    w=p(3)*.42;
                end
                x=.5-w;
                h=p(4)/2;
                y=.5-h;
                set(a, 'position', [x y p(3) p(4)]);
                set(fig, 'units', u);
            end
            if isempty(vis) || strcmpi(vis, 'on')
                set(a, 'visible', 'on');
            end
        end
        
        function [R, C]=SubPlots(N)
            if N==1
                R=1;
                C=1;
            elseif N<4
                R=1;
                C=N;
            else
                R=floor(sqrt(N));
                C=ceil(N/R);
            end
        end
        
        function img=UnderConstructionImg(sz)
            if nargin<1
                sz=.5;
            end
            img=Html.ImgXy('underConstruction.png', [], sz);
        end
        
        function pu=WarnIfBig(tableSize, where, showBusy, threshold)
            pu=[];
            if nargin<4
                threshold=[];
                if nargin<3
                    showBusy=true;
                    if nargin<2
                        where='center';
                    end
                end
            end
            if isempty(threshold) || isnan(threshold) || threshold<1
                threshold=100000*20; % 100000 x 20 doubles
            end
            if tableSize(1)*tableSize(2)>threshold
                pu=PopUp(Html.WrapSmallBold( [...
                    'Loading ' String.encodeInteger(tableSize(1)) ...
                    ' X ' String.encodeInteger(tableSize(2)) ...
                    ' data points<br><br>' Gui.UnderConstructionImg ...
                    '<hr></center></html>']), where,...
                    'Patience ...', showBusy);
            end
        end
        
        function ClosePopUp(pu)
            if ~isempty(pu)
                pu.close;
            end
        end
        
        function ok = IsFigure(h)
            ok=~isjava(h) && ~isempty(h) && ishandle(h) ...
                && strcmp(get(h,'type'),'figure');
        end
        
        function FlashN(H, times, step, deleteWhenDone)
            if nargin<4
                deleteWhenDone=true;
                if nargin<3
                    step=.25;
                    if nargin<2
                        times=5;
                    end
                end
            end
            secs=step;
            for i=1:times
                MatBasics.RunLater(@(h,e)flash1(H, 'off'), secs);
                secs=secs+step;
                MatBasics.RunLater(@(h,e)flash1(H, 'on'), secs);
                secs=secs+step;
            end
            if deleteWhenDone
                MatBasics.RunLater(@(h,e)remove(H), secs);
            end
            
            function remove(H)
                delete(H);
            end
            
            function flash1(H, visible)
                set(H, 'visible', visible);
            end
        end
        
        function H=Flash(ax, D, name, offWhenDone, times, clr, mrkr, ms)
            if nargin<8
                ms=4;
                if nargin<7
                    mrkr='.';
                    if nargin<6
                        clr=[.9 1 .2];
                        if nargin<5
                            times=8;
                            if nargin<4
                                offWhenDone=false;
                                if nargin<3
                                    name='selection(s)';
                                end
                            end
                        end
                    end
                end
            end
            isVisible=isequal('on', ax.Parent.Visible);
            highDef=BasicMap.Global.highDef;
            if isVisible && ~highDef
                 clrStr=['\fontsize{16}\bf\color[rgb]{' String.Num2Str(clr,',') '}\bullet\bullet\bullet'];
            else
                clrStr=['\bf\color[rgb]{' String.Num2Str(clr,',') '}\bullet\bullet\bullet'];
            end
            ttl=get(ax, 'title');
            ttlFs=ttl.FontSize;
            ttlStr=ttl.String;
            if isempty(D)
                if iscell(ttlStr)
                    if endsWith( ttlStr{end}, [clrStr '}'])
                        ttlStr(end)=[];
                        ttl.String=ttlStr;
                    end
                end
                H=[];
                return;
            end
            hasPredictionsObj= isa(name, 'SuhPredictions');
            if hasPredictionsObj
                predictions=name;
                name=predictions.selectedName;
            end
            name=String.RemoveTex(name);
            secs=.1;
            hold(ax, 'on');
            if size(D,2)==3
                H=plot3(ax, D(:,1), D(:,2), D(:,3), 'LineStyle', 'none', ...
                    'marker', mrkr, 'MarkerSize', ms, 'Color', clr, ...
                    'MarkerFaceColor', clr, 'MarkerEdgeColor', clr);
            else
                H=plot(ax, D(:,1), D(:,2), 'LineStyle', 'none', ...
                    'marker', mrkr, 'MarkerSize', ms, 'Color', clr, ...
                    'MarkerFaceColor', clr, 'MarkerEdgeColor', clr);
            end
            if hasPredictionsObj
                predictions.rememberHighlights(H, ttl, ttlStr);
            end
            if times>0
                strSize=String.encodeK(size(D,1));
                subTtl=['^{' strSize ' ' name clrStr '}' ];
                if iscell(ttlStr)
                    if endsWith( ttlStr{end}, [clrStr '}'])
                        ttlStr{end}=subTtl;
                    else
                        ttlStr{end+1}=subTtl;
                    end
                else
                    ttlStr={ttlStr, subTtl};
                end
                if isVisible                    
                    ttl.String={[strSize ' data points'], ...
                        ['from ' name]};
                    if ~highDef
                        ttl.FontSize=16;
                    else
                        ttl.FontSize=11;
                    end
                    MatBasics.RunLater(@(h,e)flash(), secs)
                else
                    ttl.String=ttlStr;
                end
            end
            
            function flash
                if times>0
                    off=mod(times, 2)==0;
                    ms2=ms+(times*1.5);
                    times=times-1;
                    MatBasics.RunLater(@(h,e)flash(), secs)
                else
                    off=offWhenDone;
                    ttl.Visible='on';
                    ttl.FontSize=ttlFs;
                    ttl.String=ttlStr;
                    ms2=ms;
                end
                try
                if off
                    set(H, 'visible', 'off');
                else
                    set(H, 'visible', 'on', 'MarkerSize', ms2);
                end
                catch
                end
            end
        end
    end
end
