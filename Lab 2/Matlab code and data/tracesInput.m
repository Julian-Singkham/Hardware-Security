% (C) Ing. Jiri Bucek

function [traces] = tracesInput(fileName, traceLength, startPoint, points, numOfTraces)

tracesFile = fopen(fileName,'r');
traces = zeros(numOfTraces,points);
for i=1:numOfTraces
	fseek(tracesFile, startPoint, 'cof');
	[t,l] = fread(tracesFile, points, 'uint8');
	fseek(tracesFile, (traceLength-points-startPoint), 'cof');
	traces(i,:)=t;
end
fclose(tracesFile);
