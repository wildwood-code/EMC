function [P1,P2,P3,P4] = extract(obj, varargin)

    % TODO: extract individual matrices if n1 == '^S?([dc]{2})([12]{2})?$'
    %       e.g. Sdd12, Sdc, cd, cc22, etc.
    narginchk(1,3)
    
    if nargin==1 && nargout==4
        if obj.is_legacy
		    % extract the 2-port mixed-mode S-parameters
		    P1 = EMC.S_Param(SM.Freq,SM.Data([1 3],[1 3],:),SM.Impedance,SM.UnitF,SM.Unit);
		    P2 = EMC.S_Param(SM.Freq,SM.Data([1 3],[2 4],:),SM.Impedance,SM.UnitF,SM.Unit);
		    P3 = EMC.S_Param(SM.Freq,SM.Data([2 4],[1 3],:),SM.Impedance,SM.UnitF,SM.Unit);
		    P4 = EMC.S_Param(SM.Freq,SM.Data([2 4],[2 4],:),SM.Impedance,SM.UnitF,SM.Unit);
        else
		    % extract the 2-port mixed-mode S-parameters
		    P1 = EMC.S_Param(SM.Freq,SM.Data([1 2],[1 2],:),SM.Impedance,SM.UnitF,SM.Unit);
		    P2 = EMC.S_Param(SM.Freq,SM.Data([1 2],[3 4],:),SM.Impedance,SM.UnitF,SM.Unit);
			P3 = EMC.S_Param(SM.Freq,SM.Data([3 4],[1 2],:),SM.Impedance,SM.UnitF,SM.Unit);
			P4 = EMC.S_Param(SM.Freq,SM.Data([3 4],[3 4],:),SM.Impedance,SM.UnitF,SM.Unit);	
        end
    elseif nargout==2
        [P1,P2] = extract@EMC.RF_Param(obj, varargin{:});
    elseif nargout<=1
        P1 = extract@EMC.RF_Param(obj, varargin{:});
    else
        error('Not yet implemented: extract by Sddij')
    end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net