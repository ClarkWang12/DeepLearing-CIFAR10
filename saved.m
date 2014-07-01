%% ��������������CIFAR-10ͼ�����ݿ�������Է���
%
%
% * ������Ϣ����ѧԺ 2011�� ����������1��
% * �ﺺ��
% * 2014��6��24��
%

%% STEP 0����ʼ������
clear all;
%%
% Matlab����
DEBUG = false;                  % �Ƿ����ڵ���
TEST=false;
addpath func/;
addpath minFunc/;
%%
% �ⲿ������ʼ��
TrainFileNum=5;                 % 5�������ļ�
if TEST
    TrainFileNum=1;
end;
TrainPerFile=10000;             % ÿ�������ļ�10,000��ͼ��
TestNum=10000;                  % ��������
inputSize = 32 * 32 * 3;        % ���������ʽ (32x32 RGB)
numClasses = 10;            	% ��������
load('data\batches.meta.mat');  % label_names����
%%
% �������ʼ��
hiddenSizeL1 = 300;             % Layer 1 Hidden Size
hiddenSizeL2 = 300;             % Layer 2 Hidden Size
hiddenSizeL3 = 300;             % Layer 3 Hidden Size
sparsityParam = 0.1;            % ƽ�������
lambda = 3e-3;                  % Ȩ��˥��
beta = 3;                       % �ͷ���Ȩ��
kPCA=502;
if TEST
    kPCA=366;
end;
options = struct;
options.Method = 'lbfgs';
options.maxIter = 400;
if TEST
    options.maxIter = 2;
end;
options.display = 'on';
softmaxLambda = 1e-4;
softoptions = struct;
softoptions.maxIter = 400;
if TEST
    softoptions.maxIter = 2;
end;

%% STEP 1����������
%  ���ݿ�洢�ڵ�ǰĿ¼��data�ļ����£�����������
%  batches.meta.mat             % �洢�˱�ǩ�� label_names
%  data_batch_1.mat             % ѵ������ data labels batch_label��ÿ��10,000��32��32��RGBͼ��
%  data_batch_2.mat
%  data_batch_3.mat
%  data_batch_4.mat
%  data_batch_5.mat
%  test_batch.mat               % �������� data labels batch_label����10,000��32��32��RGBͼ��
%%
% ѵ������
[ trainData, trainLabels ] = Load_CIFAR_10_Train_Data(TrainFileNum, TrainPerFile, inputSize);
trainLabels=trainLabels+1;      % 0-9�ı�ǩתΪ1-10��ǩ
%%
% ��ǩ������
load('data\batches.meta.mat');  % label_names����
%%
% �ж������Ƿ�����
if ~DEBUG
    assert(size(label_names,1)==numClasses,'��ǩ�����ݶ�ȡ����data\batches.meta.mat');
end;

%% STEP 2������Ԥ����
% ����PCA�����洢����Ӧ�Ĳ���
fprintf('����PCA������Ҫ����һ��ʱ��...\n');
%%
% ��ֵ��׼��Ϊ0
avg=mean(trainData,1);
trainData=trainData-repmat(avg,size(trainData,1),1);
%%
% $\sigma$ ��������ֵ
sigma=trainData*trainData'/size(trainData,2);
[U,S,~]=svd(sigma);
%%
% PCA���ɷ�
% xRot=U'*trainData;
trainData=U(:,1:kPCA)' * trainData;
fprintf('PCA��������\n');
%%
% ����ߴ��ΪPCA������
inputSize=kPCA;
%%
% ����ʱ������ȷ��PCA���������ɷ�ά��
if TEST
    SS=diag(S);
    PCA=cumsum(SS)./sum(SS);
end;

%% STEP 3���Ա�������������
load('saved/step1.mat');
load('saved/step2.mat');
load('saved/step3.mat');

%% STEP 4��Softmax
% ʹ����������ֱ��ѵ��Softmax������
load('saved/step4.mat');

%% STEP 5��΢������
% ջʽ�������΢��
stack = cell(3,1);
stack{1}.w = reshape(sae1OptTheta(1:hiddenSizeL1*inputSize), ...
    hiddenSizeL1, inputSize);
stack{1}.b = sae1OptTheta(2*hiddenSizeL1*inputSize+1:2*hiddenSizeL1*inputSize+hiddenSizeL1);
stack{2}.w = reshape(sae2OptTheta(1:hiddenSizeL2*hiddenSizeL1), ...
    hiddenSizeL2, hiddenSizeL1);
stack{2}.b = sae2OptTheta(2*hiddenSizeL2*hiddenSizeL1+1:2*hiddenSizeL2*hiddenSizeL1+hiddenSizeL2);
stack{3}.w = reshape(sae3OptTheta(1:hiddenSizeL3*hiddenSizeL2), ...
    hiddenSizeL3, hiddenSizeL2);
stack{3}.b = sae3OptTheta(2*hiddenSizeL3*hiddenSizeL2+1:2*hiddenSizeL3*hiddenSizeL2+hiddenSizeL3);
% Initialize the parameters for the deep model
[stackparams, netconfig] = stack2params(stack);
stackedAETheta = [ saeSoftmaxOptTheta ; stackparams ];

load('saved/step5.mat');

% -------------------------------------------------------------------------
%% STEP 6����������
[ testData, testLabels ] = Load_CIFAR_10_Test_Data(  );
testLabels = testLabels+1;
%% 
% ʹ���������ݵĲ�������PCA
avg2=mean(testData,1);
testData=double(testData)-repmat(avg2,size(testData,1),1);
% testRot=U'*testData;
testData=U(:,1:inputSize)'*testData;

%% STEP 7������
% ����Ԥ�Ⲣ��������
%% 
% ΢��ǰ
[pred] = stackedAEPredict(stackedAETheta, inputSize, hiddenSizeL3, ...
    numClasses, netconfig, testData);
acc = mean(testLabels(:) == pred(:));
fprintf('΢��ǰ���ȣ�%0.3f%%\n', acc * 100);
%%
% ΢����
[pred] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL3, ...
    numClasses, netconfig, testData);
acc = mean(testLabels(:) == pred(:));
fprintf('΢���󾫶ȣ�%0.3f%%\n', acc * 100);
%%
% ΢�����ѵ��������
[pred] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL3, ...
    numClasses, netconfig, trainData);
acc = mean(trainLabels(:) == pred(:));
fprintf('\n΢�����ѵ�������ȣ�%0.3f%%\n', acc * 100);