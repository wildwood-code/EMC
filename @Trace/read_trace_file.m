% READ_TRACE_FILE  Read from an Agilent/Keysight spectrum analzyer .trc file
%   [X, Y, isTime] = READ_TRACE_FILE(filename)
%
%   isTime indicates if the data was frequency-domain (isTime==false) or
%   time-domain (isTime==true) data
%
%   Frequency-domain:
%     X = frequency data, in Hz
%     Y = trace data, in dB
%
%   Time-domain (0 Hz span mode):
%     X = time data, in Sec
%     Y = trace data, in dB
%
%   See also: TRACE TRACE/LOAD

% Kerry S. Martin, martin@wild-wood.net
function [X, Y, isTime, detector, notes] = read_trace_file(filename)

% get suffix from filename (specifies number of ports)
[~,~,ext] = fileparts(filename);
if isempty(ext) || ~strcmp(ext, '.trc')
    throw(MException('EMC:Trace:File', 'Unrecognized file extension'))
end

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'r');
if fID==-1
    throw(MException('EMC:Trace:File', 'Unable to open file'))
end

% Verify several XML tags to make sure the file is the right type
[ismatch,~] = CheckTagValue(fID,'productCompany', '.*Agilent.*|.*Keysight.*');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
end
[ismatch,~] = CheckTagValue(fID,'model','N1996A');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
end
[ismatch,~] = CheckTagValue(fID,'fileVersion','2');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
end
[ismatch,~] = CheckTagValue(fID,'topic','gpsa');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
end
[ismatch,settings] = CheckTagValue(fID,'actuatorSettings', '.*');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Syntax error'))
else
    settings = strsplit(settings,'|');
end
[ismatch,numpoints] = CheckTagValue(fID,'numPoints','.*');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Syntax error'))
else
    Npts = str2double(numpoints);
    if Npts<1
        throw(MException('EMC:Trace:File', 'Invalid number of points'))
    end
end
[ismatch,datascale] = CheckTagValue(fID,'dataScaleFactor', '.*');
if ~ismatch
    fclose(fID);
    throw(MException('EMC:Trace:File', 'Syntax error'))
else
    dsFactor = str2double(datascale);
    if dsFactor ~= 0
        throw(MException('EMC:Trace:File', 'Unimplemented. Don''t know what to do if dataScaleFactor ~= 0'))
    end
end

% Get key characteristics
Fspan = GetSetting('gpsa','span',settings);
Fcf = GetSetting('measGlobal.specAn','cf',settings);
Tsweep = GetSetting('gpsa','sweepTimeSec',settings);
Fstart = Fcf - Fspan/2;
Fend = Fcf + Fspan/2;

% Calculate the X-points
if Fspan>0
    X = linspace(Fstart, Fend, Npts)';
    isTime = false;
else
    X = linspace(0, Tsweep, Npts)';
    isTime = true;
end

% Begin processing the traces
Ntrace = 0;
isEOF = false;
detector = cell(1,0);
notes = cell(1,0);

% Process each individual trace started with <traceNumber> until </trace>
while true
    while true
        % discard blank lines, look for EOF
        line = fgetl(fID);
        if ~ischar(line)
            % end of file encountered
            isEOF = true;
            break
        else
            line = strtrim(line);
            if ~isempty(line)
                break
            end
        end
    end
    
    if isEOF
        % end of file found
        break
    end
    
    % Process <trace>
    % line was passed from the blank/EOF loop
    if ~ischar(line)
        % end of file encountered
        throw(MException('EMC:Trace:File', 'Encountered premature end of file'))
    elseif ~regexpi(line, '^<trace>$')
        throw(MException('EMC:Trace:File', 'Syntax error'))
    end
    
    line = fgetl(fID);
    if ~ischar(line)
        % end of file encountered
        throw(MException('EMC:Trace:File', 'Encountered premature end of file'))
    elseif ~regexpi(line, '^<traceNumber>.*</traceNumber>$')
        throw(MException('EMC:Trace:File', 'Syntax error'))
    end
    
    Ntrace = Ntrace + 1;
    
    [ismatch,points] = CheckTagValue(fID,'tracePoints','.*');
    if ~ismatch
        fclose(fID);
        throw(MException('EMC:Trace:File', 'Syntax error'))
    end
    
    points = strsplit(points, ',');
    N = length(points);
    D = zeros(N,1);
    
    for i=1:N
        D(i) = str2double(points{i});
    end
    
    % data is scaled by a factor of 1000... unscale to give dB
    Y(:,Ntrace) = D/1000.0; %#ok<AGROW>
    
    % get the detector type
    param = sprintf('detType%d', Ntrace); % this is 1-base (not 0-base like trace)
    det = GetSetting('gpsa',param,settings);
    switch det
        case 0
            det = 'pk';
        case 3
            det = 'av';
        case 2
            det = 'npk';
        case 1
            det = 'samp';
        otherwise
            det = '?';
    end
    detector{end+1} = det; %#ok<AGROW>
    
    notes{end+1} = ''; %#ok<AGROW>   % TODO: add RBW/VBW notes
    
    % Process <trace>
    line = fgetl(fID);
    if ~ischar(line)
        % end of file encountered
        throw(MException('EMC:Trace:File', 'Encountered premature end of file'))
    elseif ~regexpi(line, '^</trace>$')
        throw(MException('EMC:Trace:File', 'Syntax error'))
    end
    
end

fclose(fID);

end


function [ismatch,result] = CheckTagValue(fID, hdg, val_pat)
narginchk(3,3)
line = fgetl(fID);
result = [];
if ~ischar(line)
    % end of file encountered
    ismatch = false;
else
    regex = sprintf('^<%s>(%s)</%s>$', hdg, val_pat, hdg);
    toks = regexpi(line, regex, 'tokens');
    if isempty(toks)
        ismatch = false;
    else
        ismatch = true;
        result = toks{1}{1};
    end
end
end

function value = GetSetting(section, name, settings)
value = [];
for i=1:length(settings)
    regex = sprintf('^%s:%s:(.*)$', section, name);
    toks = regexpi(settings{1,i}, regex, 'tokens'); 
    if ~isempty(toks)
        value = toks{1}{1};
        break
    end
end
if ~isempty(value)
    value = str2double(value);
end
end