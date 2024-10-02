function filename = Save(obj, filename, format, freq_format)
% Save RF parameter data to a file
% filename = obj.Save(filename, format, freq_format)
narginchk(2,4)

if ~strcmpi(obj.Unit, 'complex')
    error('Unable to save parameters that are not ''complex''')
end

if nargin<3
    format = 'RI';
else
    format = upper(format);
    switch format
        case { 'RI', 'DB', 'MA' }
        otherwise
            error('Unrecognized format')
    end
end
if nargin<4
    freq_format = obj.UnitF;
else
    freq_format = upper(freq_format);
    switch freq_format
        case { 'GHZ', 'MHZ', 'KHZ', 'H' }
            obj = obj.ConvertTo(freq_format);
        otherwise
            error('Unrecognized freq format')
    end
end

if isprop(obj,'Impedance')
    imp = obj.Impedance;
else
    imp = 50;
end

switch obj.Type
    case { 'S', 'Y', 'Z', 'G', 'H' }
        % save in touchstone format
        filename = EMC.save_params(filename, obj.Freq*obj.Fscale, obj.Data, obj.Type, format, imp, freq_format);
    otherwise
        % simply save others to a text file since they are not
        % defined for Touchstone v1.1 format
        filename = EMC.save_params_csv(filename, obj.Freq*obj.Fscale, obj.Data, obj.Type, format, imp, freq_format);
end

if nargout<1
    clear filename
end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net