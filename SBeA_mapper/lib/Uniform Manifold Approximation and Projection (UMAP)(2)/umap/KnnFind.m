%
%   KnnFind enhances the search services of knnsearch by providing an
%   additional search method 'nn_descent', which can perform dramatically
%   faster than 'kdtree' or 'exhaustive' under certain conditions, as can
%   be observed by running KnnFind.Test.
%   
%   AUTHORSHIP
%       Jonathan Ebrahimian <jebrahimian@mail.smu.edu>:  Creator of the 
%               core nn_descent C++ files, which translate and optimize 
%               the original Python code of Leland McInnes.
%       Connor Meehan <connor.gw.meehan@gmail.com>: Math lead; creator of 
%               nndescent/C++/distances.cpp and MATLAB test scripts; 
%               final authority for review, testing, and approval of all 
%               C++ and MATLAB code.
%       Stephen Meehan <swmeehan@stanford.edu>: Project lead; refactorer
%               of C++ to add parallelism as well as the conventions of 
%               standard library C++ and those described in Scott Meyers's 
%               landmark book "Effective Modern C++"; creator of KnnFind.m,
%               nndescent/C++/suh.h and nndescent/C++/mexWrapper.cpp.
%                        
%  ALGORITHMS for nn_descent
%   1 Dong, Wei; Charikar, Moses; and Li, Kai; 
%     Efficient K-Nearest Neighbor Graph Construction for Generic Similarity Measures; 
%     https://www.cs.princeton.edu/cass/papers/www11.pdf 
%   2 Dasgupta, Sanjoy, and Freund, Yoav; 
%     Random projection trees and low dimensional manifolds;
%     https://cseweb.ucsd.edu/~dasgupta/papers/rptree-stoc.pdf 
%   Provided by the Herzenberg Lab at Stanford University. 
%   License: BSD 3 clause
%
%  The 3 main usages of KnnFind are the static methods Run, Approximate
%   and Determine.  The first time you call Approximate (directly or 
%   indirectly via Test or Run) KnnFind halts and instructs you to get  
%   the MEX file using the methods Build or Download.  Only Windows and  
%   Mac versions are available for download.  Linux users must run Build.
%
%  KnnFind methods:
%  Run - discerns the most appropriate search method and calls either
%   Determine or Approximate.
%  Approximate - is a wrapper for C++ MEX function nn_descent.
%  Determine - is a wrapper for MATLAB knnsearch.
%  CanAccelerate - estimates if nn_descent is likely faster than knnsearch
%  Test - simple test program that illustrates the use of KnnFind. Test
%   expects data to be in CSV files. For some default invocations, Test
%   downloads our example data from our website using MATLAB websave.
%       

classdef KnnFind<handle
    properties(Constant)
        DFLT_TRANSFORM_Q_SZ=1.35;
        PROGRESS_PREFIX='Estimating neighbors (';
    end
    
    methods(Static)

        function [knnIndices, knnDists, X_search_graph]=Run(X, Y, varargin)
