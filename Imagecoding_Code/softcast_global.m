% 2015.8.9
% test on limit bandwidth using cloud information
%% 
clear;
close all;
img_ori=imread('./bodleian_1.bmp');
% img_ori=imread('C:\Users\wu\Desktop\Limit_bandwidth\images\all_souls\all_souls_1.bmp');
% img_ori=imread('C:\Users\wu\Desktop\Limit_bandwidth\images\bodleian_2\bodleian_ori.bmp');
[height,width] = size(img_ori);
img_ori=double(img_ori);
bw = width/8;
bh = height/8;
psnr=[];psnr_cloud=[];SSIM=[];SSIM1=[];
for lossnum=8
    %% encoder
    x_dct = dct2(img_ori-128);
    x=[];block_usedNum=lossnum*lossnum;
    for ii = 1:lossnum
         for jj = 1:lossnum
                currentBlock = x_dct((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                x = [x;reshape(currentBlock,1,bh*bw)];%64*12288
         end
    end
    % 计算矩阵G PA
    P1 = 1;% mean(mean(x.*x));
    P = P1*lossnum*lossnum;%total power constraint
    lamda = mean((x.*x)');
    lamda = lamda';
    g = sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));
    C = diag(g);
    y=C*x;
    %% awgn channel
    snrindex= 5:5:25;
    for kk=1:length(snrindex)
            snr=snrindex(kk);
            Ps = 1;%mean(mean(y.*y));
            noise_pow = Ps * 10^(-snr/10);
            noisy = sqrt(noise_pow)*randn(size(y));
            ynoisy = y + noisy;
    %% decoder
%             y_llse = diag(lamda)*C'*inv(C*diag(lamda)*C'+noise_pow)*ynoisy;
            for ii=1:block_usedNum
                y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*ynoisy(ii,:);
            end
          %% reshape 
            z1 = [];
            tt = [];
            for ii = 1:block_usedNum
                temp = y_llse(ii,:);
                currentBlock = reshape(temp,bh,bw);
                tt = [tt currentBlock];
                if mod(ii,lossnum) == 0 %调整宽度
                    z1 = [z1;tt];
                    tt = [];
                end
            end
            
            xx=idct2(z1)+128;
           for ii = 1 : size(xx,1)
                for jj = 1 : size(xx,2)
                    if xx(ii,jj)>255
                        xx1(ii,jj) = 255;
                    elseif xx(ii,jj)<0
                        xx1(ii,jj) = 0;
                    else
                        xx1(ii,jj)=round(xx(ii,jj));
                    end
                end
           end
          %% loc2
%           imwrite(uint8(xx1),['C:\Users\wu\Desktop\TMMimages\softcast\bodleian_1\softcastsnr' num2str(snr) '.bmp']);
           psnr= [psnr 20*log10(255/sqrt(mean((double(img_ori(:))-(xx1(:))).^2)))]
           SSIM =[SSIM ssim(uint8(img_ori),uint8(xx1))]
           imwrite(uint8(xx1),'0dbqimg.jpg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end