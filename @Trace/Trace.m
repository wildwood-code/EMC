% TRACE  RF trace class
%
%   TRACE is the base class for holding RF traces taken using a spectrum
%   analzyer. It supports both time-domain and frequency-domain traces.
%
%   Trace Properties:
%     Ntraces    - Number of traces
%     Freq       - Trace freq data (frequency domain only)
%     FreqHz     - Trace freq data, scaled to 'Hz' (frequency domain only)
%     Time       - Trace time data (time domain only)
%     TimeSec    - Trace time data, scaled to 's' (time domain only)
%     Data       - Trace data
%     Domain     - Domain (time/frequency)
%     Names      - Trace names
%     Notes      - Trace notes (VBW, RBW, etc)
%     Detector   - type of detector used
%     Unit       - magnitude unit
%     UnitF      - frequency abscissa unit (frequency domain only)
%     UnitT      - time abscissa unit (time domain only)
%     Offset     - scalar data offset
%     Settings   - quick access to Unit, UnitT, UnitF, Offset, and Detector
%                   (use cell to set multiple in one call)
%
%   Trace Methods:
%     Trace      - constructor
%     Load       - load trace data (static method)
%     Plot       - plot trace data
%     Meets      - compares to a Trace to a Limit
%     ConvertTo  - converts Trace to different freq or magnitude scaling
%     plus (+)   - adds a scalar, or joins two traces
%     minus (-)  - subtracts a scalar, or removes subset traces
%     lt, le, gt, ge - comparison to a trace, limit, or scalar
%
%   Trace access:
%     obj(idx)   - trace subset extraction. idx may be a scalar or vector
%
%   See also:  LIMIT
%
classdef Trace

    properties (Dependent)
        Ntraces       % Number of traces (read only)
        Freq          % Trace freq data (frequency domain only)
        FreqHz        % Trace freq data, scaled to 'Hz' (frequency domain only)
        Time          % Trace time data (time domain only)
        TimeSec       % Trace time data, scaled to 's' (time domain only)
        Data          % Trace data
        Domain        % Domain: TimeDomain or FrequencyDomain
        Names         % Trace names
        Notes         % Trace notes (RBW, VBW, etc)
        Detector      % Types of detectors used
        Unit          % Magnitude unit
        UnitF         % Frequency abscissa unit
        UnitT         % Time abscissa unit
        Offset        % Trace data offset
        Settings      % Quick way to access Unit, UnitT, UnitF, Offset, and/or Detector
        % TODO: joining traces with differing offset
    end % properties
    
    properties (Access = private)
        x                 % abscissa data
        y                 % ordinate data
        y_offs            % ordinate offset
        dom               % domain
        name              % trace name(s)
        notes             % trace notes
        det               % trace detector(s)
        unit_mag          % ordinate unit
        unit_absc         % abscissa unit
        scale_absc        % abscissa scale
    end % properties
    
    methods
        
        function obj = Trace(absc, data, domain)
            % TRACE  RF trace class constructor
            %   obj = TRACE()
            %   obj = TRACE(domain)
            %   obj = TRACE(absc, data)
            %   obj = TRACE(absc, data, domain)
            narginchk(0,3)
            if nargin==0
                domain = EMC.Domains.FrequencyDomain;
                absc = [];
                data = [];
                is_empty = true;
            elseif nargin==1
                if EMC.Trace.is_charstr(absc)
                    [~,domain] = EMC.Trace.is_charstr(absc);
                    absc = [];
                    data = [];
                    is_empty = true; 
                elseif isa(absc,'EMC.Domains')
                    domain = absc;
                    absc = [];
                    data = [];
                    is_empty = true;                   
                else
                    throw(MException('EMC:Trace:Data', 'Both abscissa and ordinate data are required'))
                end
            else % nargin==2|3
                is_empty =  false;
            end
            
            if isa(domain, 'EMC.Domains')
                dom = domain;
            elseif EMC.Trace.is_charstr(domain)
                [~,domain] = EMC.Trace.is_charstr(domain);
                switch lower(domain)
                    case { 'f', 'freq', 'frequency' }
                        dom = EMC.Domains.FrequencyDomain;
                    case { 't', 'time' }
                        dom = EMC.Domains.TimeDomain;
                    otherwise
                        throw(MException('EMC:Trace:Domain', 'Invalid domain'))
                end
            else
                throw(MException('EMC:Trace:Domain', 'domain must be a char array or EMC.Domains'))
            end

            switch dom
                case EMC.Domains.TimeDomain
                    unita = 's';
                otherwise
                    unita = 'Hz';
            end

            if is_empty
                % default (empty) trace
                obj.dom = dom;
                obj.x = [];
                obj.y = [];
                obj.y_offs = 0;
                obj.name = {};
                obj.notes = {};
                obj.det = {};
                obj.unit_mag = 'dB';
                obj.unit_absc = unita;
                obj.scale_absc = 1;
                return
            end
            
            Nf = length(absc);
            if ~isvector(absc) || ~isreal(absc)
                throw(MException('EMC:Trace:Data', '''absc'' must be a real vector'))
            elseif isrow(absc)
                % make freq a column vector
                absc = absc';
            end
            % organize data by columns
            Nds = size(data);
            if Nds(1)<Nds(2)
                data = data';
                Nds = size(data);
            end
            Ntr = Nds(2);  % traces
            Nfr = Nds(1);  % frequencies
            if Nfr~=Nf
                throw(MException('EMC:Trace:Data', '''absc'' and ''data'' must have same number of entries'))
            end

            obj.x = absc;
            obj.y = data;
            obj.y_offs = 0;
            obj.dom = dom;
            
            obj.name = cell(1,Ntr); obj.name(1:Ntr) = { '' };
            obj.notes = cell(1,Ntr); obj.notes(1:Ntr) = { '' };
            obj.det = cell(1,Ntr); obj.det(1:Ntr) = { '' };
            obj.unit_mag = 'dB';    % TODO: change/set this
            obj.unit_absc = unita;
            obj.scale_absc = 1;
            
        end % Trace constructor
        
        function n = get.Ntraces(obj)
            if isempty(obj.y)
                n = 0;
            else
                [~,n] = size(obj.y);
            end
        end
        
        function freq = get.Freq(obj)
            if obj.dom==EMC.Domains.FrequencyDomain
                freq = obj.x;
            else
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            end
        end
        
        function freq = get.FreqHz(obj)
            if obj.dom==EMC.Domains.FrequencyDomain
                freq = obj.x*obj.scale_absc;
            else
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            end
        end
        
        function time = get.Time(obj)
            if obj.dom==EMC.Domains.TimeDomain
                time = obj.x;
            else
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            end
        end
        
        function time = get.TimeSec(obj)
            if obj.dom==EMC.Domains.TimeDomain
                time = obj.x*obj.scale_absc;
            else
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            end
        end
        
        function data = get.Data(obj)
            if isempty(obj.y)
                data = [];
            else
                if isempty(obj.y_offs)
                    yoffs = 0;
                else
                    yoffs = obj.y_offs;
                end
                data = obj.y + yoffs;
            end
        end
        
        function dom = get.Domain(obj)
            dom = obj.dom;
        end
        
        function name = get.Names(obj)
            name = obj.name;
        end
        
        function obj = set.Names(obj, name)
            [~,n] = size(obj.y);
            if isempty(name)
                obj.name = cell(1,n);
                obj.name(1:n) = { '' };
            elseif iscell(name)
                if length(name)~=n
                    throw(MException('EMC:Trace:Names', 'Name count mismatch'))
                end
                obj.name = cell(1,n);
                for i=1:n
                    if EMC.Trace.is_charstr(name{i})
                        [~,ntxt] = EMC.Trace.is_charstr(name{i});
                        obj.name{i} = ntxt;
                    end
                end
            elseif EMC.Trace.is_charstr(name)
                [~,name] = EMC.Trace.is_charstr(name);
                if n==1
                    obj.name = { name };
                else
                    throw(MException('EMC:Trace:Names', 'Name count mismatch'))
                end
            else
                throw(MException('EMC:Trace:Names', 'Invalid name'))
            end
        end

        function name = get.Notes(obj)
            name = obj.notes;
        end
        
        function obj = set.Notes(obj, note)
            [~,n] = size(obj.y);
            if isempty(note)
                obj.notes = cell(1,n);
                obj.notes(1:n) = { '' };
            elseif iscell(note)
                if length(note)~=n
                    throw(MException('EMC:Trace:Notes', 'Notes count mismatch'))
                end
                obj.notes = cell(1,n);
                for i=1:n
                    if EMC.Trace.is_charstr(note{i})
                        [~,ntxt] = EMC.Trace.is_charstr(note{i});
                        obj.notes{i} = ntxt;
                    end
                end
            elseif EMC.Trace.is_charstr(note)
                [~,note] = EMC.Trace.is_charstr(note);
                for i=1:n
                    obj.notes{i} = note;
                end
            else
                throw(MException('EMC:Trace:Notes', 'Invalid note(s)'))
            end
        end
        
        function detector = get.Detector(obj)
            if ~iscell(obj.det)
                throw(MException('EMC:Trace:Detector', 'Detector not defined'))
            else
                detector = obj.det;
            end
        end
        
        function obj = set.Detector(obj, det)
%             [tf,det] = EMC.Trace.is_detector(det);
%             if tf
%                 obj = obj.ConvertTo(det);
%             else
%                 throw(MException('EMC:Trace:Detector', 'Invalid detector'))
%             end
            
            
            [~,n] = size(obj.y);
            if iscell(det)
                if length(det)~=n
                    throw(MException('EMC:Trace:Detector', 'Detector count mismatch'))
                end
                obj.det = cell(1,n);
                for i=1:n
                    if EMC.Trace.is_detector(det{i})
                        [~,detx] = EMC.Trace.is_detector(det{i});
                        obj.det{i} = detx;
                    end
                end
            elseif EMC.Trace.is_detector(det)
                [~,detx] = EMC.Trace.is_detector(det);
                for i=1:n
                    obj.det(i) = { detx };
                end
            else
                throw(MException('EMC:Trace:Detector', 'Invalid detector(s)'))
            end

            
        end
        
        function unit = get.Unit(obj)
            unit = obj.unit_mag;
        end
        
        function unitf = get.UnitF(obj)
            if obj.dom ~= EMC.Domains.FrequencyDomain
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            else
                unitf = obj.unit_absc;
            end
        end
        
        function unitf = get.UnitT(obj)
            if obj.dom ~= EMC.Domains.TimeDomain
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            else
                unitf = obj.unit_absc;
            end
        end
        
        function obj = set.UnitF(obj, value)
            if obj.dom ~= EMC.Domains.FrequencyDomain
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            elseif EMC.Trace.is_unitf(value)
                obj = obj.ConvertTo(value);
            else
                throw(MException('EMC:Trace:Unit', 'Invalid unit'))
            end
        end
        
        function obj = set.UnitT(obj, value)
            if obj.dom ~= EMC.Domains.TimeDomain
                throw(MException('EMC:Trace:Domain', 'Domain mismatch'))
            elseif EMC.Trace.is_unitt(value)
                obj = obj.ConvertTo(value);
            else
                throw(MException('EMC:Trace:Unit', 'Invalid unit'))
            end
        end
        
        function obj = set.Unit(obj, value)
            if EMC.Trace.is_unit(value)
                obj = obj.ConvertTo(value);
            else
                throw(MException('EMC:Trace:Unit', 'Invalid unit'))
            end
        end
        
        function offs = get.Offset(obj)
            offs = obj.y_offs;
        end
        
        function obj = set.Offset(obj, value)
            if isnumeric(value) && isscalar(value)
                obj.y_offs = value;
            else
                throw(MException('EMC:Trace:Offset', 'Offset must be a numeric scalar'))
            end
        end
        
        function obj = set.Settings(obj, value)
            if iscell(value)
                obj = obj.ConvertTo(value{:});
            else
                obj = obj.ConvertTo(value);
            end
        end
        
        function settings = get.Settings(obj)
            settings.Unit = obj.unit_mag;
            if obj.dom==EMC.Domains.FrequencyDomain
                settings.UnitF = obj.unit_absc;
            else
                settings.UnitT = obj.unit_absc;
            end
            settings.Offset = obj.y_offs;
            settings.Detector = obj.det;
        end
        
    end % methods
    
    methods % defined in class folder
        tf = lt(obj1, obj2)
        tf = le(obj1, obj2)
        tf = gt(obj1, obj2)
        tf = ge(obj1, obj2)
        obj = plus(obj1, obj2)
        obj = minus(obj1, obj2)
        varargout = subsref(obj, S)
        obj = ConvertTo(obj,varargin)
        tf = Meets(obj1, obj2)
        h = Plot(obj, varargin)
    end % methods
    
    methods (Access = public, Static = true) % defined in class folder
        obj = Load(varargin)
    end % methods
    
    methods (Access = private, Static = true) % defined in class folder
        [X, Y, istime, det, notes] = read_trace_file(filename)
        [X, Y, istime, det, unit, names, notes] = read_csv_file(filename, sets)
        [freq, data] = join_traces(freq1, data1, freq2, data2)
        tf = compare_trace(trace, obj, type)
        [tf,det] = is_detector(det)
        [tf,unit] = is_unit(unit)
        [tf,unitf,scale] = is_unitf(unitf)
        [tf,unitt,scale] = is_unitt(unitt)
    end % methods
    
    methods (Access = private, Static = true)
        function [tf,char] = is_charstr(cstr)
            char = cstr;
            if ischar(cstr)
                tf = true;
            elseif isstring(cstr) && isscalar(cstr)
                tf = true;
                char = convertStringsToChars(cstr);
            else
                tf = false;
                char = [];
            end
            if nargout<2
                clear char
            end
        end
    end %methods
    
end % classdef


