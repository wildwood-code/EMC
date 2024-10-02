% Y_PARAM  RF Network Admittance (Y) parameter class
%
%   Y_PARAM is a class for holding Y-parameter data
%
%   Y_Param Methods:
%     Y_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM ABCD_PARAM S_PARAM T_PARAM
%     
classdef Y_Param < EMC.RF_Param
    
    methods

        % -------------------------------
        % Y_Param constructor        
        function obj = Y_Param(freq, data, unitf, unit)
            % Constructor
            % obj = Y_PARAM(freq, data, unitf, unit)
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
            obj.Type = 'Y';  % property of superclass
        end
        
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net