% TD_SIGNAL  Time-domain signal
%
%   TD_SIGNAL is the class for holding time domain data, such as from a TDR
%
%   TD_SIGNAL Properties:
%     nPoints    - number of time samples
%     nSignals   - number of signals in the set
%     Time       - time vector (stored as seconds)
%     Data       - signal(s) matrix
%     Unit       - unit of the signals
%     UnitT      - time units (sec, msec, usec, nsec, psec) for display
%     Tscale     - time scaling (based on units) for display 
%
%   TD_SIGNAL Methods:
%     TD_SIGNAL  - constructor
%     LoadCSV    - [static] load from a CSV file
%     Plot       - plot the signal(s)
%
%   TD_SIGNAL Data access:
%     obj(idx)     - returns the indexed signal
%
%   See also:  RF_PARAM
%
classdef TD_Signal
    
    properties (SetAccess = protected)
        nPoints
        nSignals
        Time
        Data
        UnitT             % time unit
        Tscale            % time scaling unit
    end % properties
    properties
        Unit              % limit unit
    end % properties
    
    methods
        function obj = TD_Signal(t, data, unit, unitt)
            narginchk(0,4)
            if nargin<4
                unitt = 'sec';
            elseif ~ischar(unitt)
                error('Time unit must be a character vector')
            elseif isempty(unitt)
                unitt = 'sec';
            else
                unitt = lower(unitt);
            end
            if nargin<3
                unit = '';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            elseif isempty(unit)
                unit = '';
            end
            if nargin==1
                error('Must specify data if time is specified.')
            elseif nargin==0
                t = [];
                data = [];
            end
            
            switch unitt
                case {'s', 'sec' }
                    tscale = 1;
                case {'ms', 'msec' }
                    tscale = 1e-3;
                case { 'us', 'usec' }
                    tscale = 1e-6;
                case { 'ns', 'nsec' }
                    tscale = 1e-9;
                case { 'ps', 'psec' }
                    tscale = 1e-12;
                otherwise
                    tscale = 1;
                    warning('unrecognized time unit ''%s''', unitt)
            end
            
            obj.UnitT = unitt;
            obj.Tscale = tscale;
            obj.Unit = unit;
            
            if ~isempty(t) && (~isvector(t) || ~isfloat(t))
                error('time must be a floating point vector')
            elseif ~isrow(t)
                t = t';
            end
            nPoints = length(t);
            obj.nPoints = nPoints;
            obj.Time = t*tscale;  % time is stored in seconds
            
            if length(data)~=nPoints
                error('data must be the same length as t')
            elseif ~ismatrix(data) || ~isfloat(data)
                error('data must be a floating-point matrix')
            end
            obj.nSignals = min(size(data));
            if ~iscolumn(data)
                data = data';
            end
            obj.Data = data;
            
        end
    end
    
    methods
        varargout = subsref(obj, S)
        h = Plot(obj, varargin)
    end
    
    methods (Static)
        obj = LoadCSV(filename)
    end % methods(Static)
    
end