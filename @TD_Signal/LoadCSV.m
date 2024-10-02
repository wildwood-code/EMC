function obj = LoadCSV(filename)
% LOADCSV  load TD_Signal signal(s) from a CSV file

regex_float = '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
regex_csvline = [ '^' regex_float '(\s*\,\s*' regex_float ')+$' ];

% search for first line that appears to hold DSV data
iline = 0;

FID = fopen(filename, 'r');
if FID<=0
    error('Unable to open file')
end

while true
    L = fgetl(FID);
    if ~ischar(L)
        iline = -1;
        break;
    end
    if regexp(L, regex_csvline)
        break;
    else
        iline = iline + 1;
    end
end
fclose(FID);

if iline<0
    error('EOF encountered without finding CSV data')
else
    % Load the file and convert to a TD_Param object
    RAW = csvread(filename, iline, 0);
    nPoints = size(RAW, 1);
    nSignals = size(RAW, 2)-1;
    
    if nPoints<2 || nSignals<1
        error('CSV data is of invalid dimension')
    end
    time = RAW(:,1);
    if ~issorted(time)
        error('TIME column must be in ascending order')
    end
    data = RAW(:,2:end);
    
    obj = EMC.TD_Signal(time, data);
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net