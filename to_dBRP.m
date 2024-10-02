function dB = to_dBRP(rp)
% TO_DBRP  Root-power quantity decibels
%   dB = TO_DBRP(rp)
%
% See also:  TO_DB  TO_DBP

dB = 20*log10(abs(rp));

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net