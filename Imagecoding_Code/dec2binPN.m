function [numbin] = dec2binPN(numdec,N)
% �ж�������
    if(numdec>=0)
    %����ת������?
        numbin1 = dec2bin(numdec,N);
    else
    %����ת������?
        numbin1=dec2bin(abs(numdec),N);
        numbin4=0;
        for i=1:N
            if(numbin1(N-i+1)==num2str(1))%��λȡ������ʮ���Ʊ�ʾ?????????????????
                numbin4=numbin4+0;
            else
                numbin4=numbin4+2^(i-1);
            end
        end
    %ĩλ��1?
        numbin4=numbin4+1;
    %�Ѵ������ʮ������ת�ɶ����ƣ��������numbin?????????
        numbin5=dec2bin(numbin4);
        numbin1=num2str(numbin5,N);
    end
    numbin=numbin1;
end