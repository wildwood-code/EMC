classdef Limit
    
    properties (SetAccess = protected)
        % TODO: add Type { PWL, FUNC } if FUNC, then Line = fnRef and Freq
        % is the ranges of freq where it is valid
        % no combining PWL and func is intended
        Type
        Freq
        Line
        PassCriteria      % lt/gt/le/ge
        LogF              % true/false/[] - is freq log scale?
        UnitF             % frequency unit
        Unit              % limit unit
        Fscale            % frequency scaling unit
    end % properties
    
    % notes:
    %  NaN for a freq and limit entry indicate a break between sections
    %  implement overloaded + to combine two limits (with NaN break
    %  between)
    
    methods
        
        function obj = Limit(freq, limit, varargin) % criteria, freqscale, frequnit, limscale
            % LIMIT constructor
            %   obj = LIMIT()
            %   obj = LIMIT(freq, limit)
            %   obj = LIMIT(freq, limit, switch1, ...)
            %     where switch1, switch2, ... is:
            %      'log' or 'logf' = log frequency scale
            %      'lin or 'linf'  = linear frequency scale (default)
            %      'Hz'            = frequency unit Hz = 1 (default)
            %      'kHz'           = frequency unit kHz = 1e3
            %      'MHz'           = frequency unit MHz = 1e6
            %      'GHz'           = frequency unit GHz = 1e9
            %      'lt' or '<'     = data must be < limit (default)
            %      'le' or '<='    = data must be <= limit
            %      'gt' or '>'     = data must be > limit
            %      'ge' or '>='    = data must be >= limit
            %  all switches are case-insensitive
            
            narginchk(0, 6)
            
            if nargin==1
                error('''freq'' cannot be specified without ''limit''')
            elseif nargin==0
                freq = [];
                limit = [];
            end

            % load the default values
            criteria = '';
            freqscale = [];
            fscale = [];
            unitf = '';
            
            % process the input switches
            if nargin>2
                for i=1:length(varargin)
                    s = varargin{i};
                    if ~ischar(s)
                        error('switches must be character strings')
                    end
                    switch lower(s)
                        case { 'lin', 'linf' }
                            freqscale = false;
                        case { 'log', 'logf' }
                            freqscale = true;
                        case 'hz'
                            fscale = 1;
                            unitf = 'Hz';
                        case 'khz'
                            fscale = 1e3;
                            unitf = 'kHz';
                        case 'mhz'
                            fscale = 1e6;
                            unitf = 'MHz';
                        case 'ghz'
                            fscale = 1e9;
                            unitf = 'GHz';
                        case { 'le', '<=' }
                            criteria = 'le';
                        case { 'lt', '<' }
                            criteria = 'lt';
                        case { 'ge', '>=' }
                            criteria = 'ge';
                        case { 'gt', '>' }
                            criteria = 'gt';
                        case ''
                            % skip a blank
                        otherwise
                            warning('unrecognized switch ''%s'' ignored', s)
                    end
                end
                
            end
            
            if iscolumn(freq)
                freq = freq';
            end
            
            if (~isvector(freq) && ~isempty(freq)) 
                error('freq must be a vector')
            end
            
            if length(freq)==1 % 0 and 2+ are acceptable
                error('freq must have at least 2 points, or be empty')
            end
            
            obj.Freq = freq;
            obj.Fscale = fscale;
            obj.PassCriteria = criteria;
            obj.LogF = freqscale;
            obj.UnitF = unitf;
            obj.Unit = 'dB';  % TODO: add method to set/change this
                
            if isa(limit, 'function_handle')
                obj.Type = 'FUN';
                obj.Line = limit;
                
            else
                obj.Type = 'PWL';
                
                if iscolumn(limit)
                    limit = limit';
                end
                if (~isvector(limit) && ~isempty(freq))
                    error('limit must a vector')
                end
                if length(freq)~=length(limit)
                    error('freq and limit must be the same length')
                end

                obj.Line = limit;
     
            end
        end % Limit constructor
        
    end % methods
    
    methods % defined in the class folder
        obj = and(obj1, obj2)
        obj = ConvertTo(obj,to_unit)
        tf = Compare(obj, freq, data, compare_type)
        tf = IsMetBy(obj, freq, data)
        val = LimitAt(obj, freq)
        obj = plus(obj1, obj2)
        obj = minus(obj1, obj2)
        h = Plot(obj, varargin)
        [tf, margin, failures] = Test(obj, freq, data)
    end % methods
    
    methods (Access = private, Static = true) % defined in the class folder
        [tf, val] = TestParamEquality(p1, p2)
        llist = SplitToList(varargin)
        [F,L] = ListToLimit(segs)
        [isChanged, segs] = Resegment(S1, S2, logF, isAbove)
    end % methods
    
end % classdef

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net