%  KnnFind.Run has input/output arguments that are nearly identical to
%  those of MATLAB's knnsearch and are identical to those of
%  KnnFind.Approximate().
%
% Input arguments
% X          An MX-by-N numeric matrix. Rows of X correspond to
%            observations and columns correspond to variables.
% Y          An MY-by-N numeric matrix of query points. Rows of Y
%            correspond to observations and columns correspond to 
%            variables.
%
% Name-value pair arguments
%  Run() accepts all of the same name-value pair arguments documented in 
%  MATLAB's knnsearch function, plus additional ones documented in this 
%  file for KnnFind.Approximate().
%
%   'K'                     Number of nearest neighbors.
%                           Default is 15.
%
%   'IncludeTies'           A logical value indicating whether KnnFind.Run 
%                           includes all the neighbors whose distance 
%                           values are equal to the Kth smallest distance. 
%                           This is only meaningful when KnnFind.Run does
%                           not use nn_descent. See notes below.
%                           Default is false.
%
%   'NSMethod'              Nearest neighbors search method. Values:
%                           'kdtree'
%                               Instructs KnnFind.Run to use knnsearch with
%                               a kd-tree to find nearest neighbors. This
%                               is only valid when 'metric' is 'euclidean',
%                               'cityblock', 'minkowski', or 'chebychev'.
%                           'exhaustive'
%                               Instructs KnnFind.Run to use knnsearch with
%                               the exhaustive search algorithm. The
%                               distance values from all the points in X to
%                               each point in Y are computed to find
%                               nearest neighbors.
%                           'nn_descent'
%                               Instructs KnnFind.Run to use
%                               KnnFind.Approximate which uses the
%                               nn_descent C++ MEX function. This tends to
%                               deliver the fastest search given certain
%                               data conditions and name-value pair
%                               arguments. Any speedup benefit, however,
%                               comes at the cost of a slight loss of
%                               accuracy (usually < 1%). This is only valid
%                               if 'Distance' is NOT 'spearman', 'hamming',
%                               'seuclidean', 'jaccard', or a function.
%                           Default is 'nn_descent' when n_neighbors<=45
%                           and X is not a sparse matrix and has MX>=40,000
%                           & N>10. If 'Distance' is 'mahalanobis', then
%                           the nn_descent lower limit for MX is 5,000 and
%                           for N is 3. Otherwise, 'kdtree' is the default
%                           if N<=10, X is not a sparse matrix, and the
%                           'Distance' is 'euclidean', 'cityblock',
%                           'minkowski' or 'chebychev'. Otherwise,
%                           'exhaustive' is the default.
%
%   'Distance'              Controls how distance is computed in the
%                           ambient space, as does the same input argument
%                           for the original Python implementation. Values:
%                  'euclidean'   - Euclidean distance (default).
%                  'seuclidean'  - Standardized Euclidean distance. Each
%                                  coordinate difference between X and a
%                                  query point is scaled by dividing by a
%                                  scale value S. The default value of S is
%                                  the standard deviation computed from X,
%                                  S=NANSTD(X). To specify another value
%                                  for S, use the 'Scale' argument.
%                  'cityblock'   - City block distance.
%                  'chebychev'   - Chebychev distance (maximum coordinate
%                                  difference).
%                  'minkowski'   - Minkowski distance. The default
%                                  exponent is 2. To specify a different
%                                  exponent, use the 'P' argument.
%                  'mahalanobis' - Mahalanobis distance, computed using a
%                                  positive definite covariance matrix C.
%                                  The default value of C is the sample
%                                  covariance matrix of X, as computed by
%                                  NANCOV(X). To specify another value for
%                                  C, use the 'Cov' argument.
%                  'cosine'      - One minus the cosine of the included
%                                  angle between observations (treated as
%                                  vectors).
%                  'correlation' - One minus the sample linear
%                                  correlation between observations
%                                  (treated as sequences of values).
%                  'spearman'    - One minus the sample Spearman's rank
%                                  correlation between observations
%                                  (treated as sequences of values).
%                  'hamming'     - Hamming distance, percentage of
%                                  coordinates that differ.
%                  'jaccard'     - One minus the Jaccard coefficient, the
%                                  percentage of nonzero coordinates that
%                                  differ.
%
%                  function      - A distance function specified using @
%                                  (for example @KnnFind.ExampleDistFunc). 
%                                  A distance function must be of the form
%   
%                                    function D2 = DISTFUN(ZI, ZJ),
%   
%                                  taking as arguments a 1-by-N vector ZI
%                                  containing a single row of X or Y, an
%                                  M2-by-N matrix ZJ containing multiple
%                                  rows of X or Y, and returning an M2-by-1
%                                  vector of distances D2, whose Jth
%                                  element is the distance between the
%                                  observations ZI and ZJ(J,:).
%
%   'P'                     A positive scalar indicating the exponent of 
%                           Minkowski distance. This argument is only 
%                           valid when 'metric' (or 'Distance') is
%                           'minkowski'.
%                           Default is 2.
%   
%   'Cov'                   A positive definite matrix indicating the
%                           covariance matrix when computing the
%                           Mahalanobis distance. This argument is only
%                           valid when 'metric' (or 'Distance') is
%                           'mahalanobis'.
%                           Default is NANCOV(X).
%   
%   'Scale'                 A vector S containing positive values,
%                           with length N. Each coordinate difference
%                           between X and a query point is scaled by the
%                           corresponding element of Scale. This argument
%                           is only valid when 'Distance' is 'seuclidean'.
%                           Default is NANSTD(X).  
%
%   'BucketSize'            The maximum number of data points in the leaf
%                           node of the kd-tree. This is only meaningful
%                           when 'NSMethod' is 'kdtree'.
%                           Default is 50.
%
%
%  When X and Y are not equal and 'NSMethod' is 'nn_descent', an additional
%  name-value pair argument 'X_search_graph' can be used for optimal speed.
%  This can be computed once for X and returned as the 3rd output argument.
%  This argument and ones additional to nn_descent are documented in the
%  Approximate() method in this file. The search method nn_descent can be
%  run directly via the Approximate method. The method CanAccelerate()
%  details the kinds of data conditions and input arguments under which
%  nn_descent runs faster than kdtree or exhaustive.
%
% Output arguments
% knnIndices    matrix of MY rows by K columns. Each row contains indices
%               of the nearest neighbors in X for the corresponding row in
%               Y.
% knnDists      matrix of MY rows by K columns. Each row contains the
%               measured distance from the point defined by the
%               corresponding row in Y to the points in X corresponding to
%               the indices from knnIndices.
% X_search_graph 
%               sparse square matrix of MX rows by MX columns that
%               accelerates approximation for subsequent searches for X IF
%               Y differs. Subsequent calls would contain this output
%               argument as the value for 'X_search_graph' name-value pair
%               input argument. The most accurate search graph for any
%               future use with 'NSMethod' as 'nn_descent' is obtained when
%               the value for this call to Run() is 'kdtree' or
%               'exhaustive'.
%

            if nargin<2
                if nargin<1
                    error('At a minimum provide a data matrix');
                end
                Y=X;
            else
                if isempty(Y)
                    Y=X;
                else
                end
            end
            
            args=KnnFind.GetArgs(varargin{:});
            [R,C]=size(X);
            if ~KnnFind.CheckDistArgs(C, args)
                error('Incorrect supplementary metric args (P, Cov, Scale) ');
            end
            useNnDescent=isempty(args.NSMethod)...
                && KnnFind.CanAccelerate(args, [R C], args.X_search_graph);
            if useNnDescent || strcmpi(args.NSMethod, 'nn_descent')
                if nargout>=3
                    [knnIndices, knnDists, X_search_graph]=KnnFind.Approximate( X, Y,...
                        varargin{:});
                else
                    [knnIndices, knnDists]=KnnFind.Approximate(X,Y,varargin{:});
                end
            else
                if nargout>=3
                    [knnIndices,knnDists, X_search_graph]=KnnFind.Determine(X,Y, args);
                else
                    [knnIndices,knnDists]=KnnFind.Determine(X,Y, args);
                end
            end
        end
        
        function [knnIndices, knnDists, X_search_graph]=Approximate(X, Y, varargin)
