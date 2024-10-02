function [fscale, unitf] = GetFreqUnits(unitf)
% GETFREQUNITS normalize freq unit and get scaling (static, protected)
%          static, protected function of FD_Signal
%          with no argument, it returns a string array of all valid freq
%          units
%          [funits, default] = GetFimeUnits()

narginchk(0,1)

if nargin==0
    fscale = [ "Hz", "kHz", "MHz", "GHz", "THz" ];
    unitf = fscale(1);
else
    
    unitf = lower(unitf);
    switch unitf
        case { 'hz' }
            unitf = "Hz";
            fscale = 1;
        case {'khz'}
            unitf = "kHz";
            fscale = 1e3;
        case { 'mhz' }
            unitf = "MHz";
            fscale = 1e6;
        case { 'ghz' }
            unitf = "GHz";
            fscale = 1e9;
        case { 'thz' }
            unitf = "THz";
            fscale = 1e12;
        otherwise
            warning("unrecognized freq unit ''%s'', defaulting to ''Hz''", unitf)
            unitf = "Hz";
            fscale = 1;
    end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net