function [numdec] = bin2decPN(numbin,N)
%input must be a string
    if(numbin(1)=='1')
        for i=1:N
            if(numbin(i)=='1')
                numbin(i)='0';
            else
                numbin(i)='1';
            end
        end
        numdec = bin2dec(numbin);
        numdec = -(numdec+1);
    else
        numdec = bin2dec(numbin);
    end
end