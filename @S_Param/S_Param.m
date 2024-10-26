% S_PARAM  RF Network Scattering (S) parameter class
%
%   S_PARAM is a class for holding S-parameter data
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
        is_mixed        % false=single-ended, true=mixed-mode
        is_legacy       % false=new-ordering, false=legacy-ordering


        % TODO: make sure that is_mixed and is_legacy are considered
        % if converting to another format (Z, etc) and that these
        % flags do not exist in the converted RF_Param object
        % as they are specific to S
    end

    methods

        % -------------------------------
        % S_Param constructor
        function obj = S_Param(freq, data, Z, unitf, unit)
            % Constructor
            % obj = S_PARAM(freq, data, Z, unitf, unit)
            narginchk(0,5)

            if nargin<5
                unit = 'complex';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            end

            if nargin<4
                unitf = 'Hz';
            elseif ischar(unit)
                [~, unitf] = EMC.RF_Param.check_freq_unit(unitf);
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
            if nargin<3
                Z = 50.0;
            end
            if ~isreal(Z) || Z<=0
                error('Impedance must be real and >0')
            end

            obj@EMC.RF_Param(freq, data, unitf, unit);
            obj.Impedance = Z;
            obj.is_mixed = false;
            obj.is_legacy = false;
        end

        [SM_SDD,SDC,SCD,SCC] = convert_to_mixed_mode(obj, is_legacy)
        S = convert_from_mixed_mode(obj)
        [P1,P2,P3,P4] = extract(obj, varargin)


        function [SM_SDD,SDC,SCD,SCC] = ConvertToMixedMode(obj, is_legacy)
            fprintf(2, 'ConvertToMixedMode() is deprecated; please consider using convert_to_mixed_mode()\n')
            if nargout<2
                SM_SDD = obj.convert_to_mixed_mode(is_legacy);
            else
                [SM_SDD,SDC,SCD,SCC] = obj.convert_to_mixed_mode(is_legacy);
            end
        end


    end

    methods (Access=protected)
        lbl = get_label(obj, ir, ic)
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net

