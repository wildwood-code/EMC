% LOAD load a trace file from a spectrum analyzer, joins multiple files
%      support Agilent N1996A and R&S FSH
%   obj = LOAD(file)
%   obj = LOAD(file1, file2, ...)
%   obj = LOAD(file, [sets])   for single R&S csv format file only
%
%   See also: TRACE TRACE/JOIN_TRACES TRACE/PLOT

function obj = Load(varargin)

if nargin==2
    % check for Load(file,[sets]) notation
    file = varargin{1};
    sets = varargin{2};
    if ischar(file) && isnumeric(sets) && isvector(sets)
        [~,~,ext] = fileparts(file);
        if isempty(ext)
            err = true;
        elseif strcmp(ext, '.csv')
            err = false;
            is_rs_sets = true;
        else
            err = true;
        end
        if err
            throw(MException('EMC:Trace:File', 'Sets only valid for .csv'))
        end
    else
        is_rs_sets = false;
    end
else
    is_rs_sets = false;
end

obj = EMC.Trace;
Xacc = [];
Yacc = [];
err = false;
name = {};

if is_rs_sets
    Nfiles = 1;
else
    Nfiles = length(varargin);
end
for i=1:Nfiles
    file = varargin{i};
    [~,~,ext] = fileparts(file);
    if isempty(ext)
        err = true;
    elseif strcmp(ext, '.csv')
        if is_rs_sets
            [X, Y, istime, det, ~, name, note] = EMC.Trace.read_csv_file(file, sets);
        else
            [X, Y, istime, det, ~, name, note] = EMC.Trace.read_csv_file(file);
        end
    elseif strcmp(ext, '.trc')
        [X, Y, istime, det, note] = EMC.Trace.read_trace_file(file);
    else
        err = true;
    end
    
    if err
        throw(MException('EMC:Trace:File', 'Unrecognized file extension'))
    end
    
    [Xacc, Yacc] = EMC.Trace.join_traces(Xacc, Yacc, X, Y);
end

% for now, just use this info from the last processed file
if istime
    obj.dom = EMC.Domains.TimeDomain;
    obj.unit_absc = 's';  % TODO: set this to the correct time unit
else
    obj.dom = EMC.Domains.FrequencyDomain;
    obj.unit_absc = 'Hz'; % TODO: set this to the correct freq unit
end

[~,N] = size(Yacc);
if isempty(name)
    obj.name = cell(1,N);
    obj.name(1:N) = { '' };
else
    obj.name = name;
end
obj.det = det;
obj.notes = note;
obj.x = Xacc;
obj.y = Yacc;
