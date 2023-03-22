%   AUTHORSHIP
%   Developer: Stephen Meehan <swmeehan@stanford.edu>
%   Funded by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%

classdef MlpPython
% This file contains the wrappers for doing our MLP training and predicting
% (AKA classifying) via Python TensorFlow.
%
% The method MlpPython.IsAvailable confirms the installation of all
% dependencies.  If Python version 3.7, 3.8, or 3.9 is not present, the
% function guides the user to the website for version 3.7.9.  If TensorFlow
% dependencies are missing, the function explains the imports needed and
% lets the user choose automatic installation.  The imports needed are:
% pandas, numpy, matplotlib, sklearn and tensorflow.  The main processing
% is down through our script mlp.py, which you are free to evolve.
%
% By default, we invoke Python indirectly using the system command which
% calls either mlpTrain.py or mlpPredict.py to marshall input and output
% files and other command line arguments.  If you are using MATLAB r2019b
% or later, we avoid command line processing and CSV file processing and
% invoke the mlp_predict2 function in mlp.py directly in process using
% MATLAB's py routines.  For MATLAB py functions to work, you must call
% pyenv (only once) immediately after MATLAB starts to identify where the
% Python with TensorFlow is located. For example, on a Mac for version
% 3.7.9 the command is likely
%       pyenv('Version', '/usr/local/bin/python3.7');
% We display the exact command needed the first time the function
% MlpPython.Predict runs without this setup.  The function always continues
% with the out of process calling until the pyenv command is called
% correctly immediately after starting MATLAB.
%     
% 
%   EXAMPLES of Train then Predict.  Arguments are documented in each
%   function's header. If no folder is given for CSV file inputs arguments,
%   this defaults to ~/Documents/run_umap/examples folder.  If they don't
%   exist, they are downloaded from our server.
%
%   1.      Build similar model as run_umap's example 33 without UMAP.  The
%           training progress is reported in an OS "shell window" (terminal
%           on Mac and cmd.exe on MS Windows). The sample trained on is a
%           BALB/c mouse strain. Then classify a separate sample with a
%           different staining preparation (FMO=fluoresence minus one).
%           Then show the Hi-D match result.
%
%           modelTensorFlowFile1=MlpPython.Train('balbc4FmoLabeled.csv', 'epochs', 210, 'class', .12, 'confirm_model', false);
%           % The above command sets modelTensorFlowFile1='~/Documents/run_umap/examples/balbc4FmoLabeled';
%           lbls=MlpPython.Predict('balbcFmoLabeled.csv', 'model_file', modelTensorFlowFile1, 'test_label_file', 'balbc4FmoLabeled.properties', 'training_label_file', 'balbcFmoLabeled.properties', 'confirm_model', false);
%
%   2.      Build similar model as run_umap's example 39 without umap.  The
%           training progress is reported in an OS "shell window" (terminal
%           on Mac and cmd.exe on MS Windows), but unlike the above example
%           1, MATLAB does not wait for it to complete. The biological
%           sample trained on is the same as example 1, but with additional
%           stain measurements. Then classify on a biological sample with
%           compatible measurements but from a different mouse strain that
%           is genetically modified to lack T cells or B cells. Then show
%           the Hi-D match result.
%
%           modelTensorFlowFile2=MlpPython.Train('balbc4RagLabeled.csv', 'epochs', 210, 'confirm_model', false, 'wait', false);
%           % The above command sets modelTensorFlowFile2='~/Documents/run_umap/examples/balbc4RagLabeled';
%           lbls=MlpPython.Predict('ragLabeled.csv', 'model_file', modelTensorFlowFile2, 'test_label_file', 'balbc4RagLabeled.properties', 'training_label_file', 'ragLabeled.properties', 'confirm_model', false);
%
%   3.      Repeat example 2's Predict call, except provide the data matrix
%           directly.
%
%           modelTensorFlowFile2='~/Documents/run_umap/examples/balbc4RagLabeled';
%           [testSet, columnNames]=File.ReadCsv('ragLabeled.csv');
%           lbls=MlpPython.Predict(testSet, 'column_names', columnNames, 'model_file', modelTensorFlowFile2, 'test_label_file', 'balbc4RagLabeled.properties', 'training_label_file', 'ragLabeled.properties', 'confirm_model', false);
%

