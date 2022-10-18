function filename = save_params_csv(filename, F, P, type, format, imp, freq)
% SAVE_PARAMS  Save network parameters to a CSV file
%   SAVE_PARAMS(filename, F, P, type, format, imp, freq)
%     filename = string filename to load
%     F        = input frequency vector F(L,1)          L = number of freqs
%     P        = input network parameter P(N,N,L)       N = number of ports
%     type     = type of parameters (SYZHG)
%     imp      = source/load impedance in Ohms
%     freq     = format to store freq data (GHZ,MHZ,KHZ,HZ)
%
%   Saves the network parameters to a CSV file
%
%   See also: LOAD_PARAMS SAVE_PARAMS CONVERT_2PORT CONVERT_N_PORT

% History:
%   2018.09.18  KSM  Corrected dB conversion

narginchk(3,7)

[r,c,LENGTH]=size(P);
if r<1 || r~=c
    error('Dimensions of P must be N x N x L where N=ports, L=length')
elseif LENGTH<=0
    error('Length must be at least 1')
elseif numel(F)~=LENGTH
    error('Length of F must match length of P')
else    
    N_PORTS = r;
end

if nargin<7
    freq_scale = 1e9;
    freq = 'GHZ';
    freq_format = '%.9f';
else
    freq = upper(freq);
    switch freq
        % TODO: analyzer frequency vector to determine necessary resolution
        case 'GHZ'
            freq_scale = 1e9;
            freq_format = '%.9f';  % 1 Hz resolution
        case 'MHZ'
            freq_scale = 1e6;
            freq_format = '%.9f';  % 0.001 Hz resolution
        case 'KHZ'
            freq_scale = 1e3;
            freq_format = '%.7f';  % 0.0001 Hz resolution
        case 'HZ'
            freq_scale = 1;
            freq_format = '%.5f';  % 0.00001 Hz resolution
        otherwise
            error('Unrecognized freq. Valid = GHZ|MHZ|KHZ|HZ')
    end
end
F = F/freq_scale;

if nargin<6
    imp = 50;
else
    if imp<=0
        error('Impedance must be > 0')
    end
end
if nargin<5
    format = 'MA';
    x_format = '%.6f';
    y_format = '%.4f';
else
    format = upper(format);
    switch format
        case 'MA'
            x_spec = 'mag';
            y_spec = 'deg';
            x_format = '%.6f';
            y_format = '%+.4f';
        case 'DB'
            x_spec = 'dB';
            y_spec = 'deg';
            x_format = '%.4f';
            y_format = '%+.4f';
        case 'RI'
            x_spec = 're';
            y_spec = 'im';
            x_format = '%+.6f';
            y_format = '%+.6f';
        otherwise
            error('Unrecognized format. Valid = MA|DB|RI')
    end
end
if nargin<4
    type = 'S';
else
    type = upper(type);
    switch type
        case { 'S', 'Y', 'Z', 'H', 'G', 'T', 'ABCD' }
        otherwise
            error('Unrecognized type')
    end
end

[~,~,ext] = fileparts(filename);
if isempty(ext)
    filename = [ filename '.csv' ];
end

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'w');
if fID==-1
    error('Unable to open file ''%s''', filename)
end

% write a header
fprintf(fID, '! %s-Parameters, Ports=%d, Format=%s, Freq=%s, Z=%f\n', type, N_PORTS, format, freq, imp);

% write a data order description
fprintf(fID, '! FREQ');
for r=1:N_PORTS
    for c=1:N_PORTS
        fprintf(fID, ', %1$s%2$d%3$d%4$s, %1$s%2$d%3$d%5$s', type, r, c, x_spec, y_spec);
    end
end
fprintf(fID, '\n');

% write the data
for i=1:LENGTH
    fprintf(fID, freq_format, F(i));
    
    for r=1:N_PORTS
        for c=1:N_PORTS
            [x,y] = convert_value(P(r,c,i), format);
            print_value(fID, x, y, ', ');
        end
    end
    fprintf(fID, '\n');
end

% close the file
fclose(fID);

if nargout<1
    clear filename
end

% nested functions
    function print_value(fID, x, y, head, tail)
        narginchk(3,5)
        if nargin<5
            tail = '';
        end
        if nargin<4
            head = '';
        end
        fprintf(fID, [ '%s' x_format ', ' y_format '%s'], head, x, y, tail);
    end


% end of main function
end

% Local Functions
function [x,y] = convert_value(v,f)  % v is complex, f is type (MA, DB, RI)
switch f
    case 'MA'
        x = abs(v);
        y = angle(v)*180/pi;
    case 'DB'
        x = 20*log10(abs(v));
        y = angle(v)*180/pi;
    case 'RI'
        x = real(v);
        y = imag(v);
end
end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net