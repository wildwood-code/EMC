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
%     Unit       - magnitude unit
%     UnitF      - frequency unit
%     FreqHz     - frequency converted to Hz
%
%   RF_Param Methods:
%     RF_Param   - constructor
%     create     - create specified RF_Param (static method)
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

    % TODO: improvements
    %   remove Unit. Always store as 'complex'. Display unit is handled through get_plot_info()
    %   per-port impedance
    %   load latest Touchstone format

    properties (Dependent, Hidden)
        Type          % type of S-parameter
        FreqHz        % frequency scaled to Hz [1 x nPoints]
    end % dependent, hidden properties


    properties (SetAccess = protected)
        nPorts        % number of ports for this RF-parameter set
        nPoints       % number of samples in the set
        Freq          % frequencies [1 x nPoints]
        Data          % complex data [nPorts x nPorts x nPoints]
        UnitF         % frequency units
        Unit          % magnitude units
    end % set protected properties


    properties (SetAccess = protected, Hidden)
        Fscale        % frequency scaling
    end % hidden, set protected properties


    methods

        function obj = RF_Param(freq, data, unitf, unit)
            % RF_PARAM constructor
            %   obj = RF_PARAM(freq, data, unitf, unit)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     unitf = frequency unit ['Hz','kHz','MHz', 'GHz']

            narginchk(0,4)

            if nargin<4
                unit = 'complex';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            end

            if nargin<3
                unitf = 'Hz';
                fscale = 1;
            elseif ischar(unitf)
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

            if ~isnumeric(data)
                error('data must be a numeric array')
            elseif ndims(data)==2 %#ok<ISMAT>
                [nr,nc] = size(data);
                if nr==1 || nc==1
                    data = reshape(data,1,1,length(data));
                else
                    error('1-port data must be a 1 x L numeric array')
                end
            elseif ndims(data)~=3
                error('data must be a N x N x L or 1 x L numeric array')
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
        end % function RF_Param constructor


        % -------------------------------
        % RF_Param function get.FreqHz()
        function freq = get.FreqHz(obj)
            freq = obj.Freq*obj.Fscale;
        end % function get.FreqHz

        
        % -------------------------------
        % RF_Param function get.Type()
        function type = get.Type(obj)
            type = class(obj);
            m = regexp(type, '^(?:[A-Z.]+\.)?([A-Z]{1,4})(?:_param)?$', 'tokens', 'ignorecase');
            if ~isempty(m)
                type = upper(m{1}{1});
            else
                type = '';
            end
        end % function get.Type


        filename = save(obj, filename, format, freq_format)
        [P1,P2] = extract(obj, n1, n2)
        varargout = subsref(obj, S)
        h = plot(obj, varargin)
        [obj, SDC, SCD, SCC] = convert(obj, varargin)

    end % methods


    methods (Access=protected)

        % -------------------------------
        % RF_Param function get_label()
        function lbl = get_label(obj, ir, ic)
            lbl = sprintf('%s%d%d', obj.Type, ir, ic);
        end % function get_label()


        % -------------------------------
        % RF_Param function get_plot_info()
        % this function will be overloaded if specific plot types are required
        function [type, unit_lbl] = get_plot_info(obj, ir, ic) %#ok<INUSD>
            if strcmp(obj.Unit, 'complex')
                type = 'dB'; % other options 'log' 'lin'
                unit_lbl = 'dB';
            else
                type = 'lin';
                unit_lbl = obj.Unit;
            end
        end % function get_plot_info()

    end % protected methods


    methods (Static)

        obj = load(filename)
        obj = create(type, varargin)

    end % static methods


    methods (Static, Access=protected)

        [fscale,unitf] = check_freq_unit(unitf)

    end % protected static methods


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

    end % deprecated methods


    methods (Static) % deprecated

        function obj = Load(filename)
            fprintf(2, 'Load() is deprecated; please consider using load()\n')
            obj = EMC.RF_Param.load(filename);
        end
        function obj = Create(type, varargin)
            fprintf(2, 'Create() is deprecated; please consider using create()\n')
            obj = EMC.RF_Param.create(type, varargin{:});
        end

    end % static deprecated methods


end % RF_param

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net