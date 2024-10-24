% ABCD_PARAM  RF Network Cascade (ABCD) parameter class
%
%   ABCD_PARAM is a class for holding ABCD-parameter data
%
%   ABCD_Param Methods:
%     ABCD_Param    - constructor
%
%   See also:  RF_PARAM H_PARAM G_PARAM Z_PARAM Y_PARAM S_PARAM T_PARAM
%     
classdef ABCD_Param < EMC.RF_Param
    
    methods

        % -------------------------------
        % ABCD_Param constructor        
        function obj = ABCD_Param(freq, data, unitf, unit)
            % Constructor
            % obj = ABCD_PARAM(freq, data, unit_freq, unit)
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
                error('ABCD-Parameters only valid for 2-port networks')
            end
            
            obj@EMC.RF_Param(freq, data, unitf, unit);
        end
		
		function lbl = get_label(obj, ir, ic)
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
		end
        
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net
