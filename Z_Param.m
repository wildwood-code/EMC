% Z_PARAM  RF Network Impedance (Z) parameter class
%
%   Z_PARAM is a class for holding Z-parameter data
%
%   Z_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%     FScale     - frequency scale (1=Hz, 1e3=kHz, 1e6=MHz, 1e9=GHz)
%
%   Z_Param Methods:
%     Z_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Y_PARAM ABCD_PARAM S_PARAM T_PARAM
%     
classdef Z_Param < EMC.RF_Param
    
    methods

        function obj = Z_Param(freq, data, fscale)
            % Z_PARAM constructor
            %   obj = RF_PARAM(freq, data, fscale)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     fscale = frequency unit ['Hz','kHz','MHz', 'GHz']
            %              of scale value: [1.0, 1.0e3, 1.0e6, 1.0e9]
            %              default='Hz'=1.0
            %
            %   If no arguments are specified, an empty Z_Param is created

            narginchk(0,3)

            if nargin<3
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
            
            obj@EMC.RF_Param(freq, data, fscale);

        end % Z_Param constructor
        
    end % methods


    methods (Access=protected)

        function [type, unit_lbl] = get_plot_info(obj, ir, ic) %#ok<INUSD>
            % GET_PLOT_INFO gets the plot format and label for given row, col
            %   [format, unit_lbl] = obj.GET_PLOT_INFO(row, col)
            type = 'log';
            unit_lbl = '\Omega';
        end % function get_plot_info

    end % protected methods

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net