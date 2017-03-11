function [numbin] = dec2binPN(numdec,N)
% 判断正负号
    if(numdec>=0)
    %正数转二进制?
        numbin1 = dec2bin(numdec,N);
    else
    %负数转二进制?
        numbin1=dec2bin(abs(numdec),N);
        numbin4=0;
        for i=1:N
            if(numbin1(N-i+1)==num2str(1))%按位取反，用十进制表示?????????????????
                numbin4=numbin4+0;
            else
                numbin4=numbin4+2^(i-1);
            end
        end
    %末位加1?
        numbin4=numbin4+1;
    %把处理完的十进制数转成二进制，并输出在numbin?????????
        numbin5=dec2bin(numbin4);
        numbin1=num2str(numbin5,N);
    end
    numbin=numbin1;
end