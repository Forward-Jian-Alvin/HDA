function [ papr ] = cal_papr( y )
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
    ymax=max(abs(y(:)));
    ymean=mean(abs(y(:)));
    papr=20*log10(ymax/ymean);
end