function [ TrainData, TrainLabel ] = Load_CIFAR_10_Train_Data( TrainFileNum, TrainPerFile, inputSize )
%Load_CIFAR_10_Train_Data ����CIFAR-10ͼ�����ݿ�ѵ������

%% ��ʼ�����������洢ѵ������

TrainNum=TrainFileNum*TrainPerFile;     % ����ѵ��ͼƬ����
TrainData=zeros(inputSize,TrainNum);    % ÿ��һ��ͼƬ
TrainLabel=zeros(TrainNum,1);           % ��������ÿ�ж�Ӧ��ǩ��

%% ��ȡ���ݲ��洢��TrainData��
TrainPreString='data/data_batch_';
TrainSufString='.mat';
for i=1:TrainFileNum
    FileName=strcat(TrainPreString,int2str(i),TrainSufString);
    S=load(FileName);
    colBegin=(i-1)*TrainPerFile+1;
    colEnd=i*TrainPerFile;
    TrainData(:,colBegin:colEnd)=S.data';
    TrainLabel(colBegin:colEnd,:)=S.labels;
end;
end

