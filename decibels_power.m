function dB = decibels_power(x)
% convert power quantity to decibels

dB = 10*log10(abs(x));