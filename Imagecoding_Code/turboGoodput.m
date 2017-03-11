clear all;
datestr(now)
Es = 1;

snrset = 5:5:25;
T = 10000;
m = 4;
M = 2.^m;
rate = 1/3;
frmLen = 6144;
intrlvrIndices = randperm(frmLen);
hTEnc = comm.TurboEncoder('TrellisStructure',poly2trellis(4, ...
    [13 15],13),'InterleaverIndices',intrlvrIndices);
hTDec = comm.TurboDecoder('TrellisStructure',poly2trellis(4, ...
    [13 15],13),'InterleaverIndices',intrlvrIndices, 'NumIterations',8);
hMod = comm.RectangularQAMModulator('ModulationOrder',M, ...
    'BitInput',true, 'NormalizationMethod','Average power');
ber = zeros(numel(snrset),1);
bler = zeros(numel(snrset),1);
goodput = zeros(numel(snrset),1);
for ii = 1:numel(snrset)
    EsN0dB = snrset(ii);
    sigma2 = Es * 10^(-EsN0dB/10);
    sigma = sqrt(sigma2);
    hDemod = comm.RectangularQAMDemodulator('ModulationOrder',M, ...
        'BitOutput',true, 'NormalizationMethod','Average power', ...
        'DecisionMethod','Log-likelihood ratio', 'Variance',sigma2);
    hError = comm.ErrorRate;
    for frmIdx = 1:T
        data = randi([0 1],frmLen,1);
        encodedData = step(hTEnc,data);
        modSignal = step(hMod,encodedData);
        noise = sigma / sqrt(2) * (randn(size(modSignal)) + 1i*randn(size(modSignal)));
        receivedSignal = modSignal + noise;
        demodSignal = step(hDemod,receivedSignal);
        receivedBits = step(hTDec,-demodSignal);
        ber_1 = sum(data~=receivedBits)/numel(data);
        ber(ii) = ber(ii) + ber_1;
        if ber_1 ~= 0
            bler(ii) = bler(ii)+1;
        end
    end
    ber(ii) = ber(ii) / T;
    bler(ii) = bler(ii)/T;
    goodput(ii,1) = m * rate *(1-bler(ii));   
end
plot(snrset,goodput(:,1));
grid on;
datestr(now)