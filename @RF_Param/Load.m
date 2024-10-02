function obj = Load(filename)
% Load RF parameter data from a file
% obj = RF_Param.Load(filename)
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