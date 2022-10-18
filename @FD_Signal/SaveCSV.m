function SaveCSV(obj, filename, varargin)
% SAVECSV save TD_Signal object to CSV file
%    obj.SaveCSV(filename)          % generates a 2 line header
%    obj.SaveCSV(filename, true)    % generates no header

narginchk(2,3)

validHeaders = { "header", "noheader" };
checkHeaders = @(x) any(validatestring(x, validHeaders));

P = inputParser;
addRequired(P, "filename", @ischar);
addOptional(P, "header", validHeaders{1}, checkHeaders);
parse(P, filename, varargin{:});

switch P.Results.header
    case 'header'
        noheader = false;
    case 'noheader'
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
    fprintf(FID, "%% FD_Signal file written %s\n%s", char(datetime('now')), obj.FreqUnits);
    for j=1:obj.nSignals
        if isempty(obj.MagUnits)
            fprintf(FID, ",signal%d", j);
        elseif obj.nSignals>1
            fprintf(FID, ",%s%d", obj.MagUnits, j);
        else
            fprintf(FID, ",%s", obj.MagUnits);
        end
    end
    fprintf(FID, "\n");
end
fscale = EMC.FD_Signal.GetFreqUnits(obj.FreqUnits);
for i=1:obj.nPoints
    v = num2str(obj.Freq(i)/fscale);
    fprintf(FID, "%s", v);
    for j=1:obj.nSignals
        val = obj.Data(i,j);
        if isreal(val)
            v = num2str(val);
        else
            vr = num2str(real(val));
            vi = num2str(imag(val));
            if val==0
                v = '0';
            elseif real(val)==0
                v = [ vi 'i' ];
            elseif imag(val)==0
                v = vr;
            elseif imag(val)<0
                v = [ vr vi 'i' ];
            else
                v = [ vr '+' vi 'i' ];
            end
        end
        fprintf(FID, ", %s", v);
    end
    fprintf(FID, "\n");
end

fclose(FID);