function [ DataEnc ] = RLE_enc( DataIn )
%UNTITLED8 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    DataEnc=[];ii=1;
    while ii<=size(DataIn,2)
        DataEnc=[DataEnc DataIn(ii)];
        cnt=1;
        while(DataIn(ii)==DataIn(ii+1))
            ii=ii+1;
            cnt=cnt+1;
            if ii==size(DataIn,2)
                break;
            end
        end
        DataEnc=[DataEnc (cnt)];
        ii=ii+1;
        if ii>size(DataIn,2)
           break;
        end
    end
    DataEnc;
end

