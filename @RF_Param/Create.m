function obj = Create(TYPE, varargin)
% CREATE  Create an RF_Param of the specified type with the specified
% arguments
%   obj = RF_Param.Create(TYPE, ...)
switch upper(TYPE)
    case 'Z'
        obj = EMC.Z_Param(varargin{:});
    case 'Y'
        obj = EMC.Y_Param(varargin{:});
    case 'H'
        obj = EMC.H_Param(varargin{:});
    case 'G'
        obj = EMC.G_Param(varargin{:});
    case 'S'
        obj = EMC.S_Param(varargin{:});
    case 'T'
        obj = EMC.T_Param(varargin{:});
    case 'ABCD'
        obj = EMC.ABCD_Param(varargin{:});
    otherwise
        error('Parameter type not implemented')
end

% Copyright (c) 2022, Kerry S. Martin, martin@wild-wood.net