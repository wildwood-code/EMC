% H_PARAM  RF Network Hybrid (H) parameter class
%
%   H_PARAM is a class for holding H-parameter data
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
        function obj = H_Param(freq, data, unitf, unit)
            % Constructor
            % obj = H_PARAM(freq, data, unitf, unit)
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
                error('H-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
            obj.Type = 'H';  % property of superclass
        end
        
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net