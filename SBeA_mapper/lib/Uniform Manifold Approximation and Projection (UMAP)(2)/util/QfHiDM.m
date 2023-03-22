%   Class for Hi-D matching with merging of data subsets using 
%       QFMatch or F-measure or both 
%
%
%   QF Algorithm is described in 
%   https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6586874/
%   and
%   https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5818510/
%
%   Primary Inventor:    Darya Orlova <dyorlova@gmail.com>
%   Primary Developer:   Stephen Meehan <swmeehan@stanford.edu> 
%   Math/Statistics:     Connor Meehan <connor.gw.meehan@gmail.com>
%                        Guenther Walther<gwalther@stanford.edu>
%                        Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%

classdef QfHiDM < handle
    %HiD QF for matching with merging from a pair of data sets
    %t prefix is data set #1 (previously referred to as teacher or training set)
    %s prefix is data set #2 (previously referred to as student or test set)
    
    properties(Constant)
        HTML_MATRIX_LIMIT=10000; %cells
        MERGE_LIMITS=Html.WrapSmallBoldCell({...
            'Unlimited matches per subset',...
            '&lt;= 7 matches per subset (120 mergers)',...
            '&lt;= 8 matches per subset (247 mergers)',...
            '&lt;= 9 matches per subset (502 mergers)',...
            '&lt;= 10 matches per subset (1,013 mergers)',...
            '&lt;= 11 matches per subset (2,036 mergers)',...
            '&lt;= 12 matches per subset (4,083 mergers)',...
            '&lt;= 13 matches per subset (8,178 mergers)',...
            '&lt;= 14 matches per subset (16,369 mergers)',...
            '&lt;= 15 matches per subset (32,752 mergers)',...
            '&lt;= 16 matches per subset (65,519 mergers)',...
            '&lt;= 17 matches per subset (131,054 mergers)'...
            });
        MERGE_STRATEGIES=Html.WrapSmallBoldCell({...
            'Best matches (QF or F)', ...
            '<html>Best + top 1.5 * N matches', ...
            '<html>Best + top 2 * N matches',...
            '<html>Best + top 2.5 * N matches', ...
            '<html>Best + top 3 * N matches',...
            '<html>Best + top 3.5 * N matches',...
            '<html>Best + top 4 * N matches', ...
            '<html>Best + top 4.5 * N matches', ...
            '<html>Best + top 5 * N matches'});
        MSG_ID_TOO_BIG='QFHiDM:tooBig';
        MAX_GATE_SIZE=200000;
        MAX_QF_DISTANCE=100;
        PROP_F_MEASURE_OPTIMIZE='matchStrategyV1.1';
        PROP_MIN_SECS='minSecs';
        PROP_SECS='secs';
        PROP_BIN_SIZE='2logN';
        PROP_QFTREE_FCS='dendrogramFcs';
        PROP_BIN_METHOD='ProbBinMethodV2';
        PROP_MERGE_STRATEGY='mergeStrategy';
        PROP_MERGE_LIMIT='mergeLimit';
        PROP_MERGE_PAUSE='mergePause';
        PROP_DEVIATION_TYPE='tooFarDevTypeV4';
        PROP_DEVIATION_DATA='tooFarDevDataV2';
        DFLT_DEVIATION_TYPE_FACS=2;
        DFLT_DEVIATION_TYPE_CYTOF=2;
        DFLT_DEVIATION_DATA_FACS=2;
        DFLT_DEVIATION_DATA_CYTOF=1;
        PROP_SDU_STAIN='sduStainV4';
        PROP_SDU_SCATTER='sduScatterV4';
        PROP_MAX_DEVIANT_PARAMETERS='maxDeviantParameters';
        PROP_EMD='Emd';
        TIP_MERGE_STRATEGY=[...
            '<html>If matching 10 automatic subsets to 6 non<br>'...
            'automatic subsets then the merge candidates for'...
            '<ul><li><b>Best matches (QF or F)</b><br>' ...
            'are the 10 automatic gate''s best matches'...
            '<li><b>Best + top 1.5 * N matches</b><br>'...
            'are the 10 automatic gate''s best matches<br>'...
            'PLUS the highest 9 matches overall (1.5 * 6)'...
            '<li><b>Best + top 2 * N matches</b><br>'...
            'are the 10 automatic gate''s best matches<br>'...
            'PLUS the highest 12 matches overall (2 * 6)'...
            '<li><b>Best + top 2.5 thru 5 * N matches</b><br>'...
            'Same logic as above with more top matches overall'...
            '<hr></html>'];
        TIP_MERGE_LIMIT=[...
            '<html>Set the max merge candidates per subset'...
            '</html>'];
        TIP_MERGE_PAUSE=[...
            '<html>Pause to allow speed up of limits exceeded'...
            '</html>'];
        TIP_DEVIATION_TYPE='Robust handles skewing better (AKA median absolute deviation)...';
        TIP_DEVIATION_DATA='Log provides normal distribution...';
        F_MEASURE_OPTIMIZE=true;
        TEST_F_MEASURE_OPTIMIZE=false;
        DO_NEXT_BEST=false;
        DEV_MAX=4;%stain parameters
        DEV_MAX_LOG10=1;%scatter parameters
        ALLOW_WAYNE_MOORE_RANDOMIZE=true;
        DISTANCES={'QF', 'CityBlock', 'Chebychev',...
                        'Cosine', 'Euclidean', 'SquaredEuclidean', ...
                        'Earth mover''s (EMD)', 'QF + Euclidean', ...
                        'QF + CityBlock', 'Fast EMD'};
       F_MEASURE_MERGE_FAST=1; %1=YES, 0=NO, -1=TEST
       PROP_DISSIMILARITY_LIMIT='qfLimit';
       MERGE_LIMITS2=Html.WrapSmallBoldCell({...
            'Unlimited matches per subset',...
            '&lt;= 7 matches (per subset, 120 mergers)',...
            '&lt;= 8 matches (per subset, 247 mergers)',...
            '&lt;= 9 matches (per subset, 502 mergers)',...
            '&lt;= 10 matches (per subset,  1,013 mergers )',...
            '&lt;= 11 matches (per subset, 2,036 mergers )',...
            '&lt;= 12 matches (per subset, 4,083 mergers )',...
            '&lt;= 13 matches (per subset, 8,178 mergers)',...
            '&lt;= 14 matches (per subset, 16,369 mergers)',...
            '&lt;= 15 matches (per subset, 32,752 mergers)',...
            '&lt;= 16 matches (per subset, 65,519 mergers)',...
            '&lt;= 17 matches (per subset, 131,054 mergers)'...
            });
        BLAME_FALSE_POS=1;
    end
    
    properties(SetAccess=private)
        isScatter=[];
        sduStain;
        sduScatter;
        scatterDevUnitsExceeded=0;
        stainDevUnitsExceeded=0;
        forbiddenByDevUnits=0;
        devType=1;
        mergeLimit=0;
        distanceType;
        adaptiveBins;
        %emdBins;
        nCells;
        tData;
        sData;
        tCompData;
        sCompData;
        tIsCytof=false;
        sIsCytof=false;
        tDevData;
        sDevData;
        tIdPerRow; 
        sIdPerRow;
        tIds; % > 0
        sIds; % > 0
        tSizes;
        sSizes
        bins;
        result;
        sMergedIds={};
        tMergedIds={};
        pu;
        matches;
        matches2nd;
        nextBest;
        binStrategy;
        sizeLimit=0;
        ignoreTooBig=false;
        cancelled;
        tree;
        isTree=false;
        numLeaves;
        branches;
        branchLevels;
        phyTree;
        treeSz;
        leafSzs;
        nodeSzs;
        branchNames;
        branchQfs;
        nodeQfs;
        isIdentityMatrix=false;
        areEqual;
        isMerging=false;
        devMax;
        qfDistCoefficient=0;
        matrixHtml;
        measurements;
        rawMeasurements;
        fcsIdxs;
        fcsIdxsStr;
        sGt;
        tGt;
        studGid;
        teachGid;
        tMergeCnts;
        sMergeCnts;
        avoidedMerging=false;
        tUnmatched;
        sUnmatched;
        falsePosNegs;
        falsePosEvents;
        falsePosCulprits={};
        falseNegCulprits={};
        falsePosNegCnts;
        matrixUnmerged;
        matrixFinal;
        matchTiming;
        idxsTruePos={};
        idxsFalsePos={};
        idxsFalseNeg={};
        densityBars;
    end
    
    properties
        columnNames;
        tAvoidMerges;
        sAvoidMerges;
        timing;
        sNames;
        tNames;
        debugLevel=0;
        debugTxt;
        debugAb;
        maxDeviantParameters=0;
        matchStrategy=0;
        mergeStrategy=1;
        fMeasuringUnmerged=false;
        fMeasuringMerged=false;
        maxMerges=0;
        tClrs;
        falsePosNegSubsetsFile;
        falsePosNegFile;
        description;
        args;
    end
    
    
    methods(Static)
        %if strategy=0 bin the merged samples ONCE as described in paper an
        %if strategy=-1 same as 0 but scale subset weight to sample size
        %if strategy=1 then bin EACH subset pair (not supported by paper)
        function strategy=BIN_STRATEGY
            strategy=0;
        end
        
        %if bins>3 then create 2^log(N)
        %if bins<4 && >-1 then 2*log
        %if bins is -1 then half smallest cluster        
        %if bins is -2 then 2% of max+min cluster        
        function bins=BINS
            bins=-50; %50% of smallest 
        end
    end
    methods(Access=private)
        function ok=preCheckDeviations(this)
            ok=this.maxDeviantParameters>=0 && ~this.isIdentityMatrix;
        end
    end
    methods
        function this=QfHiDM(tData, tCompData, tIdPerRow, sData, ...
                sCompData, sIdPerRow, bins, binStrategy, ...
                teachStudCacheFile, studTeachCacheFile, devMax, isScatter)
            if nargin<12
                isScatter=[];
                if nargin<11
                    devMax=zeros(1, size(tCompData,2))+QfHiDM.DEV_MAX;
                    if nargin<10
                        studTeachCacheFile=[];
                        if nargin<9
                            teachStudCacheFile=[];
                        end
                    end
                end
            end
           this.isScatter=isScatter;
           this.timing=tic;
           this.matchTiming=this.timing;
           this.devMax=devMax;
           this.tIdPerRow=tIdPerRow;
           [this.tIds, this.tSizes]=MatBasics.GetUniqueIdsAndCntIfGt0(tIdPerRow);
           this.sIdPerRow=sIdPerRow;
           [this.sIds, this.sSizes]=MatBasics.GetUniqueIdsAndCntIfGt0(sIdPerRow);
           if nargin<8
               binStrategy=QfHiDM.BIN_STRATEGY;
               if nargin<7
                   bins=QfHiDM.BINS;
               end
           end
           this.bins=bins;
           allSizes=[this.tSizes' this.sSizes'];
           mn=min(allSizes);

           tooBig=sum(allSizes>QfHiDM.MAX_GATE_SIZE);
           if tooBig>0
               if isempty(this.pu)
                   this.ignoreTooBig=false;
               else
                   if tooBig==1
                       word1=[num2str(tooBig) ' gate is'];
                       word2='';
                   else
                       word1=[num2str(tooBig) ' gates are'];
                       word2='maximum=';
                   end
                   msgTxt=sprintf(...
                       ['<html>%s &gt; %s (%s%s cells), thus QFMatching '...
                       '<br>could be very slow or run out of memory.<br>'...
                       '<br>Ignore these big gates ...or try to match them?<hr></html>'], ...
                       word1, String.encodeK(QfHiDM.MAX_GATE_SIZE),...
                       word2, String.encodeK(max(allSizes)));
                   ignoreTxt='Ignore big gates';
                   [answ, ~, this.cancelled]=questDlg(struct(...
                       'msg', msgTxt, 'remember', 'QfHiDM:tooBig'), ...
                       'Size issues...', ignoreTxt, 'Match (slow)', ignoreTxt);
                   if this.cancelled
                       return;
                   end
                   this.ignoreTooBig=isempty(answ) || isequal(answ, ignoreTxt);
               end
           end
           if bins<-9 %half smallest subset size?                              
               perc=abs(bins)/100;
               sizeLimit_=floor(mn*perc);
               if ~isequal(sData, tData)
                   nEvents=size(sData,1)+size(tData,1);
                   minEvents=min([size(sData,1)+size(tData,1);]);
               else
                   nEvents=size(sData,1);
                   minEvents=nEvents;
               end
               min2mLog=floor(2*log(minEvents));
               this.debugAb='<h2>Probability bin summary</h2>';
               %bins=0;
               if sizeLimit_<min2mLog
                   bins=0;
                   this.debugAb=sprintf([this.debugAb ...
                       '<h3>%d events per probability '...
                       'bin based on 2*log(%s)</h3>'], min2mLog, nEvents);
               else
                   if perc ~= .5 %experimenting with % of min
                       txt=sprintf(...
                           ['<html><center>Bin size is %d <br>'...
                           '(%d%% of smallest subset is %d)</center>'...
                           '<hr></html>'], ...
                           sizeLimit_, round(perc*100, 1), floor(mn));
                       if ~isempty(this.pu)
                           msg(txt);
                       else
                           disp(txt);
                       end
                   end
                   this.sizeLimit=sizeLimit_;
                   this.debugAb=sprintf([this.debugAb ...
                       '<h3>%d events per probability '...
                       'bin based on %s of smallest subset %s</h3>'], ...
                       sizeLimit_, String.encodePercent(perc, 1, 0), ...
                       String.encodeInteger(mn));
               end
           end
           this.nextBest=BasicMap;
           this.binStrategy=binStrategy;
           this.tData=tData;
           this.tCompData=tCompData;
           this.sData=sData;
           this.areEqual=isequal(this.tData, this.sData);
           if this.areEqual
               this.densityBars=DensityBars(this.tData);
           else
               this.densityBars=DensityBars([this.tData; this.sData]);
           end
           this.nCells=MatBasics.CountNonZeroPerColumn(tIdPerRow)+...
               MatBasics.CountNonZeroPerColumn(sIdPerRow);
           this.sCompData=sCompData;
           if this.binStrategy==-1 || this.binStrategy==0
               if bins<-9 %half smallest subset size
                   this.adaptiveBins=AdaptiveBins(tData, sData, ...
                       this.sizeLimit, false, teachStudCacheFile, ...
                       studTeachCacheFile);               
               elseif bins<4  %use 2*log of size of merged data
                   this.adaptiveBins=AdaptiveBins(tData, sData, [],...
                       false, teachStudCacheFile, studTeachCacheFile);
               else
                   this.adaptiveBins=AdaptiveBins(tData, sData, bins, ...
                       true, teachStudCacheFile, studTeachCacheFile);
               end
               [pbR, pbC]=size(this.adaptiveBins.means);
               this.debugAb=sprintf('%s<h3>%s bins of %d dimensions<h3><hr>', ...
                   this.debugAb, String.encodeInteger(pbR), pbC);
           end
        end
        
        function setColumnNames(this, columnNames)
            this.columnNames=columnNames;
        end
        
        function ok=compress(this, probability_bins)
            if nargin<2
                probability_bins=this.probability_bins;
            end
            if ~isempty(probability_bins) && ...
                    isequal(probability_bins.originalData, this.sData)
                ok=true;
                this.probability_bins=probability_bins;
                this.sData=probability_bins.compress;
                this.uncompressedSids=this.sIdPerRow;
                this.sIdPerRow=probability_bins.fit(this.sIdPerRow);
                this.adaptiveBins.compressStudPtrs(probability_bins);
                if this.areEqual
                    this.tData=this.sData;
                    this.uncompressedTids=this.tIdPerRow;
                    this.tIdPerRow=probability_bins.fit(this.tIdPerRow);
                    this.adaptiveBins.compressTeachPtrs(probability_bins);
                end
            else
                ok=true;
            end
        end
        
        function ok=decompress(this)
            if ~isempty(this.probability_bins)
                ok=true;
                this.sData=this.probability_bins.originalData;
                this.sIdPerRow=this.uncompressedSids;
                if this.areEqual
                    this.tData=this.sData;
                    this.tIdPerRow=this.uncompressedTids;
                end
                this.adaptiveBins.uncompress;
            else
                ok=false;
            end
        end
    end
    properties(SetAccess=private)
        probability_bins;
        uncompressedTids;
        uncompressedSids;
    end
    methods
        function fcs=sortColumnNames(this, gt, gid)
            fcs=gt.getFirstFcs(gid);
            this.columnNames=StringArray.Sort(this.columnNames,...
                fcs.statisticParamNames);
            this.fcsIdxs=fcs.findFcsIdxs(this.columnNames);
            this.fcsIdxsStr=MatBasics.toString(this.fcsIdxs,'-');
        end
        
        function prepareMedianMarkerExpressions(this, gt, gid)
            oldOrder=this.columnNames;
            fcs= this.sortColumnNames(gt, gid);
            R=length(this.tIds);
            C=length(this.columnNames);
            mdns=zeros(R, C);
            oldRaw=MatBasics.GetMdns(this.tCompData, this.tIdPerRow, this.tIds);
            if isempty(fcs.logicle.out)
                for i=1:R
                    result_=zeros(1,C);
                    for j=1:C
                        result_(j)=oldRaw(i,j);
                    end
                    mdns(i,:)=result_;
                end
                this.measurements=mdns;
                this.rawMeasurements=oldRaw;

                return;
            end
            Ws=fcs.logicle.out.Ws;
            spn=fcs.statisticParamNames;
            newRaw=zeros(R, C);
            for i=1:R
                result_=zeros(1,C);
                for j=1:C
                    name=this.columnNames{j};
                    fcsCol=StringArray.IndexOf(spn,name);
                    oldI=StringArray.IndexOf(oldOrder, name);
                    W=Ws(fcsCol);
                    T=fcs.getUpperLimit(fcsCol);
                    v=oldRaw(i,oldI);
                    if W==0
                        result_(j)=v;
                    else
                        result_(j)=Logicle.TransformFast(v, T, W, ...
                            fcs.hdr.isCytof);
                    end
                    newRaw(i,j)=v;
                end
                mdns(i,:)=result_;
            end
            this.measurements=mdns;
            this.rawMeasurements=newRaw;
        end
        
        function webPage(this)
            if this.debugLevel>0 && (this.binStrategy==-1 || this.binStrategy==0)
                if this.bins<-9 %half smallest subset size
                    sl=this.sizeLimit;
                    fixed=false;
                elseif this.bins<4  %use 2*log of size of merged data
                    sl=[];
                    fixed=false;
                else
                    sl=this.bins;
                    fixed=true;
                end                
                [~, ~,~,~,~, html, dataHtml, idHtml, statHtml]=...
                    probabilityBins(this.tData, this.sData, sl, fixed, [], ...
                    this.tIdPerRow);
                idHtml=['<hr><h2>Probability bin results per gate</h2>' idHtml];
                Html.Browse(['<html>' idHtml this.debugTxt idHtml ...
                    '<hr><h2>Input data & bin assignment</h2>' dataHtml idHtml ...
                    '<hr><h2>Probability bin results per gate</h2>' statHtml...
                    '<hr><h2>Probability binn means/distances</h2>' ...
                    html idHtml '</html>']);
            else
                Html.Browse([this.debugTxt '</html>']);
            end
        end
        
        function setGts(this, teachGt, studGt, teachGid, studGid, fcsNames)
            this.tGt=teachGt;
            this.teachGid=teachGid;
            this.sGt=studGt;
            this.studGid=studGid;
            devData=teachGt.tp.getNumeric(QfHiDM.PROP_DEVIATION_DATA,...
                QfHiDM.DFLT_DEVIATION_DATA_CYTOF);    
            [this.tDevData, this.tIsCytof]=randomize(teachGt, teachGid,...
                this.tCompData);
            [this.sDevData, this.sIsCytof]=randomize(studGt, studGid, ...
                this.sCompData);
            this.sduScatter=teachGt.tp.getNumeric(QfHiDM.PROP_SDU_SCATTER, ...
                QfHiDM.DEV_MAX_LOG10);
            this.sduStain=teachGt.tp.getNumeric(QfHiDM.PROP_SDU_STAIN, ...
                QfHiDM.DEV_MAX);
            if this.sduStain ~= QfHiDM.DEV_MAX ...
                    || this.sduScatter ~= QfHiDM.DEV_MAX_LOG10
                N2=length(this.devMax);
                if isempty(this.isScatter)
                    for ii=1:N2
                        if this.devMax(ii)==QfHiDM.DEV_MAX
                            this.devMax(ii)=this.sduStain;
                        else
                            this.devMax(ii)=this.sduScatter;
                        end
                    end
                else
                    for ii=1:N2
                        if ~this.isScatter(ii)
                            this.devMax(ii)=this.sduStain;
                        else
                            this.devMax(ii)=this.sduScatter;
                        end
                    end
                end
            end
            
            function [out, isCytof]=randomize(gt, gid, data)
                out=[];
                isCytof=gt.isCytof(gid) ;
                if devData~=3 && isCytof && QfHiDM.ALLOW_WAYNE_MOORE_RANDOMIZE
                    [R, C]=size(data);
                    ran=-.5+rand(R,C);
                    out=data+ran;
                    if devData==2
                        fcs=gt.getFirstFcs(gid);
                        fcsIdxs_=fcs.findFcsIdxs(fcsNames);
                        N=length(fcsIdxs_);
                        for i=1:N
                            col=fcsIdxs_(i);
                            out(:,i)=Logicle.TransformFastCol(out(:,i), fcs, col);
                        end
                    elseif devData==1
                        out=MatBasics.LogReal(@log10, out);
                    elseif devData==4
                        out=MatBasics.LogReal(@log2, out);
                    elseif devData==5
                        out=MatBasics.LogReal(@log, out);
                    end
                end
            end
        end
        
        function done=compute(this, pu, convertIdsToCellStrings, ...
                totalSteps, reporting, doHtml)
            if nargin<5
                reporting=2;
            end
            if nargin<4
                totalSteps='/5';
            elseif isnumeric(totalSteps)
                totalSteps=['/' num2str(totalSteps)];
            end
            this.nextBest.reset;
            done=false;
            if nargin<3
                convertIdsToCellStrings=true;
                if nargin<2
                    pu=[];
                end
            end
            this.pu=pu;
            this.fMeasuringUnmerged=...
                this.matchStrategy==2 ...
                && ~this.isIdentityMatrix ...
                && isempty(this.debugTxt);
            this.fMeasuringMerged=...
                this.matchStrategy>=2 ...
                && ~this.isIdentityMatrix ...
                && isempty(this.debugTxt);
            this.setText(['Step 1' totalSteps]);
            unmergedQfs=this.computeUnmerged;
            if this.forbiddenByDevUnits>0
                if reporting==2
                    str1=sprintf('%d subset matches &gt; your deviation units thresholds', ...
                        this.forbiddenByDevUnits);
                    str2=sprintf('%d scatter parameter matches are too far apart', this.scatterDevUnitsExceeded);
                    str3=sprintf('%d stain parameter matches are too far apart', this.stainDevUnitsExceeded);
                    disp(str1);
                    disp(str2);
                    disp(str3);
                    msg(Html.WrapHr(['<i>' str1 '</i><ul><li>' str2 ...
                        '<li>' str3 '</ul>']), 8, 'south west', 'Note...');
                end
            end
            if this.isCancelled
                return;
            end
            this.isMerging=true;
            this.setText('Computing mergers', true);
            %ticMerged=tic;
            if ~isempty(this.pu)
                progressBeforeMerge=this.pu.pb.getValue;
            end
            if ~this.checkSpeedUp(unmergedQfs)
                return;
            end
            if this.mergeStrategy>=0
                [M, sIdsM, tIdsM]=this.computeMerged(unmergedQfs, totalSteps);
                %toc(ticMerged);
                if this.isCancelled
                    if this.userWantsToAvoidMerges
                        this.pu.cancelled=false;
                        this.cancelled=false;
                        if ~isempty(this.pu)
                            this.pu.pb.setValue(progressBeforeMerge);
                        end
                        this.avoidedMerging=true;
                        [M, sIdsM, tIdsM]=this.computeMerged(unmergedQfs, totalSteps);
                        if this.isCancelled
                            return;
                        end
                    else
                        return;
                    end
                end
                this.sMergedIds=sIdsM;
                this.tMergedIds=tIdsM;
            else
                M=unmergedQfs; sIdsM=[]; tIdsM=[];
            end
            this.matrixUnmerged=unmergedQfs;
            this.matrixFinal=M;
            this.setText(['Step 4' totalSteps]);
            collectBestMatches(this, M, convertIdsToCellStrings);
            if this.cancelled
                return;
            end
            this.matchTiming=toc(this.matchTiming);
            this.pu=[];
            done=true;
            [mnRows, mnCols]=MatBasics.Min(M);
            if this.fMeasuringUnmerged
                ttl='Scores are 1-F measure';
            else
                if this.fMeasuringMerged
                    ttl=['Scores: mass+distance dissimilarity (QFMatch)<br>' ...
                        '(Optimized by F measure)'];
                else
                    ttl='Scores: mass+distance dissimilarity (QFMatch) unoptimized';
                end
            end
            if (nargin<6 || doHtml) && QfHiDM.HTML_MATRIX_LIMIT>=numel(M) 
                this.matrixHtml=['<html><center><h2>' ttl '</h2><hr></center>' ...
                    Html.MatrixColored(...
                    doHdr(this.sIds, sIdsM, this.sNames, this.sSizes, 'test'), ...
                    doHdr(this.tIds, tIdsM, this.tNames, this.tSizes, 'train'), M, {},-1,@encode)...
                    '</html>'];
            end
            
            function num=encode(row, col, num)
                try
                    if num==QfHiDM.MAX_QF_DISTANCE
                        num='';
                        return;
                    end
                    if num>QfHiDM.MAX_QF_DISTANCE
                        num=num-QfHiDM.MAX_QF_DISTANCE;
                        num=['<small>' num2str(num) '>sdu</small>'];
                        return;
                    end
                    num=String.encodeRounded(num, 2, true);
                    
                    if mnCols(col)==row && mnRows(row)==col
                        num=['<b><font color="red">' num '</font></b>'];
                    elseif mnCols(col)==row || mnRows(row)==col
                        num=['<b>' num '</b>'];
                    end
                catch ex
                    ex.getReport
                end
            end
            function hdr=doHdr(ids, mergeIds, names, szs, setName)
                nIds=length(ids);
                if isempty(names)
                    names=cell(1,nIds);
                    for i=1:nIds
                        names{i}=[setName ' #' num2str(i)];
                    end
                end
                nMergeIds=length(mergeIds);
                hdr=cell(1, nIds+nMergeIds);
                for i=1:nIds
                    hdr{i}=[names{i} '<br>  ID=' num2str(ids(i)) '; '...
                        String.encodeInteger(szs(i))];
                end
                for i=1:nMergeIds
                    if size(mergeIds{i},2)>1
                        hdr{i+nIds}=['Merged IDs=' num2str(mergeIds{i})];
                    else
                        hdr{i+nIds}=['Merged IDs=' num2str(mergeIds{i}')];
                    end
                end
            end
        end
        
        
        function  matrix=computeQfPlusDist(this, matrix, fnc)
            dt=this.distanceType;
            if ~isequal(dt, 'QF + Euclidean')...
                    && ~isequal(dt, 'QF + CityBlock') 
                return;
            end
            if isequal(dt, 'QF + Euclidean')
                this.distanceType='Euclidean';
            else
                this.distanceType='CityBlock';
            end
            distanceMatrix=feval(fnc);
            this.distanceType=dt;
            
            % every time dendrogram is constructed
            %   compute the coefficient ONCE for unmerged subsets ONLY
            if this.qfDistCoefficient==0 
                minQf=min(matrix(matrix(:)~=0));% avoid 0 identity value
                maxDistance=max(distanceMatrix(:));
                this.qfDistCoefficient=(maxDistance/minQf)^(-1);
            end
            matrix=matrix+(this.qfDistCoefficient*distanceMatrix);
        end
        
        function done=computeTree(this, pu, names)
            dt=BasicMap.Global.getNumeric(QfTree.PROP_DISTANCE, ...
                QfTree.DFLT_DISTANCE);
            this.distanceType=QfHiDM.DISTANCES{dt};
            this.isIdentityMatrix=true;
            this.isTree=true;
            this.tree=BasicMap;
            this.nextBest.reset;
            done=false;
            this.tNames=names;
            if nargin<3
                if nargin<2
                    pu=[];
                end
            end
            this.pu=pu;
            this.focusPriorFig;
            this.setText(['Computing phenogram using ' ...
                this.distanceType ' distance']);
            this.numLeaves=length(this.tIds);
            if ~isempty(this.debugTxt)
                this.debugTxt=[this.debugTxt this.debugAb];
            end
            [matrix, tSzs]=this.computeUnmerged;
            this.treeSz=sum(tSzs);
            try
                if BasicMap.Global.has(QfTree.PROP_FREQ_BASIS)
                    tz=BasicMap.Global.get(QfTree.PROP_FREQ_BASIS);
                    if isnumeric(tz) && ~isnan(tz)
                        if tz>this.treeSz
                            this.treeSz=tz;
                        end
                    end
                    BasicMap.Global.remove(QfTree.PROP_FREQ_BASIS);
                end
            catch
            end
            this.leafSzs=tSzs;
            if this.isCancelled
                return;
            end
            matrix=this.computeQfPlusDist(matrix, ...
                @()computeUnmerged(this));
            if this.isCancelled
                return;
            end
            [pairs, unpaired]=MatBasics.FindBestPairs(matrix, max(matrix(:))+100);
            nPairs=size(pairs,1);
            if nPairs==0
                return;
            end
            nUnpaired=length(unpaired);
            prevIds=cell(1, this.numLeaves);
            for i=1:this.numLeaves
                prevIds{i}=this.tIds(i);
            end
            if nPairs+nUnpaired>1
                level=2;
                while nPairs+nUnpaired>1
                    nextIds=cell(1, nPairs+nUnpaired);
                    for i=1:nPairs
                        nextIds{i}=newBranch(pairs(i,:));
                    end
                    for j=1:nUnpaired
                        nextIds{i+j}=prevIds{unpaired(j)};
                    end
                    levelTxt=['Phenogram level #' num2str(level) ':'];
                    [matrix, tSzs]=this.computeNbyN(nextIds, nextIds, levelTxt);
                    if this.isCancelled
                        return;
                    end
                    matrix=this.computeQfPlusDist(matrix, ...
                        @()computeNbyN(this, nextIds, nextIds, levelTxt));
                    if this.isCancelled
                        return;
                    end
                    [pairs, unpaired]=MatBasics.FindBestPairs(matrix, max(matrix(:))+100);
                    nPairs=size(pairs,1);
                    nUnpaired=length(unpaired);
                    prevIds=nextIds;
                    level=level+1;
                end
            end
            if this.isCancelled
                return;
            end
            if nPairs==1
                newBranch(pairs(1,:));
            end
            [this.phyTree, this.branchNames, this.nodeQfs, branchSzs,...
                this.branchQfs]=Branch.PhyTree(this.branches, this.numLeaves);
            this.nodeSzs=[this.leafSzs branchSzs];
            this.pu=[];
            done=true;
            
            function merge=newBranch(pair)
                left_=pair(1);
                right_=pair(2);
                merge=this.addBranch(...
                    matrix(left_, right_),...
                    tSzs(left_), tSzs(right_),...
                    prevIds{left_}, prevIds{right_});
            end
        end
        
        function qfTree=viewTree(this, ttl, ...
                props,  colors, edgeColors, lineWidths, tNames)
            qfTree=QfTree(this, ttl, props, '', colors, ...
                edgeColors, lineWidths, tNames);
        end
        
        function [tUnmatched, tN, sUnmatched, sN]=getMatchCounts(this)
            sN=length(this.sIds);
            tN=length(this.tIds);
            tUnmatched=this.tUnmatched;
            sUnmatched=this.sUnmatched;
        end
        
        function [data, unmatched,matchesStr]...
                =getTableData(this, clrs, extraColumns)
            if nargin<3
                extraColumns=0;
                if nargin<2
                    clrs=[];
                end
            end
            sN=length(this.sIds);
            tN=length(this.tIds);
            if isempty(clrs)
                clrs=zeros(tN, 3);
            end
            data=cell(tN+sN, 10+extraColumns);
            for i=1:tN
                data{i, 1}=i;
                data{i, 2}=String.RemoveTex(this.tNames{i});
            end
            sNames_=this.getStudNames;
            for i=1:sN
                data{tN+i, 1}=tN+i;
                data{tN+i, 2}=String.RemoveTex(sNames_{i});
            end
            tSz=sum(this.tSizes);
            sSz=sum(this.sSizes);
            n=length(this.matches);
            for i=1:n
                match=this.matches{i};
                tIdx=find(this.tIds==str2double(match.tIds{1}),1);
                cnt=length(match.tIds)+length(match.sIds);
                processIds(0, match.tIds, this.tIds, this.tSizes, tSz, cnt,...
                    match.qfDissimilarity, match.fMeasure, tIdx);
                processIds(tN, match.sIds, this.sIds, this.sSizes, sSz, cnt,...
                    match.qfDissimilarity, match.fMeasure, tIdx);
            end
            for i=1:tN+sN
                if isempty(data{i,3})
                    data{i, 3}=0;
                    data{i, 4}=nan;
                    data{i, 5}=nan;
                    if i>tN
                        group='no';
                        sz=this.sSizes(i-tN);
                        freq=sz/sSz;
                    else
                        group='yes';
                        sz=this.tSizes(i);
                        freq=sz/tSz;
                    end
                    data{i, 6}=group;
                    data{i, 7}=freq;
                    data{i, 8}=sz;
                    data{i, 9}=Html.Symbol([.8 .8 .8], freq*200);
                    data{i, 10}=nan;
                end
            end
            % now create match IDs that reflect order of BEST match
            [uu,~,ic]=unique(cell2mat(data(:,4)));
            worstRank=sum(~isnan(uu))+1;
            n_=length(ic);
            this.tUnmatched=0;
            this.sUnmatched=0;
            for i=1:n_
                dissimilarity=data{i, 4};
                if isnan(dissimilarity)
                    data{i, end}=worstRank;
                    if i<=tN
                        this.tUnmatched=this.tUnmatched+1;
                    else
                        this.sUnmatched=this.sUnmatched+1;
                    end
                else
                    data{i, 4}=1-dissimilarity;
                    data{i, end}=ic(i);
                end
            end
            unmatched=this.tUnmatched+this.sUnmatched;
            matchesStr=QfHiDM.GetMatchesString(...
                [this.sUnmatched this.tUnmatched], [sN tN]);
            
            function processIds(startIdx, matchStrIds, ids, szs, sz, ...
                    cnt, q, f, tIdx)
                if startIdx>0
                    group='no';
                else
                    group='yes';
                end
                n_=length(matchStrIds);
                if n_==0
                    return;
                end
                for j=1:n_
                    id=str2double(matchStrIds{j});
                    idx=find(id==ids, 1);
                    if ~isempty(idx)
                        row=idx+startIdx;
                        data{row, 3}=cnt;
                        data{row, 4}=q;
                        data{row, 5}=f;
                        data{row, 6}=group;
                        frq=szs(idx)/sz;
                        data{row, 7}=frq;
                        data{row, 8}=szs(idx);
                        data{row, 9}=Html.Symbol(clrs(tIdx,:), frq*200);
                        data{row, 10}=i;
                    end
                end
            end 
        end

        function match=getMatch(this, id, isIdTrainingSet)
            if nargin<3
                isIdTrainingSet=true;
            end
            if isnumeric(id)
                id=num2str(id);
            end
            n=length(this.matches);
            if isIdTrainingSet
                for i=1:n
                    match=this.matches{i};
                    nn=length(match.tIds);
                    for j=1:nn
                        if isequal(id, match.tIds{j})
                            return;
                        end
                    end
                end
            else
                for i=1:n
                    match=this.matches{i};
                    nn=length(match.sIds);
                    for j=1:nn
                        if isequal(id, match.sIds{j})
                            return;
                        end
                    end
                end
            end
            match=[];
        end
        
        function [tCnt, sCnt, tBestIdx4S, tBestId4S, qfs, fms, multipleT4S]=...
                getMatches(this, id, isIdTrainingSet)
            if nargin>1
                if nargin<3
                    isIdTrainingSet=true;
                end
                tBestIdx4S=[]; tBestId4S=[]; qfs=[]; fms=[];
                multipleT4S=[];
                match=this.getMatch(id, isIdTrainingSet);
                if isempty(match)
                    sCnt=[]; 
                    tCnt=[];
                    return;
                end
                nn=length(match.sIds);
                sCnt=zeros(1,nn);
                for i=1:nn
                    sCnt(i)=str2double(match.sIds(i));
                end
                nn=length(match.tIds);
                tCnt=zeros(1,nn);
                for i=1:nn
                    tCnt(i)=str2double(match.tIds(i));
                end
                return;
            end
            nS=length(this.sIds);
            nT=length(this.tIds);
            tBestIdx4S=zeros(1, nS);
            tBestId4S=zeros(1, nS);
            tCnt=zeros(1, nT);
            sCnt=zeros(1, nS);            
            n=length(this.matches);
            qfs=zeros(1, nS);
            fms=zeros(1, nS);
            multipleT4S=cell(1, nS);
            for i=1:n
                match=this.matches{i};
                nTeaches=length(match.tIds);
                cnt=nTeaches+length(match.sIds);
                tCnt=processIds(match.tIds, this.tIds, tCnt, cnt);
                [sCnt, sIdxs]=processIds(match.sIds, this.sIds, sCnt, cnt);
                if nTeaches<2
                    tId=str2double(match.tIds{1});
                    tIdx=find(this.tIds==tId,1);
                    multipleTrainers=[];
                else
                    multipleTrainers=zeros(1,nTeaches);
                    %find most frequent
                    mx=0;
                    for ii=1:nTeaches
                        tId_=str2double(match.tIds{ii});
                        multipleTrainers(ii)=tId_;
                        tIdx_=find(this.tIds==tId_,1);
                        sz=this.tSizes(tIdx_);
                        if sz>mx
                            mx=sz;
                            tIdx=tIdx_;
                            tId=tId_;
                        end
                    end
                end
                for k=1:length(sIdxs)
                    tBestId4S(sIdxs(k))=tId;
                    tBestIdx4S(sIdxs(k))=tIdx;
                    qfs(sIdxs(k))=match.qfDissimilarity;
                    fms(sIdxs(k))=match.fMeasure;
                    multipleT4S{sIdxs(k)}=multipleTrainers;
                end
            end
            
            function [cnts, idxs]=processIds(strIds, ids, cnts, cnt)
                idxs=[];
                n_=length(strIds);
                if n_==0
                    return;
                end
                for j=1:n_
                    id=str2double(strIds{j});
                    idx=find(id==ids, 1);
                    if ~isempty(idx)
                        idxs(end+1)=idx;
                        cnts(idx)=cnt;
                    end
                end
            end
        end

        function [trainedTestEvents, trainingMap, dissimilarities, ...
                fMeasures]=matchTestEvents(this, verbose)
            sIdPer=this.sIdPerRow(:,1);
            C=size(sIdPer, 2);
            C2=size(this.tIdPerRow, 2);
            trainedTestEvents=zeros(size(sIdPer, 1), 1);
            [~, ~, tIdxs, bestTrainer4TestClass, dissimilarities, ...
                fMeasures, multipleTrainers]=this.getMatches;
            N=length(bestTrainer4TestClass);
            trainingMap=Map;
            for sIdx=1:N
                tId=bestTrainer4TestClass(sIdx);
                tIdx=tIdxs(sIdx);
                sId=this.sIds(sIdx);
                if nargin==1 || verbose
                    printMatch;
                end
                if tId>0
                    for c=1:C
                        if any(sIdPer(:,c)==sId)
                            if this.areEqual && ~isempty(multipleTrainers{sIdx})
                                try % recent improvement to accuracy
                                    handleMultipleTrainers
                                catch ex
                                    ex.getReport
                                end
                            else
                                trainingMap.add(num2str(tId), sIdx);
                                trainedTestEvents(sIdPer(:,c)==sId)=tId;
                            end
                            break;
                        end
                    end
                end
            end
            
            function handleMultipleTrainers
                si=find(this.sIds==sId);
                isSid=sIdPer(:,c)==sId;
                trainingIds=multipleTrainers{sIdx};
                nTrainingIds=length(trainingIds);
                trainingIdsPerRow=zeros(size(this.tIdPerRow,1), 1);
                assert(length(isSid)==length(trainingIdsPerRow));
                badOverlap=zeros(1,nTrainingIds);
                dissimilarity=zeros(1,nTrainingIds);
                sizes=zeros(1,nTrainingIds);
                names=cell(1, nTrainingIds);
                for j=1:nTrainingIds
                    tId=trainingIds(j);
                    ti=find(this.tIds==tId);
                    names{j}=this.tNames{ti};
                    trainingMap.add(num2str(tId), sIdx);
                    for cc=1:C2
                        if any(this.tIdPerRow(:,cc)==tId)
                            l=this.tIdPerRow(:,cc)==tId;
                            assert(length(l)==length(isSid));
                            truPos=l & isSid;
                            if this.fMeasuringUnmerged %matching done by overlap?
                                % matrixUnmerged cell contains 1 - fMeasure
                                badOverlap(j)=this.matrixUnmerged(si,ti);
                                dissimilarity(j)=this.distance(sId, tId);
                            else % NO .. matching done by similarity
                                % matrixUnmerged cell contains
                                % dissimilarity
                                dissimilarity(j)=this.matrixUnmerged(si,ti);
                                badOverlap(j)=1-this.fMeasure(sId, tId);
                            end
                            sizes(j)=this.tSizes(ti);
                            trainedTestEvents(truPos)=tId;
                            trainingIdsPerRow(l)=tId;
                            break;
                        end
                    end
                end
                lFalsePos=isSid& (trainingIdsPerRow==0);
                assert(length(lFalsePos)==length(isSid));
                falsePosIdxs=find(lFalsePos);
                nFalsePosIdxs=length(falsePosIdxs);
                falsePosIdx=1;
                totalBadOverlap=sum(badOverlap);
                totalDissimilarity=sum(dissimilarity);
                totalSize=sum(sizes);
                for j=1:nTrainingIds
                    tId=trainingIds(j);
                    idxs=[];
                    if j==nTrainingIds
                        idxs=falsePosIdxs(falsePosIdx:end);
                    else
% how do we proportionalize the blame (distribute the false
% positives) for multiple trainers? 
%   1)biggest gets most blame? (size matters?)
%   2)worst overlap gets most blame?
%   3)most dissimilar gets most blame?
%   On Nov 10 Connor and I decided to go with the biggest
%   trainer gets the most blame (false positives)

                        if QfHiDM.BLAME_FALSE_POS == 1
                            proportion=sizes(j)/totalSize;
                        elseif QfHiDM.BLAME_FALSE_POS==2
                            % original try
                            proportion=badOverlap(j)/totalBadOverlap;
                        else %if QfHiDM.BLAME_FALSE_POS==3
                            proportion=dissimilarity(j)/totalDissimilarity;
                        end
                        nFalsePos=floor(proportion*nFalsePosIdxs);
                        if falsePosIdx<nFalsePosIdxs
                            if falsePosIdx+nFalsePos>nFalsePosIdxs
                                idxs=falsePosIdxs(falsePosIdx:end);
                            else
                                idxs=falsePosIdxs(falsePosIdx:falsePosIdx+nFalsePos);
                            end
                        end
                        falsePosIdx=falsePosIdx+nFalsePos;
                    end
                    if ~isempty(idxs)
                        trainedTestEvents(idxs)=tId;
                    end
                end
            end
            
            function printMatch
                if sIdx>length(this.sNames)
                    sName=['Test set ID=' num2str(sId)];
                else
                    sName=this.sNames{sIdx};
                end
                sName=[sName '(' num2str(sId) ')'];
                tIdStr=['(' num2str(tId) ')'];
                if tId>0
                    tSz=this.tSizes(tIdx);
                    tName=[this.tNames{tIdx} tIdStr];
                    tIds_=multipleTrainers{sIdx};
                    if length(tIds_)>1
                        tName=[tName ' and also '];
                        for i=2:length(tIds_)
                            tName=[tName '[' ...
                                this.tNames{find(this.tIds==tIds_(i), 1)}...
                                '](' num2str(tIds_(i)) ')'];
                        end
                    end
                else
                    tSz=0;
                    tName=['**NOT MATCHED**' tIdStr];
                end
                fprintf(...
                    '%d events of "%s"  best matches %d of "%s"\n', ...
                    this.sSizes(sIdx), sName, tSz, tName);
            end
        end
    end
    methods(Static)
        function prp=PlotFalsePos(precisions, recalls, names, tSizes, clrs)
            try
                prp=FalsePositiveNegative.PlotPrecisionRecall(...
                    precisions', recalls', ...
                    names','visible',false, 'invert', true,...
                    'sizes', tSizes, 'colors', clrs);
            catch ex
                ex.getReport
                prp=[];
            end
        end
    end
    methods
        function relocateFalsePosNegFiles(this, file, saving, args)
            f1=File.SwitchExtension(file, '.txt') ;
            if ~isempty(this.falsePosNegFile)
                File.moveFile(this.falsePosNegFile, f1, true);
            end
            this.falsePosNegFile=f1;
            if nargin<3 || ~saving
                f2=[File.SwitchExtension(file, '') FalsePositiveNegative.FILE_EXTENSION];
                if nargin<4
                    args={};
                end
                qft=QfTable(this,[],[],[],false, args);
                qft.save(this,f2)
                this.falsePosNegSubsetsFile=f2;
            end
        end
        
        function saveFalsePosNegProps(this, props, args)
            try
                if this.getFalsePosNegRecords
                    this.getFalsePosNegsTab(false, args);
                    this.relocateFalsePosNegFiles(props.propertyFile, false, args);
                    props.set('falsePosNegFile', this.falsePosNegFile);
                    props.set('falsePosNegSubsetsFile', this.falsePosNegSubsetsFile);
                    props.set('falsePosNegCnts', num2str(this.falsePosNegCnts(:)'));
                    props.setAll('falsePosCulprits', this.falsePosCulprits);
                    props.setAll('falseNegCulprits', this.falseNegCulprits);
                    props.setAll('tNames', this.tNames);
                    props.setAll('sNames', this.sNames);
                end
            catch ex2
                ex2.getReport
            end
        end
        
        function [ok, prp]=getFalsePosNegRecords(this, doGscatter)
            prp=[];
            if ~isequal(this.tData, this.sData)
                ok=false;
                this.falsePosNegs={};
                return;
            end
            ok=true;
            [trainedTestEvents, trainingMap, dissimilarities, fMeasures]=...
                this.matchTestEvents(QfHiDM.DEBUG_LEVEL>0);
            this.falsePosEvents=trainedTestEvents;
            trainingEvents=this.tIdPerRow;
            [this.falsePosNegs, precisions, recalls]=...
                FalsePositiveNegative.CreateRecords(this.tIds, this.tSizes, ...
                this.tNames, this.sIds, this.sSizes, this.sNames, ...
                trainingEvents,trainedTestEvents, trainingMap, ...
                dissimilarities, fMeasures);
            if nargin>1 && doGscatter
                try
                    prp=FalsePositiveNegative.PlotPrecisionRecall(...
                        precisions', recalls', ...
                        this.tNames','visible',false, 'invert', true,...
                        'sizes', this.tSizes, 'colors', this.tClrs);
                catch ex
                    ex.getReport
                    prp=[];
                end
            end
        end
        
        function [body, fig]=getFalsePosNegsTab(this, doPlot, args)
            reduction='0';
            sampleSet='n/a';
            trainingSet='teach';
            testSet='stud';
            n_neighbors=30;
            hiD=size(this.tData,2);
            loD=2;
            matchType=3;
            clusterDetail=1;
            if nargin>2 && ~isempty(args)
                if isfield(args, 'training_set') && ...
                        ~isempty(args.training_set)
                    trainingSet=args.training_set;
                elseif isfield(args, 'template_file') && ...
                        ~isempty(args.template_file)
                    [~,trainingSet]=fileparts(args.template_file);
                end
                if isfield(args, 'test_set') && ...
                        ~isempty(args.test_set)
                    testSet=args.test_set;
                elseif isfield(args, 'csv_file_or_data') && ...
                        ~isempty(args.csv_file_or_data) && ...
                        ischar(args.csv_file_or_data) 
                    [~,testSet]=fileparts(args.csv_file_or_data);
                end
                if isfield(args, 'n_neighbors') && ...
                        ~isempty(args.n_neighbors)
                    n_neighbors=args.n_neighbors;
                end
                if isfield(args, 'n_components')
                    loD=args.n_components;
                end
                if isfield(args, 'hiD')
                    hiD=args.hiD;
                end
                if isfield(args, 'clusterDetail')
                    clusterDetail=args.clusterDetail;
                end
            end
            [body, notFound]=FalsePositiveNegative.TabRows(...
                this.falsePosNegs, reduction, sampleSet, trainingSet, ...
                testSet, n_neighbors, hiD, loD, matchType, clusterDetail);
            if ~isempty(notFound)
                body=[body newline notFound];
            end
            body=[body newline];
            this.falsePosNegFile=tempname;
            File.SaveTextFile(this.falsePosNegFile, ...
                [FalsePositiveNegative.TabHead body])
            fig=[];
            if nargin<2 || doPlot
                fig=FalsePositiveNegative.Plot([0 1], this.falsePosNegFile);
            end
        end
       
        function [ti, truePosIdxs, falsePosIdxs, negIdxs, actualIdxs]...
                =getPredictions(this, trainingId, verbose)
            if nargin<3
                verbose=true;
            end
            ti=find(this.tIds==trainingId,1);
            tC=size(this.tIdPerRow,2);
            sC=size(this.sIdPerRow,2);
            for c=1:tC
                if ~any(this.tIdPerRow(:,c)==trainingId)
                    continue;
                end
                is=this.tIdPerRow(:,c)==trainingId;
                truePos=is & this.falsePosEvents==trainingId;
                truePosIdxs=find(truePos)';
                
                l=~is & this.falsePosEvents==trainingId;
                falsePosIdxs=find(l)';
                falsePosTids=zeros(1, length(falsePosIdxs));
                for ii=1:tC
                    v=this.tIdPerRow(l,ii);
                    falsePosTids(v~=0)=v(v~=0);
                end
                posNumerator=length(falsePosIdxs);
                posDenominator=sum(this.falsePosEvents==trainingId);
                l=is & this.falsePosEvents~=trainingId;
                negIdxs=find(l)';
                falseNegSids=zeros(1, length(negIdxs));
                for ii=1:sC
                    v=this.sIdPerRow(l,ii);
                    falseNegSids(v~=0)=v(v~=0);
                end
                negNumerator=length(negIdxs);
                negDenominator=sum(is);

                actualIdxs=find(is)';
                if verbose
                    fprintf('%d ...', c);
                end
                break;
            end
            this.falsePosCulprits{ti}=['<b><u>'...
                String.encodeInteger(posNumerator) '/' ...
                String.encodeInteger(posDenominator) ' ('...
                String.encodePercent(posNumerator, ...
                posDenominator) ')</u></b>:  '  ...
                MatBasics.HistCountsText(...
                falsePosTids, this.tIds, this.tNames)];
            this.falseNegCulprits{ti}=['<b><u>'...
                String.encodeInteger(negNumerator) '/' ...
                String.encodeInteger(negDenominator) ' ('...
                String.encodePercent(negNumerator, ...
                negDenominator) ')</u></b>:  '  ...
                MatBasics.HistCountsText(...
                falseNegSids, this.sIds, this.sNames)];
            if ~verbose
                return;
            end
            if ti>0
                tName=this.tNames{ti};
            else
                tName='?';
            end
            fprintf('"%s" ', tName);
            fprintf(...
                'Predictions: \n\t%d true pos, %d false pos, %d false neg, %d actual\n',...
                length(truePosIdxs), length(falsePosIdxs),...
                length(negIdxs), length(actualIdxs));
            if verbose==2
                fprintf('Indexes are from 1 to %d\n', size(this.tIdPerRow,1));
            end
        end
        
        function [tCnt, sCnt, tMi, sMi, t1stIdx4S, t1stId4S, tNot, sNot,...
                tNotIds, sNotIds]=getMatches2(this)
            nS=length(this.sIds);
            nT=length(this.tIds);
            tNot=true(1, nT);
            sNot=true(1, nS);
            t1stIdx4S=zeros(1, nS);
            t1stId4S=zeros(1, nS);
            tCnt=zeros(1, nT);
            sCnt=zeros(1, nS);
            tMi=nan(1, nT);
            sMi=nan(1, nS);
            
            n=length(this.matches);
            for i=1:n
                match=this.matches{i};
                cnt=length(match.tIds)+length(match.sIds);
                [tNot, tCnt,tMi]=processIds(match.tIds, this.tIds, ...
                    tNot, tCnt, cnt, tMi);
                [sNot, sCnt, sMi, sIdxs]=processIds(match.sIds, this.sIds, ...
                    sNot, sCnt, cnt, sMi);
                tId=str2double(match.tIds{1});
                tIdx=find(this.tIds==tId,1);
                for k=1:length(sIdxs)
                    t1stId4S(sIdxs(k))=tId;
                    t1stIdx4S(sIdxs(k))=tIdx;
                end
            end
            tNotIds=this.tIds(tNot);
            sNotIds=this.sIds(sNot);
            
            function [not, cnts, mi, idxs]=processIds(strIds, ids, not,...
                    cnts, cnt, mi)
                idxs=[];
                n_=length(strIds);
                if n_==0
                    return;
                end
                for j=1:n_
                    id=str2double(strIds{j});
                    idx=find(id==ids, 1);
                    if ~isempty(idx)
                        not(idx)=false;
                        idxs(end+1)=idx;
                        cnts(idx)=cnt;
                        mi(idx)=i;
                    end
                end
            end
        end

        function [t,s]=getFreqs(this)
            t=freqOut(this.tSizes, size(this.tData,1));
            s=freqOut(this.sSizes, size(this.sData,1));
            function f=freqOut(szs, rows)
                N=length(szs);
                f=zeros(1, N);
                for i=1:N
                    f(i)=szs(i)/rows;
                end
            end
        end
        
        function names=getStudNames(this)
            if ~isempty(this.sNames)
                names=this.sNames;
            else
                names=cell(1, length(this.sIds));
                N=length(names);
                for i=1:N
                    names{i}=['test subset ID=' num2str(i)];
                end
            end
        end
        
        
        function [tQ, sQ, tF, sF]=getScores(this)
            tQ=nan(1, length(this.tIds));
            sQ=nan(1, length(this.sIds));
            tF=nan(1, length(this.tIds));
            sF=nan(1, length(this.sIds));
            n=length(this.matches);
            for i=1:n
                match=this.matches{i};
                tQ=processIds(match.tIds, this.tIds, tQ, match.qfDissimilarity);
                sQ=processIds(match.sIds, this.sIds, sQ, match.qfDissimilarity);
                tF=processIds(match.tIds, this.tIds, tF, match.fMeasure);
                sF=processIds(match.sIds, this.sIds, sF, match.fMeasure);

            end
            
            function s=processIds(strIds, ids, s, score)
                n_=length(strIds);
                for j=1:n_
                    id=str2double(strIds{j});
                    idx=find(id==ids, 1);
                    if ~isempty(idx)
                        s(idx)=score;
                    end
                end
            end
        end
    end
    
    methods(Access=private)
        function merge=addBranch(this, qfScore, leftSize, rightSize, leftIds, rightIds)
            ptr=this.numLeaves+length(this.branches)+1;
            left2=QfTree.Size(this, leftIds);
            right2=QfTree.Size(this, rightIds);
            branch=Branch(this.tree, this.tIds,qfScore, left2, right2, leftIds, rightIds, ptr);
            if branch.leftPtr<=this.numLeaves
                branch.leftName=this.tNames(branch.leftPtr);
                if QfHiDM.DEBUG_LEVEL>0
                    disp(['teachName=' branch.leftName ' ' num2str(leftSize)]);
                end
            end
            if branch.rightPtr<=this.numLeaves
                branch.rightName=this.tNames(branch.rightPtr);
                if QfHiDM.DEBUG_LEVEL>0
                    disp(['teachName=' branch.rightName ' ' num2str(rightSize)]);
                end
            end
            this.branches{end+1}=branch;
            merge=branch.merge;
        end
        
        function ok=userWantsToAvoidMerges(this)
            ok=false;    
            try
                ok=AvoidMerging.Adjust(this);
            catch ex
                disp(ex);
            end
        end
        
        function [M, sIdsM, tIdsM]=computeMerged(this, unmergedQfs, totalSteps)
            this.setText(['Step 2' totalSteps]);
            [M, sIdsM]=go(unmergedQfs, unmergedQfs, false);
            if ~isempty(this.pu)
                if ~isempty(this.pu.cancelBtn)
                    this.pu.cancelBtn.setText('Cancel');
                end
            end
            if this.isCancelled
                tIdsM=[];
                this.getMergers(unmergedQfs, true);
                return;
            end
            this.setText(['Step 3' totalSteps]);
            [M, tIdsM]=go(unmergedQfs, M, true);
            if ~isempty(this.pu)
                if ~isempty(this.pu.cancelBtn)
                    this.pu.cancelBtn.setText('Cancel');
                end
            end
            function [newMatrix, idsM]=go(...
                    unmergedMatrix, newMatrix, transpose)
                idsM={};
                [idxsAllMerges, mergerIdxs, idxsMergable]=this.getMergers(...
                    unmergedMatrix, transpose);
                if this.isCancelled
                    return;
                end
                nCols=length(mergerIdxs);
                if nCols==0
                    return;
                end
                if transpose
                    word='2nd pass';
                    allStudIds=[QfHiDM.ToCell(this.sIds) sIdsM];
                else
                    word='1st pass';
                end
                if ~isempty(idxsAllMerges)
                    cnt=sum(cellfun(@(x) numel(x),idxsAllMerges));
                else
                    cnt=nCols;
                end
                this.initProgress(cnt);
                if this.fMeasuringMerged
                    word2='F measure matches';
                else
                    word2='QFMatches';
                end
                this.setText(sprintf(...
                    '%s by %s %s for %s mergers', ...
                    String.encodeInteger(cnt), ...
                    String.encodeInteger(nCols), word2, word), true);
                for jj=1:nCols
                    if ~isempty(idxsAllMerges)
                        idxs=idxsAllMerges{jj};
                    else
                        idxs=[];
                    end
                    if ~transpose
                        mergerCol=mergerIdxs(jj);
                        ids=QfHiDM.ToIds(idxs, this.sIds);
                        if this.fMeasuringMerged
                            if QfHiDM.F_MEASURE_MERGE_FAST~=1
                                [r, bestRow]=this.fMeasureNby1(ids, ...
                                    this.tIds, mergerCol);
                            end
                            if QfHiDM.F_MEASURE_MERGE_FAST~=0
                                [v, bestIds]=this.getBestMerger(...
                                    this.sIds(idxsMergable{jj}), ...
                                    this.tIds, mergerCol, false);
                                if QfHiDM.F_MEASURE_MERGE_FAST==-1
                                    if ~this.isCancelled &&...
                                            ~isequal(v, r(bestRow, :))
                                        msgTxt=sprintf(...
                                            ['"%s" optimization<hr>'...
                                            'fast FM %s(%s)<br>'...
                                            '<b>versus</b><br>'...
                                            'slow FM %s(%s)'], ...
                                            this.tNames{mergerCol}, ...
                                            String.encodeRounded(v(mergerCol),3), ...
                                            MatBasics.toString(bestIds{1}),...
                                            String.encodeRounded(r(bestRow, mergerCol),3), ...
                                            MatBasics.toString(ids{bestRow}));
                                        if this.areEqual
                                            msg(['<html>' msgTxt '<hr></html>']);
                                        end
                                    end
                                end
                            end
                            if QfHiDM.F_MEASURE_MERGE_FAST==1
                                bestRow=1;
                                r=v;
                                ids=bestIds;
                                this.increment;
                            end
                            if QfHiDM.TEST_F_MEASURE_OPTIMIZE
                                r2=this.computeNbyN(ids, this.tIds, '', mergerCol, false);
                                testMerge(r, r2);
                            end
                        else
                            r=this.computeNbyN(ids, this.tIds, '', mergerCol, false);
                            [~, bestRow]=min(r(:,mergerCol));
                            if QfHiDM.TEST_F_MEASURE_OPTIMIZE
                                [~, xx]=this.fMeasureNby1(ids, this.tIds, mergerCol);
                                if xx~=bestRow
                                    disp('xx~=bestRow');
                                    this.fMeasureNby1(ids, this.tIds, mergerCol);
                                end
                            end
                        end
                        if bestRow>0
                            r=r(bestRow,:);
                            ids={ids{bestRow}};
                        end
                        newMatrix=[newMatrix;r];
                    else
                        mergerRow=mergerIdxs(jj);
                        ids=QfHiDM.ToIds(idxs, this.tIds);
                        if this.fMeasuringMerged
                            if QfHiDM.F_MEASURE_MERGE_FAST~=1
                                [r, bestCol]=this.fMeasure1byN(...
                                    allStudIds, ids, mergerRow);
                            end
                            if QfHiDM.F_MEASURE_MERGE_FAST~=0
                                [v, bestIds]=this.getBestMerger(...
                                    this.tIds(idxsMergable{jj}), ...
                                    allStudIds, mergerRow, true);
                                if QfHiDM.F_MEASURE_MERGE_FAST==-1
                                    if ~this.isCancelled && ...
                                            ~isequal(v, r(:, bestCol))
                                        msgTxt=sprintf(['"%s", '...
                                            'optimization defect <hr>'...
                                            'fast FM %s(%s)<br>'...
                                            '<b>versus</b><br>'...
                                            'slow FM %s(%s)'], ...
                                            this.sNames{mergerRow},...
                                            String.encodeRounded(v(mergerRow), 3), ...
                                            MatBasics.toString(bestIds{1}),...
                                            String.encodeRounded(r(mergerRow, bestCol), 3), ...
                                            MatBasics.toString(ids{bestCol}));
                                        if this.areEqual
                                            msg(['<html>' msgTxt ...
                                                '<hr></html>']);
                                        end
                                    end
                                end
                            end
                            if QfHiDM.F_MEASURE_MERGE_FAST==1
                                bestCol=1;
                                r=v;
                                ids=bestIds;
                                this.increment;
                            end
                            if QfHiDM.TEST_F_MEASURE_OPTIMIZE
                                r2=this.computeNbyN(allStudIds, ids, '', mergerRow, true);
                                testMerge(r, r2);
                            end
                        else
                            r=this.computeNbyN(allStudIds, ids, '', mergerRow, true);
                            [~, bestCol]=min(r(mergerRow, :));
                            if QfHiDM.TEST_F_MEASURE_OPTIMIZE
                                [~, xx]=this.fMeasure1byN(allStudIds, ids, mergerRow);
                                if xx~=bestCol
                                    disp('assert(xx==bestCol);');
                                    this.fMeasure1byN(allStudIds, ids, mergerRow)
                                end
                            end
                        end
                        if bestCol>0
                            r=r(:,bestCol);
                            ids={ids{bestCol}};
                        end
                        newMatrix=[newMatrix r];
                    end
                    idsM=[idsM ids];                        
                    if this.isCancelled
                        return;
                    end
                end
            end
            
            function testMerge(r, r2)
                [mn1, mnI1]=min(r(:));
                [mn2, mnI2]=min(r2(:));
                if this.matchStrategy==3
                    good=mn1==mn2;
                else
                    good=mnI1==mnI2;
                end
                if ~good
                    msgBox('F measure issues');
                end
            end
        end
        
        function D=fastEmd(this, tIdSet, sIdSet)
            tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSet);
            sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSet);
            tData_=this.tData(tChoices, :);
            sData_=this.sData(sChoices, :);
            D=AdaptiveBins.Emd(tData_, sData_, 7);
            fprintf('EMD=%s....tIds="%s" & sIds="%s"\n', ...
                String.encodeRounded(D, 4), num2str(tIdSet), ...
                num2str(sIdSet'));
        end
        
        function collectBestMatches(this, M, toCellStrings)
            this.result=MatBasics.SortMatrix(M);
            this.setText(sprintf('Finding best of %s comparisons', ...
                String.encodeInteger(this.result.N) ), true);
            N=this.result.N;
            nTeaches=length(this.tIds);
            nStuds=length(this.sIds);
            nMatches=min([nTeaches nStuds]);
            matchCnt=0;
            xUsed=false(1, nStuds);
            yUsed=false(1, nTeaches);
            this.initProgress(N);
            for i=1:N
                [qfDissimilarity, x, y]=...
                    MatBasics.PokeSortedMatrix(this.result, i);
                try
                    [sIds_, sIdxs]=QfHiDM.GetIds(x, this.sIds, this.sMergedIds);
                    [tIds_, tIdxs]=QfHiDM.GetIds(y, this.tIds, this.tMergedIds);
                catch ex
	                ex.getReport
                    continue;
                end
                
                if ~any(xUsed(sIdxs)) && ~any(yUsed(tIdxs))
                    xUsed(sIdxs)=true;
                    yUsed(tIdxs)=true;
                    makeMatch(true);
                    if this.cancelled
                        return;
                    end
                    matchCnt=matchCnt+1;
                    if ~QfHiDM.DO_NEXT_BEST
                        if matchCnt==nMatches
                            break;
                        end
                    end
                elseif QfHiDM.DO_NEXT_BEST
                    addNextBest(sIds_, sIdxs, xUsed);
                    addNextBest(tIds_, tIdxs, yUsed);
                end
                if this.isCancelled
                    return;
                end
                this.increment;
            end
            
            function cnt=makeMatch(best)
                if toCellStrings
                    match.sIds=QfHiDM.ToCellStrings(sIds_);
                    match.tIds=QfHiDM.ToCellStrings(tIds_);
                else
                    match.sIds=sIds_;
                    match.tIds=tIds_;
                end
                [match.madUnits, match.tFreq, match.sFreq,~,~,match.tIsMaxSd]=...
                    feval(this.devFcn, this.tDevData, this.sDevData, ...
                    this.tIdPerRow, tIds_, this.sIdPerRow, sIds_);
                if this.matchStrategy==2
                    match.fMeasure=abs(qfDissimilarity-1);
                    match.qfDissimilarity=this.distance(sIds_, tIds_);
                else
                    match.qfDissimilarity=qfDissimilarity;
                    if this.areEqual
                        [match.fMeasure,match.precision,match.recall]=MatBasics.F_measure(this.tCompData,...
                            this.sCompData,this.tIdPerRow, tIds_, ...
                            this.sIdPerRow, sIds_);
                    else
                        [match.fMeasure, match.precision,match.recall]=this.fMeasureInBins(tIds_, sIds_);
                    end
                end
                if this.cancelled
                    cnt=0;
                    return;
                end
                match.x=x;
                match.y=y;
                if this.maxDeviantParameters<0
                    disallow=false;
                else
                    try
                        disallow=sum(match.madUnits>=this.devMax) > this.maxDeviantParameters;
                        if disallow
                            if QfHiDM.DEBUG_LEVEL>0
                                fprintf('DISALLOWED--->> %d > %d\n',...
                                    sum(match.madUnits>=this.devMax), this.maxDeviantParameters);
                            end
                        end
                    catch
                        disallow=false;
                    end
                end
                if best && ~disallow
                    this.matches{end+1}=match;
                    cnt=length(this.matches);
                    word='best';
                else
                    this.matches2nd{end+1}=match;
                    cnt=length(this.matches2nd);
                    word='2nd best';
                end
                if length(match.sIds)>1 || length(match.tIds)>1
                    word=[word ' (MERGER)  '];
                end
                if QfHiDM.DEBUG_LEVEL>0
                    fprintf('%s match #%d: %s; X ids=%s & Y ids=%s\n', ...
                        word,  cnt, ...
                        String.encodeRounded(qfDissimilarity, 3, true),...
                        num2str(sIds_), num2str(tIds_));
                end
            end
            
            function addNextBest(ids, idxs, used)
                N2=length(ids);
                for j=1:N2
                    if used(idxs(j))
                        if ~this.nextBest.has(num2str(ids(j)))
                            lastIdx=makeMatch(false);
                            this.nextBest.set(num2str(ids(j)), lastIdx);
                        end
                    end
                end
            end
        end
        
        function [qfDistance, sIds_, tIds_]=...
                getInAscendingOrder(this, nTH, idAsCellString)
            [qfDistance, x, y]=MatBasics.PokeSortedMatrix(...
                this.result, nTH);
            [sIds_, ~]=QfHiDM.GetIds(x, this.sIds, this.sMergedIds);
            [tIds_, ~]=QfHiDM.GetIds(y, this.tIds, this.tMergedIds);
            if nargin>2 && idAsCellString
               sIds_=QfHiDM.ToCellStrings(sIds_);
               tIds_=QfHiDM.ToCellStrings(tIds_);
            end
        end
        
        function [result, tSzs]=computeUnmerged(this)
            if ~isempty(this.tGt)
                app=this.tGt.tp;
            else
                app=BasicMap.Global;
            end
            this.mergeLimit=0;
            if this.tIsCytof || this.sIsCytof
                dfltType=QfHiDM.DFLT_DEVIATION_TYPE_CYTOF;
                dfltData=QfHiDM.DFLT_DEVIATION_DATA_CYTOF;
            else
                dfltType=QfHiDM.DFLT_DEVIATION_TYPE_FACS;
                dfltData=QfHiDM.DFLT_DEVIATION_DATA_FACS;
            end            
            if isempty(app)
                this.devType=dfltType;
            else
                this.devType=app.getNumeric(QfHiDM.PROP_DEVIATION_TYPE,...
                    dfltType);
            end
            if isempty(this.tDevData) && isempty(this.sDevData)
                if isempty(app)
                    devData=dfltData;
                else
                    devData=app.getNumeric(QfHiDM.PROP_DEVIATION_DATA, dfltData);
                end
                if devData==1
                    this.tDevData=MatBasics.LogReal(@log10, this.tCompData);
                    this.sDevData=MatBasics.LogReal(@log10, this.sCompData);
                elseif devData==2
                    this.tDevData=this.tData;
                    this.sDevData=this.sData;
                elseif devData==3
                    this.tDevData=this.tCompData;
                    this.sDevData=this.sCompData;
                elseif devData==4
                    this.tDevData=MatBasics.LogReal(@log2, this.tCompData);
                    this.sDevData=MatBasics.LogReal(@log2, this.sCompData);
                else
                    this.tDevData=MatBasics.LogReal(@log, this.tCompData);
                    this.sDevData=MatBasics.LogReal(@log, this.sCompData);
                end
            end
            if this.fMeasuringUnmerged
                tSzs=[];%would not be needed if f measuring ... not QF tree!
                result=this.fMeasureNbyN(this.sIds, this.tIds, 'unmerged subsets');
            else
                [result, tSzs]=this.computeNbyN(this.sIds, this.tIds, 'unmerged subsets');
            end
        end
        
        function lbls=getLabels(this, idSets)
            isCell_=iscell(idSets);
            N=length(idSets);
            lbls=cell(1,N);
            for i=1:N
                if isCell_
                    lbls{i}=this.getLabel(idSets{i});
                else
                    lbls{i}=this.getLabel(idSets(i));
                end
            end
        end
        
        function lbl=getLabel(this, ids)
            id='';
            lbl='<small>';
            try
                N=length(ids);
                for i=1:N
                    id=ids(i);
                    idx=find(this.tIds==id,1);
                    n=this.tNames{idx};
                    lbl=[lbl n ', ID=' num2str(id) ', '];
                    try
                        lbl=[lbl String.encodeInteger(this.leafSzs(idx))...
                            ' events'];
                    catch ex
                        disp(getReport(ex));
                    end
                    if i<N
                        lbl=[lbl '<br>'];
                    end
                end
            catch ex
                disp(ex);
                lbl=[lbl sprintf('bug @%d', id)];
            end
            lbl=[lbl '</small>'];
        end
        
        % not transposed
        function matrix=fMeasureNbyN(this, sIdSets, tIdSets, txt)
            rows=length(sIdSets);
            cols=length(tIdSets);
            matrix=zeros(rows, cols);
            if rows==0 || cols==0
                return;
            end
            mx=QfHiDM.MAX_QF_DISTANCE;%realmax;%highest value to not select QF]
            sIsCell=iscell(sIdSets);
            tIsCell=iscell(tIdSets);
            if txt(end)==':'
                txt=sprintf('%s  %s by %s F measure matches', txt, ...
                    String.encodeInteger(rows), ...
                    String.encodeInteger(cols));
            else
                txt=sprintf('%s by %s F measure matches for %s', ...
                    String.encodeInteger(rows), ...
                    String.encodeInteger(cols), txt);
            end
            this.initProgress(rows*cols);
            this.setText(txt, true);
            matrix(:)=mx;
            chunk=floor(rows*cols/200);
            for row=1:rows
                if sIsCell
                    sIdSet=sIdSets{row};
                else
                    sIdSet=sIdSets(row);
                end
                for col=1:cols
                    if tIsCell
                        tIdSet=tIdSets{col};
                    else
                        tIdSet=tIdSets(col);
                    end
                    doF=true;
                    if this.preCheckDeviations 
                        try
                            devUnits=feval(this.devFcn, this.tDevData, ...
                                this.sDevData, this.tIdPerRow, tIdSet, ...
                                this.sIdPerRow, sIdSet);
                            deviants=sum(devUnits>this.devMax);
                        catch
                            deviants=0;
                        end
                        try
                            if isempty(this.isScatter)
                                stainDeviants=sum(devUnits>=this.devMax & ...
                                    this.devMax>=3);
                            else
                                stainDeviants=sum(devUnits>=this.devMax & ...
                                    ~this.isScatter);
                            end
                        catch
                            stainDeviants=0;
                        end
                        if deviants>this.maxDeviantParameters
                            doF=false;
                        end
                        this.stainDevUnitsExceeded=...
                            this.stainDevUnitsExceeded+stainDeviants;
                        this.scatterDevUnitsExceeded=...
                            this.scatterDevUnitsExceeded+(deviants-stainDeviants);
                        if deviants>0
                            this.forbiddenByDevUnits=...
                                this.forbiddenByDevUnits+1;
                        end
                    end
                    if ~doF
                    elseif this.areEqual
                        matrix(row,col)=1-MatBasics.F_measure(...
                            this.tCompData,this.sCompData,...
                            this.tIdPerRow, tIdSet, ...
                            this.sIdPerRow, sIdSet, true);
                        if QfHiDM.DEBUG_LEVEL<0
                            realF=1-matrix(row,col);
                            binF=this.fMeasureInBins(tIdSet, sIdSet);
                            if realF>.05 || binF>.05
                                absDif=abs(realF-binF);
                                strAbsDif=String.encodeRounded(absDif, 3, true);
                                if absDif>.3
                                    fprintf('%s <<<<<<<<<<<<< .  ', strAbsDif);
                                elseif absDif>.2
                                    fprintf('%s >>>>>>>>   ', strAbsDif);
                                elseif absDif>.1
                                    fprintf('%s !!!!!!!!!   ', strAbsDif);
                                elseif absDif>.05
                                    fprintf('%s ??? ', strAbsDif);
                                end
                                fprintf('F measure==%s, ', String.encodeRounded(...
                                    realF, 3, true));
                                fprintf('BIN f measure==%s', ...
                                    String.encodeRounded(binF, 3, true));
                                if realF>.8
                                    fprintf('!!\n');
                                else
                                    fprintf('\n');
                                end
                            end
                        end
                    else
                        matrix(row,col)=1-this.fMeasureInBins(tIdSet, sIdSet);
                    end
                    if ~isempty(this.pu)
                        if chunk>3
                            idx=((row-1)*cols)+col;
                            if mod(idx, chunk)==0
                                this.pu.incrementProgress(chunk);
                            end
                        else
                            this.pu.incrementProgress;
                        end
                    end
                    if this.isCancelled
                        return;
                    end
                end
            end
        end

        function [topFs, range_]=getOptimizationRange(this)
            if this.matchStrategy~=2
            %if this.matchStrategy==3
                if this.areEqual
                    topN=5;
                    range_=.02;
                else
                    topN=10;
                    range_=.1;
                end
            else
                topN=1;
                range_=0;
            end
            topFs=TopItems(topN);
            %topFs=TopItems(1);
            topFs.add(-1, -1);
        end

        
        % not transposed
        function [matrix, bestRow]=fMeasureNby1(...
                this, sIdSets, tIdSets, mergerCol)
            bestRow=0;
            rows=length(sIdSets);
            cols=length(tIdSets);
            matrix=zeros(rows, cols);
            if rows==0 || cols==0
                return;
            end
            matrix(:)=QfHiDM.MAX_QF_DISTANCE;
            sIsCell=iscell(sIdSets);
            tIsCell=iscell(tIdSets);                
            if tIsCell
                tIdSet=tIdSets{mergerCol};
            else
                tIdSet=tIdSets(mergerCol);
            end
            bpfm=MatBasics.BestPossibleF_measures(this.tIdPerRow, ...
                tIdSet, this.sIdPerRow, sIdSets);
            [bpfm,I]=sort(bpfm, 'descend');
            tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSet);
            tSize=sum(tChoices);
            chunk=floor(rows/200);
            [topFs, range_]=this.getOptimizationRange;
            for row=1:rows
                maxF=topFs.best;
                if bpfm(row)-range_>maxF
                    row_=I(row);
                    if sIsCell
                        sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSets{row_});
                    else
                        sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSets(row_));
                    end
                    if this.areEqual
                        F=Clusters.F_measure(sum(tChoices&sChoices),...
                            tSize, sum(sChoices));
                    else
                        F=this.adaptiveBins.fMeasure(tChoices, sChoices);
                    end
                    topFs.add(F, row_);
                elseif ~isempty(this.pu)
                    this.pu.incrementProgress(rows-row);
                    break;
                end
                if ~isempty(this.pu)
                    if chunk>3
                        if mod(row, chunk)==0
                            this.pu.incrementProgress(chunk);
                        end
                    else
                        this.pu.incrementProgress;
                    end
                end
                if this.isCancelled
                    return;
                end
            end
            if this.matchStrategy==2
                [maxF, bestRow]=topFs.best;
                matrix(bestRow, mergerCol)=1-maxF;
            else
                [rows, ~]=topFs.all;
                nRows=length(rows);
                scores=zeros(1, nRows);
                for i=1:nRows
                    if rows(i)<=0
                        scores(i)=QfHiDM.MAX_QF_DISTANCE;
                    else
                        if sIsCell
                            sIdSet=sIdSets{rows(i)};
                        else
                            sIdSet=sIdSets(rows(i));
                        end
                        scores(i)=this.distance(sIdSet, tIdSet);
                    end
                end
                [mn, mnI]=min(scores);
                bestRow=rows(mnI);
                matrix(bestRow, mergerCol)=mn;
            end            
        end


        %transposed
        function [matrix, bestCol]=fMeasure1byN(...
                this, sIdSets, tIdSets, mergerRow)
            rows=length(sIdSets);
            cols=length(tIdSets);
            matrix=zeros(rows, cols);
            bestCol=0;
            if rows==0 || cols==0
                return;
            end
            matrix(:)=QfHiDM.MAX_QF_DISTANCE;
            sIsCell=iscell(sIdSets);
            tIsCell=iscell(tIdSets);          
            if sIsCell
                sIdSet=sIdSets{mergerRow};
            else
                sIdSet=sIdSets(mergerRow);
            end
            bpfm=MatBasics.BestPossibleF_measures(this.sIdPerRow, ...
                sIdSet, this.tIdPerRow, tIdSets);
            [bpfm, I]=sort(bpfm, 'descend');
            sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSet);
            sSize=sum(sChoices);
            chunk=floor(cols/200);
            [topFs, range_]=this.getOptimizationRange;
            for col=1:cols
                maxF=topFs.best;
                if bpfm(col)-range_>maxF
                    col_=I(col);
                    if tIsCell
                        tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSets{col_});
                    else
                        tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSets(col_));
                    end
                    if this.areEqual
                        newMaxF=Clusters.F_measure(sum(tChoices&sChoices),...
                            sum(tChoices), sSize);
                    else
                        newMaxF=this.adaptiveBins.fMeasure(tChoices, sChoices);
                    end
                    topFs.add(newMaxF, col_);
                elseif ~isempty(this.pu)
                    this.pu.incrementProgress(cols-col);
                    break;
                end
                if ~isempty(this.pu)
                    if chunk>3
                        if mod(col, chunk)==0
                            this.pu.incrementProgress(chunk);
                        end
                    else
                        this.pu.incrementProgress;
                    end
                end
                if this.isCancelled
                    return;
                end
            end
            if this.matchStrategy==2
                [maxF, bestCol]=topFs.best;
                matrix(mergerRow, bestCol)=1-maxF;
            else
                [cols, ~]=topFs.all;
                nCols=length(cols);
                scores=zeros(1, nCols);
                for i=1:nCols
                    if cols(i)<=0
                        scores(i)=QfHiDM.MAX_QF_DISTANCE;
                    else
                        if tIsCell
                            tIdSet=tIdSets{cols(i)};
                        else
                            tIdSet=tIdSets(cols(i));
                        end
                        scores(i)=this.distance(sIdSet, tIdSet);
                    end
                end
                [mn, mnI]=min(scores);
                bestCol=cols(mnI);
                matrix(mergerRow, bestCol)=mn;
            end
        end
        

        function [vector, bestIds]=getBestMerger(...
                this, mergeIds, matchIds, matchCol, transpose)
            cols=length(matchIds);
            if cols==0
                vector=[];
                return;
            end
            sIsCell=iscell(mergeIds);
            tIsCell=iscell(matchIds);
            if tIsCell
                matchId=matchIds{matchCol};
            else
                matchId=matchIds(matchCol);
            end
            if sIsCell
                mergeIds=CellBasics.UniqueNumbers( mergeIds );
            end
            if this.areEqual
                ab=[];
            else
                ab=this.adaptiveBins;
            end
            if QfHiDM.F_MEASURE_MERGE_FAST ~= 1
                if ~transpose
                    l=ismember(  this.sIds, mergeIds);
                    fprintf('match ID=%d, size=%d, name="%s"\n', matchId,...
                        this.tSizes(matchCol),this.tNames{matchCol});
                    names=StringArray.toString(this.sNames(l), ',', true);
                    fprintf(...
                        '\tmerge %d IDs=%s\n\t\tsizes=%s\n\t\tnames=%s]\n', ...
                        length(mergeIds), MatBasics.toString(mergeIds),...
                        MatBasics.toString(this.sSizes(l)), names);
                else
                    l=ismember(  this.tIds, mergeIds);
                    fprintf('match ID=%d, size=%d, name="%s"\n', matchId,...
                        this.sSizes(matchCol),this.sNames{matchCol});
                    names=StringArray.toString(this.tNames(l), ',', true);
                    fprintf(...
                        '\tmerge %d IDs=%s\n\t\tsizes=%s\n\t\tnames=%s]\n',...
                        length(mergeIds), MatBasics.toString(mergeIds),...
                        MatBasics.toString(this.tSizes(l)), names);
                end
            end
            [bestIds, maxF]=FMeasureMerger.GetBest(this.tIdPerRow, ...
                this.sIdPerRow, matchId, mergeIds, ab, transpose);
            if ~transpose
                vector=zeros(1, cols);                
            else
                vector=zeros(cols, 1);
            end
            vector(:)=QfHiDM.MAX_QF_DISTANCE;
            if this.matchStrategy==2
                vector(matchCol)=1-maxF;
            else                        
                if transpose
                    ds=this.distance(matchId, bestIds);
                else
                    ds=this.distance(bestIds, matchId);
                end
                vector(matchCol)=ds;
            end 
            if QfHiDM.F_MEASURE_MERGE_FAST ~= 1
                if length(mergeIds) ~= length(bestIds)
                    [length(mergeIds)            bestIds]
                else
                    fprintf('\tEverything got merged!!\n');
                end
            end
            bestIds={bestIds};
        end

        function [matrix, tSzs]=computeNbyN(this, sIdSets, tIdSets, txt, ...
                only, transpose)
            rows=length(sIdSets);
            cols=length(tIdSets);
            tSzs=zeros(1, cols);
            matrix=zeros(rows, cols);
            if rows==0 || cols==0
                return;
            end
            sIsCell=iscell(sIdSets);
            tIsCell=iscell(tIdSets);
            if nargin<5
                if txt(end)==':'
                    txt=sprintf('%s  %s by %s QFMatches', txt, ...
                        String.encodeInteger(rows), ...
                        String.encodeInteger(cols));
                else
                    txt=sprintf('%s by %s QFMatches for %s', ...
                        String.encodeInteger(rows), ...
                        String.encodeInteger(cols), txt);
                end
                this.initProgress(rows*cols);
                this.setText(txt, true);
            else
                txt=sprintf('%s by %s QFMatches, only=%d, transpose=%d',...
                    String.encodeInteger(rows), ...
                    String.encodeInteger(cols), only, transpose);
            end
            dbgMat=cell(rows, cols);
            mx=QfHiDM.MAX_QF_DISTANCE;%realmax;%highest value to not select QF]
            for row=1:rows
                if nargin>5 && transpose  && row~=only
                    matrix(row,:)=mx;%realmax;%highest value to not select QF
                    continue;
                end
                if sIsCell
                    sIdSet=sIdSets{row};
                else
                    sIdSet=sIdSets(row);
                end
                for col=1:cols
                    if this.isIdentityMatrix
                        if col==row
                            if col>1 %need tSz(col) calculated
                                this.increment;
                                continue;
                            end
                        elseif col<row
                            this.increment;
                            matrix(row, col)=matrix(col, row);
                            continue;
                        end
                    end
                    if nargin>5 && ~transpose && col~=only 
                        matrix(row,col)=mx;
                        continue;
                    end
                    if tIsCell
                        tIdSet=tIdSets{col};
                    else
                        tIdSet=tIdSets(col);
                    end
                    doQf=true;
                    if this.preCheckDeviations && nargin<6 
                        devUnits=feval(this.devFcn, this.tDevData, this.sDevData, ...
                            this.tIdPerRow, tIdSet, this.sIdPerRow, sIdSet);
                        if ~isempty(devUnits)
                            deviants=sum(devUnits>this.devMax);
                            if isempty(this.isScatter)
                                stainDeviants=sum(devUnits>=this.devMax & ...
                                    this.devMax>=3);
                            else
                                stainDeviants=sum(devUnits>=this.devMax & ...
                                    ~this.isScatter);
                            end
                            if deviants>this.maxDeviantParameters
                                doQf=false;
                                tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSet);
                                tSzs(col)=sum(tChoices);
                                matrix(row,col)=mx+deviants;
                            end
                            this.stainDevUnitsExceeded=...
                                this.stainDevUnitsExceeded+stainDeviants;
                            this.scatterDevUnitsExceeded=...
                                this.scatterDevUnitsExceeded+(deviants-stainDeviants);
                            if deviants>0
                                this.forbiddenByDevUnits=...
                                    this.forbiddenByDevUnits+1;
                            end
                        end
                    end
                    if doQf
                        [matrix(row,col), tSzs(col), dbgMat{row, col}]=...
                            this.distance(sIdSet, tIdSet);
                    end
                    this.increment;
                    if this.isCancelled
                        return;
                    end
                end
            end
            if ~isempty(this.debugTxt)
                if isempty(this.leafSzs)
                    this.leafSzs=tSzs;
                end
                tLbls=this.getLabels(tIdSets);
                sLbls=this.getLabels(sIdSets);
                if this.debugLevel<=0
                    matHtml=['<h3>' txt '</h3>' ...
                        MatBasics.ToHtml(matrix, tLbls, sLbls, [], 100, 4)];
                    this.debugTxt=[this.debugTxt matHtml];
                else
                    isIdMat=isequal(sIdSets, tIdSets);
                    dh=['<table><tr><td><h2>' txt '</h2></td><td><h2>QF ' ...
                        'calculation details for ' txt '</td><td>'...
                        '</h2></tr><tr><td><hr>' ...
                        MatBasics.ToHtml(matrix, tLbls, sLbls, [], 100, 4)...
                        '</td><td><hr><table border="1"><tr><td></td>'];
                    for col=1:cols
                        dh=[dh '<td><font color="blue">' tLbls{col} '</font></td>'];
                    end
                    dh=[dh '</tr>'];
                    for row=1:rows
                        dh=[dh '<tr><td><font color="blue">' sLbls{row} '</font></td>'];
                        for col=1:cols
                            if ~isIdMat || col>row
                                dh=[dh '<td>' dbgMat{row,col} '</td>'];
                            else
                                dh=[dh '<td></td>'];
                            end
                        end
                        dh=[dh '</tr>'];
                    end
                    dh=[dh '</table></td></tr></table>'];
                    this.debugTxt=[this.debugTxt '</table></td></tr></table>'];
                    this.debugTxt=[this.debugTxt dh];
                end
            end
        end 
        
        function [f, p, r]=fMeasureInBins(this, tIdSet, sIdSet)
            tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSet);
            sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSet);
            [f, p, r]=this.adaptiveBins.fMeasure(tChoices, sChoices);
        end
    end
    
    methods
        
        function fm=fMeasure(this, sId, tId)
            fm=MatBasics.F_measure(...
                this.tCompData, this.tCompData, ...
                this.tIdPerRow, tId, this.sIdPerRow,...
                sId, true);
        end
        
        function [D, tSz, html]=distance(this, sIdSet, tIdSet)
            html='';
            tt=tic;
            tChoices=MatBasics.LookForIds(this.tIdPerRow, tIdSet);
            tSz=sum(tChoices);
            sChoices=MatBasics.LookForIds(this.sIdPerRow, sIdSet);
            if ~isempty(this.distanceType) && ...
                    ~isequal('QF', this.distanceType) ...
                    && ~isequal('QF + Euclidean', this.distanceType) ...
                    && ~isequal('QF + CityBlock', this.distanceType) 
                tData_=this.tData(tChoices, :);
                sData_=this.sData(sChoices, :);
                if isequal(this.distanceType, 'Fast EMD')
                    D=AdaptiveBins.Emd(tData_, sData_, 7);
                    %fprintf('EMD=%s\n', String.encodeRounded(D));
                elseif isequal(this.distanceType, 'Earth mover''s (EMD)')
                    D=AdaptiveBins.Emd(tData_, sData_);
                else
                    D=pdist2(median(tData_, 1), median(sData_,1), this.distanceType,...
                        'Smallest', 1);
                end
                return;
            end
            if this.debugLevel>0
                if length(sIdSet)>1 || length(tIdSet)>1
                    fprintf('counts t=%s (ids: %s) and  s=%s (ids: %s)', ...
                        String.encodeInteger( sum(tChoices)), num2str(tIdSet'), ...
                        String.encodeInteger(sum(sChoices)), num2str(sIdSet'));
                    fprintf('\n');
                else
                    fprintf('counts t=%s (ids: %s) and  s=%s (ids: %s)\n', ...
                        String.encodeInteger( sum(tChoices)), num2str(tIdSet), ...
                        String.encodeInteger(sum(sChoices)), num2str(sIdSet));
                end
            end
            isMeans=true;
            if this.binStrategy==1
                tData_=this.tData(tChoices, :);
                sData_=this.sData(sChoices, :);
                if nargin>2 && this.bins>3
                    [meansOrDists, ~, ~, h, f]=AdaptiveBins.Create(tData_, sData_, this.bins, true);
                else
                    if this.bins<=-9
                        [meansOrDists, ~, ~, h, f]=AdaptiveBins.Create(...
                            tData_, sData_, this.sizeLimit);
                    else %use 2*log of size of merged data
                        [meansOrDists, ~, ~, h, f]=AdaptiveBins.Create(tData_, sData_);
                    end
                end
            else
                weighBySampleSize=this.binStrategy<0;
                [meansOrDists, h, f]=this.adaptiveBins.weigh(...
                    tChoices, sChoices, weighBySampleSize);
                isMeans=isempty(this.adaptiveBins.dists);
            end
            if this.debugLevel<=0
                D=QfHiDM.Distance(h, f, meansOrDists, isMeans, this.ignoreTooBig);
            elseif ~isequal(tIdSet, sIdSet)
                [D, d_max, A_IJ]=QfHiDM.Distance(h, f, meansOrDists, isMeans, this.ignoreTooBig);
                hPtrs=this.adaptiveBins.teachPtrs(tChoices);
                fPtrs=this.adaptiveBins.studPtrs(sChoices);
                uPtrs=unique([hPtrs fPtrs]);
                colHdrs=StringArray.Num2Str(uPtrs);
                distHtml=Html.Matrix([],colHdrs, meansOrDists);
                aijHtml=Html.Matrix([], colHdrs, A_IJ);
                data_=[h;f];
                tLbls=this.getLabels(tIdSet);
                sLbls=this.getLabels(sIdSet);
                hfHtml=Html.Matrix({['H: ' StringArray.toString(tLbls)],...
                    ['F: ' StringArray.toString(sLbls) ]}, colHdrs, data_);
                html=['<table><tr><td colspan="2" align="center">'...
                    '<h3>QF dissimilarity ' String.encodeRounded(D, 3, true)...
                    '</h3><hr></td></tr><tr><td colspan="2" align="center">' ...
                    hfHtml '</td></tr><tr><td colspan="2" align="center">' ...
                    String.encodeRounded(d_max,3,true) ...
                    ' max distance</td></tr>'...
                    '<tr><td>Distances<br>' distHtml ...
                    '</td><td>A_IJ<br>' aijHtml '</td></tr></table>'];
            else
                D=0;
            end
            if QfHiDM.DEBUG_LEVEL>0
                fprintf(['   QF dist, %d & %d %dD items, total bins=%d, ' ...
                    'bins/weights=%s/%s & %s/%s\n'],...
                    sum(tChoices), sum(sChoices), size(meansOrDists,2), ...
                    size(meansOrDists,1), num2str(max(h)), num2str(sum(h>0)),...
                    num2str(max(f)), num2str(sum(f>0)));
                toc(tt);
            end
        end
        
        function [names, clrs]=getMatchingNamesAndColors(this, lblMap)
            N=length(this.sIds);
            names=cell(1,N);
            clrs=zeros(N,3);
            for i=1:N
                sId=this.sIds(i);
                m=this.getMatch(sId, false);
                if ~isempty(m)
                    %m.tIds
                    tId=m.tIds{1};
                    names{i}=char(lblMap.get(tId));
                    sClr=lblMap.get([tId '.color']);
                    if isempty(sClr)
                        clr=Gui.HslColor(i,N);
                    else
                        clr=str2num(sClr);
                        if any(clr>1)
                            clr=clr/256;
                        end
                    end
                    clrs(i,:)=clr;
                else
                    names{i}=this.sNames{i};
                    clrs(i,:)=Gui.HslColor(i, N);
                end
            end
        end
    end

    %new confusion stuff in Feb 2022
    properties
        confusionMatrix;
        confusionLabels;
    end

    methods(Static)
        function [chart, parent]=ConfusionChart(qf, parent)
            if isempty(qf.confusionMatrix) 
                if isa(qf, 'QfHiDM')
                    qf.computeConfusion;
                end
            end
            if nargin<2 || isempty(parent)
                parent=Gui.Figure(false, '', '', 'southeast', false);
            end
            if verLessThan('matlab', '9.5')
                set(parent, 'visible', 'on');
                msgError(Html.WrapHr(['MATLAB '...
                    'Version r2018b (or later)<br>'...
                    'is needed for the confusion chart']));
                chart=[];
            else
                try
                    chart=confusionchart( ...
                        qf.confusionMatrix, ...
                        qf.confusionLabels,...
                        'Normalization', 'total-normalized',...
                        'ColumnSummary','column-normalized',...
                        'RowSummary','row-normalized',...
                        'Parent', parent);
                    pos=get(parent, 'OuterPosition');
                    [R,C]=size(qf.confusionMatrix);
                    L=10;
                    N=15;
                    resize=false;
                    if R>L
                        resize=true;
                        factor=1+(min(R-L, N)/N);
                        pos(3)=pos(3)*factor;
                    end
                    if C>L
                        resize=true;
                        factor=1+(min(C-L, N)/N);
                        pos(4)=pos(4)*factor;
                    end
                    if resize
                        set(parent, 'OuterPosition', pos);
                    end
                catch ex
                    qf.confusionLabels=StringArray.ForceUnique( ...
                        qf.confusionLabels, '', '');
                    chart=confusionchart( ...
                        qf.confusionMatrix, ...
                        qf.confusionLabels,...
                        'Normalization',  'total-normalized',...
                        'ColumnSummary','column-normalized',...
                        'RowSummary','row-normalized',...
                        'Parent', parent);
                end
            end
        end
    end

    methods

        function computeConfusion(this)
            if isempty(this.confusionMatrix)
                if ~this.areEqual
                    warning('Data must be equal for confusion matrix');
                else
                    matched=this.matchTestEvents(false);
                    if size(this.tIdPerRow, 2)>1
                        warning('Only 1 training id per row needed for confusion matrix');
                        [this.confusionMatrix, o]=confusionmat(LabelBasics.RemoveOverlap(this.tIdPerRow), matched);
                    else
                        [this.confusionMatrix, o]=confusionmat(this.tIdPerRow(:,1), matched);
                    end
                    N=length(o);
                    classLabels=cell(N, 1);
                    for i=1:N
                        idx=find(this.tIds==o(i),1);
                        if ~isempty(idx)
                            classLabels{i}=this.tNames{idx};
                        elseif o(i)==0
                            classLabels{i}='Background';
                        else
                            classLabels{i}=['Label=' num2str(o(i))];
                        end
                    end
                    this.confusionLabels=classLabels;
                end
            end
        end
    end
    
    methods(Access=private)
        function ok=isCancelled(this)
            if ~isempty(this.pu)
                drawnow;
                ok=this.pu.cancelled;
                if ok
                    this.pu.setText('Quitting....');
                end
            else
                ok=false;
            end
        end
        
        function focusPriorFig(this)
            if ~isempty(this.pu)
                if ~isempty(this.pu.priorFig)
                    figure(this.pu.priorFig);
                end
            end
        end
        
        function setText(this, txt, line2)
            if ~isempty(this.pu)
                if nargin==2 || ~line2
                    this.pu.setText(txt);
                else
                    this.pu.setText2(txt);
                end
            end
        end
        
        function initProgress(this, N)
            if ~isempty(this.pu)
                this.pu.initProgress(N, char(this.pu.label.getText));
            end            
        end
        
        function increment(this)
            if ~isempty(this.pu)
                this.pu.incrementProgress(1);
            end
        end
        
        function fcn=devFcn(this)
            %fcn=@MatBasics.GetMeanUnits;
            %fcn=@MatBasics.GetMdnUnits;
            if this.devType==3
                fcn=@MatBasics.GetMad1DevUnits;
            elseif this.devType==2
                fcn=@MatBasics.GetStdDevUnits;
            else
                fcn=@MatBasics.GetMadDevUnits;
            end
        end
        
    end
    
    methods(Static, Access=private)
        
        function [cnt, b]=Background(tIdPerRow, sIdPerRow, sIds2)
            [tR, tC]=size(tIdPerRow);
            sC=size(sIdPerRow,2);
            sIds2(end+1)=0;
            l=true(tR,1);
            for j=1:tC
                l=l&tIdPerRow(:,j)==0;
            end
            cnt=sum(l);
            if nargout>1 && nargin>2
                if any(l)
                    sLabels=zeros(1, sum(l));
                    for k=1:sC
                        v=sIdPerRow(l, k);
                        sLabels(v~=0)=v(v~=0);
                    end
                    b=MatBasics.HistCountsTally(...
                        sLabels, sIds2);
                else
                    b=zeros(1, length(sIds2));
                end
            end
        end
        
        function [cnt, o]=Overlap(idPerRow, ids)
            [R, C]=size(idPerRow);
            ids(end+1)=0;
            o=zeros(1, length(ids));
            if C<2
                cnt=0;
                return;
            end
            l=true(R,1);
            for j=1:C
                l=l&idPerRow(:,j)~=0;
            end
            cnt=sum(l);
            if nargout>1  && any(l)
                labels=zeros(1, sum(l));
                for k=1:C
                    v=idPerRow(l, k);
                    labels(v~=0)=v(v~=0);
                    cnts=MatBasics.HistCountsTally(labels, ids);
                    o=o+cnts;
                end
            end
        end
        
        
        function strings=ToCellStrings(nums)
            N=length(nums);
            strings=cell(1, N);
            for i=1:N
                strings{i}=num2str(nums(i));
            end
        end
        
        function [ids, unMergedIdxs]=GetIds(i, unmerged, merged)
            if i>length(unmerged)
                i=i-length(unmerged);
                ids=merged{i};
                if nargout>1
                    N=length(ids);
                    unMergedIdxs=zeros(1,N);
                    for i=1:N
                        unMergedIdxs(i)=find(unmerged==ids(i), 1);
                    end
                end
            else
                unMergedIdxs=i;
                ids=unmerged(i);
            end
        end
        
        function out=ToCell(nums)
            N=length(nums);
            out=cell(1, N);
            for i=1:N
                out{i}=nums(i);
            end
        end
        
        function ids=ToIds(idxs, singleIds)
            N=length(idxs);
            ids=cell(1, N);
            for i=1:N
                ids{i}=singleIds(idxs{i});
            end
        end
        
    end
    
    
    methods(Access=private)
        function ok=checkSpeedUp(this, unmergedScores)
            ok=true;
            if ~isempty(this.tGt)
                app=this.tGt.multiProps;
            else
                app=BasicMap.Global;
            end
            this.mergeLimit=0;
            if isempty(app)
                isPausing=false;
            else
                isPausing=app.is(QfHiDM.PROP_MERGE_PAUSE, false);
                mergeLimitIdx=app.getNumeric(QfHiDM.PROP_MERGE_LIMIT, 1);
                if mergeLimitIdx>1 % NOT unlimited
                    this.mergeLimit=5+mergeLimitIdx; % set limit
                end
            end
            if isPausing
                this.computeMergeCost(unmergedScores);
                if this.mergeLimit>0
                    if any(this.sMergeCnts>this.mergeLimit) || ...
                        any(this.tMergeCnts>this.mergeLimit)
                        [~, cancelled_]=AvoidMerging.Adjust(this);
                        if cancelled_
                            ok=false;
                        end
                    end
                end
            end
        end
        
        function computeMergeCost(this, matrix)
            if this.mergeStrategy>1
                perc=QfHiDM.MergeStrategyPerc(this.mergeStrategy);
                [~, cntPerCol]=QfHiDM.FindMerges(matrix, true, perc);
                this.sMergeCnts=cntPerCol;
                [~, cntPerCol]=QfHiDM.FindMerges(matrix, false, perc);
                this.tMergeCnts=cntPerCol;
            else
                [~, cntPerCol]=...
                    QfHiDM.FindMinRowsForCol(matrix, true);
                this.sMergeCnts=cntPerCol;
                [~, cntPerCol]=...
                    QfHiDM.FindMinRowsForCol(matrix, false);
                this.tMergeCnts=cntPerCol;
            end
        end
        
        function [idxsAllMerges, mergeColIdxs, idxsMergable]=getMergers(this, matrix, ...
                transpose)
            if this.mergeStrategy~=1
                perc=QfHiDM.MergeStrategyPerc(this.mergeStrategy);
                if transpose
                    [rowsToMergePerCol, cntPerCol]=QfHiDM.FindMerges(matrix, ...
                        transpose, perc, this.sAvoidMerges);
                    this.sMergeCnts=cntPerCol;
                else
                    [rowsToMergePerCol, cntPerCol]=QfHiDM.FindMerges(matrix, ...
                        transpose, perc, this.tAvoidMerges);
                    this.tMergeCnts=cntPerCol;
                end
            else
                if transpose
                    [rowsToMergePerCol, cntPerCol]=...
                        QfHiDM.FindMinRowsForCol(...
                        matrix, transpose, this.sAvoidMerges);
                    this.sMergeCnts=cntPerCol;
                else
                    [rowsToMergePerCol, cntPerCol]=...
                        QfHiDM.FindMinRowsForCol(...
                        matrix, transpose, this.tAvoidMerges);
                    this.tMergeCnts=cntPerCol;
                end
            end
            mergers=rowsToMergePerCol(cntPerCol>1);
            mergeColIdxs=find(cntPerCol>1);
            idxsAllMerges={};
            idxsMergable={};
            N=length(mergers);
            if N>0
                if ~this.avoidedMerging && max(cntPerCol)>8
                    if isempty(this.pu) || isempty(this.pu.cancelBtn)
                        %disp('hmmm');
                    else
                        this.pu.cancelBtn.setText(...
                            '<html>Cancel <b><i>or speed up</i></b></html>');
                        drawnow;
                    end
                end
                this.setText('Computing mergers', true);
                this.initProgress(sum(cntPerCol(cntPerCol>1)));
                mergers_={};
                mergeColIdxs_=[];
                md=mad(matrix(:));
                for i=1:N
                    merger=mergers{i};
                    col=mergeColIdxs(i);
                    N2=length(merger);
                    ols=[];
                    scores=[];
                    ol=0;
                    merger_=[];
                    for j=1:N2
                        this.increment;
                        row=merger(j);
                        if ~transpose
                            sIdSet=QfHiDM.ToIds({row}, this.sIds);
                            sIdSet=sIdSet{1};
                            tIdSet=this.tIds(col);
                            best=min(matrix(:, col));
                            qf=matrix(row, col);
                            if qf>=QfHiDM.MAX_QF_DISTANCE
                                continue;
                            end
                            if this.preCheckDeviations 
                                devUnits=feval(this.devFcn, this.tDevData,...
                                    this.sDevData, this.tIdPerRow, ...
                                    tIdSet, this.sIdPerRow, sIdSet);
                                
                            end
                            if this.areEqual && this.mergeLimit>0
                                ol=MatBasics.Overlap(this.tCompData, ...
                                    this.sCompData, this.tIdPerRow, tIdSet, ...
                                    this.sIdPerRow, sIdSet, this.areEqual);
                            end
                        else
                            tIdSet=QfHiDM.ToIds({row}, this.tIds);
                            tIdSet=tIdSet{1};
                            sIdSet=this.sIds(col);
                            best=min(matrix(col, :));
                            qf=matrix(col, row);
                            if qf>=QfHiDM.MAX_QF_DISTANCE
                                continue;
                            end
                            if this.preCheckDeviations
                                devUnits=feval(this.devFcn, ...
                                    this.sDevData, this.tDevData, ...
                                    this.sIdPerRow, sIdSet, ...
                                    this.tIdPerRow, tIdSet);                                
                            end
                            if this.areEqual && this.mergeLimit>0
                                ol=MatBasics.Overlap(this.sCompData, ...
                                    this.tCompData, this.sIdPerRow, sIdSet, ...
                                    this.tIdPerRow, tIdSet, this.areEqual);
                            end
                        end
                        dif=abs(qf-best);
                        if this.preCheckDeviations && ~isempty(devUnits)...
                                && sum(devUnits>this.devMax)>...
                                this.maxDeviantParameters
                            fprintf(...
                                '%d dimensions exceed max mad units\n', ...
                                sum(devUnits>this.devMax))
                        
                        else
                            merger_(end+1)=row;
                            if this.areEqual
                                ols(end+1)=ol;
                            else
                                ols(end+1)=QfHiDM.MAX_QF_DISTANCE-qf;
                            end
                            scores(end+1)=qf;
                            if dif>=md*QfHiDM.DEV_MAX
                                if md>0 && this.preCheckDeviations
                                    fprintf(['QF %s more than %d mad (%s) units '...
                                        ' away from %s\n'], String.encodeRounded(qf,2), ...
                                        QfHiDM.DEV_MAX, String.encodeRounded(md,3), ...
                                        String.encodeRounded(best,3));
                                end
                            end
                        end                        
                    end
                    if length(merger_)>1
                        if this.mergeLimit>0
                            if length(ols)>this.mergeLimit
                                [~,yy]=sort(ols, 'descend');
                                merger_=merger_(yy(1:this.mergeLimit));
                            end
                        end
                        mergers_{end+1}=merger_;
                        mergeColIdxs_(end+1)=mergeColIdxs(i);
                    end
                end
                mergers=mergers_;
                idxsMergable=mergers;
                mergeColIdxs=mergeColIdxs_;
                if this.fMeasuringMerged && QfHiDM.F_MEASURE_MERGE_FAST==1
                    return;
                end
                N=length(mergers);
                this.setText('Gathering mergers', true);
                this.initProgress(N);
                totalMerges=0;
                for i=1:N
                    merger=mergers{i};
                    nMerger=length(merger);
                    lastComboSize=nMerger-1;
                    if this.maxMerges>0 && lastComboSize>this.maxMerges
                        lastComboSize=this.maxMerges;
                    end
                    for comboSize=2:lastComboSize
                        totalMerges=totalMerges+nchoosek(nMerger, comboSize);
                    end
                end
                strTotal=sprintf('%s total mergers', String.encodeK(totalMerges));
                this.setText(strTotal, true);
                for i=1:N
                    nextMergers={};
                    merger=mergers{i};
                    nMerger=length(merger);
                    lastComboSize=nMerger-1;
                    if this.maxMerges>0 && lastComboSize>this.maxMerges
                        lastComboSize=this.maxMerges;
                    end
                    subTotalMerges=0;
                    for comboSize=2:lastComboSize
                        subTotalMerges=subTotalMerges+nchoosek(nMerger, comboSize);
                    end
                    str_=sprintf('Subset #%d/%d, %d candidates, %s/%s',...
                        i, N, nMerger, String.encodeK(subTotalMerges), strTotal);
                    this.setText(str_, true);
                    for comboSize=2:lastComboSize
                        combos=nchoosek(merger, comboSize);
                        nCombos=length(combos);
                        if lastComboSize>18
                            this.setText(sprintf('%s-->%s combos of %d',...
                                str_, String.encodeK(nCombos), comboSize), true);
                            if this.isCancelled
                                return;
                            end
                        end
                        nextMergers=[nextMergers;num2cell(combos,2)];
                    end
                    this.increment;
                    idxsAllMerges{end+1}=[merger nextMergers'];
                end
            end
        end
    end
    
    methods(Static)
        function str=MatchStrategyString(strategy)
            if ischar(strategy)
                strategy=str2double(strategy);
            end
            if strategy==2
                str='F';
            else
                if strategy==1
                    str='QF';
                else
                    str='QFxF';
                end
            end
        end
        
        function str=MergeStrategyString(mergeStrategy)
            if ischar(mergeStrategy)
                mergeStrategy=str2double(mergeStrategy);
            end
            perc=QfHiDM.MergeStrategyPerc(mergeStrategy);
            if perc == 1
                str='best';
            else
                str=['best + top ' num2str(perc) ' * N'];
            end
        end
        
        function perc=MergeStrategyPerc(mergeStrategy)
            if ischar(mergeStrategy)
               mergeStrategy=str2double(mergeStrategy);
            end
            perc=1+((mergeStrategy-1)*.5);
        end
        
        function [rowsThatAreMinForCol, cntMinForCol, isMinRowForColMinColForRow]=...
                FindMinRowsForCol(matrix, transpose, avoidMerges)
            if nargin<3
                avoidMerges=[];
            end
            if nargin>1 && transpose
                dimRow=2;
                dimCol=1;
            else
                dimRow=1;
                dimCol=2;
            end
            cols=size(matrix, dimCol);
            cntMinForCol=zeros(1, cols);
            rowsThatAreMinForCol=cell(1, cols);
            isMinRowForColMinColForRow=false(1, cols);
            [~, minColForRow]=min(matrix, [], dimCol);
            [~, minRowForCol]=min(matrix, [], dimRow);
            for col=1:cols
                if ~isempty(avoidMerges) && avoidMerges(col)
                    continue;
                end
                minRows=find(minColForRow==col);
                if transpose
                    l=matrix(col, minRows)>=QfHiDM.MAX_QF_DISTANCE;
                else
                    l=matrix(minRows, col)>=QfHiDM.MAX_QF_DISTANCE;
                end
                if sum(l)>0
                    minRows=minRows(~l);
                end
                cntMinForCol(col)=length(minRows);
                isMinRowForColMinColForRow(col)=ismember(...
                    minRowForCol(col), minRows);
                rowsThatAreMinForCol{col}=minRows;
            end
        end
        
        function D=ComputeFastHiD(h, f, means)
            try
                Java=edu.stanford.facs.swing.ChangeQuantification;
                D=Java.quadraticFormHiD(h, f, means);
            catch
                D=1; % max distance !!
            end
        end
        
        function [D, d_max, A_IJ]=Distance(h, f, meansOrDists, isMeans, ignoreTooBig)
            try
                originalMeans=meansOrDists;
                if nargin<4 || isMeans
                    R=size(meansOrDists, 1);
                    if R>AdaptiveBins.MAX_SIZE
                        if nargin<5 || ~ignoreTooBig
                            D=QfHiDM.ComputeFastHiD(h, f, meansOrDists);
                            if isnan(D)
                                D=QfHiDM.MAX_QF_DISTANCE;%close to max QF distance
                            end
                        else
                            D=QfHiDM.MAX_QF_DISTANCE;
                        end
                        return;
                    end
                    meansOrDists=MatBasics.PDist2Self(meansOrDists);
                end
                d_max=max(max(meansOrDists));
                A_IJ=1-meansOrDists/d_max;
                [H, F]=meshgrid(h-f, h-f);
                D=sqrt(sum(sum(A_IJ.*H.*F)));
            catch
                if nargin<4 || isMeans
                    D=QfHiDM.ComputeFastHiD(h, f, originalMeans);
                end
            end
            if isnan(D)
                D=QfHiDM.MAX_QF_DISTANCE;%close to max QF distance
            end
        end
        
        function value=IdValue(ids)
            value='';
            N=length(ids);
            if iscell(ids)
                for i=1:N
                    if i>1
                        value=[value ', ' ids{i}];
                    else
                        value=[ids{i}];
                    end
                end
            else
                for i=1:N
                    if i>1
                        value=[value ', ' ids(i)];
                    else
                        value=[ids(i)];
                    end
                end
            end
        end
        
        function [teachData, studData]=Data(columnNames, ...
                teachData, teachColNames, teachColIdxs, studData, ...
                studColNames, studColIdxs)
            teachData=QfHiDM.GetRequiredData(teachData, columnNames, ...
                teachColNames, teachColIdxs);
            studData=QfHiDM.GetRequiredData(studData, columnNames, ...
                studColNames, studColIdxs);
            teachData=QfHiDM.Log10(teachData);
            studData=QfHiDM.Log10(studData);
        end
        
        function this=New(teachData, teachCompData, teachIds, studData, ...
                studCompData, studIds, bins, binStrategy, columnNames, ...
                teachColNames, teachColIdxs, studColNames, studColIdxs, ...
                teachStudCacheFile, studTeachCacheFile)
            if nargin<15
                studTeachCacheFile=[];
                if nargin<14
                    teachStudCacheFile=[];
                    if nargin<9
                        columnNames=[];
                        if nargin<8
                            binStrategy=QfHiDM.BIN_STRATEGY;
                            if nargin<7
                                bins=QfHiDM.BINS;
                            end
                        end
                    end
                end
            end
            if ~isempty(columnNames)
                % same data may be in different columns of this and that data
                columnNames=QfHiDM.RemoveMissingColumns(columnNames, ...
                    teachColNames, teachColIdxs);
                columnNames=QfHiDM.RemoveMissingColumns(columnNames, ...
                    studColNames, studColIdxs);
                teachData=QfHiDM.GetRequiredData(teachData, columnNames, ...
                    teachColNames, teachColIdxs);
                if ~isempty(teachCompData)
                    teachCompData=QfHiDM.GetRequiredData(teachCompData, ...
                        columnNames, teachColNames, teachColIdxs);
                end
                studData=QfHiDM.GetRequiredData(studData, columnNames, ...
                    studColNames, studColIdxs); 
                if ~isempty(studCompData)
                    studCompData=QfHiDM.GetRequiredData(studCompData, ...
                        columnNames, studColNames, studColIdxs);
                end
            end            
            teachData=QfHiDM.Log10(teachData);
            nCols=size(teachData,2);
            devMax=zeros(1, nCols)+QfHiDM.DEV_MAX;
            isScatter=false(1, nCols);
            for i=1:nCols
                if String.StartsWithI(columnNames{i}, 'FSC-') ...
                        || String.StartsWithI(columnNames{i}, 'SSC-')
                    devMax(i)=QfHiDM.DEV_MAX_LOG10;
                    isScatter(i)=true;
                end
            end
            studData=QfHiDM.Log10(studData);
            if ~isempty(teachCompData)
                assert(isequal(size(teachData), size(teachCompData)));
            end
            if ~isempty(studCompData)
                assert(isequal(size(studData), size(studCompData)));
            end
            this=QfHiDM(teachData, teachCompData, teachIds, studData, ...
                studCompData, studIds, bins, binStrategy, ...
                teachStudCacheFile, studTeachCacheFile, devMax, isScatter);
            if nargin>8
                this.columnNames=columnNames;
            end
        end
        
        function [outData, scatterColumns]=Log10(inData, whichRows, ...
                scatterColumns, divisor)
            if nargin<4
                divisor=2.5;
                if nargin<3
                    scatterColumns=[];
                    if nargin<2
                        whichRows=[];
                    end
                end
            end
            if isempty(whichRows)
                whichRows=true(1, size(inData,1));
            end
            outData=inData(whichRows, :);
            if isempty(scatterColumns)
                maxInData=max(inData);
                
                %since logicle can be < 0 and > 11
                LIKELY_LOGICLE_UPPER_LIMIT=100;
                if any(maxInData>LIKELY_LOGICLE_UPPER_LIMIT)
                    scatterColumns=find(maxInData>LIKELY_LOGICLE_UPPER_LIMIT);
                    nScatterColumns=length(scatterColumns);
                    for k=1:nScatterColumns
                        handleLog10InfOrComplex(scatterColumns(k));
                    end
                end
                if length(scatterColumns)==length(maxInData)
                    return;
                end
            end
            if ~isempty(scatterColumns)
                outData(:,scatterColumns)=log10(outData(:,scatterColumns))/divisor;
            end
            
            function handleLog10InfOrComplex(scatCol)
                %log10 converts 0s to inf and negatives to complex
                %thus 0s and negs must be re-fit BELOW the lowest unconverted 
                %number between 0 and 1 or re-fit between .01 and 1
                %BEFORE log10 conversion
                nonRealIndex=inData(:, scatCol)<=0;
                if any(nonRealIndex)
                    nonReal=outData(nonRealIndex, scatCol);
                    maxNonReal=max(nonReal);
                    sum(nonRealIndex) %display count to console
                    real=outData(~nonRealIndex, scatCol);
                    minNegLog10=min(real(real<=1));
                    if isempty(minNegLog10)
                        if maxNonReal==0
                            maxRefit=1; % log10 of 1 is 0
                        else
                            maxRefit=.99;
                        end
                        minRefit=0.01;
                    else
                        maxRefit=.99*minNegLog10;
                        minRefit=.01*minNegLog10;
                    end
                    refitRegion=maxRefit-minRefit;
                    minNonReal=min(nonReal);
                    nonRealRange=maxNonReal-minNonReal;
                    if  nonRealRange==0
                        nonRealRatio=.5;
                    else
                        nonRealRatio=(nonReal-minNonReal)/nonRealRange;
                    end
                    nonRealAdjusted=minRefit+(nonRealRatio*refitRegion);
                    outData(nonRealIndex, scatCol)=nonRealAdjusted;
                end
            end
        end

        function data=GetRequiredData(data, requiredColumnNames, ...
                dataColumnNames, dataColumnIdxs)
            requiredColumnIdxs=QfHiDM.GetRequiredColumns(...
                requiredColumnNames, dataColumnNames, dataColumnIdxs);
            data=data(:,requiredColumnIdxs);
        end
        
        function requiredColumnIdxs=GetRequiredColumns( ...
                requiredColumnNames, dataColumnNames, dataColumnIdxs)
            N=length(requiredColumnNames);
            requiredColumnIdxs=[];
            for i=1:N
                idx=StringArray.IndexOf(dataColumnNames, ...
                    requiredColumnNames{i});
                if idx>0
                    requiredColumnIdxs(end+1)=dataColumnIdxs(idx);
                end
            end
        end

        function [out, missing]=RemoveMissingColumns( ...
                requiredColumnNames, dataColumnNames, dataColumnIdxs)
            N=length(requiredColumnNames);
            missing={};
            out={};
            for i=1:N
                name=requiredColumnNames{i};
                idx=StringArray.IndexOf(dataColumnNames, name);
                if idx<1
                    missing{end+1}=name;
                else
                    out{end+1}=name;
                end
            end
        end
        
        function D=Match(teachData, studData, bins, ...
                columnNames, thisColumnNames, ...
                thisColumnIdxs, thatColumnNames, thatColumnIdxs)
            if nargin<3
                bins=[];
            end
            if nargin>3 
                % same data may be in different columns of this and that data
                teachData=QfHiDM.GetRequiredData(teachData, columnNames, ...
                    thisColumnNames, thisColumnIdxs);
                studData=QfHiDM.GetRequiredData(studData, columnNames, ...
                    thatColumnNames, thatColumnIdxs);
            end
            teachData=QfHiDM.Log10(teachData);
            studData=QfHiDM.Log10(studData);
            if bins<-9
                mn=min([size(teachData,1) size(studData,1)]);
                if mn>=30
                    perc=abs(bins)/100;
                    sizeLimit=floor(mn*perc);
                    [means, ~, ~, h, f]=AdaptiveBins.Create(teachData, ...
                        studData, sizeLimit);
                else
                    [means, ~, ~, h, f]=AdaptiveBins.Create(...
                        teachData, studData);
                end
            elseif isempty(bins) || bins<4
                [means, ~, ~, h, f]=AdaptiveBins.Create(teachData, studData);
            else
                [means, ~, ~, h, f]=AdaptiveBins.Create(teachData, ...
                    studData, bins);
            end
            D=QfHiDM.Distance(h, f, means);
            if isnan(D)
                D=QfHiDM.MAX_QF_DISTANCE;%max distance;
            end
        end
        function lvl=DEBUG_LEVEL
            lvl=0;
            %lvl=1;
        end
        
        function names=GetDescriptions(qf, gtp, doStud)
            if nargin>2 && doStud
                ids=qf.sIds;
            else
                ids=qf.tIds;
            end
            names=cell(1, length(ids));
            for i=1:length(names)
                gid=num2str(ids(i));
                names{i}=gtp.getDescription(gid);
            end
        end

        
        function names=GetNames(qf, gtp)
            names=cell(1, length(qf.tIds));
            for i=1:length(names)
                gid=num2str(qf.tIds(i));
                names{i}=gtp.getNode(gid, MatchInfo.PROP_LAST_NAME);
                if isempty(names{i})
                    names{i}=gtp.getDescription(gid);
                end
            end
        end
        
        function [colors, edgeColors, lineWidths]=GetColors(qf, gtp)
            N=length(qf.tIds);
            colors=zeros(N, 3);
            edgeColors=zeros(N, 3);
            lineWidths=zeros(1, N);
            for i=1:N
                gid=num2str(qf.tIds(i));
                clr=str2num(gtp.getNode(gid, MatchInfo.PROP_LAST_COLOR));
                if ~isempty(clr)
                    colors(i,:)=clr;
                end
                e=str2num(gtp.getNode(gid, MatchInfo.PROP_LAST_EDGE));
                if ~isempty(clr)
                    edgeColors(i,:)=e(1:3);
                    lineWidths(i)=e(4);
                end
            end
        end
        
        function QF=TreeData(qft, qf)
            qf=qft.qf;
            QF.tIds=qf.tIds;
            QF.numLeaves=qf.numLeaves;
            QF.branchNames=qf.branchNames;
            QF.branchQfs=qf.branchQfs;
            QF.treeSz=qf.treeSz;
            QF.phyTree=qf.phyTree;
            QF.nodeQfs=qf.nodeQfs;
            QF.nodeSzs=qf.nodeSzs;
            QF.columnNames=qf.columnNames;
            QF.distanceType=qf.distanceType;
            QF.measurements=qf.measurements;
            QF.rawMeasurements=qf.rawMeasurements;
            [QF.colors, QF.edgeColors, QF.lineWidths]...
                =qft.getLeafPlotElements;
            QF.names=qft.originalNames;
            QF.ttl='Phenogram';
            try
                QF.ttl=qft.ttl;
            catch
            end
        end
        
        function [finalData, cols, columnNames, gtIds, gtData, ...
                gtCompData]=GetRequiredData2(fcs, fcsIdxs, gt, gid, pu, visible)
            finalData=[];
            cols=[];
            columnNames={};
            [gtData, gtCompData, gtCols, gtColNames, gtIds, fg2]=...
                NdTreeGater.QfInputs(gt, gid, pu, true, visible);
            if isempty(gtIds)
                if ~isempty(pu)
                    pu.close;
                end
                return;
            end
            fcsParams=fcs.statisticParamNames(fcsIdxs);
            columnNames=QfHiDM.RemoveMissingColumns(fcsParams, ...
                gtColNames, gtCols);
            fcsParams=fcs.statisticParamNames(fcsIdxs);
            if isequal(columnNames, fcsParams)
                finalData=QfHiDM.GetRequiredData(gtData, columnNames, ...
                    gtColNames, gtCols);
                cols=StringArray.IndexesOf(gtColNames, columnNames);
                cols=gtCols(cols);
            end
            N2=length(fcsIdxs);
            fcsIdxs2=zeros(1, N2);
            fcs2=fg2.fcs;
            bad=false;
            for j=1:N2
                fcsIdx2=fcs2.findFcsIdx(fcs, fcsIdxs(j));
                if fcsIdx2==0 % hmmm ....FMO?
                    bad=true;
                    break;
                end
                fcsIdxs2(j)=fcsIdx2;
            end
            if bad
                html=Html.To2Lists(Fcs.Sort(columnNames),...
                    Fcs.Sort(fcsParams), 'ol', 'UMAP', ...
                    'GatingTree pick', true);
                msg(Html.WrapC(['<b>Incompatible FCS parameters'...
                    '</b>' html]));
                if ~isempty(pu)
                    pu.close;
                end
                return;
            end
            cols=fcsIdxs2;
            finalData=gtData(:, cols);            
        end

        function [rowIdxs, cntMinForCol, isMinRowForColMinColForRow]=...
                FindMerges(matrix, transpose, percLimit, avoidMerges)
            if nargin<4
                avoidMerges=[];
                if nargin<3
                    percLimit=1.5;
                    if nargin<2
                        transpose=false;
                    end
                end
            end
            if transpose
                dimRow=2;
                dimCol=1;
            else
                dimRow=1;
                dimCol=2;
            end
            cols=size(matrix, dimCol);
            rows=size(matrix, dimRow);
            cntMinForCol=zeros(1, cols);
            rowIdxs=cell(1, cols);
            isMinRowForColMinColForRow=false(1, cols);
            mnSize=min(rows, cols);
            mxIdx=floor(percLimit*mnSize);
            if length(matrix(:))<mxIdx
                %return;
                mxIdx=length(matrix(:));
            else
            end
            S=sort(matrix(:));
            if mxIdx<=length(S)
                mx=S(mxIdx);
            else
                mx=S(end);
            end
            [~, minColForRow]=min(matrix, [], dimCol);
            [~, minRowForCol]=min(matrix, [], dimRow);
            for col=1:cols
                if ~isempty(avoidMerges) && avoidMerges(col)
                    continue;
                end
                minRows=find(minColForRow==col);
                if transpose
                    minRows2=find(matrix(col, :)<=mx);
                    if ~isempty(minRows2) && ~isequal(minRows, minRows2)
                        minRows=unique([minRows minRows2]);
                    end
                else
                    minRows2=find(matrix(:,col)<=mx);
                    if ~isempty(minRows2) && ~isequal(minRows, minRows2)
                        minRows=unique([minRows' minRows2']);
                    end
                end
                cntMinForCol(col)=length(minRows);
                isMinRowForColMinColForRow(col)=ismember(...
                    minRowForCol(col), minRows);
                rowIdxs{col}=minRows;
            end
        end
        
        function swb=BackgroundReadings(...
                sayBackground, tb, app, newLine)
            if nargin<4
                newLine=false;
                if nargin<3
                    app=BasicMap.Global;
                end
            end
            if app.highDef
                factor=1.2;
            else
                factor=.97;
            end
            sm1=['<b>' app.smallStart];
            sm2=['</b>' app.smallEnd];
            swb=Gui.FlowLeftPanel;
            if sayBackground
                dflt=1;
                lbl=javax.swing.JLabel(['<html>' sm1 ...
                    'Readings:  ' sm2 '</html>']);
                Gui.SetTransparent(lbl);
                swb.add(lbl);
            else
                dflt=2;
            end
            if newLine
                nl='<br>&nbsp;&nbsp;&nbsp;&nbsp;';
            else
                nl=' ';
            end
            combo=Gui.Combo(Html.WrapSmallBoldCell({...
           [Html.ImgXy('mds.png', [], factor) ...
           '&nbsp;&nbsp;MDS &amp; phenograms' nl '(QF-tree)' ], ...
           [Html.ImgXy('match16.png', [], factor) ...
           '&nbsp;&nbsp;QFMatch/Hi-D match'],...
           [Html.ImgXy('emd.png', [], factor) ...
           '&nbsp;&nbsp;Earth mover''s' nl 'distance (EMD)' ],...
           [Html.ImgXy('epp.png', [], factor) ...
           '&nbsp;&nbsp;Exhaustive proj' nl 'ection pursuit (EPP)']}), dflt,...
                '',[], @(h,e)lookup(h), 'Read background material on this');
            swb.add(combo);
            Gui.SetTransparent(combo);
            Gui.SetTransparent(swb);
            if nargin>1 && ~isempty(tb)
                drawnow;
                ToolBarMethods.addComponent(tb, swb);
                drawnow;
            end

            function lookup(h)
                idx=h.getSelectedIndex;
                QfHiDM.BrowseReading(idx+1)
            end
        end
        
        function ReadingsToolBarBtn(tb, app)
            if nargin<2
                app=BasicMap.Global;
            end
            ToolBarMethods.addButton(tb, 'help2.png', ...
                'See background readings', @(h,e)go(h));
                        
            function go(h)
                if app.highDef
                    factor=1.2;
                else
                    factor=.97;
                end

                choices=Html.WrapSmallBoldCell({...
                    [Html.ImgXy('mds.png', [], factor) ...
                    '&nbsp;&nbsp;MDS &amp; phenograms (QF-tree)' ], ...
                    [Html.ImgXy('match16.png', [], factor) ...
                    '&nbsp;&nbsp;QFMatch/Hi-D match'],...
                    [Html.ImgXy('emd.png', [], factor) ...
                    '&nbsp;&nbsp;Earth mover''s distance (EMD)' ],...
                    [Html.ImgXy('epp.png', [], factor) ...
                    '&nbsp;&nbsp;Exhaustive projection pursuit (EPP)']});
                jMenu=PopUp.Menu;
                for i=1:length(choices)
                    Gui.NewMenuItem(jMenu, choices{i}, ...
                        @(h,e)QfHiDM.BrowseReading(i));
                end
                jMenu.show(h, 15, 25);
            end

        end

        function BrowseReading(idx)
            switch idx
                case 4
                    url='https://1drv.ms/b/s!AkbNI8Wap-7_jOIovIYSl7wCo_awxA?e=DngGRy';
                case 2
                    url='https://www.nature.com/articles/s41598-018-21444-4';
                case 1
                    url='https://www.nature.com/articles/s42003-019-0467-6';
                otherwise
                    url='https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0151859';
            end
            web(url, '-browser');
        end

        function swb=BackgroundReadingBtns
            app=BasicMap.Global;
            sm1=app.smallStart;
            sm2=app.smallEnd;
            swb=Gui.SetTitledBorder('Background reading...');
            Gui.BorderPanel(swb);
            swb.add(Gui.NewBtn(['<html><b>' sm1 'Earth mover''s '...
                sm2 '</b></html>'], @(h,e)web(...
                'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0151859',...
                '-browser'), ['See our plublication earth mover''s '...
                'distance'], 'emd.png'), 'West');
            swb.add(Gui.NewBtn(['<html><b>' sm1 'QFMatch' ...
                sm2 '</b></html>'], @(h,e)web(...
                'https://www.nature.com/articles/s41598-018-21444-4', ...
                '-browser'), ['See our publication on <b>speeding'...
                ' up</b> earth mover''s distance'], 'match.png'), 'Center');
        end
        
        function [names, lbls, tLbls, sLbls]...
                =GetNamesLbls(qf, isTeachers, qfIdxs, btnsObj)
            N=length(qfIdxs);
            names=cell(1,N);
            lbls=zeros(1,N);
            try
                wantsBtnClicks=nargin>3 && ~isempty(btnsObj) ...
                    && ~isempty(btnsObj.btns)...
                    && ~isempty(btnsObj.btnLbls);
            catch
                wantsBtnClicks=false;
            end
            if nargout>2 || wantsBtnClicks
                tLbls=zeros(1,N);
                sLbls=zeros(1,N);
                for i=1:N
                    [names{i}, lbls(i), tLbls(i), sLbls(i)]...
                        =QfHiDM.GetIds2(qf, isTeachers(i), qfIdxs(i));
                end
                if wantsBtnClicks
                    for i=1:N
                        lblIdx=find(btnsObj.btnLbls==tLbls(i), 1);
                        if isempty(lblIdx)
                            lblIdx=find(btnsObj.btnLbls==sLbls(i), 1);
                        end
                        if ~isempty(lblIdx)
                            btnsObj.btns.get(lblIdx-1).doClick;
                        end
                    end
                end
            else
                for i=1:N
                    [names{i},lbls(i)]=QfHiDM.GetIds2(...
                        qf,isTeachers(i),qfIdxs(i));
                end
            end
        end
        
        function [name, lbl, tLbl, sLbl]=GetIds2(qf, isTeacher, qfIdx)
            matches_=qf.matches;
            nQfs=length(matches_);
            sLbl=[];tLbl=[];
            if isTeacher
                name=qf.tNames{qfIdx};
                lbl=qf.tIds(qfIdx);
                if nargout>=4
                    tLbl=lbl;
                    s=num2str(lbl);
                    sLbl=[];
                    for i=1:nQfs
                        tIds_=matches_{i}.tIds;
                        n3=length(tIds_);
                        for j=1:n3
                            if isequal(s, tIds_{j})
                                if ~isempty(matches_{i}.sIds)
                                    sLbl=str2double(matches_{i}.sIds{1});
                                end
                                break;
                            end
                        end
                        if ~isempty(sLbl)
                            break;
                        end
                    end
                end
            else
                name=qf.sNames{qfIdx};
                lbl=qf.sIds(qfIdx);
                if nargout>=3
                    sLbl=lbl;
                    s=num2str(lbl);
                    tLbl=[];
                    for i=1:nQfs
                        sIds_=qf.matches{i}.sIds;
                        n3=length(sIds_);
                        for j=1:n3
                            if isequal(s, sIds_{j})
                                if ~isempty(matches_{i}.tIds)
                                    tLbl=str2double(matches_{i}.tIds{1});
                                end
                                break;
                            end
                        end
                        if ~isempty(tLbl)
                            break;
                        end
                    end
                end
            end
            if isempty(sLbl)
                sLbl=0;
            end
            if isempty(tLbl)
                tLbl=0;
            end
        end
        
        function str=ConvertMatchesTex2Html(str)
            str=Html.WrapSmallBold([strrep(strrep(strrep(...
                strrep(strrep(strrep(str, '\color{red}', ...
                '<font color="red">'), '\color{blue}', ...
                '<font color="blue">'), '\color[rgb]{0 .5 .5}', ...
                '<font color="#008888">'), ...
                '\color{black}', '</font>'),...
                '^{', '<sup>'), '}', '</sup>')]); 
        end
        
        function str=GetMatchesString(unmatched, totals, html1tex2plain3)
            if nargin<3
                html1tex2plain3=2;
            end
            if html1tex2plain3==1
                app=BasicMap.Global;
                red='<font color="red">';
                blue='<font color="blue">';
                green='<font color="#008888">';
                black='</font>';
                supStart=app.supStart;
                supEnd=app.supEnd;
            elseif html1tex2plain3==2
                red='\color{red}';
                blue='\color{blue}';
                green='\color[rgb]{0 .5 .5}';
                black='\color{black}';
                supStart='^{';
                supEnd='}';
            else
                red='';
                blue='';
                black='';
                green='';
                supStart='';
                supEnd='';
            end
            N=length(unmatched);
            sb=java.lang.StringBuilder(300);
            sb.append(['MATCH sets:  training=']);
            encode(2, red, 'UNMATCHED!');
            sb.append(', test=');
            encode(1, green, 'NEW!');
            str=char(sb.toString);
            function encode(i, red, words)
                if unmatched(i)<1
                    sb.append(sprintf('%sall %d matched!%s', ...
                        blue, totals(i), black));
                else
                    sb.append(sprintf('%s%d/%d %s(%s%d %s%s)%s',...
                        blue, totals(i)-unmatched(i), totals(i), ...
                        supStart, red, unmatched(i), words, ...
                        black, supEnd));
                end
            end
        end
        
        function argsObj=GetArgsWithMetaInfo(csvFile, varargin)
            if isempty(csvFile)
                csvFile='sample10k.csv';
            end
            argsObj=Args.NewMerger({SuhEpp.DefineArgs, ...
                SuhModalSplitter.DefineArgs,...
                SuhDbmSplitter.DefineArgs}, varargin{:});
            m=mfilename('fullpath');
            p=fileparts(m);
            argsObj.setSources(@run_epp, fullfile(p, 'run_epp.m'), m);
            argsObj.setPositionalArgs('csv_file_or_data');
            argsObj.update('csv_file_or_data', csvFile);
            argsObj.load;
        end
        
        function argsObj=SetArgsMetaInfo(argsObj) 
            argsObj.setMetaInfo('cytometer', ...
                'type', 'char', 'valid_values', SuhEpp.CYTOMETER_VALUES);
            argsObj.setMetaInfo('output_folder', 'type', 'folder');
            argsObj.setMetaInfo('properties_file', 'type', 'file_readable');
            argsObj.setArgGroup({'balanced', 'W', 'sigma', ...
                'max_clusters', 'min_branch_size'}, ...
                'Modal cluster settings');
            argsObj.setArgGroup({'balanced', 'cluster_detail', ...
                'trimLeaves', 'minLeafSize', ...
                'max_clusters', 'balancedNoisy'}, 'DBM cluster settings')
            argsObj.setArgGroup({'KLD_normal_2D', 'KLD_normal_1D', ...
                'KLD_exponential_1D'}, ...
                'Kullback-Leibler Divergence settings')
            argsObj.setFileFocus('EPP''s input data', 'csv_file_or_data');
            argsObj.setCsv('csv_file_or_data', true, 'label_column', 'label_file');
        end
        
        function p=DefineArgs(p)
            if nargin<1
                p = inputParser;
            end
            addParameter(p,'binStrategy', 0, @isnumeric);
            addParameter(p,'log10', true,  @islogical);
            addParameter(p,'mergeLimit', 6, @(x)validMergeLimit(x));
            addParameter(p,'matchStrategy',1, @(x)validMatchStrategy(x));
            addParameter(p,'mergeStrategy', 2, @(x)validMergeStrategy(x));
            addParameter(p,'maxDeviantParameters', 0, @(x)isnumeric(x) && x>=-1 && x<20);
            addParameter(p,'probabilityBinSize', '2*log*N', @validateBinSize);
            addParameter(p, 'html', false, @islogical);
            addParameter(p,'check_equivalence', false, @islogical);        
        
            function ok=validateBinSize(x)
                ok=false;
                if ~ischar(x)
                    return;
                end
                code=QfHiDM.BinsCode(x);
                ok=~isnan(code)&&isnumeric(code);
            end
            
            
            function ok=validMergeLimit(x)
                ok=isnumeric(x) && x>=1 && x <=12;
            end
            
            function ok=validMatchStrategy(x)
                ok=isnumeric(x) && x>=1 && x <=3;
            end
            function ok=validMergeStrategy(x)
                ok=isnumeric(x) && (x==-1) || (x>=0 && x <=8);
            end
        end
        
        function code=BinsCode(x)
            code=binsDoubleLogData(x);
            if isnan(code)
                code=binsHalfMinSubset(x);
                if isnan(code)
                    code=binsFixed(x);
                end
            end
            
            
            function code=binsHalfMinSubset(x)
                if strcmpi(x, '.5*min(class)')
                    code=-10;
                else
                    code=nan;
                end
            end
            function code=binsDoubleLogData(x)
                if strcmpi(x, '2*log*N')
                    code=0;
                else
                    code=nan;
                end
            end
            
            function code=binsFixed(x)
                code=nan;
                if startsWith(lower(x), 'fixed:')
                    if length(x)>6
                        num=str2double(x(7:end));
                        if num>32
                            code=floor(log2(num));
                        end
                    end
                end
            end
        end
        
        
        
        function tip=Tip(widthPixels)
            if nargin<1
                widthPixels=250;
            end
            if BasicMap.Global.highDef
                widthPixels*1.3;
            end
            tip=['<table cellpadding="8" width="' num2str(widthPixels) ...
                'px"><tr><td><u><b>Similarity</b></u> is based on a change '...
                'quantification metric that measures both'...
                ' mass + distance using either<ul><li>Earth-'...
                'mover''s distance (<b>EMD</b>)<li><b>QFMatch</b> '...
                'which is an optimization of QFMatch'...
                '</ul></td></tr></table>'];
        end
    end
end