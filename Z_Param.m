% Z_PARAM  RF Network Impedance (Z) parameter class
%
%   Z_PARAM is a class for holding Z-parameter data
%
%   Z_Param Methods:
%     Z_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Y_PARAM ABCD_PARAM S_PARAM T_PARAM
%     
classdef Z_Param < EMC.RF_Param
    
    methods

        % -------------------------------
        % Z_Param constructor        
        function obj = Z_Param(freq, data, unitf, unit)
            % Constructor
            % obj = Z_PARAM(freq, data, unitf, unit)
            narginchk(0,4)
            
            if nargin<4
                unit = 'complex';
            elseif ~ischar(unit)
                error('Unit must be a character vector')
            end
            
            if nargin<3
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
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
        end
        
    end % methods


    methods (Access=protected)
        function [type, unit_lbl] = get_plot_info(obj, ir, ic) %#ok<INUSD>
            type = 'log';
            unit_lbl = '\Omega';
        end
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net