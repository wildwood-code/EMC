% T_PARAM  RF Network Scattering transfer (T) parameter class
%
%   T_PARAM is a class for holding T-parameter data
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

        % -------------------------------
        % T_Param constructor        
        function obj = T_Param(freq, data, Z, unitf, unit)
            % Constructor
            % obj = T_PARAM(freq, data, Z, unitf, unit)
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
                data = zeros(2,2,0);
                freq = zeros(1,0);
            elseif nargin<2
                NL = length(freq);
                data = zeros(2,2,NL);
            end
            if nargin<3
                Z = 50.0;
            end
            if ~isreal(Z) || Z<=0
                error('Impedance must be real and >0')
            end
            
            [NR,~,~] = size(data);
            if NR~=2
                error('T-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
            obj.Type = 'T';  % property of superclass
            obj.Impedance = Z;
        end
        
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net