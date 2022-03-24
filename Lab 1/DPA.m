% (C) Ing. Jiri Bucek, Petr Vyleta

more off
tic
disp load

tracesLengthFile = fopen('traceLength.txt','r');
traceLength      = fscanf(tracesLengthFile, '%d');
numOfTraces      = 300;
startPoint       = 0;
points           = traceLength;
plaintextLength  = 16;

traces = tracesInput('traces.bin', traceLength, startPoint ,points, numOfTraces);
toc
disp('mean correction')
mm     = mean(mean(traces));
tm     = mean(traces, 2);
traces = traces - tm(:,ones(1,size(traces,2))) + mm;
toc

%kontrola zarovnani
%plot(traces(:,1:200)')

disp('load text')
inputs = plaintextInput('plaintext.txt', plaintextLength, numOfTraces);

disp('power hypotheses')
load tab.mat
disp('**** Add your code to complete the analysis here ****')
%This is a graph of the entire trace
%hold on
%plot(traces(1,14000:274000))
%plot(traces(100,14000:274000))
%plot(traces(200,14000:274000))
%hold off

%Histogram graph of the encyption
%histogram(traces(:,14000:274000))

%100 data segments of the beginning of encryption for all traces. 
%Used to see the offset
%plot(traces(1:200,15000:15100)')
%100 data segments of the middle of encryption for all traces. 
%plot(traces(1:200,135000:135100)')
%100 data segments of the end of encryption for all traces. 
plot(traces(1:200,250000:250100)')