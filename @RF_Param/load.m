function obj = load(filename)
% LOAD  Load RF parameter data from a file
%   obj = RF_Param.load(filename)
%
% Note: any param derived from RF_Param may also be used as it is inherited
%       obj = S_Param.load(filename)
%       it still generates the correct RF_Param object regardless of which
%       derived class was used for the call

[F,P,TYPE,IMP,~] = EMC.load_params(filename);

switch TYPE
    case 'Z'
        obj = EMC.Z_Param(F,P);
    case 'Y'
        obj = EMC.Y_Param(F,P);
    case 'H'
        obj = EMC.H_Param(F,P);
    case 'G'
        obj = EMC.G_Param(F,P);
    case 'S'
        obj = EMC.S_Param(F,P,IMP);
    case 'T'
        obj = EMC.T_Param(F,P,IMP);
    case 'ABCD'
        obj = EMC.ABCD_Param(F,P);
    otherwise
        error('Parameter type not implemented')
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net