%
% Input arguments
% X          An MX-by-N numeric matrix. Rows of X correspond to
%            observations and columns correspond to variables.
% Y          An MY-by-N numeric matrix of query points. Rows of Y
%            correspond to observations and columns correspond to 
%            variables.
%
% Name-Value Pair arguments
%  KnnFind.Approximate() accepts all of the same name-value pair
%  arguments documented in MATLAB's knnsearch function.
%  In addition to these, Approximate() uses the following arguments 
%
%   'X_search_graph'        A sparse square matrix of MX rows by MX columns 
%                           that accelerates approximation for searches of 
%                           X if Y is not equal. You can obtain this as 
%                           the 3rd output argument of Approximate() or 
%                           as the 3rd output argument of Determine().
%
%   'n_async_tasks'         The # of parallel tasks for processing
%                           the search.  
%                           If > 1, then the progress_callback is not 
%                           called if Y differs from X due to
%                           thread issues with our MEX implementation.
%                           Default is 3.
%
%   'nn_descent_min_rows'   the # of input data rows needed before Run will
%                           consider 'nn_descent' a candidate for
%                           'NSMethod'.
%                           Default is 40,000.
%  
%   'nn_descent_min_cols'   the # of input data columns needed before Run
%                           will consider 'nn_descent' a candidate for
%                           'NSMethod'.
%                           Default is 11.
%
%   'nn_descent_transform_queue_size' 
%                           a factor of "slack" used in searches where X
%                           and Y are not equal. 1 means no slack and 4
%                           means 300% extra slack. The more slack, the
%                           greater the accuracy, but the less the
%                           acceleration.
%                           Default is 1.35.
% 
%  'nn_descent_max_neighbors'
%                           the maximum # of n_neighbors after which Run
%                           will not consider 'nn_descent' a candidate for
%                           'NSMethod'.
%                           The default is 45.                        
%
% Output arguments
% knnIndices    matrix of MY rows by K columns. Each row contains indices
%               of the nearest neighbors in X for the corresponding row in
%               Y.
% knnDists      matrix of MY rows by K columns. Each row contains the
%               measured distance from the point defined by the
%               corresponding row in Y to the points in X corresponding to
%               the indices from knnIndices.
% X_search_graph 
%               sparse square matrix of MX rows by MX columns that
%               accelerates approximation for subsequent searches of X IF Y
%               is not equal. Subsequent calls would contain this output
%               argument as the value for 'X_search_graph' name-value pair.


            if ~KnnFind.MexIsAvailable
                mf=KnnFind.MexFile;
                [p,f,e]=fileparts(mf);
                error(['First run KnnFind.Build or KnnFind.Download to get ' ...
                    f e  ' in the folder ' p]);
            end
            if nargin<2
                if nargin<1
                    error('At a minimum provide a data matrix');
                end
                self_search=true;
                Y=X;
            else
                if isempty(Y)
                    Y=X;
                    self_search=true;
                else
                    self_search=isequal(X, Y);
                end
            end
            [args, argued]=KnnFind.GetArgs(varargin{:});
            [~,C]=size(X);
            if ~KnnFind.CheckDistArgs(C, args)
                error('Incorrect supplementary metric args (P, Cov, Scale) ');
            end
            if ~KnnFind.CanAccelerate(args, size(X)) 
                warning('KnnFind:CanAccelerate', ...
                    'Approximate() called but CanAccelerate==false');
            end
            n_neighbors=args.K;
            metric=args.metric;
            dist_args=args.dist_args; 
            randomize=args.randomize;
            n_async_tasks=args.n_async_tasks;
            progress_callback=args.progress_callback;
            X_search_graph=args.X_search_graph;
            transform_queue_size=args.nn_descent_transform_queue_size;
            
            mex_cancelled=false;
            if strcmpi(metric, 'mahalanobis') 
                if ~isempty(dist_args)
                    dist_args=inv(dist_args);
                end
            end

            if issparse(X) || issparse(Y)
                warning('Using knnsearch (nn_descent cannot use sparse matrices)');
                if ~self_search
                    [knnIndices, knnDists]=KnnFind.Determine(X, Y, args);
                else
                    [knnIndices, knnDists]=KnnFind.Determine(X, X, args);
                end
                return;
            end
            if isequal('function_handle', class(metric)) ...
                    || KnnFind.CellIndex(...
                    KnnFind.NN_DESCENT_METRIC_NOT_READY, metric)>0
                warning(['Using knnsearch:  nn_descent is not '...
                    'valid with distance "%s"'], char(metric) );
                if ~self_search
                    [knnIndices, knnDists]=KnnFind.Determine(X, Y, args);
                else
                    [knnIndices, knnDists]=KnnFind.Determine(X, X, args);
                end
                return;
            end
            if ~randomize && n_async_tasks > 1
                    warning('NN-descent cannot be parallelized while ''randomize'' is false; setting ''n_async_tasks'' to 1!');
                    n_async_tasks = 1;
            end
            
            try
                KnnFind.Quarantine;
                if ~randomize
                    rand = 0;
                else
                    rand = -1;
                end
                if ~self_search % is self/other search
                    if isempty(X_search_graph)
                        [R1, C1]=size(Y);
                        otherSize=[KnnFind.Encode(R1) ' X ' ...
                            KnnFind.Encode(C1) ];
                        if nargout<3
                            warning(...
                                ['Avoid cost of building X_search_graph'...
                                ' for X''s data %s by:'...
                                '\n\t. Collecting X_search_graph in '...
                                'the 3rd output arg of KnnFind.Approximate()'...
                                '\n\t. Re-using it for every subsequent'...
                                ' call of KnnFind.Approximate() with same Y'...
                                '\n\t. Saving it with save() for next '...
                                'MATLAB  session'], otherSize);
                        else
                            fprintf(['Building 3rd argout '...
                                'X_search_graph for %s\n'], otherSize);

                        end
                        [knnIndices, knnDists]=KnnFind.Approximate(X, [],...
                            'K', n_neighbors, 'metric', metric, ...
                            'dist_args', dist_args);
                        [~, ~, ~, fSearchGraph]=KnnFind.FindCallbacks;
                        X_search_graph=feval(fSearchGraph, X, n_neighbors, ...
                            knnIndices, knnDists, [], .5);
                    end
                    if strcmpi('mahalanobis', metric)
                        if ~argued.contains('nn_descent_transform_queue_size')                            
                            transform_queue_size=transform_queue_size*2;
                        end
                        if isempty(transform_queue_size)
                            transform_queue_size=KnnFind.DFLT_TRANSFORM_Q_SZ*2;
                        end
                    end
                    if isempty(transform_queue_size)
                        transform_queue_size=KnnFind.DFLT_TRANSFORM_Q_SZ;
                    end
                    [pythonIndptr, pythonIndices]=...
                        KnnFind.IndPtrAndIndices(X_search_graph);
                    if isequal('function_handle', class(progress_callback))
                        [knnIndices, knnDists] = nn_descent(Y, n_neighbors, ...
                            metric, dist_args, rand, n_async_tasks, X,...
                            int32(pythonIndptr), int32(pythonIndices), ...
                            transform_queue_size, @callback);
                    else
                        [knnIndices, knnDists] = nn_descent(Y, n_neighbors,...
                            metric, dist_args, rand, n_async_tasks, X, ...
                            int32(pythonIndptr), int32(pythonIndices), ...
                            transform_queue_size);
                    end
                else
                    if isequal('function_handle', class(progress_callback))
                        [knnIndices, knnDists] = nn_descent(X, n_neighbors,...
                            metric,dist_args,  rand, n_async_tasks, @callback);
                    else
                        [knnIndices, knnDists] = nn_descent(X, n_neighbors, ...
                            metric, dist_args, rand, n_async_tasks);
                    end
                end
                if mex_cancelled
                    knnIndices=[];
                    knnDists=[];
                end
            catch ex
                ex.getReport
                disp('');
                
                dlg=KnnFind.MsgBox(['<html>Mex nn_descent could NOT run...<br>'...
                    'Using MATLAB knnSearch instead...<br><br>'...
                    'Rebuild nn_descent on your computer with<br>'...
                    'your C++ compiler using our command<br><br>'...
                    '<center><b>KnnFind.Build</b></center><hr></html>']);
                
                if isequal('function_handle', class(progress_callback))
                    feval(progress_callback, ['REVERTING to knnsearch '...
                        'neighbor graph...']);
                end
                args.NSMethod=[];
                if ~self_search
                    [knnIndices, knnDists]=KnnFind.Determine(X, Y, args);
                else
                    [knnIndices, knnDists]=KnnFind.Determine(X, X, args);
                end
                dlg.setVisible(false);
            end

            if nargout>2 
                if isempty(X_search_graph)
                    [~, ~, ~, fSearchGraph]=KnnFind.FindCallbacks;
                    X_search_graph=feval(fSearchGraph, X, n_neighbors, ...
                        knnIndices, knnDists, [], .5);
                end
            end
            
            function ok=callback(iters)
                s=[KnnFind.PROGRESS_PREFIX num2str(iters(1)) ...
                    '/' num2str(iters(2)) ' max. searches)'];
                try
                    ok=feval(progress_callback, s);
                catch ex
                    ok=true; %keep going if poorly written callback
                end
                if ok
                    ok=int32(1);
                else
                    mex_cancelled=true;
                    ok=int32(0);
                end
            end
        end
        
        function Download
            %This downloads the prebuilt Mac or Windows MEX file for
            %nn_descent. If you are using Unix, you can call KnnFind.Build
            %to build for your platform, assuming you have set up the C++
            %compiler using the MATLAB tools.
            if ~ispc && ~ismac
                fprintf(['We have built nn_descent for the Mac '...
                    'and Windows!\n\tCall KnnFind.Build to build for '...
                    'Unix (or other platforms)\n']);
                error('You can only download for nn_descent Mac or Windows.');
            end
            mexFile=KnnFind.MexFile;
            [p,f,e]=fileparts(mexFile);
            url=['http://cgworkspace.cytogenie.org/run_umap/' f e];
            dlg=KnnFind.MsgBox(['<html>Downloading:<br>&nbsp;&nbsp;'... 
                '&nbsp;&nbsp;<b>' url '</b><br>to:<br>&nbsp;&nbsp;<i>'...
                '<font color="blue"><b>' p ...
                '</b></font></i><hr></html>']);
                try
                    websave(mexFile, url);
                catch ex
                    dlg.setVisible(false);
                    ex.getReport
                end
                dlg.setVisible(false);
        end
        

        function ok=Build
            %This invokes your C++ compiler to build a Mac or Windows MEX
            %file for nn_descent. If you have not yet installed a compiler,
            %then use the command "mex -setup" in the MATLAB Command
            %Window.
            curPath=fileparts(mfilename('fullpath'));
            cppPath=fullfile(curPath, 'nndescent', 'C++');
            cppFile=fullfile(cppPath, 'KnnDescent.cpp');
            if ~exist(cppFile, 'file')
                error(['Mex C++ source does not exist: ' cppFile]);
            end
            priorPwd=pwd;
            try
                cd(cppPath);
                disp('Building MEX-ecutable for nearest neighbor descent!!!')
                mex mexWrapper.cpp distances.cpp KnnDescent.cpp RpTree.cpp KnnGraph.cpp suh_math.cpp -output ../../nn_descent
            catch ex
                ex.getReport
                disp('You may need to set up your C++ compiler with "mex -setup C++"!');
            end
            cd(priorPwd);
            ok=true;
        end
        
        function ok=CanAccelerate(args, data_size, search_graph)
            %This estimates whether nn_descent will run faster than MATLAB
            %knnsearch for the input arguments and data conditions.
            ok=false;
            if ~isempty(args.NSMethod) ...
                    && ~strcmpi(args.NSMethod, 'nn_descent')
                return;
            end
            if args.nn_descent_min_rows<1
                return;
            end
            if ~KnnFind.MexIsAvailable
                return;
            end
            if ~isempty(args.NSMethod) ...
                    && strcmpi(args.NSMethod, 'nn_descent')
                ok=true;
                return;
            end
            metric=args.metric;
            if  ~strcmpi('seuclidean', metric)...
                    && ~strcmpi('euclidean', metric)...
                    && ~strcmpi('cityblock', metric)...
                    && ~strcmpi('cosine', metric)...
                    && ~strcmpi('correlation', metric)...
                    && ~strcmpi('mahalanobis', metric)...
                    && ~strcmpi('minkowski', metric) 
                return;
            end
            minRows=args.nn_descent_min_rows;
            minCols=args.nn_descent_min_cols;
            if strcmpi('mahalanobis', metric)
                minCols=3;
                minRows=6000;
            end
            if length(data_size) ~= 2 || data_size(1)<2 || data_size(2)<2
                warning('dataSizes must be [rows cols] where both >1');
                return;
            end
            
            if data_size(1)<minRows
                return;
            end
            if data_size(2)<minCols
                return;
            end
            if args.n_neighbors>args.nn_descent_max_neighbors
                return;
            end
            if nargin > 2 && isempty(search_graph)
                nextLine='<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                
                txt=['<html><b>Note:</b>&nbsp;&nbsp; If you re-create this ' ...
                    'template then' nextLine 'you will get'...
                    ' a nice speed-up that' nextLine 'was released '...
                    'in November 2020...<hr></center></html>'];
                if isempty(which('UmapUtil.m'))
                    KnnFind.MsgBox(txt)
                else
                    msg(txt, 0, 'north east+', ...
                        'Older template in use ...', 'genieSearch.png');
                end
                
                return;
            end
            ok=true;
        end
        
        