properties(Constant)
        PIP={'pandas', 'numpy', 'matplotlib', ...
            'sklearn', 'tensorflow'};
        PY_V='3.7.9';
        PY_V_CMD='3.7';
        PY_V_CMD_F='3.9';
        %Stephen's most tested Python version is 3.7.9
        PY_379_URL='https://www.python.org/downloads/release/python-379/';
        PROP_CMD=['pythonMlpCmdVer' MlpPython.PY_V];
        TRY_PYTHON=false;
        DEBUG_PYRUN=false;
    end
    
    methods(Static)
        function cmd=GetCmd(app)  
            if nargin < 1
                app = BasicMap.Global;
            end   
            if ispc
                cmd=app.get(MlpPython.PROP_CMD, 'py');
            else
                cmd=app.get(MlpPython.PROP_CMD, 'python');
            end
        end


        function p=DefineArgsForTrain
            p = Mlp.DefineArgs;
            addParameter(p, 'epochs', 200, ... %25 seems fine for most flow cytometry so far
                @(x)Args.IsNumber(x,'epochs', 10, 200000));
            addParameter(p, 'wait', true, @islogical);
        end

        function [modelFileName, stdoutPython]=Train(csvFileOrData, varargin)
%
%   MlpPython.Train builds a fastforward fully connected neural network
%   using Python's TensorFlow package as programmed by Jonathan Ebrahimian.
%
%   [modelFileName, stdout]=MlpPython.Train(csvFileOrData,...
%   'NAME1',VALUE1, 'NAMEN',VALUEN) 
%
%RETURN VALUES
%   MlpPython.Train has 2 output arguments:
%   1)modelFilename:  the path and name of file with TensorFlow model.
%   2)stdoutPython:  output from shell invocation of Python.
%
%
%   REQUIRED INPUT ARGUMENT
%   csvFileOrData is a CSV file containing a matrix or a matrix where the
%   columns are numeric measurements and the last column MUST be a numeric
%   identifier of the class of the matrix row.
%
%   OPTIONAL NAME VALUE PAIR ARGUMENTS
%   Additional arguments include:
%
%   Name                    Value
%   'column_names'          A cell of names for each column. This is only
%                           needed if csvFileOrData is a matrix; otherwise,
%                           the column names are required in the first line
%                           of the CSV file.
%
%   'model_file'            Name of file to save model to.  If no argument
%                           is specified, then this function saves the
%                           model to the folder containing the input CSV
%                           file, substituting the extension "csv" with
%                           "h5". If the input data is a matrix, the
%                           file model is saved to ~/Documents/mlp with a
%                           generated name based on size and mean of
%                           classification label.
%                           
%   'confirm_model'         true/false.  If true a file save window pops up
%                           to confirm the model file name.
%                           Default is true.
%
%  'epochs'                 The # of epochs to run for training.
%                           Default is 200.
%           
%  'wait'                   true/false to wait for model to complete.
%                           Default is true.
%
            txt=['<html>Python''s TensorFlow is training '...
            '<br>an MLP neural network...<hr></html>'];
            stdoutPython=[];
            try
                args=Args.NewKeepUnmatched(...
                    MlpPython.DefineArgsForTrain,varargin{:});
                if isempty(args.pu)
                    closePu=true;
                    args.pu=PopUp(txt);
                else
                    closePu=false;
                    args.pu.setText(txt);
                end
            catch ex
                BasicMap.Global.reportProblem(ex);
                if closePu
                    args.pu.close;
                end
                throw(ex);
            end
            if nargin<1
                csvFileOrData='';
            end
            if isempty(csvFileOrData) %fav example from Eliver Ghosn
                csvFileOrData='balbc4FmoLabeled.csv';
            end            
            app=BasicMap.Global;
            if ~MlpPython.IsAvailable(app)
                msg(Html.WrapHr(['Python ' MlpPython.PY_V ' (or later, up to ' MlpPython.PY_V_CMD_F ') and ' ...
                    '<br>essential MLP Python packages<br>appear to be unavailable...']),...
                    8, 'north', 'So sorry...');
                modelFileName='';
                stdoutPython='';
                if closePu
                    args.pu.close;
                end
                return;
            end
            if isempty(csvFileOrData)
                csvFileOrData='balbc4FmoLabeled.csv';
            end
            [csvFile, modelFileName, ~,~,isTempFile]=Mlp.ResolveData(...
                csvFileOrData, args.column_names, ...
                args.model_file, args.confirm_model, ...
                true, true, true, args.class_limit, ...
                args.props, args.property, ...
                args.model_default_folder, args.epochs);
            if isempty(csvFile) || isempty(modelFileName)
                if closePu
                    args.pu.close;
                end
                return;
            end
            cmd=MlpPython.GetCmd(app);
            cmdline=String.ToSystem(cmd);
            pyFilePath=fileparts(mfilename('fullpath'));
            pythonScript=String.ToSystem(fullfile(pyFilePath, ...
                'mlpTrain.py'));
            pathArg=String.ToSystem(csvFile);
            modelArg=String.ToSystem(modelFileName);
            fullCmd=[cmdline ' ' pythonScript ' ' pathArg...
                ' ' modelArg ...
                ' --epochs ' num2str(args.epochs)];
            fldr=fileparts(csvFile);
                terminalName=['  >>> Training MLP via '...
                    'Python TensorFlow ' ];
            script=fullfile(fldr, 'mlp.cmd');
            args.pu.stop;
            args.pu.setText2([num2str(args.epochs) ...
                ' epochs for:'...
                Html.FileTree(modelFileName)])
            x=tic;
            [status, stdout]=File.Spawn(fullCmd, script,  ...
                terminalName, ~args.wait, true);
            stdoutPython=strtrim(stdout);
            if args.wait
                took=toc(x);
                if isTempFile
                    delete(csvFile);
                end
            end
            if status~=0
                modelFileName=[];
            end
            if closePu
                args.pu.close;
            end
            if args.wait
                fprintf('MLP training time %s\n',...
                    String.HoursMinutesSeconds(took));
            end
        end

        function [labels, modelFileName, cmdOut, confidenceFile, ...
                confidence, qfTable]=Predict(csvFileOrData, varargin)
                   
