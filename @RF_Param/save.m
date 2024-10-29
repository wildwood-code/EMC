function filename = save(obj, filename, format, freq_format)
% SAVE Saves RF_Param object to a Touchstone or CSV file
%   filename = obj.SAVE(filename, format, freq_format)
%
%     filename = name of Touchstone file being saved
%     format   = 'RI', 'DB', 'MA'  {default='RI'}
%     freq_format = 'GHZ', 'MHZ', 'KHZ', 'HZ'  {default=obj.FScale}
%
%    outputs the filename including .sNp suffix
%    S, Y, Z, G, and H parameters are saved in Touchstone format
%    others are saved in CSV format

% TODO: improved features
%         choose .sNp or .csv based first upon filesuffix
%         then upon the obj.Type if none given
%         output filename should contain the new suffix if it was changed
%         check that the suffix makes sense if .sNp
%         (e.g., give informative warning if .s4p given for 2-port)

narginchk(2,4)

if nargin<4
    freq_format = obj.FScale;
elseif not( ischar(freq_format) || isscalar(freq_format) )
    freq_format = [];
end

[~,freq_format] = EMC.RF_Param.check_freq_unit(freq_format);

if isempty(freq_format)
    error('Unrecognized or invalid freq format')
end

freq_format = upper(freq_format);

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

if isprop(obj,'Impedance')
    imp = obj.Impedance;
else
    imp = 50;
end

switch obj.Type
    case { 'S', 'Y', 'Z', 'G', 'H' }
        % save in touchstone format
        filename = EMC.save_params(filename, obj.Freq*obj.FScale, obj.Data, obj.Type, format, imp, freq_format);
    otherwise
        % simply save others to a text file since they are not
        % defined for Touchstone v1.1 format
        filename = EMC.save_params_csv(filename, obj.Freq*obj.FScale, obj.Data, obj.Type, format, imp, freq_format);
end

if nargout<1
    clear filename
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net