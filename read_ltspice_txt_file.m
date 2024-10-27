function [x,y,h] = read_ltspice_txt_file(filename)
% READ_LTSPICE_TXT_FILE  Reads an LTspice exported data file
%   [x,y,h] = READ_LTSPICE_TXT_FILE(filename)
%     filename = string filename to load
%     x        = output time or frequency vector (Nx1)
%     y        = ouput data vector (NxM)
%     h        = output header cell array {1xM+1}
%                  first element is 'time' or 'Freq.'
%                  other M elements are the variable names
%
%   Loads an LTspice file that was exported 'data as text'
%   Tested using output from LTspice version 24.0.12
%
%   Data may be time-domain or frequency-domain
%   Frequency domain data may be polar or cartesian
%
%   See also: READ_LTSPICE_PARAM_TXT_FILE DETECT_FILE_TYPE

% History:
%   2024.10.26  KSM  Initial version

is_freq = false;    % frequenc domain (true) or time domain (false)
is_polar = false;   % frequency domain: polar (true) or cartesian (false)

x = [];             % initial x vector - we will grow this with each read line
y = [];             % initial y array - we will grow this with each read line

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'r');
if fID==-1
    error('Unable to open file ''%s''', filename)
end

% read heading line, determine if frequency or time domain
line = fgetl(fID);
h = split(line);
M = length(h)-1;
yd = zeros(1,M);
switch h{1}
    case 'time'
        is_freq = false;
    case 'Freq.'
        is_freq = true;
end

N = 0;              % number of points (increment as we read data)

while true % read data lines

    line = fgetl(fID);

    if ~ischar(line) || isempty(line)
        % exit condition is last line
        break
    end

    data = split(line);

    if N==0 && is_freq
        % first line determines polar or cartesian coordinate system
        if regexp(data{2}, '^\([^,]+dB,[^,]+°\)$')
            is_polar = true;
        elseif regexp(data{2}, '^[^,(]+,[^,)]+$')
            is_polar = false;
        else
            error('Frequency domain file appears to be neither cartesian nor polar')
        end
    end

    x(end+1,1) = convert_value(data{1}); %#ok<AGROW>

    if ~is_freq

        % time-domain
        for i=1:M
            yd(1,i) = convert_value(data{i+1});
        end

    else

        % frequency-domain
        for i=1:M
            if is_polar
                % frequency-domain polar
                tok = regexp(data{i+1}, '^\((.+)dB,(.+)°\)$', 'tokens');
                if ~isempty(tok)
                    dB = convert_value(tok{1}{1});
                    mag = 10.^(dB/20);
                    pha = convert_value(tok{1}{2});
                    z = mag*exp(1i*deg2rad(pha));
                else
                    error('invalid polar data point')
                end

            else
                % frequency-domain cartesian
                tok = regexp(data{i+1}, '^(.+),(.+)$', 'tokens');
                if ~isempty(tok)
                    re = convert_value(tok{1}{1});
                    im = convert_value(tok{1}{2});
                    z = complex(re,im);
                else
                    error('invalid cartesian data point')
                end
            end

            yd(1,i) = z;

        end

    end

    y(end+1,:) = yd; %#ok<AGROW>

    N = N + 1;  % data point count

end

fclose(fID);

end


function x = convert_value(str)
% CONVERT_VALUE support function to convert a string value to double
%   for now, it simply uses str2double(), but it may get modified if
%   LTspice is found to produce numbers in a suffix format (e.g. 10.0k)
x = str2double(str);
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net