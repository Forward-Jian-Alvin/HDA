function [ DataDec ] = RLE_dec( DataIn )
%UNTITLED10 此处显示有关此函数的摘要
%   此处显示详细说明
    DataDec=[];
    for ii=1:size(DataIn,2)/2
        DataDec=[DataDec ones(1,DataIn(2*ii))*DataIn(2*ii-1)];
    end
    DataDec;
end