% %MlpPython.Predict classifies a data matrix using a prior neural networks 
% built by Python TensorFlow via the script mlp.py.
%
%   [labels, modelFileName, cmdOut, confidenceFile, confidence, qfTable]
%       =MlpPython.Predict(csvFileOrData, 'NAME1',VALUE1, 'NAMEN',VALUEN) 
%            
%RETURN VALUES
%   MlpPython.Predict has 6 output arguments:
%   1)labels:  the classification labels predicted for each input row.
%   2)modelFileName:  the file containing the Python Tensorflow object
%      used.
%   3)cmdOut:  results reported by mlp.py if invoked via system command.
%   4)confidenceFile:  the name of the file containing the confidence
%      matrix if invoked by the system command.
%   5)confidence:  a matrix containing confidence values for each row's
%      classification for each training class in the neural network model.
%      Every column represents a training class.
%   6)qfTable:  the match table object if the input argument has_labels 
%      is true.
%
%   REQUIRED INPUT ARGUMENT
%   csvFileOrData is either a CSV file containing a matrix or a matrix
%   in which the columns are numeric measurements.  If the last column
%   contains numeric identifiers for an alternate classification of each
%   matrix row, THEN you must set the argument has_labels to true. 
%
%   OPTIONAL NAME VALUE PAIR ARGUMENTS
%
%   Name                    Value
%   'column_names'          A cell of names for each column. This is only
%                           needed if csvFileOrData is a matrix; otherwise,
%                           the column names are required in the first line
%                           of the CSV file.
%
%   'model_file'            Name of file from which to load the model. If
%                           no argument is specified, then this function
%                           searches the folder containing the input CSV
%                           file for a model of the same name, substituting
%                           the extension "csv" with "h5". If no folder for
%                           the file is given, then Train will query for
%                           its location.                 
%                           
%   'confirm_model'         true/false.  If true a file window pops up to
%                           confirm the model file to load.
%                           Default is true.
%
%   'has_labels'            true/false indicating that the last column
%                           of the matrix denoted by the csvFileOrData
%                           argument contains class identifiers (labels).
%                           Default is true.
%

            cmdOut=[];
            modelFileName='';
            confidenceFile=[];
            confidence=[];
            labels=[];
            qfTable=[];
            try
                txt=['<html>Engaging Python TensorFlow to classify'...
                    '<br>with an MLP neural network...<hr></html>'];
                [args, ~,~, argsObj]=Args.NewKeepUnmatched(...
                    Mlp.DefineArgsForPredict,varargin{:});
                if ~isempty(args.pu)
                    args.pu.setText(txt);
                end
            catch ex
                BasicMap.Global.reportProblem(ex);
                throw(ex);
            end
            if nargin<1
                csvFileOrData='';
            end
            app=BasicMap.Global;
            if ~MlpPython.IsAvailable(app)
                msg(Html.WrapHr(...
                    ['Python ' MlpPython.PY_V ' (or later, up to ' ...
                    MlpPython.PY_V_CMD_F ...
                    ') <br>is not available...']),...
                    8, 'north');
                return;
            end
            if isempty(csvFileOrData)
                csvFileOrData='balbcFmoLabeled.csv';
            end
            if isempty(args.model_file)
                args.model_file='balbc4FmoLabeled';
            elseif ~isa(args.model_file, 'ClassificationNeuralNetwork')
                args.model_file=Mlp.DoModelFileExtension(args.model_file, false);
            end
            [csvFile, modelFileName, columnNames, predictedLabels, isTempFile]...
                =Mlp.ResolveData(csvFileOrData, args.column_names, ...
                args.model_file, args.confirm_model, ...
                false, args.has_labels, true, ...
                args.class_limit, args.props, args.property);
            if isempty(csvFile) || isempty(modelFileName)
                return;
            end
            x=tic;
            if MlpPyRun.CanDo
                [labels, confidence]=MlpPyRun.Predict( ...
                    csvFile, modelFileName, false);
                if ~isempty(labels)
                    if ~isempty(varargin) && ~isempty(predictedLabels)
                        varArgIn=argsObj.getUnmatchedVarArgs;
                        [~, ~,~, argsObj]...
                            =Args.NewKeepUnmatched(...
                            SuhMatch.DefineArgs, varArgIn{:});
                        matchArgIn=argsObj.getVarArgIn;
                        try
                            [~, ~, ~, extras]=suh_pipelines(...
                                'pipe', 'match', ...
                                'training_set', csvFile,...
                                'training_label_column', predictedLabels, ...
                                'test_set', [], ...
                                'test_label_column', labels, ...
                                'column_names', columnNames, ...
                                'matchStrategy', 2, matchArgIn{:});
                            qfTable=extras.qfd{1};
                        catch
                            parent=fileparts(fileparts(mfilename('fullpath')));
                            addpath(parent);
                            [~, ~, ~, extras]=suh_pipelines(...
                                'pipe', 'match', ...
                                'training_set', csvFile,...
                                'training_label_column', predictedLabels, ...
                                'test_set', [], ...
                                'test_label_column', labels, ...
                                'column_names', columnNames, ...
                                'matchStrategy', 2, matchArgIn{:});
                            qfTable=extras.qfd{1};
                        end
                    end
                    return;
                end
                [csvFile, modelFileName, columnNames, predictedLabels, isTempFile]...
                    =Mlp.ResolveData(csvFileOrData, args.column_names, ...
                    args.model_file, args.confirm_model, ...
                    false, args.has_labels, true, ...
                    args.class_limit, args.props, args.property);
                if isempty(csvFile) || isempty(modelFileName)
                    return;
                end
            end
            tic
            cmd=MlpPython.GetCmd(app);
            cmdline=String.ToSystem(cmd);
            pyFilePath=fileparts(mfilename('fullpath'));
            pythonScript=String.ToSystem(fullfile(pyFilePath, ...
                'mlpPredict.py'));
            pathArg=String.ToSystem(csvFile);
            modelArg=String.ToSystem(modelFileName);
            [p,f]=fileparts(csvFile);
            outFile=fullfile(p,[f '_mlp.csv']);
            if exist(outFile, 'file')
                delete(outFile);
            end
            outArg=String.ToSystem(outFile);
            confidenceFile=fullfile(p,[f '_mlp_confidence.csv']);
            if exist(confidenceFile, 'file')
                delete(confidenceFile);
            end
            predArg=String.ToSystem(confidenceFile);
            fullCmd=[cmdline ' ' pythonScript ' ' pathArg...
                ' ' modelArg ...
                ' --output_csv_file ' outArg ...
                ' --predictions_csv_file ' predArg];
            fldr=fileparts(csvFile);
            if ~isempty(args.pu)
                ttl=['AutoGate MLP ' datestr(datetime)];
            else
                ttl='';
            end
            script=fullfile(fldr, 'mlp.cmd');
            varArgIn=argsObj.getUnmatchedVarArgs;
            [~, ~,~, argsObj]...
                    =Args.NewKeepUnmatched(SuhMatch.DefineArgs, varArgIn{:});
            matchArgIn=argsObj.getVarArgIn;
            %varArgIn=argsObj.getUnmatchedVarArgs;
            [status, stdout]=File.Spawn(fullCmd, script, ttl, false);
            haveResult=exist(outFile, 'file');
            if ~haveResult
                msgError(['<html>Classification result not found...'...
                    Html.FileTree(outFile) '</html>'], 8);
            else
                outData=File.ReadCsv(outFile);
                labels=outData(:,end);
            end
            cmdOut=strtrim(stdout);
            took=toc(x);
            if status==0 && haveResult ...
                    && ~isempty(varargin) && ~isempty(predictedLabels)
                testSet=File.ReadCsv(csvFile);
                try
                    [~, ~, ~, extras]=suh_pipelines('pipe', 'match', ...
                        'training_set', testSet,...
                        'training_label_column', predictedLabels, ...
                        'test_set', [], 'test_label_column', labels, ...
                        'column_names', columnNames, ...
                        'matchStrategy', 2, matchArgIn{:});
                    qfTable=extras.qfd{1};
                catch
                    parent=fileparts(fileparts(mfilename('fullpath')));
                    addpath(parent);
                    [~, ~, ~, extras]=suh_pipelines('pipe', 'match', ...
                        'training_set', testSet,...
                        'training_label_column', predictedLabels, ...
                        'test_set', [], 'test_label_column', labels, ...
                        'column_names', columnNames, ...
                        'matchStrategy', 2, matchArgIn{:});
                    qfTable=extras.qfd{1};
                end
            end
            delete(outFile);
            if isTempFile
                delete(csvFile);
            end
            if ~isempty(args.pu)
                fprintf('Classification compute time %s\n',...
                    String.HoursMinutesSeconds(took));
            end
            if nargout>4 && haveResult
                confidence=File.ReadCsv(confidenceFile);
            end
        end
        
        function [ok, pipCmd]=IsPipAvailable(cmd)
            [fldr,python, ext]=fileparts(cmd);
            if startsWith('python3', lower(python))
                pipCmd=fullfile(fldr, ['pip' python(7:end) ext]);
                if ~exist(pipCmd, 'file')
                    if ispc
                        pipCmd = 'py -m pip';
                    else
                        pipCmd='pip';
                    end
                end
            else
                pipCmd='pip';
            end

            status=system([pipCmd ' help']);
            ok=status==0;
            if ~ok
                if ispc
                    if askYesOrNo(Html.WrapHr([...
                            'MLP needs some Python packages installed <br>'...
                            'but pip.exe cannot be launched....<br><br>'...
                            '<b>See help on installing pip for MS Windows??</b>']))
                        web('https://phoenixnap.com/kb/install-pip-windows', '-browser');
                    end
                end
            end
        end

        function [ok, version, cmd]=ResetInstallation
            [ok, version, cmd]=MlpPython.IsAvailable(BasicMap.Global, true, true);
        end

       function [ok, version, cmd]=IsAvailable(app, interactWithUser, reset)
           if nargin<3
               reset=false;
               if nargin<2
                   interactWithUser=true;
                   if nargin<1
                       app=BasicMap.Global;
                   end
               end
           end
           if reset
               try
                   app.python=rmfield(app.python, 'mlp');
               catch
               end
           end
           if isfield(app.python, 'mlp')
               version=app.python.mlp;
               ok=~isempty(version);
               if ok
                   if nargout>2
                       cmd=MlpPython.GetCmd(app);
                   end
                   return;
               end
           end
           cmd=MlpPython.GetCmd(app);
            if isempty(cmd)
                cmd='python';
            end
            cmdline=String.ToSystem(cmd);
            [status, version]=system([cmdline ' -V']);
            if reset
                ok=false;
            else
                ok=status==0;
                if ~ok && ismac && isempty(fileparts(cmd))
                    tryCmd=fullfile('/usr/local/bin', cmdline);
                    [status, version]=system([tryCmd ' -V']);
                    ok=status==0;
                    if ok
                        cmdline=tryCmd;
                        cmd=fullfile('/usr/local/bin', cmd);
                        app.set(MlpPython.PROP_CMD, cmd);
                    end
                end
            end
            firstCmdOk=ok;
            if ok
                done=true;
                ok=String.StartsWithI(version, 'python 3.7') ...
                    || String.StartsWithI(version, 'python 3.8')...
                    || String.StartsWithI(version, 'python 3.9');
                if ok
                    curPath=fileparts(mfilename('fullpath'));
                    pythonScript=String.ToSystem(...
                        fullfile(curPath, 'testMlpImports.py'));
                    [status,output]=system([cmdline ' ' pythonScript]);
                    ok=status==0;
                    %ok=false;
                    if ~ok
                        msgWarning(Html.WrapTable(String.ToHtml( output), 2, 3, '0', 'center', 'in'), ...
                            0, 'south++', 'Python TensorFlow dependencies problem...');
                        [pipOk, pipCmd]=MlpPython.IsPipAvailable(cmd);
                        if ~pipOk
                            updateApp(ok, version);
                            return;
                        end
                        app.python.mlp=[];
                        if interactWithUser
                            if ispc
                                cmdApp='Windows "cmd" window';
                            else
                                cmdApp='Mac''s "terminal"';
                            end
                            needed=MlpPython.PIP;
                            htmlNeeded='';
                            for i=1:length(needed)
                                htmlNeeded=[htmlNeeded '<li>' pipCmd ...
                                    '  install <b>' needed{i} '</b>']; %#ok<AGROW> 
                            end
                            html=Html.Wrap([...
                                'MLP requires the Python packages:<ol>'...
                                htmlNeeded '<hr>']);
                            choice=Gui.Ask(html,...
                                {'Try automatic download & install', ...
                                ['Open ' cmdApp ' to install myself'], ...
                                'Specify different Python command'}, ...
                                'mlpInstall', 'MLP packages needed');
                            if choice==1
                                cmds=cell(1,length(needed));
                                for i=1:length(needed)
                                    cmds{i}=[pipCmd ' install ' needed{i}];
                                end
                                File.Spawn(cmds, ...
                                    fullfile(app.appFolder, 'pipMlp.cmd'),...
                                    ['AutoGate is installing MLP ' ...
                                    datestr(datetime)], false, true);
                                [ok, version]=MlpPython.IsAvailable(...
                                    app, true);
                            elseif choice==2
                                msg(Html.Wrap(['The Python packages '...
                                    'which MLP needs are<br>'...
                                    Html.ToList(MlpPython.PIP) ...
                                    'From the the command line type <br>'...
                                    '<br><i> ' pipCmd ' install "'...
                                    '<b>package name</b>"'...
                                    '</i><br><br>for <b>each</b> of the '...
                                    'packages in the list above.']));
                                if ispc
                                    system('start cmd');
                                else
                                    system('open -b com.apple.terminal');
                                end
                            elseif choice==3
                                app.remove(MlpPython.PROP_CMD);
                                done=false;
                            end
                        end
                    end
                    if done
                        updateApp(ok,version);
                        return;
                    end
                end
            end
            if interactWithUser
                bp=Gui.BorderPanel;
                if isempty(version)
                    problem='';
                else
                    if firstCmdOk
                        problem=['<br>(Incorrect version "' version '" was found)'];
                    else
                        problem=['<br>("' cmdline '" returned "'...
                            version '")'];
                    end
                end
                if ispc
                    cmdApp='Command Prompt';
                    whichCmd='where';
                else
                    cmdApp='Terminal app';
                    whichCmd='which';
                end
                lbl=Gui.Label(['<html><font color="red">Python version '...
                    '<b>' MlpPython.PY_V_CMD '</b> to <b>' MlpPython.PY_V_CMD_F...
                    '</b> is <b>required</b></font>.' ...
                    app.smallStart problem app.smallEnd ...
                    '<br><br>Please enter the path/location '...
                    'where Python <br>version <b>3.x</b> is installed '...
                    'on your computer...<br><br>' app.smallStart ...
                    '<b>NOTE:  </b>To find a Python installation, open <b>' ...
                    cmdApp '</b><br>and type commands like "' whichCmd ...
                    ' python" or "' whichCmd ' python3" etc.'...
                    '<hr><br></html>']);
                btn=Gui.NewBtn(['<html>' app.smallStart ...
                    'Download Python <b>3.7.9</b>' ...
                    app.smallEnd '</html>'], @(h,e)download());
                bp.add(lbl, 'Center');
                bp2=Gui.BorderPanel;
                bp2.add(btn, 'East');
                bp.add(bp2, 'North');
                cmd=inputDlg(struct('msg', ...
                    bp, 'where', 'North'),...
                    ['MLP needs Python version ' ...
                    MlpPython.PY_V '...'], cmd);
                if ~isempty(cmd)
                    was=app.get(MlpPython.PROP_CMD);
                    app.set(MlpPython.PROP_CMD, cmd);
                    [ok, version]=MlpPython.IsAvailable(app, true);
                    if ~ok
                        app.set(MlpPython.PROP_CMD, was);
                    else
                        app.save;
                    end
                else
                    if askYesOrNo(struct('msg', ...
                            Html.WrapHr(['Open the download page'...
                            ' for <br>Python version ' MlpPython.PY_V ...
                            ' in your'...
                            ' browser?']),'where', 'North'))
                        web( MlpPython.PY_379_URL,'-browser');
                    end
                end
            end
            updateApp(ok, version);
            
           function updateApp(ok, version)
               if ~ok
                   app.python.mlp=[];
               else
                   app.python.mlp=version;
               end
           end
           function download
               web( MlpPython.PY_379_URL,'-browser');
           end
       end
        
        function Wait(this, outFile)
            prefix=['<html><center><b>Running the Python MLP <br>'...
                'implementation of Leland McInnes</b><hr><br>'];
            progress='(<i>see Python progress in shell window</i>)';
            if  isempty(this) || ishandle(this) 
                fig=this;
                btn=[];
                html=[prefix progress ];
            else
                html=[prefix String.RemoveTex(this.focusTitle) '<br>'...
                    '<font color="blue">' this.sizeTitle ...
                    '</font><br><br>' progress ];
                btn=this.btn;
                fig=this.h;
            end
            html=[html '</center></html>'];
            File.Wait(outFile, fig, btn, html);
        end
        
    end
end