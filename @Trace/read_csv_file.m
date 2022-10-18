function [X, Y, isTime, detector, unit, names, notes] = read_csv_file(filename, sets)
% READ_CSV_FILE  Read from a csv file if R&S FSH InstrumentView format
%   [X, Y, isTime, detector, unit, names] = READ_CSV_FILE(filename, sets)
%
%   isTime indicates if the data was frequency-domain (isTime==false) or
%   time-domain (isTime==true) data
%   sets is an optional array of set numbers to extract (ex/ [1], [2], or
%   [1 2]. Extracted sets will not be re-ordered or repeated, just filtered
%   to include those specified and exclude those not specified. Sets=Inf is
%   the default and specifies all sets in the file.
%
%   Note that sets chooses the data sets, not the traces. This file format
%   support 2 data sets, each of which may contain up to 3 traces. Each
%   data set has independent frequency, which is not supported by Trace.
%   Use sets if pulling in data from a file without matching frequency
%   data.
%
%   Frequency-domain:
%     X = frequency data, in Hz
%     Y = trace data, in dB
%
%   Time-domain (0 Hz span mode):
%     X = time data, in sec
%     Y = trace data, in dB

narginchk(1,2)
if nargin<2
    sets = Inf;  % by default, extract all sets
elseif nargin==2
    if isempty(sets)
        % No sets... just exit with an empty data set
        X = [];
        Y = [];
        isTime = false;
        detector = {};
        unit = {};
        names = {};
        notes = {};
        return
    elseif ~isnumeric(sets) || ~isvector(sets)
        throw(MException('EMC:Trace:Argument', 'Invalid ''sets'' argument'))
    end
end

% get suffix from filename (specifies number of ports)
[~,~,ext] = fileparts(filename);
if isempty(ext) || ~strcmp(ext, '.csv')
    throw(MException('EMC:Trace:File', 'Unrecognized file extension'))
end

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'r');
if fID==-1
    throw(MException('EMC:Trace:File', 'Unable to open file'))
end

% first line must follow specific format, or exit ungracefully
[tf,tok,line] = MatchLine(fID,'^(?:.*)Name,Sweep \((.*)\),,,Name,Sweep \((.*)\),,,$', 1);
if tf
    is_doubleset = true;
    T = tok{1};
else
    tok = regexp(line, '^(?:.*)Name,Sweep \((.*)\),,,$', 'tokens');
    if ~isempty(tok)
        is_doubleset = false;
        T = tok{1};
    else
        throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
    end
end

re_instrument = '^Instrument,FSH20.*$';
re_inst_mode = '^Instrument Mode,Spectrum Analyzer,.*$';
re_meas_mode = '^Meas Mode,Spectrum,.*$';

if is_doubleset
    Nsets = 2;
    Ncolsperset = 4;
    re_detectors = '^Trace Detector,([^,]+),,,Trace Detector,([^,]+),,,$';
    re_header_line = '^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),$';
    re_data_line = '^([-.0-9]*),([-.0-9]*),([-.0-9]*),([-.0-9]*),([-.0-9]*),([-.0-9]*),([-.0-9]*),([-.0-9]*),$';
    
    % double set specific checks
    re_freq_center = '^Center Frequency,(.+),Hz,,Center Frequency,(.+),Hz,,$';
    re_freq_offset = '^Frequency Offset,(.+),Hz,,Frequency Offset,(.+),Hz,,$';
    re_freq_span = '^Span,(.+),Hz,,Span,(.+),Hz,,$';
    re_freq_zero = '^Span,Zero Span,,,Span,Zero Span,,,$';
else
    Nsets = 1;
    Ncolsperset = 4;
    re_detectors = '^Trace Detector,([^,]+),,,$';
    re_header_line = '^([^,]*),([^,]*),([^,]*),([^,]*),$';
    re_data_line = '^([-.0-9]*),([-.0-9]*),([-.0-9]*),([^,]*),$';
end

if isinf(sets)
    % default to all sets in the file
    sets = 1:Nsets;
end

% Check for a few specific lines in the header
err = false;
if ~MatchLine(fID, re_instrument, 4)
    err = true;
elseif ~MatchLine(fID, re_inst_mode, 2)
    err = true;
elseif ~MatchLine(fID, re_meas_mode, 1)
    err = true;
end
if err
    throw(MException('EMC:Trace:File', 'Unsupported device/file format'))
end

