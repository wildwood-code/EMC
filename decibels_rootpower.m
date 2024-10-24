function dB = decibels_rootpower(x)
% convert root-power quantity (Volts, Amps, etc) to decibels

dB = 20*log10(abs(x));

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net