function out=zigzag(in)
% 26-July-2015
% down by Jian Wu.
%% Need to be in the same directory with invzigzag
% example: a=[1 2 3 4;5 6 7 8;9 10 11 12];b=zigzag(a)
% b =
% 
%      1     2     5     9     6     3     4     7    10    11     8    12
%% in -> out 
    [h,w]=size(in);
    mask=zeros(1,h*w);
    for ii=1:h*w
        mask(ii)=mask(ii)+ii;
    end
    out_temp=invzigzag(mask,h,w);
    out=zeros(1,h*w);
        for kk=1:h
            for mm=1:w
                out(out_temp(kk,mm))=in(kk,mm);
            end
        end

end