function obj = LoadCSV(filename, varargin)
% LOADCSV  load FD_Signal signal(s) from a CSV file

narginchk(1,3)

islog = false;
if nargin>=2
    [flags, va] = EMC.FD_Signal.process_flags(varargin{:});
    varargin = va;
    if length(flags)>1
        error("too many lin/log flags specified")
    elseif length(flags)==1
        flags = lower(flags{1});
        
        switch flags
            case "log"
                islog = true;
            case "lin"
                islog = false;
            otherwise
                error("invalid lin/log flag")
        end
    end
end

                
[validFreqUnits,defaultFreqUnits] = EMC.FD_Signal.GetFreqUnits;
checkFreqUnits = @(x) any(validatestring(lower(x), validFreqUnits));

P = inputParser;
addRequired(P, "filename", @isstrchar);
addOptional(P, "units_freq", defaultFreqUnits, checkFreqUnits);
addOptional(P, "units_mag", "", @isstrchar);
parse(P, filename, varargin{:});

[~,unitf] = EMC.FD_Signal.GetFreqUnits(P.Results.units_freq);
unit = P.Results.units_mag;


regex_float = "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?";
regex_cplx = "(" + "(" + regex_float + ")?" + "[-+][0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?[ijIJ]" + ")";
regex_value = "(" + regex_float + "|" + regex_cplx + ")";
regex_csvline = "^" + regex_float + "(\s*\,\s*" + regex_value + ")+$";

% search for first line that appears to hold CSV data
iline = 0;

FID = fopen(P.Results.filename, "r");
if FID<=0
    error("Unable to open file")
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
    error("EOF encountered without finding CSV data")
else
    % Load the file and convert to a TD_Param object
    RAW = csvread(filename, iline, 0);
    nPoints = size(RAW, 1);
    nSignals = size(RAW, 2)-1;
    
    if nPoints<2 || nSignals<1
        error("CSV data is of invalid dimension")
    end
    freq = RAW(:,1);
    if ~issorted(freq)
        error("FREQ column must be in ascending order")
    elseif min(freq)<0
        error("FREQ cannot be less than 0")
    end
    data = RAW(:,2:end);
    
    if islog
        scale = "log";
    else
        scale = "lin";
    end
    obj = EMC.FD_Signal(freq, data, unitf, unit, scale);
end

end





function tf = isstrchar(v)
    tf = ischar(v) || isStringScalar(v);
end