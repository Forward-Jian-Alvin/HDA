function [ papr ] = cal_papr( y )
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    ymax=max(abs(y(:)));
    ymean=mean(abs(y(:)));
    papr=20*log10(ymax/ymean);
end