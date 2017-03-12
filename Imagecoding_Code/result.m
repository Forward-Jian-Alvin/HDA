%% 
% snr=5:5:25;
% softcast=[27.9266   32.3472   37.0868   41.9179   46.7252];
% cactus  =[30.2280   34.1944   38.2966   42.6256   47.0714];
% layeredHybrid_softcast=[31.3518   35.6207   40.1612   44.3961   47.7555];
% layeredHybrid_cactus=[33.5278   37.3646   41.2302   44.9440   47.9527];
% figure(1);plot(snr,softcast,'-^r',snr,cactus,'-+k',snr,layeredHybrid_softcast,'-*m',snr,layeredHybrid_cactus,'-sb');xlabel('snr');ylabel('psnr');
% papr_softcast=58.7001;papr_cactus=20.8507;
% legend('softcast','cactus','layeredHybrid_softcast','layeredHybrid_cactus');
% 
% softcastssim=[0.7539    0.8729    0.9462    0.9803    0.9930];
% cactusssim=[0.8800    0.9379    0.9697    0.9863    0.9942];
% layeredHybrid_softcastssim=[0.8225    0.9131    0.9646    0.9864    0.9940];
% layeredHybrid_cactusssim=[0.9191    0.9584    0.9793    0.9899    0.9947];
% figure(2);plot(snr,softcastssim,'-^r',snr,cactusssim,'-+k',snr,layeredHybrid_softcastssim,'-*m',snr,layeredHybrid_cactusssim,'-sb');
% legend('softcast','cactus','layeredHybrid_softcast','layeredHybrid_cactus');
% test100=[30.5856   32.6112   33.7621   34.2341   34.4001];
% test200=[31.7756   35.3603   38.2899   40.0240   40.7972];
% test300=[31.9483   36.0876   40.2342   43.6819   45.8630];
% test400=[31.8923   36.1502   40.6030   44.7938   48.0159];
% 
% plot(5:5:25,test100,'-r+',5:5:25,test200,'-b+',5:5:25,test300,'-g+',5:5:25,test400,'-m+')

softcast=[27.9229   32.3192   37.0594   41.9093   46.6698];
softcast_ssim =[0.7549    0.8721    0.9463    0.9803    0.9930];
HDA=[33.5658   38.2407   43.0038   47.4651 51.0830];
HDA_ssim = [0.890827253989761 0.951836157227020 0.981626577362430 0.993241867449241 0.997188337995047];
figure(1);plot(5:5:25,softcast,'-r+',5:5:25,HDA,'-rs');legend('softcast','HDA');
figure(2);plot(5:5:25,softcast_ssim,'-r+',5:5:25,HDA_ssim,'-rs');legend('softcast','HDA');