function [accuracy, time_approximate, time_determine, args]...
                =Test(X_csv, Y_csv, varargin)%
%  A simple test program that illustrates the use of KnnFind. Test scoops
%  up example data from CSV files that we download from our website.
%
% Input arguments
% X_csv      A comma-separated file containing an MX-by-N numeric matrix to
%            use as the 1st X argument to KnnFind's Run, Approximate, and
%            Determine methods. Rows of X correspond to observations and
%            columns correspond to variables. If no argument is provided,
%            then the function opens a 40k-by-29 data set to illustrate the
%            performance improvements of the nn_descent nearest neighbor
%            search method versus the exhaustive search method.
% Y_csv      A comma-separated file containing an MY-by-N numeric matrix
%            of query points to use as the 2nd Y argument of KnnFind's Run,
%            Approximate, and Determine methods. Rows of Y correspond to
%            observations and columns correspond to variables. If no
%            argument or NaN is given, then Y_csv is set to X_csv, thus
%            indicating a self-only nearest neighbor search.
%
% Name-value pair arguments
%  Test() accepts all of the same name-value pair arguments documented in 
%  this file for Run and Approximate. Additional arguments specific to Test
%  include 
%
%  'rows'         A string that selects a subset of rows for X_csv and
%                 Y_csv. For example:
%                   '1:2:end' selects half of the rows,
%                   '1:3:end' selects one-third,
%                   '1:5000' selects the first 5 thousand.
%
%  'cols'         A string that selects a subset of columns for X_csv and
%                 Y_csv. This behaves exactly like the 'rows' argument.
%                 This can be useful if X_csv or Y_csv has columns that
%                 harm the search, like a label column identifying classes
%                 for each row. With our UMAP distribution for MATLAB, we
%                 often have csv files where the label is the last column.
%                 Thus 'cols'=='1:end-1' eliminates this label column.
%
% Output Arguments
%  accuracy      A number from 0 to 1, where 1 indicates 100% accuracy
%                in the indices found by C++ nn_descent when compared 
%                with MATLAB knnsearch methods.
%  time_approximate 
%                A number indicating the number of seconds it took for
%                the C++ nn_descent (via KnnFind.Approximate) to run.
%  time_determine 
%                A number indicating the number of seconds it took for
%                the MATLAB knnsearch (via KnnFind.Determine) to run.
%  args          A struct containing all of the name-value pair arguments
%                used to execute C++ nn_descent (via KnnFind.Approximate) 
%                and MATLAB knnsearch (via KnnFind.Determine).
%
        
            if nargin<2 
                Y_csv=''; 
            end
            if isempty(Y_csv)
                if nargin==0
                    disp('Illustrating the speed of C++ nn_descent....');
                    X_csv=30;
                    Y_csv=nan;
                    varargin{end+1}='rows';
                    varargin{end+1}='1:40000';
                elseif ischar(X_csv)
                    temp=str2double(X_csv);
                    if ~isnan(temp)
                        X_csv=temp;
                    end
                end
            end
            args=KnnFind.GetArgs(varargin{:});
            n_neighbors=args.K;
            metric=char(args.metric);
            sfx=['_' metric];
            url=[];
            if isnumeric(X_csv)
                only1=~isempty(Y_csv) && isnumeric(Y_csv) && all(all(isnan(Y_csv)));
                if isnan(X_csv)
                    X_csv=0;
                end
                if X_csv==30
                    varargin{end+1}='cols';
                    varargin{end+1}='1:end-1';
                    args.cols='1:end-1';
                    X_csv='s1_samusikImported_29D';
                    if only1
                        Y_csv=X_csv;
                    else
                        Y_csv='s2_samusikImported_29D';
                    end
                    url='https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896314/';
                elseif X_csv==29
                    X_csv='cytofExample1';
                    if only1
                        Y_csv=X_csv;
                    else
                        Y_csv='cytofExample2';
                    end
                    url='https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896314/';
                elseif X_csv==27
                    varargin{end+1}='cols';
                    varargin{end+1}='1:end-1';
                    args.cols='1:end-1';
                    X_csv='s1_genentech_27D';
                    if only1
                        Y_csv=X_csv;
                    else
                        Y_csv='s2_genentech_27D';
                    end
                    url='https://www.frontiersin.org/articles/10.3389/fimmu.2019.01194/full';
                else
                    X_csv='sample10k';
                    if only1
                        Y_csv=X_csv;
                    else
                        Y_csv='sample30k';
                    end
                    url='https://www.pnas.org/content/107/6/2568';

                end
            else
                only1=isempty(Y_csv) || (isnumeric(Y_csv) && isnan(Y_csv));           
                if only1
                    Y_csv=X_csv;
                end
            end
            if ~isempty(url)
                fprintf('Using data published at\n\t%s\n', url);
            end
            search_graph_file=[X_csv sfx];
            if ~ischar(Y_csv)
                error('Y_csv must identify a file CSV file');
            end
            if ~endsWith(X_csv, '.csv', 'IgnoreCase', true) 
                X_csv=[X_csv '.csv'];
            end
            if ~endsWith(Y_csv, '.csv', 'IgnoreCase', true) 
                Y_csv=[Y_csv '.csv'];
            end
            self_search=isequal(X_csv, Y_csv);
            [fLocate, ~, fSecs, fSearchGraph]=KnnFind.FindCallbacks;
            if isempty(args.example_finder_callback)
                args.example_finder_callback=fLocate;
            end
            if ~self_search
                files=feval(args.example_finder_callback, {X_csv, Y_csv});
            else
                files=feval(args.example_finder_callback, {X_csv});
            end
            p=fileparts(files{1});
            X=KnnFind.ReadCsv(X_csv, args);
            [R1, C1]=size(X);
            X_sz=[KnnFind.Encode(R1) ' X ' KnnFind.Encode(C1) ];
            if ~self_search
                search_graph_file=[search_graph_file '_' num2str(R1) ...
                    'x' num2str(C1) '.mat'];    
                search_graph_file=fullfile(p, search_graph_file);
                if ~exist(search_graph_file, 'file')
                    fprintf(['FIRST building search_graph ' ...
                        'for %s and storing in \n\t  %s\n'], ...
                        X_sz, search_graph_file);
                    [knnIndices, knnDists]=KnnFind.Approximate(X,[],varargin{:});
                    search_graph=feval(fSearchGraph, X, args.K, ...
                        knnIndices, knnDists, [], .5);
                    save(search_graph_file, 'search_graph');
                else
                    load(search_graph_file, 'search_graph');
                end
            end
            if ~self_search
                Y=KnnFind.ReadCsv(Y_csv, args);
                [R2, C2]=size(Y);
                Y_sz=[KnnFind.Encode(R2) ' X ' KnnFind.Encode(C2)];
                sz=[Y_sz ' in ' X_sz ', K=' ....
                    num2str(n_neighbors) ' and Distance="' metric '"'];
                varargin{end+1}='X_search_graph';
                varargin{end+1}=search_graph;
            else
                Y=X;
                sz=X_sz;
            end
            
            timeCpp=tic;
            fprintf('Starting C++ nn_descent on %s\n',  sz);
            if isempty(args.progress_callback)
                cb=[];
                %cb=@test_callback;
                if ~isempty(cb)
                    varargin{end+1}='progress_callback';
                    varargin{end+1}=cb;
                end
            end
            nvpa=varargin;
            nvpa{end+1}='NSMethod';
            nvpa{end+1}='nn_descent';
            knnIndices2=KnnFind.Approximate(X, Y, nvpa{:});
            time_approximate=toc(timeCpp);
            fprintf('Done ... C++ nn_descent took %s searching %s \n', ...
                feval(fSecs, time_approximate), sz);
            fprintf('Starting MATLAB knnsearch on %s\n', sz);
            timeMatLab=tic;
            knnIndices1=KnnFind.Determine(X, Y, args);
            time_determine=toc(timeMatLab);
            fprintf(['Done ... MATLAB knnsearch took %s searching %s \n'...
                '\t(%s%% as long as C++ nn_descent)\n'],...
                feval(fSecs, time_determine), sz, KnnFind.Encode(...
                time_determine/time_approximate*100));
            
            accuracy = KnnFind.AssessApproximation(knnIndices1, knnIndices2);
            disp(['C++ nn_descent accuracy is ' num2str(100*accuracy) ...
                ' percent!']);
            
          

        end

        
        function [knnIndices, knnDists, X_search_graph]=...
                Determine(X, Y, knnsearch_args)
