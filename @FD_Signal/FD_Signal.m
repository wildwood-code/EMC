% FD_SIGNAL  Frequency-domain signal
%
%   FD_SIGNAL is the class for holding frequency-domain data
%
%   FD_SIGNAL Properties:
%     nPoints    - number of frequency samples
%     nSignals   - number of signals in the set
%     Freq       - frequency vector (always stored in Hz)
%     Data       - signal(s) matrix
%     MagUnits       - unit of the signals
%     FreqUnits      - freq units (Hz, kHz, MHz, GHz, THz) for display
%
%   FD_SIGNAL Methods:
%     FD_SIGNAL  - constructor
%     LoadCSV    - [static] load from a CSV file
%     SaveCSV    - save to a CSV file
%     Plot       - plot the signal(s)
%
%   FD_SIGNAL Data access:
%     obj(idx)     - returns the indexed signal
%
%   See also:  RF_PARAM TD_SIGNAL TRACE LIMIT
%
classdef FD_Signal
    
    % ----------------------
    % Properties definitions
    properties (SetAccess = protected)
        nPoints
        nSignals
        Freq
        Data
    end
    properties
        FreqUnits             % freq unit
        MagUnits              % limit unit
        isLog             % lin=false, log=true
    end
    
    % -------------------
    % Methods definitions
    methods (Static)
        obj = LoadCSV(filename, varargin)
        [fscale, unitf] = GetFreqUnits(unitf)
    end
    methods
        SaveCSV(obj, filename, varargin)
        varargout = subsref(obj, S)
        h = Plot(obj)
        
        function obj = FD_Signal(varargin)
            % FD_SIGNAL constructor for frequency-domain signal objects
            %   obj = FD_Signal(freq, data, freq_unit, mag_unit, 'log|lin')
            %   obj = FD_Signal(csv_filename, freq_unit, mag_unit, 'log'|'lin')
            %
            %   freq_unit is optional (default = 'Hz')
            %   mag_unit is optional (default = '')
            %   lin/log flag is optional frequency scale (default = 'lin')
            %   lin/log flag can occur anywhere following data or csv_filename
            %   mag_unit must follow freq_unit
            %
            % Example:
            %   Fsig1 = FD_Signal(F, 20*log10(abs(H)), 'MHz', 'dB', 'log')
            %   Fsig2 = FD_Signal('Freqdata.csv')
            
            if nargin>0 && isstrchar(varargin{1})
                
                % FD_Signal(filename, freq_unit, mag_unit)
                narginchk(1,3)
                obj = EMC.FD_Signal.LoadCSV(varargin{:});
                
            else
                
                % FD_Signal(freq, data, freq_unit, mag_unit, "log")
                narginchk(0,5)
                if nargin==1
                    error("Must specify data if freq is specified.")
                end
                
                islog = false;
                if nargin>=3
                    [flags, va] = EMC.FD_Signal.process_flags(varargin{3:end});
                    varargin = { varargin{1:2} va{:} }; %#ok<CCAT>
                    if length(flags)>1
                        error("Only one lin/log flag may be specified.")
                    elseif length(flags)==1
                        flags = lower(flags{1});
                        
                        switch flags
                            case {'log'}
                                islog = true;
                            case {'lin'}
                                islog = false;
                            otherwise
                                error("Invalid lin/log flag.")
                        end
                    end
                end
                obj.isLog = islog;
                
                [validFreqUnits, defaultFreqUnits] = EMC.FD_Signal.GetFreqUnits;
                checkFreqUnits = @(x) strlength(validatestring(x, validFreqUnits))>0;
                
                P = inputParser;
                addOptional(P, "freq", [], @checkFreq)
                addOptional(P, "data", [], @checkData)
                addOptional(P, "freq_unit", defaultFreqUnits, checkFreqUnits)
                addOptional(P, "mag_unit", "", @isstrchar)
                parse(P, varargin{:})
                
                freq = P.Results.freq;
                data = P.Results.data;
                unit = convertCharsToStrings(P.Results.mag_unit);
                unitf = convertCharsToStrings(P.Results.freq_unit);
                
                if ~isrow(freq)
                    freq = freq';
                end
                
                [fscale,unitf] = EMC.FD_Signal.GetFreqUnits(unitf);
                
                obj.FreqUnits = unitf;
                obj.MagUnits = unit;
                
                nPoints = length(freq);
                obj.nPoints = nPoints;
                obj.Freq = freq*fscale;  % time is stored in seconds
                
                obj.nSignals = min(size(data));
                if length(data)~=nPoints
                    error("Data must be the same length as freq")
                end
                if size(data,1)<size(data,2)
                    data = data';
                end
                obj.Data = data;
            end
            
            if obj.isLog && min(obj.Freq)<=0
                error("Log scale must have all freq > 0")
            end
        end
        
        function obj = set.FreqUnits(obj, value)
            if ~isstrchar(value)
                error("FreqUnits must be a character vector or string")
            end
            [~, unitf] = EMC.FD_Signal.GetFreqUnits(value);
            obj.FreqUnits = unitf;
        end
        
        function obj = set.isLog(obj, value)
            if islogical(value)
                if ~isempty(obj.Freq) %#ok<MCSUP>
                    if value && min(obj.Freq)<=0 %#ok<MCSUP>
                        error("Log scale must have all freq > 0")
                    end
                end
                obj.isLog = value;
            end
        end
    end
    
    methods (Static, Access = protected)
        function [flags, va] = process_flags(varargin)
            % process "log" and "lin" flags
            va = {};
            flags = {};
            for i=1:length(varargin)
                p = varargin{i};
                if isstrchar(p)
                    switch lower(p)
                        case {'lin', 'log'}
                            flags{end+1} = lower(p); %#ok<AGROW>
                        otherwise
                            va{end+1} = p; %#ok<AGROW>
                    end
                else
                    va{end+1} = p; %#ok<AGROW>
                end
            end
        end
    end
    
end


function tf = checkFreq(f)
if ~isempty(f) && (~isvector(f) || ~isfloat(f))
    tf = false;
elseif ~issorted(f)
    tf = false;
elseif min(f)<0
    tf = false;
else
    tf = true;
end
end


function tf = checkData(data)
if ~ismatrix(data) || ~isfloat(data)
    tf = false;
end
end


function tf = isstrchar(v)
tf = ischar(v) || isStringScalar(v);
end
