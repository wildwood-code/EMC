function [fscale,unitf] = check_freq_unit(unitf)
% CHECK_FREQ_UNIT  check freq unit and get scaling factor
%   [fscale, unitf] = CHECK_FREQ_UNIT(unitf)
%   [fscale, unitf] = CHECK_FREQ_UNIT(fscale)
%
%   fscale is the frequency scaling factor (e.g., 1e6 for 'MHz')
%   unitf is returned as the correctly capitalized unit (e.g., 'kHz' for 'KHZ')
%   if unitf is not recognized, empty matrices are returned for fscale and unitf
%
% Valid input values for unitf (case is ignored): Hz, kHz, MHz, GHz
% Valid input values for fscale: 1.0, 1.0e3, 1.0e6, 1.0e9

if ischar(unitf)
    switch lower(unitf)
        case 'hz'
            fscale = 1;
            unitf = 'Hz';
        case 'khz'
            fscale = 1e3;
            unitf = 'kHz';
        case 'mhz'
            fscale = 1e6;
            unitf = 'MHz';
        case 'ghz'
            fscale = 1e9;
            unitf = 'GHz';
        otherwise
            % unrecognized unit type
            fscale = [];
            unitf = [];
    end
elseif isscalar(unitf)
    switch unitf
        case 1
            fscale = 1;
            unitf = 'Hz';
        case 1e3
            fscale = 1e3;
            unitf = 'kHz';
        case 1e6
            fscale = 1e6;
            unitf = 'MHz';
        case 1e9
            fscale = 1e9;
            unitf = 'GHz';
        otherwise
            % unrecognized frequency scale
            fscale = [];
            unitf = [];
    end
else
    fscale = [];
    unitf = [];
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net