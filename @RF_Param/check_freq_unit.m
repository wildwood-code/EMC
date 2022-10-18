function [fscale,unitf] = check_freq_unit(unitf)
% CHECK_FREQ_UNIT  check freq unit and get scaling factor
%   [fscale, unitf] = check_freq_unit(unitf)
%   fscale is the frequency scaling factor (e.g., 1e6 for 'MHz')
%   unitf is returned as the correctly capitalized unit (e.g., 'kHz' for 'KHZ')
%   if unitf is not recognized, empty matrices are returned for fscale and unitf
%
% Valid input values for unitf (case is ignored): Hz, kHz, MHz, GHz

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
