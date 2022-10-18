% IS_UNIT function to determine if unit is valid decibel unit
%   tf = IS_UNIT(unit)             true if value dB unit, false otherwise
%   [tf,unit] = IS_UNIT(unit)      also conditions unit to dB
function [tf,unit] = is_unit(unit)

tf = false;

if regexpi(unit, '^dB.*')
    tf = true;
    unit(1:2) = 'dB'; % capitalize properly
else
    unit = [];
end


if nargout<2
    clear unit
end