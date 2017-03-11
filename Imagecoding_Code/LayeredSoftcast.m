% 2016.1.27
% test on layered hybrid digital-analog
%% 
clear;
close all;
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
    x_enc = numbin;
end

%% FEC+Modulation

%
TotalBandwidth=height*width;
AverageP=1;
ResBand=TotalBandwidth-16*size(x_enc,2)*2;
UseBand=64*(bh-1)*(bw-1);
if ResBand-UseBand<0
    fprintf('error:above limit bandwidth!\n');
end
% To keep a const total bandwidth 
x=[];block_Num=64;
bhu=bh-1;bwu=bw-1;
xTx=xRem(1:height-8,1:width-8);
for ii = 1:8
     for jj = 1:8
            currentBlock = xTx((ii-1)*bhu+1:ii*bhu,(jj-1)*bwu+1:jj*bwu);
            x = [x;reshape(currentBlock,1,bhu*bwu)];%64*12288
     end
end

% 计算矩阵G PA
P1 = 1;% mean(mean(x.*x));
P = P1*block_Num;%total power constraint
lamda = mean((x.*x)');
lamda = lamda';
g = sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));
C = diag(g);
y=C*x;
%%
papr=cal_papr(y)
%% awgn channel
snrindex= 5:5:25;
for kk=1:length(snrindex)
        snr=snrindex(kk);
        Ps = 1;%mean(mean(y.*y));
        noise_pow = Ps * 10^(-snr/10);
        noisy = sqrt(noise_pow)*randn(size(y));
        ynoisy = y + noisy;
%% decoder
        x_dec=RLE_dec(x_enc);
        x_dec=reshape(invzigzag(x_dec,bh,bw),1,bh*bw);
        for ii=1:block_Num
            y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*ynoisy(ii,:);
        end
        %y_llse(1,:)=y_llse(1,:)+x_dec*QStep;
      %% reshape 
        z1 = [];
        tt = [];
        for ii = 1:block_Num
            temp = y_llse(ii,:);
            currentBlock = reshape(temp,bhu,bwu);
            tt = [tt currentBlock];
            if mod(ii,8) == 0 %调整宽度
                z1 = [z1;tt];
                tt = [];
            end
        end
%% fill edges
        z2=zeros(height,width);
        z2(1:height-8,1:width-8)=z1;
        ResBlock = z2(1:bh,1:bw);
        temp1=reshape(ResBlock,1,bh*bw)+x_dec*QStep;%64*12288
        temp2=reshape(temp1,bh,bw);
        z2(1:bh,1:bw)=temp2;
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
