% 2016.1.27
% test on layered hybrid digital-analog
%% 
clear;
close all;
datestr(now)
%%
img_ori=imread('./bodleian_1.bmp');
[height,width] = size(img_ori);
img_ori=double(img_ori);
bw = width/8;
bh = height/8;
psnr=[];Ssim=[];QStep=1000;Ssim_double=[];
%% encoder
x_dct = dct2(img_ori-128);
%% layered
xRem=rem(x_dct,QStep);
x_int=(x_dct-xRem)/QStep;
% x_intreshape=reshape(x_int(1:bh,1:bw),1,bh*bw);
x_zigzag=zigzag(x_int(:,:));
% x_dec=reshape(invzigzag(x_enc,bh,bw),1,bh*bw);
if QStep>10
    x_encDigi=RLE_enc(x_zigzag);% mark1:最后一个数一定是0的个数，我们不用，decode的时候直接补0
else
    x_encDigi=x_zigzag;
end
% [x_encSort,Ind] = sort(x_encDigi(1:end-1),'descend');
N=12;
x_enc=[];
for ii=1:length(x_encDigi)-1;
    numbin=dec2binPN(x_encDigi(ii),N);
    x_enc = [x_enc numbin];
end
TxD=reshape(double(x_enc-'0'),[],1);
%% FEC+Modulation
frmLen=length(x_enc);
M=4;
intrlvrIndices = randperm(frmLen);
hTEnc = comm.TurboEncoder('TrellisStructure',poly2trellis(4, ...
    [13 15],13),'InterleaverIndices',intrlvrIndices);
hTDec = comm.TurboDecoder('TrellisStructure',poly2trellis(4, ...
    [13 15],13),'InterleaverIndices',intrlvrIndices, 'NumIterations',8);
hMod = comm.RectangularQAMModulator('ModulationOrder',M, ...
    'BitInput',true, 'NormalizationMethod','Average power');

encodedData = step(hTEnc,TxD);
modSignal = step(hMod,encodedData);

%
% % TotalBandwidth=height*width;
% % AverageP=1;
% % ResBand=TotalBandwidth-16*size(x_enc,2)*2;
% % UseBand=64*(bh-1)*(bw-1);
% % if ResBand-UseBand<0
% %     fprintf('error:above limit bandwidth!\n');
% % end
% To keep a const total bandwidth 
xRemZigzag=zigzag(xRem);
xRemZigzag(end-length(modSignal)*2+1:end)=0;
xRem_dec=invzigzag(xRemZigzag,height,width);

x=[];block_Num=64;
% bhu=bh-1;bwu=bw-1;
% xTx=xRem(1:height-8,1:width-8);
for ii = 1:8
     for jj = 1:8
            currentBlock = xRem_dec((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
            x = [x;reshape(currentBlock,1,bh*bw)];%64*12288
     end
end

% 计算矩阵G PA
P1 = 1;% mean(mean(x.*x));
P = P1*block_Num;%total power constraint
lamda = mean((x.*x)');
lamda = lamda';
g = sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));
gNew= g* sqrt((height*width-length(modSignal)*2)/height/width);
C = diag(gNew);
y=C*x;
%% reshape 
AnaSignalTmp = [];
tt = [];
for ii = 1:block_Num
    temp = y(ii,:);
    currentBlock = reshape(temp,bh,bw);
    tt = [tt currentBlock];
    if mod(ii,8) == 0 %调整宽度
        AnaSignalTmp = [AnaSignalTmp;tt];
        tt = [];
    end
end
%% invsplit
AnaSignalZigzag=zigzag(AnaSignalTmp);
AnaSignal=AnaSignalZigzag(1:end-length(modSignal)*2);
AnaTx=AnaSignal(1:2:end)+AnaSignal(end:-2:2)*1i;
TxData=[modSignal.'  AnaTx];
% papr=cal_papr(y)
%% awgn channel
snrindex= 20;
for kk=1:length(snrindex)
        snr=snrindex(kk);
        Ps = 1;%mean(mean(y.*y));
        noise_pow = Ps * 10^(-snr/10);
        noisy = sqrt(noise_pow/2)*(randn(size(TxData))+ 1i*randn(size(TxData)));
        ynoisy = TxData + noisy;
%% decoder
% step1 : split
        RxDigi=ynoisy(1:length(modSignal));
        RxAna =ynoisy(length(modSignal)+1:end);
        RxAnaData=zeros(1,height*width-length(modSignal)*2);
        RxAnaData(1:2:end) =real(RxAna);
        RxAnaData(end:-2:2) =imag(RxAna);
        RxAnaSignal=[RxAnaData zeros(1,length(modSignal)*2)];
        RxAnaSignal=invzigzag(RxAnaSignal,height,width);
        RxAnaTmp=[];
        for ii = 1:8
             for jj = 1:8
                    currentBlock = RxAnaSignal((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                    RxAnaTmp = [RxAnaTmp;reshape(currentBlock,1,bh*bw)];%64*12288
             end
        end
% step2 : decode turbo        
        % EsN0dB = snrset(ii);
        hDemod = comm.RectangularQAMDemodulator('ModulationOrder',M, ...
            'BitOutput',true, 'NormalizationMethod','Average power', ...
            'DecisionMethod','Log-likelihood ratio', 'Variance',noise_pow);
        demodSignal = step(hDemod,RxDigi.');
        receivedBits = step(hTDec,-demodSignal);
        Err=TxD-receivedBits;
        Ber=length(find(Err~=0))/length(TxD);
        if(Ber~=0)
            disp('Digital decode Error Exist!');
        end
%         x_dec=RLE_dec(x_enc);
%         x_dec=reshape(invzigzag(x_dec,bh,bw),1,bh*bw);
% step3 : decode analog  
      
        for ii=1:block_Num
            y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*RxAnaTmp(ii,:);
        end
        %y_llse(1,:)=y_llse(1,:)+x_dec*QStep;
      %% reshape 
        z1 = [];
        tt = [];
        for ii = 1:block_Num
            temp = y_llse(ii,:);
            currentBlock = reshape(temp,bh,bw);
            tt = [tt currentBlock];
            if mod(ii,8) == 0 %调整宽度
                z1 = [z1;tt];
                tt = [];
            end
        end
        imshow(idct2(z1)+128,[]);
%% fill edges
        z2=z1+x_int*QStep;%64*12288
        %
        xx=idct2(z2)+128;
        xx(xx<0)=0;
        xx(xx>255)=255;
        xx1=round(xx);
        imshow(xx1,[]);
        psnr= [psnr 20*log10(255/sqrt(mean((double(img_ori(:))-(xx1(:))).^2)))];
        Ssim=[Ssim ssim(uint8(img_ori),uint8(xx1))];
%         Ssim_double=[Ssim_double ssim(double(img_ori),double(xx1))];
end
psnr