if is_doubleset && any(1==sets) && any(2==sets)
    % check that the frequency settings match between the two sets
    % TODO: this will still not check for the rare conditions where span
    % and center frequency are the same, but number of points is not. There
    % is no field for number of points. It can only be checked in the
    % actual data.
    [tf,tok] = MatchLine(fID, re_freq_center, 4);
    if tf
        if str2double(tok{1}{1})~=str2double(tok{1}{2})
            err = true;
        end
    else
        err = true;
    end
    [tf,tok] = MatchLine(fID, re_freq_offset, 1);
    if tf
        if str2double(tok{1}{1})~=str2double(tok{1}{2})
            err = true;
        end        
    else
        err = true;
    end
    [tf,tok,line] = MatchLine(fID, re_freq_span, 1);
    if tf
        if str2double(tok{1}{1})~=str2double(tok{1}{2})
            err = true;
        end
    elseif ~regexp(line, re_freq_zero)
        err = true;
    end

    if err
        throw(MException('EMC:Trace:File', 'Frequency mismatch between sets'))
    end
end

% Extract the detectors
[tf,tok] = MatchLine(fID, re_detectors, Inf);
if tf
    D = cell(1, Nsets);
    for i=1:Nsets
        D{i} = GetDetector(tok{1}{i});
    end
else
    throw(MException('EMC:Trace:File', 'Syntax error'))
end

% Look for the blank line
MatchLine(fID, '', Inf);

% Get the header line and analyze it to determine how many data sets
[tf,tok] = MatchLine(fID, re_header_line, 1);
if ~tf
    throw(MException('EMC:Trace:File', 'Syntax error'))
end

col_f = [];
col_data = [];
names = {};
notes = {};
detector = {};
UF = [];
unit = {};

hlist = tok{1};

for set=1:Nsets
    if any(set==sets)
        idxf = (set-1)*Ncolsperset+1;
        tok = regexp(hlist{idxf}, '(?:Frequency|Time) \[(.+)\]', 'tokens');
        if isempty(tok)
            throw(MException('EMC:Trace:File', 'Syntax error'))
        end
        if isempty(UF)
            UF = tok{1}{1};
            col_f = [col_f idxf]; %#ok<AGROW>
        end
        for i=1:2
            idxd = (set-1)*Ncolsperset+i+1;
            tok = regexp(hlist{idxd}, '(.+) \[(.+)\]', 'tokens');
            if ~isempty(tok)
                col_data = [col_data idxd]; %#ok<AGROW>
                detector{end+1} = D{set}; %#ok<AGROW>
                unit{end+1} = tok{1}{2}; %#ok<AGROW>
                names{end+1} = [T{set} ' ' tok{1}{1}]; %#ok<AGROW>
                notes{end+1} = ''; %#ok<AGROW> #TODO: generate RBW/VBW notes
            end
        end
    end
end

[tf,~,scalef] = EMC.Trace.is_unitf(UF);
if tf
    isTime = false;
else
    [tf,~,scalef] = EMC.Trace.is_unitt(UF);
    if tf
        isTime = true;
    else
        throw(MException('EMC:Trace:File', 'Syntax error'))
    end
end

% Read each data line
X = [];
Y = [];
while true
    [tf,tok] = MatchLine(fID, re_data_line, 1);
    if tf
        tok = tok{1};
        f = str2double(tok{col_f});
        N = length(col_data);
        V = zeros(1,N);
        for i=1:N
            V(i) = str2double(tok{col_data(i)});
        end
        
        X = [X;f]; %#ok<AGROW>
        Y = [Y;V]; %#ok<AGROW>
    else
        break
    end
end

% scale frequency vector to Hz
X = X * scalef;

fclose(fID);

end



%% LOCAL FUNCTIONS

function [tf,tok,line] = MatchLine(fID, re, diecount)
tf = false;
tok = {};
narginchk(2,3);
if nargin<3
    diecount = 1;
end
while diecount>0
    if isinf(diecount) && feof(fID)
        break
    end
    line = fgetl(fID);
    if isnumeric(line) && line==-1
        break
    end
    
    if isempty(re) && isempty(line)
        tf = true;
        break
    elseif nargout>1
        tok = regexp(line, re, 'tokens');
        if ~isempty(tok)
            tf = true;
            break
        end
    else
        if regexp(line, re)
            tf = true;
            break
        end
    end
    diecount = diecount-1;
end
end

function det = GetDetector(det)
if regexpi(det, '^Auto Peak$')
    det = 'pk';
elseif regexpi(det, '^Max Peak$')
    det = 'pk';
elseif regexpi(det, '^Min Peak$')
    det = 'npk';
elseif regexpi(det, '^RMS$')
    det = 'av';
elseif regexpi(det, '^Sample$')
    det = 'samp';
else
    det = '??';
end
end