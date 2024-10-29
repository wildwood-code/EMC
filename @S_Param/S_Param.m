% S_PARAM  RF Network Scattering (S) parameter class
%
%   S_PARAM is a class for holding S-parameter data
%
%   S_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%     FScale     - frequency scale (1=Hz, 1e3=kHz, 1e6=MHz, 1e9=GHz)
%     Mode       - 'single-ended' or 'mixed'
%     Impedance  - port impedance (in Ohms)
%
%   S_Param Methods:
%     S_Param                 - constructor
%     convert_to_mixed_mode   - convert to mixed-mode (DM/CM) form
%     convert_from_mixed_mode - convert from mixed-mode to single-ended
%     extract                 - extract mixed-mode elements/matrices
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM Y_PARAM ABCD_PARAM T_PARAM
%
classdef S_Param < EMC.RF_Param

    properties (SetAccess = private)

        Impedance       % impedance Zinout or [Zin Zout]
        Mode            % 'single-ended' or 'mixed' (get .is_mixed for boolean)

        % TODO: make sure that is_mixed and is_legacy are considered
        % if converting to another format (Z, etc) and that these
        % flags do not exist in the converted RF_Param object
        % as they are specific to S

    end % set private properties


    properties (SetAccess = private, Hidden)

        is_mixed        % false=single-ended, true=mixed-mode
        is_legacy       % false=new-ordering, false=legacy-ordering

    end % hidden, set private properties


    methods

        function obj = S_Param(freq, data, Z, fscale)
            % S_PARAM constructor
            %   obj = RF_PARAM(freq, data, Z, fscale)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     Z     = s-parameter port impedance
            %     fscale = frequency unit ['Hz','kHz','MHz', 'GHz']
            %              of scale value: [1.0, 1.0e3, 1.0e6, 1.0e9]
            %              default='Hz'=1.0
            %
            %   If no arguments are specified, an empty S_Param is created

            narginchk(0,4)

            if nargin<4
                fscale = 1;
            elseif ischar(fscale) || isscalar(fscale)
                [fscale, ~] = EMC.RF_Param.check_freq_unit(fscale);
            else
                fscale = []; % will error out in RF_Param constructor
            end

            if nargin<1
                data = zeros(1,1,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(1,1,NL);
            end
            if nargin<3
                Z = 50.0;
            end
            if ~isreal(Z) || Z<=0
                error('Impedance must be real and >0')
            end

            obj@EMC.RF_Param(freq, data, fscale);
            obj.Impedance = Z;
            obj.is_mixed = false;
            obj.is_legacy = false;

        end % function S_param constructor


        function mode = get.Mode(obj)
            % GET.MODE  Get method for the S_Param mode (single-ended or mixed)
            %   mode = obj.Mode
            %           'single-ended'
            %           'mixed'
            if obj.is_mixed
                mode = 'mixed';
            else
                mode = 'single-ended';
            end
        end % function get.Mode()


        [SM_SDD,SDC,SCD,SCC] = convert_to_mixed_mode(obj, is_legacy)
        S = convert_from_mixed_mode(obj)
        [P1,P2,P3,P4] = extract(obj, varargin)

    end % methods


    methods (Access=protected)

        lbl = get_label(obj, ir, ic)

    end % protected methods


    methods % depracated

        function [SM_SDD,SDC,SCD,SCC] = ConvertToMixedMode(obj, is_legacy)
            fprintf(2, 'ConvertToMixedMode() is deprecated; please consider using convert_to_mixed_mode()\n')
            if nargout<2
                SM_SDD = obj.convert_to_mixed_mode(is_legacy);
            else
                [SM_SDD,SDC,SCD,SCC] = obj.convert_to_mixed_mode(is_legacy);
            end
        end

    end % deprecated methods

end % S_param

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net