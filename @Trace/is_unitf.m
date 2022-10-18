% IS_UNITF function to determine if unit is valid frequency unit
%   tf = IS_UNITF(unitf)                 true if valid, false otherwise
%   [tf,unitf,scale] = IS_UNITF(unitf)
%      conditions unitf to proper capitalization and provides the frequency
%      scaling factor to convert to Hz
function [tf,unitf,scale] = is_unitf(unitf)

tf = true;

switch lower(unitf)
    case 'hz'
        scale = 1;
        unitf = 'Hz';
    case 'khz'
        scale = 1e3;
        unitf = 'kHz';
    case 'mhz'
        scale = 1e6;
        unitf = 'MHz';
    case 'ghz'
        scale = 1e9;
        unitf = 'GHz';
    case 'thz'
        scale = 1e12;
        unitf = 'THz';
    otherwise
        tf = false;
        scale = 0;
        unitf = [];
end

if nargout<2
    clear unitf scale
elseif nargout<3
    clear scale
end