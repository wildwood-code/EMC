function dB = to_dBP(p)
% TO_DBP Power quantity decibels
%   dB = TO_DBP(p)
%
% See also: TO_DB  TO_DBRP

dB = 10*log10(abs(p));

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net