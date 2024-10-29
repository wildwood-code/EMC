% ABCD_PARAM  RF Network Cascade (ABCD) parameter class
%
%   ABCD_PARAM is a class for holding ABCD-parameter data
%
%   ABDC_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%     FScale     - frequency scale (1=Hz, 1e3=kHz, 1e6=MHz, 1e9=GHz)
%
%   ABCD_Param Methods:
%     ABCD_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM Y_PARAM S_PARAM T_PARAM
%
classdef ABCD_Param < EMC.RF_Param

    methods

        function obj = ABCD_Param(freq, data, fscale)
            % ABCD_PARAM constructor
            %   obj = RF_PARAM(freq, data, fscale)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     fscale = frequency unit ['Hz','kHz','MHz', 'GHz']
            %              of scale value: [1.0, 1.0e3, 1.0e6, 1.0e9]
            %              default='Hz'=1.0
            %
            %   If no arguments are specified, an empty ABCD_Param is created

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
                error('ABCD-Parameters only valid for 2-port networks')
            end

            obj@EMC.RF_Param(freq, data, fscale);

        end % ABCD_Param constructor

    end % methods


    methods (Access=protected)

        function lbl = get_label(obj, ir, ic) %#ok<INUSL>
            % GET_LABEL gets the display label for the given row, col
            %   lbl = obj.GET_LABEL(row, col)
            %
            %   ABCD_Param get_label() will get the labels A, B, C, D
            ix = (ir-1)*2+ic;  % map it 1-4
            switch ix
                case 1
                    lbl = 'A';
                case 2
                    lbl = 'B';
                case 3
                    lbl = 'C';
                case 4
                    lbl = 'D';
                otherwise
                    lbl = '???';
            end
        end % function get_label

    end % protected methods

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net
