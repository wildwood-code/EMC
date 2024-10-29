% H_PARAM  RF Network Hybrid (H) parameter class
%
%   H_PARAM is a class for holding H-parameter data
%
%   H_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%     FScale     - frequency scale (1=Hz, 1e3=kHz, 1e6=MHz, 1e9=GHz)
%
%   H_Param Methods:
%     H_Param    - constructor
%
%   See also:  RF_PARAM G_PARAM Z_PARAM Y_PARAM ABCD_PARAM S_PARAM T_PARAM
%     
classdef H_Param < EMC.RF_Param
    
    methods

        % -------------------------------
        % H_Param constructor        
        function obj = H_Param(freq, data, fscale)
            % H_PARAM constructor
            %   obj = RF_PARAM(freq, data, fscale)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     fscale = frequency unit ['Hz','kHz','MHz', 'GHz']
            %              of scale value: [1.0, 1.0e3, 1.0e6, 1.0e9]
            %              default='Hz'=1.0
            %
            %   If no arguments are specified, an empty H_Param is created

            narginchk(0,3)

            if nargin<3
                fscale = 1;
            elseif ischar(fscale) || isscalar(fscale)
                [fscale, ~] = EMC.RF_Param.check_freq_unit(fscale);
            else
                fscale = []; % will error out in RF_Param constructor
            end
            
            if nargin<1
                data = zeros(2,2,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(2,2,NL);
            end
            
            [NR,~,~] = size(data);
            if NR~=2
                error('H-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, fscale);

        end % H_Param constructor
        
    end % methods

    methods (Access=protected)

        function [type, unit_lbl] = get_plot_info(obj, ir, ic) %#ok<INUSL> 
            % GET_PLOT_INFO gets the plot format and label for given row, col
            %   [format, unit_lbl] = obj.GET_PLOT_INFO(row, col)
            i = (ir-1)*2+ic; % map 1-4
            switch i
                case 1
                    unit_lbl = '\Omega'; % V/A
                case 2
                    unit_lbl = '-';  % V/V
                case 3
                    unit_lbl = '-';  % A/A
                case 4
                    unit_lbl = 'S'; % A/V
            end
            type = 'lin';
        end

    end % protected methods

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net