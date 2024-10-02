% IS_UNITT function to determine if unit is valid time unit
%   tf = IS_UNITT(unitt)                 true if valid, false otherwise
%   [tf,unitt,scale] = IS_UNITT(unitt)
%      conditions unitf to proper capitalization and provides the time
%      scaling factor to convert to seconds
function [tf,unitt,scale] = is_unitt(unitt)

tf = true;

switch lower(unitt)
    case { 'hr' }
        scale = 3600;
        unitt = 'hr';
    case { 'min' }
        scale = 60;
        unitt = 'min';
    case { 'ks', 'ksec' }
        scale = 1e3;
        unitt = 'ks';
    case { 's', 'sec' }
        scale = 1;
        unitt = 's';
    case { 'ms', 'msec' }
        scale = 1e-3;
        unitt = 'ms';
    case { 'us', 'usec', 'µs', 'µsec' }
        scale = 1e-6;
        unitt = 'us';
    case { 'ns', 'nsec' }
        scale = 1e-9;
        unitt = 'ns';
    case { 'ps', 'psec' }
        scale = 1e-12;
        unitt = 'ps';
    otherwise
        tf = false;
        scale = 0;
        unitt = [];
end

if nargout<2
    clear unitt scale
elseif nargout<3
    clear scale
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net