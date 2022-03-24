%{ 
Lab 3: DPA Attack on Hiding in Time

This program is designed to extract the AES encryption key from a card implementing
misalignment by compressing the traces and aligning them with the first trace. 
The Hamming Weight power model is used with the correlation coefficient to solve for the key.
%}
clear all;

more off
tic
disp('load')

tracesLengthFile = fopen('traceLength.txt','r');
traceLength      = fscanf(tracesLengthFile, '%d');
numOfTraces      = 300;
startPoint       = 0;
%points           = traceLength; % All the points
points           = 499975; %Have to remove enough points to make the 25x compression work
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


%{
Trace Compression

Based on observations, it would appear a clock cycle lasts ~25 points.
The compression method works by splitting the trace into 25-point submatricies
The 25 points are then summed together into 1 point, a compression of 25x
All the submatricies are then combined together to form 1 trace.
%}
interval = int32(25); %25x compression
subTrace = reshape(traces, numOfTraces, interval, []); %Divide the trace into 25-point submatrices
combined = sum(subTrace, 2); %Add up all the columns of every row
traces = squeeze(combined); %Combine all the submatrices into 1 coherent trace
disp('Compression')
toc

%{
Trace Alignment

Based on observations, it would appear that from 18500-end there appears to
be 4 distinct high-value columns in all traces. These distinct points will
be used to allign the traces.
Trace Alignment works by using the xcorr function which finds how many
points to shift trace I to closely match trace 1.
%}
for i = 2:numOfTraces
    %Find how many spaces to shift trace I to match trace 1
    [c,lags] = xcorr(traces(1,18500:end), traces(i,18500:end)); %C: Probability, Lags: All possible shifts
    maximum = max(max(abs(c)));
    [y,x]=find(abs(c)==maximum); %The X value has the location of the best shift
    shift = lags(x);
    
    traces(i,:) = circshift(traces(i,:),shift); %Shift the trace to best match trace 1
end
disp('Integration')
toc

%{
hold on
figure(1)
title('Aligned traces at intervals of 50')
plot(traces(50,:))
plot(traces(100,:))
plot(traces(150,:))
plot(traces(200,:))
plot(traces(250,:))
plot(traces(300,:))
hold off
%}

%{
Hamming Weight

Hamming Weight is a statistical model that counts all the one's in a given
set of data (byte).
%}
keys = [0:255];
cipherKeyHW = strings(1,16);
for i = 1:16
    inp = inputs(:,i); %second part is which byte I'm attacking
    keyMat = repmat(keys, numOfTraces, 1);
    inpMat = repmat(inp, 1, 256);
    xMat = bitxor(keyMat, inpMat);
    sMat = SubBytes(xMat + 1);
    hamWeightMat = byte_Hamming_weight(sMat + 1); 
    cor = corr(hamWeightMat, traces);
    
    maximum = max(max(abs(cor)));
    [y,x]=find(abs(cor)==maximum);
    cipherKeyHW(1,i) = dec2hex(y-1);
end
disp('Hamming Weight')
toc

disp('DONE')

