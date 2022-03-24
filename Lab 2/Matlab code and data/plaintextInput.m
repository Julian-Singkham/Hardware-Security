% (C) Ing. Jiri Bucek

function [inputs] = plaintextInput(fileName, plaintextLength, numOfPLaintexts)
myfile = fopen(fileName,'r');
inputs = zeros(numOfPLaintexts, plaintextLength);
for i=1:numOfPLaintexts
	s = fgets(myfile, 1024);
    % Accept plaintext as hex numbers
	[ii,l] = sscanf(s, '%x ', plaintextLength);
	inputs(i,:) = ii;
end
fclose(myfile);
