% (C) Ing. Jiri Bucek

function [traces] = tracesInput(fileName, traceLength, startPoint, points, numOfTraces)

myfile = fopen(fileName,'r');
traces = zeros(numOfTraces,points);
for i=1:numOfTraces
	fseek(myfile, startPoint, 'cof');
	[t,l] = fread(myfile, points, 'uint8');
	fseek(myfile, (traceLength-points-startPoint), 'cof');
	traces(i,:)=t;
end
fclose(myfile);
