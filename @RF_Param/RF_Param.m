% RF_PARAM  RF Network Parameter class
%
%   RF_PARAM is the base class for holding RF network parameter data, such
%   as S-parameters, Y-parameters, Z-parameters, H-parameters, etc. Network
%   parameter objects are usually constructed from one of the subclasses of
%   RF_Param, but manipulated using the member functions of RF_Param.
%
%   RF_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%
%   RF_Param Methods:
%     RF_Param   - constructor
%     save       - save parameter data
%     load       - load parameter data (static method)
%     extract    - extract parameter data
%     convert    - convert this parameter to another type
%     plot       - plot the parameter data (in decibels)
%
%   RF_Param Data access:
%     obj(idx)     - returns the S-param matrix Data(:,:,idx)
%     obj(r,c)     - returns the given S-parameter Data(r,c,:)
%     obj(r,c,idx) - returns the specific value Data(r,c,idx)
%
%   See also:  H_PARAM G_PARAM Z_PARAM Y_PARAM ABCD_PARAM S_PARAM T_PARAM
%              TD_SIGNAL
%
classdef RF_Param
    
	properties (Dependent)
		FreqHz        % frequency scaled to Hz [nPoints x 1]
	end
	
    properties (SetAccess = protected)  
        nPorts        % number of ports for this RF-parameter set
        nPoints       % number of samples in the set
        Freq          % frequencies [nPoints x 1]
        Data          % complex data [nPorts x nPorts x nPoints]
        UnitF         % frequency units
        Unit          % magnitude units
        Fscale        % frequency scaling
    end
    
    properties (SetAccess = protected, Hidden = true)
        Type = '';    % used to identify type of subclass by this superclass
    end
    
    methods
        
        % -------------------------------
        % RF_Param constructor
        function obj = RF_Param(freq, data, unitf, unit)
            % Constructor
            % obj = RF_PARAM(freq, data, unitf, unit)
            
            narginchk(0,4)
            
            if nargin<4
                unit = 'complex';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            end
            
            if nargin<3
                unitf = 'Hz';
                fscale = 1;
            elseif ischar(unit)
                [fscale, unitf] = EMC.RF_Param.check_freq_unit(unitf);
            else
                error('UnitF must be a character vector')
            end
                
            if nargin<1
                data = zeros(1,1,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(1,1,NL);
            end
            
            if ~isnumeric(data) || ndims(data)~=3
                error('data must be a N x N x L numeric array')
            end
            
            [N, NC, NL] = size(data);
            
            if N<1 || N~=NC
                error('data must be a N x N x L numeric array')
            end
            
            obj.nPorts = N;
            obj.nPoints = NL;
            
            if ~isnumeric(freq) || ~isvector(freq)
                error('freq must be numeric vector')
            end
            
            % Make sure freqeuncy is stored as a column vector
            if iscolumn(freq)
                obj.Freq = freq';
            else
                obj.Freq = freq;
            end
            
            obj.Data = data;
            obj.UnitF = unitf;
            obj.Unit = unit;
            obj.Fscale = fscale;
        end
		
		function freq = get.FreqHz(obj)
			freq = obj.Freq*obj.Fscale;
        end

        % TODO: may make this protected
        function lbl = get_label(obj, ir, ic)
            lbl = sprintf('%s%d%d', obj.Type, ir, ic);
        end
        
    end % methods
    
    methods
        filename = save(obj, filename, format, freq_format)
        [P1,P2] = extract(obj, n1, n2)
        varargout = subsref(obj, S)        
        h = plot(obj, varargin)
        [obj, SDC, SCD, SCC] = convert(obj, varargin)
    end % methods


    methods % deprecated
        function filename = Save(obj, filename, format, freq_format)
            fprintf(2, 'Save() is deprecated; please consider using save()\n')
            filename = obj.save(filename, format, freq_format);
        end
        function h = Plot(obj, varargin)
            fprintf(2, 'Plot() is deprecated; please consider using plot()\n')
            if nargout>0
                h = obj.plot(varargin{:});
            else
                obj.plot(varargin{:})
            end
        end
        function [P1,P2] = Extract(obj, n1, n2)
            fprintf(2, 'Extract() is deprecated; please consider using extract()\n')
            [P1,P2] = obj.extract(n1, n2);
        end
        function [obj, SDC, SCD, SCC] = Convert(obj, varargin)
            fprintf(2, 'Convert() is deprecated; please consider using convert()\n')
            [obj, SDC, SCD, SCC] = obj.convert(varargin{:});
        end
    end
    
    methods (Static)
        obj = load(filename)
        obj = create(type, varargin)
    end % methods(Static)

    methods (Static) % deprecated
        function obj = Load(filename)
            fprintf(2, 'Load() is deprecated; please consider using load()\n')
            obj = EMC.RF_Param.load(filename);
        end
        function obj = Create(type, varargin)
            fprintf(2, 'Create() is deprecated; please consider using create()\n')
            obj = EMC.RF_Param.create(type, varargin{:});
        end
    end
    
    methods (Static, Access=protected)
        [fscale,unitf] = check_freq_unit(unitf)
    end
    
end % RF_param

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net