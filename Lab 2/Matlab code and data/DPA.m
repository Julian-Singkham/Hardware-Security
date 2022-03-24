%{ 
Lab 2: Differntial Power analysis with hidden key

This program is designed to extract the AES encryption key by analyzing
the power consumption of the smart card. Hamming Weight, Hamming Distance, 
and Single Byte analysis models, along with correlation, are used to solve
for the key.

This program is currently setup to find the PGE of each power model.
Read the comments on how to revert to the program to find the hidden key.
%}

clear all

more off
tic
disp load

tracesLengthFile = fopen('traceLength.txt','r');
traceLength      = fscanf(tracesLengthFile, '%d');
numOfTraces      = 200;
startPoint       = 0;
%points           = traceLength; % All the points
points           = 50000; %Only part we care about, first round
plaintextLength  = 16;

traces = tracesInput('traces.bin', traceLength, startPoint ,points, numOfTraces);
toc
disp('mean correction')
mm     = mean(mean(traces));
tm     = mean(traces, 2);
traces = traces - tm(:,ones(1,size(traces,2))) + mm;
toc


disp('load text')
inputs = plaintextInput('plaintext.txt', plaintextLength, numOfTraces);

disp('power hypotheses')
load tab.mat

%This block is for finding the partial guessing entropy (PGE)
%Basically how many times the code has to run until it gets the correct byte
correctKey = ["CA","FE","BA","BE","36","69","AA","0","90","60","90","FF","73","75","70","6F"];
pgeHW = zeros(1,16);
pgeHW(1,:) = -1;
pgeHD = zeros(1,16);
pgeHD(1,:) = -1;
pgeSB = zeros(1,16);
pgeSB(1,:) = -1;

keys = [0:255];
%Code used to complete lab tasks
%{
cipherKey = strings(1,16);
inp = inputs(:,1); %second part is which byte I'm attacking
keyMat = repmat(keys, numOfTraces, 1);
inpMat = repmat(inp, 1, 256);
xMat = bitxor(keyMat, inpMat);
sMat = SubBytes(xMat + 1);
hamWeightMat = byte_Hamming_weight(sMat + 1); 
cor = corr(hamWeightMat, traces(:, 10000:50000));
maximum = max(max(abs(cor)));
[y,x]=find(abs(cor)==maximum);

hold on
title('Hamming Weight')
plot(cor(255,1:10000))
plot(cor(183,1:10000))
plot(cor(203,1:10000))
legend('FE', 'B6', 'CA')
hold off
%}

%This is the core code block for HW,HD, and SB (just change some things)
%Swap this out for the while loop to find the secret key
%maximum = max(max(abs(cor)));
%[y,x]=find(abs(cor)==maximum);
%cipherKeyHW(1,i) = dec2hex(y-1);

% Hamming Weight: The count of all the ones in a byte.
cipherKeyHW = strings(1,16);
for i = 1:16
    inp = inputs(:,i); %second part is which byte I'm attacking
    keyMat = repmat(keys, numOfTraces, 1);
    inpMat = repmat(inp, 1, 256);
    xMat = bitxor(keyMat, inpMat);
    sMat = SubBytes(xMat + 1);
    hamWeightMat = byte_Hamming_weight(sMat + 1); 
    cor = corr(hamWeightMat, traces(:, 10000:50000));
    
    flag = true;
    while flag
        maximum = max(max(abs(cor)));
        [y,x]=find(abs(cor)==maximum);
        pgeHW(1,i) = pgeHW(1,i) + 1;
        if dec2hex(y-1) == correctKey(i)
            cipherKeyHW(1,i) = dec2hex(y-1);
            flag = false;
        elseif pgeHW(1,i) == 255
            cipherKeyHW(1,i) = 'XX'; %Literally impossi 
            ble
            flag = false;
        else
            cor(y,:) = 0;
        end 
    end
end


%Hamming Distance: How many bits of A are different from B
cipherKeyHD = strings(1,16);
for i = 1:16
    inp = inputs(:,i); %second part is which byte I'm attacking
    keyMat = repmat(keys, numOfTraces, 1);
    inpMat = repmat(inp, 1, 256);
    xMat = bitxor(keyMat, inpMat);
    sMat = SubBytes(xMat + 1);
    hamDistMat = byte_Hamming_weight(bitxor(xMat, sMat)+ 1); 
    cor = corr(hamDistMat, traces(:, 10000:50000));
    
    flag = true;
    while flag
        maximum = max(max(abs(cor)));
        [y,x]=find(abs(cor)==maximum);
        pgeHD(1,i) = pgeHD(1,i) + 1;
        if dec2hex(y-1) == correctKey(i)
            cipherKeyHD(1,i) = dec2hex(y-1);
            flag = false;
        elseif pgeHD(1,i) == 255
            cipherKeyHD(1,i) = 'XX';%Literally impossible
            flag = false;
        else
            cor(y,:) = 0;
        end
    end
end

% Single bit: Not sure how this works
cipherKeySB = strings(1,16);
for i = 1:16
    inp = inputs(:,i); %second part is which byte I'm attacking
    keyMat = repmat(keys, numOfTraces, 1);
    inpMat = repmat(inp, 1, 256);
    xMat = bitxor(keyMat, inpMat);
    sMat = SubBytes(xMat + 1);
    sBMat = mod(sMat, 2); 
    cor = corr(sBMat, traces(:, 10000:50000));
    
    %Byte 3 is incorrectly guessed as 2A, by zeroing row 43, it finds the
    %second highest row.
    %{
    if i == 3
        cor(43,:) = 0;
    end
    %}
    
    flag = true;
    while flag
        maximum = max(max(abs(cor)));
        [y,x]=find(abs(cor)==maximum);
        pgeSB(1,i) = pgeSB(1,i) + 1;
        if dec2hex(y-1) == correctKey(i)
            cipherKeySB(1,i) = dec2hex(y-1);
            flag = false;
        elseif pgeSB(1,i) == 255
            cipherKeySB(1,i) = 'XX';%Literally impossible
            flag = false;
        else
            cor(y,:) = 0;
        end
    end
end

disp('DONE')