% A basic wrapper around the most common arguments for knnsearch, except
% that knnsearch's name-value pair arguments are given in the struct
% knnsearch_args.
%
% Input arguments
% X                 An MX-by-N numeric matrix. Rows of X correspond to
%                   observations and columns correspond to variables.
% Y                 An MY-by-N numeric matrix of query points. Rows of Y
%                   correspond to observations and columns correspond to 
%                   variables.
% knnsearch_args    struct containing knnsearch's name-value pair
%                   arguments.
%
% Output arguments
% knnIndices        matrix of MY rows by K columns. Each row contains
%                   indices of the nearest neighbors in X for the
%                   corresponding row in Y.
% knnDists          matrix of MY rows by K columns. Each row contains the
%                   measured distance from the point defined by the
%                   corresponding row in Y to the points in X corresponding
%                   to the indices from knnIndices.
% X_search_graph    sparse square matrix of MX rows by MX columns that
%                   accelerates approximation for subsequent searches of X
%                   IF Y is not equal. Subsequent calls would contain this
%                   output argument as the value for 'X_search_graph'
%                   name-value pair.
%
            if ~isstruct(knnsearch_args)
                hasName=@isprop;
                getValue=@getprop;
            else
                hasName=@isfield;
                getValue=@getfield;
            end
            nameValuePairs={};
            [~,metric]= addNameValuePair('Distance', 'metric');
            addNameValuePair('K', 'n_neighbors');
            if ~addNameValuePair('P') ...
                    && ~addNameValuePair('Cov') ...
                    && ~addNameValuePair('Scale')
                if strcmpi(metric, 'mahalanobis')
                    addNameValuePairAs('dist_args', 'Cov');
                elseif strcmpi(metric, 'minkowski')
                    addNameValuePairAs('dist_args', 'P');
                elseif strcmpi(metric, 'seuclidean')
                    addNameValuePairAs('dist_args', 'Scale');
                end
            end
            addNameValuePair('BucketSize');
            addNameValuePair('IncludeTies');
            addNameValuePair('NSMethod');
            [knnIndices, knnDists]=knnsearch(X, Y, nameValuePairs{:});
            if nargout>2 
                if ~isempty(args.X_search_graph)
                    X_search_graph=args.X_search_graph;
                else
                    [~, ~, ~, fSearchGraph]=KnnFind.FindCallbacks;
                    X_search_graph=feval(fSearchGraph, X, n_neighbors, ...
                        knnIndices, knnDists, [], .5);
                end
            end
            function value=getprop(instance, name)
                value=instance.(name);
            end
            function [ok, value]=addNameValuePair(name, synonym)
                ok=false;
                value=[];
                if feval(hasName, knnsearch_args, name)
                    value=feval(getValue, knnsearch_args, name);
                    if ~isempty(value)
                        nameValuePairs{end+1}=name;
                        nameValuePairs{end+1}=value;
                        ok=true;
                    end
                end
                if ~ok && nargin>1
                    [ok, value]=addNameValuePairAs(synonym, name);
                end
            end
            function [ok,value]=addNameValuePairAs(name, as)
                ok=false;
                value=[];
                if feval(hasName, knnsearch_args, name)
                    value=feval(getValue, knnsearch_args, name);
                    if ~isempty(value)
                        nameValuePairs{end+1}=as;
                        nameValuePairs{end+1}=value;
                        ok=true;
                    end
                end
            end
            
        end
        
        function ok=MexIsAvailable()
            ok=exist(KnnFind.MexFile, 'file')~=0;
        end

        function mexFile=MexFile()
            mexFile=fullfile(fileparts(mfilename('fullpath')),...
                ['nn_descent.' mexext ]);
        end

        
        function ok=CheckDistArgs(nCols, args)
            ok=true;
            cnt=KnnFind.CountDistArgs(args);
            if cnt>1
                ok=false;
                warning(['Only 1 of these 4 parameters can be set:  '...
                    'dist_args, P, Cov Scalar']);
                return;
            end
            if ~isempty(args.dist_args)
                metric=lower(args.metric);
                if strcmpi(metric, 'minkowski')
                    if length(args.dist_args)~=1
                        warning('metric=Minkowski thus dist_args of P must be a scalar');  
                        args.dist_args=[];
                    elseif args.dist_args<1
                        warning('metric=Minkowski thus dist_args of P must be >=1');
                        ok=false;
                    end
                elseif strcmpi(metric, 'mahalanobis')
                    [~, C]=size(args.dist_args);
                    if C ~= nCols
                        warning(['metric=Mahalanobis thus '...
                            '# columns for Cov/dist_args ' num2str(C) ...
                            ' must match data columns ' num2str(nCols)]);
                        ok=false;
                    elseif ~issymmetric(args.dist_args)
                        warning(['metric=Mahalanobis thus Cov/dist_args'...
                            ' must be a covariance matrix']);
                        ok=false;
                    end
                elseif strcmpi(metric, 'seuclidean')
                    [R, C]=size(args.dist_args);
                    if R ~= 1
                        warning(['metric=SEuclidean thus '...
                            '# rows for Scalar/dist_args  ' num2str(C) ...
                            'must be 1 for standard eviation']);
                        ok=false;
                    elseif C ~= nCols
                        warning(['metric=SEuclidean thus '...
                            '# columns ' num2str(C) ' for Scale' ...
                            '/dist_args must match data columns ' ...
                            num2str(nCols)]);
                        ok=false;
                    end
                else
                    ok=false;
                    if ischar(args.metric)
                        strMetric='args.metric';
                    else
                        strMetric=class(args.metric); 
                        %ok=true;
                    end
                    warning(['metric=' strMetric ' thus '...
                            'dist_args argument=' ...
                            String.toString(args.dist_args) ...
                            ''' is meaningless']);
                end
            end
        end
        
        function args=ExtractDistArgs(args, argued)
            %Sort out argument synonyms used by knnsearch and C++
            %nn_descent.
            if nargin==1 || argued.contains(java.lang.String('k'))
                args.n_neighbors=args.K; % synonym
            end
            if ~isempty(args.Distance) || ...
                    (nargin>1 && argued.contains(java.lang.String('distance')))
                args.metric=args.Distance;
            end
            
            cnt=KnnFind.CountDistArgs(args);
            if cnt<2
                if isempty(args.dist_args)
                    if ~isempty(args.Scale)
                        if ~strcmpi('seuclidean', args.metric)
                            error('Scale is only needed for metric SEuclidean ... ');
                        else
                            args.dist_args=args.Scale;
                        end
                        args.Scale=[];
                    end
                    if ~isempty(args.P)
                        if ~strcmpi('minkowski', args.metric)
                            error('Scale is only needed for metric minkowski... ignoring');
                        else
                            args.dist_args=args.P;
                        end
                        args.P=[];
                    end
                    if ~isempty(args.Cov)
                        if ~strcmpi('mahalanobis', args.metric)
                            error('Scale is only needed for metric minkowski... ignoring');
                        else
                            args.dist_args=args.Cov;
                        end
                        args.Cov=[];
                    end
                end
            end
        end
        

        function [indptr, indices]=IndPtrAndIndices(sparseArray)
            % Get the equivalent of the data members indptr and indices
            % used by Python NumPy for a sparse matrix. This is needed by
            % the C++ code for nn_descent.
            assert(issparse(sparseArray));
            [indices, rows] = find((sparseArray)');
            indices=indices-1;
            indptr = find(rows ~= [rows(2:end); 0]);
            indptr = [0; indptr];
        end
        
        
        
        function search_graph=SearchGraph(knnIndices)
            % This builds a sparse square matrix of MX rows by MX columns
            % that accelerates nn_descent for self-other searches where X
            % and Y are not equal.
            
            [n_samples, n_neighbors] = size(knnIndices);    
            knn_fail = knnIndices == -1;
            rows = repmat((1:n_samples)', 1, n_neighbors);
            rows(knn_fail) = NaN;
            rows = rows';
            rows = rows(:);
            cols = knnIndices;
            cols(knn_fail) = NaN;
            cols = cols';
            cols = cols(:);
            result= sparse(rows, cols, true(1, length(rows)), n_samples, n_samples);
            transpose = result';
            search_graph = result + transpose - (result .* transpose) + speye(n_samples);
        end
        
        function prop_found = AssessApproximation(exact_nn_ids,approx_nn_ids)
            %AssessApproximation reports how many of the correct nearest
            %neighbor indices (stored in the array exact_nn_ids) were found
            %by an approximate nearest neighbor method (results of which
            %are stored in approx_nn_ids).
            if size(exact_nn_ids) ~= size(approx_nn_ids)
                error('Input arguments must be arrays of the same size');
            end
            [n_samples, n_neighbors] = size(exact_nn_ids);

            if all(exact_nn_ids(:,1) == (1:n_samples)') && all(approx_nn_ids(:,1) == (1:n_samples)')
                exact_nn_ids = exact_nn_ids(:,2:end);
                approx_nn_ids = approx_nn_ids(:,2:end);
                n_neighbors = n_neighbors-1;
            else
                warning('The first column of your two index arrays do not match.');
            end

            total_entries = n_samples*n_neighbors;
            total_overlap = 0;
            for i = 1:n_samples
                total_overlap = total_overlap + length(intersect(exact_nn_ids(i,:),approx_nn_ids(i,:)));
            end
            prop_found = total_overlap/total_entries;
        end
        
        function D2=ExampleDistFunc(Z1,ZJ)
            %A nonsense distance callback function provided here to
            %illustrate callback API.
        
            [R,C]=size(ZJ);
            D2=zeros(R,1);
            for r=1:R
                for c=1:C
                    D2(r)=Z1(c)-ZJ(r,c);
                end
            end
        end

    end
    
    properties(Constant, Access=private)
        METRICS = {'euclidean', 'cityblock', 'seuclidean', ...
                'minkowski', 'mahalanobis', 'cosine', 'chebychev', ...
                'correlation', 'hamming', 'jaccard', 'spearman'};
            
        NN_DESCENT_METRIC_NOT_READY={'jaccard'};
        NN_DESCENT_METRIC={'euclidean', 'cityblock', ...
                'minkowski', 'mahalanobis', 'cosine', 'chebychev', ...
                'correlation', 'hamming', 'spearman', 'seuclidean'};
    end

    methods(Static, Access=private)
        function [fLocate, fCsv, fSecs,fSearchGraph]=FindCallbacks
            umapIsInstalled=~isempty(which('UmapUtil.m'));
            if umapIsInstalled
                fLocate=@UmapUtil.RelocateExamples;
                try
                    edu.stanford.facs.swing.Basics.RemoveXml('<html>hi</html>');
                catch 
                    umapIsInstalled=false;
                    fLocate=@KnnFind.GetExamples;
                end
            else
                fLocate=@KnnFind.GetExamples;
            end
            if nargout>1
                if umapIsInstalled && ~isempty(which('File.m'))
                    fCsv=@File.ReadCsv;
                else
                    fCsv=@KnnFind.CsvRead;
                end
                if nargout>2
                    if umapIsInstalled && ~isempty(which('String.m'))
                        try
                            String.MinutesSeconds(61);                            
                            fSecs=@String.MinutesSeconds;
                        catch
                            fSecs=@KnnFind.EncodeSecs;
                        end
                    else
                        fSecs=@KnnFind.EncodeSecs;
                    end
                    if nargout>3
                        if umapIsInstalled
                            fSearchGraph=@NnDescent.SearchGraph;
                        else
                            fSearchGraph=...
                                @(data, n_neighbors, knnIndices, ...
                                knnDists, labels, target_weight)...
                                KnnFind.SearchGraph(knnIndices);
                        end
                    end
                end
            end
        end
        
        function args=DefineArgs(varargin)
            args = inputParser;
            addParameter(args,'K', 15, @(x) isnumeric(x));
            addParameter(args,'X_search_graph', [], @(x) isnumeric(x));
            addParameter(args,'randomize', true, @(x)islogical(x));
            addParameter(args,'n_async_tasks', 3, @(x) x>= 1 && x<=100);
            addParameter(args,'dist_args', [], @(x) isnumeric(x));
            addParameter(args,'nn_descent_transform_queue_size', ...,
                KnnFind.DFLT_TRANSFORM_Q_SZ, @(x) isnumeric(x));
            addParameter(args,'progress_callback',  [], ...
                @(x)isequal('function_handle', class(x)) || isempty(x));
            addParameter(args,'metric', 'euclidean', ...
                @(x)isequal('function_handle', class(x)) || ...
                any(validatestring(x, KnnFind.METRICS)));
            addParameter(args,'Distance', [], ...
                @(x) isequal('function_handle', class(x)) || ...
                any(validatestring(x, KnnFind.METRICS)));
            addParameter(args,'rows', ':', ...
                @(x)ischar(x)|| (isnumeric(x) && x>=0 && x<1));
            addParameter(args,'cols', ':', @(x)ischar(x));
            addParameter(args,'example_finder_callback',  [], ...
                @(x)isequal('function_handle', class(x)) || isempty(x));
            addParameter(args,'nn_descent_min_rows', 40000, ...
                @(x)isnumeric(x) && (x==0 || x>4097));
            addParameter(args,'nn_descent_min_cols', 11, ...
                @(x)isnumeric(x) && x>3);
            addParameter(args,'nn_descent_max_neighbors', 45, ...
                @(x)isnumeric(x) && x>3);
            addParameter(args,'Cov', [], @(x)isnumeric(x));
            addParameter(args,'P', [], @(x)isnumeric(x));
            addParameter(args,'Scale', [], @(x)isnumeric(x));
            expectedNSMethod= {'kdtree', 'exhaustive', 'nn_descent'};
            addParameter(args,'NSMethod', [], ...
                @(x) any(validatestring(x,expectedNSMethod)));
            addParameter(args,'IncludeTies', false, @(x)islogical(x));
            addParameter(args,'BucketSize', [], @(x)isnumeric(x));
        end
       
        function cnt=CountDistArgs(args)
            cnt=0;
            if ~isempty(args.dist_args)
                cnt=1;
            end
            try
                if ~isempty(args.Scale)
                    cnt=cnt+1;
                end
                if ~isempty(args.P)
                    cnt=cnt+1;
                end
                if ~isempty(args.Cov)
                    cnt=cnt+1;
                end
            catch
            end
        end
                
        function outFiles=GetExamples(files)
            N=length(files);
            outFiles=cell(1,N);
            dfltFldr=fullfile(...
                char(java.lang.System.getProperty('user.home')),...
                'knnFind');
            missing={};
            ts=java.util.TreeSet;
            ts.add(dfltFldr);
            if ~exist(dfltFldr, 'dir')
                mkdir(dfltFldr);
            end
            for i=1:N
                [p, f, e]=fileparts(files{i});
                if isempty(p)
                    outFiles{i}=fullfile(dfltFldr, [f e]);
                else
                    outFiles{i}=fullfile(p, [f e]);
                end
                if ~exist(outFiles{i}, 'file')
                    missing{end+1}=outFiles{i};
                    if ~isempty(p)
                        ts.add(p);
                    end
                end
            end
            N=length(missing);
            if N>0
                html=['<html>Downloading %d of ' ...
                    num2str(N) ' example CSV file(s) to<br>your local'...
                    'folder(s):<hr><br><b><i>%s</i></b>'...
                    '<br>&nbsp;&nbsp;&nbsp;&nbsp;<b>' ...
                     '%s</b><br><br><hr></html>'];
                [dlg, jl]=KnnFind.MsgBox(sprintf(html, 0, '', ''));
                try
                    for i=1:N
                        [p,f,e]=fileparts(missing{i});
                        jl.setText(sprintf(html, i, [f e], p));
                        websave(missing{i},...
                            ['http://cgworkspace.cytogenie.org/'...
                            'run_umap/examples/' f e]);
                    end
                catch ex
                    dlg.setVisible(false);
                    ex.getReport
                end
                dlg.setVisible(false);
            end
        end
        
        function s=EncodeSecs(num)
            s=[ KnnFind.Encode(num) ' secs' ];
        end

        function s=Encode(num)
            nf = java.text.DecimalFormat;
            s=char(nf.format(num));
        end
        
        function idx=CellIndex(items, item)
            idx=0;
            C=length(items);
            for i=1:C
                if strcmpi(items{i}, item)
                    idx=i;
                    return;
                end
            end
        end
        
        function output=ToSystem(input)
            SHELL='[\\\|&\(\)< >'':\`\*;"]';
            if ~isempty(regexp(input, SHELL, 'once'))
               if ispc
                   output=['"' input '"'];
               else
                   output=regexprep(input, SHELL, '\\$0');
               end
            else
                output=input;
            end
        end
        
        function [dlg, jl]=MsgBox(html)
            jl=javaObjectEDT('javax.swing.JLabel', html);
            jop=javaObjectEDT(javax.swing.JOptionPane(jl));
            dlg=javaObjectEDT(jop.createDialog([], 'Note...'));
            dlg.setModal(false);
            dlg.show;
        end
        
        
        function [args, argued]=GetArgs(varargin)
            argued=java.util.TreeSet;
            N=length(varargin);
            for i=1:2:N
                argued.add(java.lang.String(lower(varargin{i})));
            end
            args=KnnFind.DefineArgs();
            parse(args,varargin{:});
            args=args.Results;
            args=KnnFind.ExtractDistArgs(args, argued);
        end
        
        
        function mexFile=Quarantine()
            mexFile=KnnFind.MexFile;
            if ismac
                system(['xattr -r -d com.apple.quarantine ' ...
                    KnnFind.ToSystem(mexFile)]);
            end
        end

        function data=ReadCsv(file, args)
            warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');
            [fLocate, fCsv]=KnnFind.FindCallbacks;
            if nargin>1
                fLocate=args.example_finder_callback;
            end
            f=feval(fLocate, {file});
            file=f{1};
            data=feval(fCsv, file);
            if nargin>1
                if isnumeric(args.rows)
                    R=size(data,1);
                    args.rows=floor(args.rows*R);
                    args.rows=['1:' num2str(rows)];
                end
                if ~isequal(args.rows, ':') || ~isequal(args.cols, ':')
                    data=eval(['data(' args.rows ',' args.cols ')']);
                end
            end
        end

        function inData=CsvRead(csvFile)
            t=readtable(csvFile, 'ReadVariableNames', true);
            try
                inData=table2array(t);
                if verLessThan('matlab', '9.6')
                    if all(isnan(inData(:,end)))
                        C=size(inData,2);                        
                        if isequal(['Var' num2str(C)], ...
                                t.Properties.VariableNames{end}) ...
                                && isequal('', ...
                                t.Properties.VariableDescriptions{end})
                            inData(:,end)=[];
                        end
                    end
                end
            catch ex
                if verLessThan('matlab', '9.6')
                    inData=[];
                    ex.getReport
                    return;
                end
                t=removevars(t, t.Properties.VariableNames{end});
                inData=table2array(t);
            end
            if iscell(inData) && mustBeNumbers
                inData=[];
                warning('comma separated file does NOT contain numbers');
            end
        end

       
    end
end