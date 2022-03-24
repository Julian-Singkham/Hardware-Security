%{ 
Lab 3: DPA Attack on Hiding in Time

This program is designed to extract the AES encryption key from a card implementing
hiding in time by compressing the traces and integrating the traces to itself.
The Hamming Weight power model is used with the correlation coefficient to solve for the key.
%}
clear all;

more off
tic
disp('load')

tracesLengthFile = fopen('traceLength.txt','r');
traceLength      = fscanf(tracesLengthFile, '%d');
numOfTraces      = 1000;
startPoint       = 107000; %Remove the garbage from the beginning
%points           = traceLength; % All the points
points           = 207000; %Limit to the first round for efficiency & is increment of 25
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
Trace Integration

Trace integration works by adding the trace with its shifted version.
The trace is shifted I places to the left without looping [(1,2,3) shifted left 1 would be (2,3,0)] 
By integrating the traces, the  peaks that contain the key values become more pronounced
%}
exponents = 0:6;
values = power(2, exponents);
for i = 1:32
    traces(:,1:end-i) = traces(:,1:end-i) + traces(:, i+1:end); %shift left I places
end
disp('Integration')
toc

%{
hold on
figure(1)
title('Integrated traces at intervals of 200')
plot(traces(100,:))
plot(traces(200,:))
plot(traces(400,:))
plot(traces(600,:))
plot(traces(800,:))
plot(traces(1000,:))
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

