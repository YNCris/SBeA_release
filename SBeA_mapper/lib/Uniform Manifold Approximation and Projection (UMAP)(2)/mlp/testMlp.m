%   AUTHORSHIP
%   Developer: Stephen Meehan <swmeehan@stanford.edu>
%   Funded by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%

modelTensorFlowFile1=MlpPython.Train('balbc4FmoLabeled.csv', 'epochs', 210, 'class', .12, 'confirm_model', false);
% The above command sets modelTensorFlowFile1='~/Documents/run_umap/examples/balbc4FmoLabeled';
lbls=MlpPython.Predict('balbcFmoLabeled.csv', 'model_file', modelTensorFlowFile1, 'test_label_file', 'balbc4FmoLabeled.properties', 'training_label_file', 'balbcFmoLabeled.properties', 'confirm_model', false);

modelTensorFlowFile2=MlpPython.Train('balbc4RagLabeled.csv', 'epochs', 210, 'confirm_model', false, 'wait', false);
lbls=MlpPython.Predict('ragLabeled.csv', 'model_file', modelTensorFlowFile2, 'test_label_file', 'balbc4RagLabeled.properties', 'training_label_file', 'ragLabeled.properties', 'confirm_model', false);
           
modelTensorFlowFile2='~/Documents/run_umap/examples/balbc4RagLabeled';
[testSet, columnNames]=File.ReadCsv('ragLabeled.csv');
lbls=MlpPython.Predict(testSet, 'column_names', columnNames, 'model_file', modelTensorFlowFile2, 'test_label_file', 'balbc4RagLabeled.properties', 'training_label_file', 'ragLabeled.properties', 'confirm_model', false);


modelFitcnetFile1=Mlp.Train('balbc4FmoLabeled.csv', 'confirm_model', false, 'hold', .15);
%  The above command sets modelFitcnetFile1='~/Documents/run_umap/examples/balbc4FmoLabeled';
lbls=Mlp.Predict('balbcFmoLabeled.csv', 'model_file', modelFitcnetFile1, 'confirm', false, 'test_label_file', 'balbc4FmoLabeled.properties', 'training_label_file', 'balbcFmoLabeled.properties');

[trainingSet, trainingHdr]=File.ReadCsv('balbc4FmoLabeled.csv');
[modelFitcnetFile2,modelObject2]=Mlp.Train(trainingSet,'column', trainingHdr, 'hold', .33, 'model_file', 'mlpExample2', 'verbose', 1, 'VerboseFrequency', 50);
lbls=Mlp.Predict('balbcFmoLabeled.csv', 'model_file', modelObject2, 'confirm_model', false, 'test_label_file', 'balbc4FmoLabeled.properties', 'training_label_file', 'balbcFmoLabeled.properties', 'Acceleration', 'none');

modelFitcnetFile3=Mlp.Train('balbc4RagLabeled.csv', 'confirm_model', false, 'hold', .13);
%   The above command sets modelFitcnetFile3='~/Documents/run_umap/examples/balbc4RagLabeled';
lbls=Mlp.Predict('ragLabeled.csv', 'model_file', modelFitcnetFile3, 'confirm_model', false, 'test_label_file', 'balbc4RagLabeled.properties', 'training_label_file', 'ragLabeled.properties');

