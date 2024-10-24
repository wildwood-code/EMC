% G_PARAM  RF Network Inverse hybrid (G) parameter class
%
%   G_PARAM is a class for holding G-parameter data
%
%   G_Param Methods:
%     G_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM Z_PARAM Y_PARAM ABCD_PARAM S_PARAM T_PARAM
%     
classdef G_Param < EMC.RF_Param
    
    methods

        % -------------------------------
        % G_Param constructor        
        function obj = G_Param(freq, data, unitf, unit)
            % Constructor
            % obj = G_PARAM(freq, data, unitf, unit)
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
                data = zeros(2,2,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(2,2,NL);
            end
            
            [NR,~,~] = size(data);
            if NR~=2
                error('G-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
        end
        
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net
