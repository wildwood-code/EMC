function obj = ConvertTo(obj,to_unit)

isConvertFreq = true;

switch lower(to_unit)
    case 'hz'
        f_to = 1;
        unitf = 'Hz';
    case 'khz'
        f_to = 1e3;
        unitf = 'kHz';
    case 'mhz'
        f_to = 1e6;
        unitf = 'MHz';
    case 'ghz'
        f_to = 1e9;
        unitf = 'GHz';
    otherwise
        if regexpi(to_unit, '^dB.*')
            isConvertFreq = false;
            % make sure capitalization is 'dB'
            to_unit(1:2) = 'dB';
        else
            error('unrecognized frequency or dB unit')
        end
end

if isConvertFreq
    % Convert/scale frequency unit
    f_from = obj.Fscale;
    obj.Freq = obj.Freq*f_from/f_to;
    obj.Fscale = f_to;
    obj.UnitF = unitf;
else
    % Just rename mag unit
    obj.Unit = to_unit;
end
