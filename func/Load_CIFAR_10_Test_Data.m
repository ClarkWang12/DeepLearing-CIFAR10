function [ TestData, TestLabel ] = Load_CIFAR_10_Test_Data(  )
%Load_CIFAR_10_Test_Data ����CIFAR-10ͼ�����ݿ��������

%% ��ȡ���ݲ��洢��TestData��

S=load('data/test_batch.mat');
TestData=S.data';
TestLabel=S.labels;

end

