function SaveCSV(obj, filename, varargin)
% SAVECSV save TD_Signal object to CSV file
%    obj.SaveCSV(filename)              % generates a 2 line header
%    obj.SaveCSV(filename, "noheader")  % generates no header

narginchk(2,3)

validHeaders = [ "header", "noheader" ];
defaultHeaders = validHeaders{1};
checkHeaders = @(x) any(validatestring(x, validHeaders));

P = inputParser;
addRequired(P, "filename", @ischar);
addOptional(P, "header", defaultHeaders, checkHeaders);
parse(P, filename, varargin{:});

switch P.Results.header
    case "header"
        noheader = false;
    case "noheader"
        noheader = true;
end

if obj.nPoints<=0 || obj.nSignals<=0
    error("object is empty")
end

FID = fopen(P.Results.filename, "w");

if FID<=0
    error("Unable to open file for write")
end

% generate header
if ~noheader
    fprintf(FID, "%% TD_Signal file written %s\n%s", char(datetime('now')), obj.TimeUnits);
    for j=1:obj.nSignals
        if isempty(obj.MagUnits)
            fprintf(FID, ",signal%d", j);
        else
            fprintf(FID, ",%s%d", obj.MagUnits, j);
        end
    end
    fprintf(FID, "\n");
end
tscale = EMC.TD_Signal.GetTimeUnits(obj.TimeUnits);
for i=1:obj.nPoints
    v = num2str(obj.Time(i)/tscale);
    fprintf(FID, "%s", v);
    for j=1:obj.nSignals
        v = num2str(obj.Data(i,j));
        fprintf(FID, ", %s", v);
    end
    fprintf(FID, "\n");
end

fclose(FID);

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net