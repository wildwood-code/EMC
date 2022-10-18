function [tscale, unitt] = GetTimeUnits(unitt)
% GETTIMEUNITS normalize time unit and get scaling (static, protected)
%          static, protected function of TD_Signal
%          with no argument, it returns a string array of all valid time
%          units
%          [tunits, default] = GetTimeUnits()

narginchk(0,1)

if nargin==0
    tscale =  [ "sec", "msec", "usec", "nsec", "psec", "s", "ms", "us", "ns", "ps" ];
    unitt = tscale(1);
else
    
    unitt = lower(unitt);
    switch unitt
        case { 's', 'sec' }
            unitt = "sec";
            tscale = 1;
        case { 'ms', 'msec' }
            unitt = "msec";
            tscale = 1e-3;
        case { 'us', 'usec' }
            unitt = "usec";
            tscale = 1e-6;
        case { 'ns', 'nsec' }
            unitt = "nsec";
            tscale = 1e-9;
        case { 'ps', 'psec' }
            unitt = "psec";
            tscale = 1e-12;
        otherwise
            warning("unrecognized time unit ''%s'', defaulting to ''sec''", unitt)
            unitt = "sec";
            tscale = 1;
    end
end