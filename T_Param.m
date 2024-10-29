% T_PARAM  RF Network Scattering transfer (T) parameter class
%
%   T_PARAM is a class for holding T-parameter data
%
%   T_Param Properties:
%     nPorts     - number of ports in the network
%     nPoints    - number of frequency points in the parameter data
%     Freq       - column vector of frequencies (in Hz)
%     Data       - complex parameter data
%     FScale     - frequency scale (1=Hz, 1e3=kHz, 1e6=MHz, 1e9=GHz)
%     Impedance  - port impedance (in Ohms)
%
%   T_Param Methods:
%     T_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM Y_PARAM ABCD_PARAM S_PARAM
%     
classdef T_Param < EMC.RF_Param

    properties (SetAccess = private)
        Impedance       % impedance Zinout or [Zin Zout]
    end
    
    methods

        function obj = T_Param(freq, data, Z, fscale)
            % T_PARAM constructor
            %   obj = RF_PARAM(freq, data, fscale)
            %     freq  = frequency data [1 x Npoints]
            %     data  = complex parameter data [Nports x Nports x Npoints]
            %     Z     = s-parameter port impedance
            %     fscale = frequency unit ['Hz','kHz','MHz', 'GHz']
            %              of scale value: [1.0, 1.0e3, 1.0e6, 1.0e9]
            %              default='Hz'=1.0
            %
            %   If no arguments are specified, an empty T_Param is created

            narginchk(0,4)
            
            if nargin<4
                fscale = 1;
            elseif ischar(fscale) || isscalar(fscale)
                [fscale, ~] = EMC.RF_Param.check_freq_unit(fscale);
            else
                fscale = []; % will error out in RF_Param constructor
            end

            if nargin<3
                Z = 50.0;
            end

            if nargin<1
                data = zeros(2,2,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(2,2,NL);
            end

            if ~isreal(Z) || Z<=0
                error('Impedance must be real and >0')
            end
            
            [NR,~,~] = size(data);
            if NR~=2
                error('T-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, fscale);
            obj.Impedance = Z;

        end % T_Param constructor
        
    end % methods

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net