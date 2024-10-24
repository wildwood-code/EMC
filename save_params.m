function filename = save_params(filename, F, P, type, format, imp, freq)
% SAVE_PARAMS  Save network parameters to a touchstone file
%   SAVE_PARAMS(filename, F, P, type, format, imp, freq)
%     filename = string filename to load
%     F        = input frequency vector F(L,1)          L = number of freqs
%     P        = input network parameter P(N,N,L)       N = number of ports
%     type     = type of parameters (SYZHG)
%     imp      = source/load impedance in Ohms
%     freq     = format to store freq data (GHZ,MHZ,KHZ,HZ)
%
%   Saves the network parameters to a Touchstone v1.1 format
%   network parameter file (suffix .s#p where # is the # of ports is
%   auto-generated if not specified.
%
%   See also: LOAD_PARAMS CONVERT_2PORT CONVERT_N_PORT

% History:
%   2018.09.18  KSM  Corrected dB conversion

narginchk(3,7)

[ir,ic,LENGTH]=size(P);
if ir<1 || ir~=ic
    error('Dimensions of P must be N x N x L where N=ports, L=length')
elseif LENGTH<=0
    error('Length must be at least 1')
elseif numel(F)~=LENGTH
    error('Length of F must match length of P')
else    
    N_PORTS = ir;
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
            x_format = '%.6f';
            y_format = '%+.4f';
        case 'DB'
            x_format = '%.4f';
            y_format = '%+.4f';
        case 'RI'
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
        case { 'S', 'Y', 'Z', 'H', 'G' }
        otherwise
            error('Unrecognized type. Valid = S|Y|Z|H|G')
    end
end

[~,~,ext] = fileparts(filename);
ext = upper(ext);
if isempty(ext)
    filename = [ filename sprintf('.s%up', N_PORTS) ];
end

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'w');
if fID==-1
    error('Unable to open file ''%s''', filename)
end

% write a header
fprintf(fID, '! Touchstone v1.1 network parameters\n');
fprintf(fID, '! Generated by save_params on %s\n', date);
fprintf(fID, '! Copyright (c) Kerry S. Martin, martin@wild=wood.net\n');
fprintf(fID, '# %s %s %s R %f\n', freq, type, format, imp);

% write a data order description
switch N_PORTS
    case 1
        fprintf(fID, '! FREQ <%1$s11>\n', type);
    case 2
        fprintf(fID, '! FREQ <%1$s11> <%1$s21> <%1$s12> <%1$s22>\n', type);
    case 3
        fprintf(fID, '! FREQ <%1$s11> <%1$s12> <%1$s13>\n', type);
        fprintf(fID, '!\t<%1$s21> <%1$s22> <%1$s23>\n', type);
        fprintf(fID, '!\t<%1$s31> <%1$s32> <%1$s33>\n', type);
    case 4
        fprintf(fID, '! FREQ <%1$s11> <%1$s12> <%1$s13> <%1$s14>\n', type);
        fprintf(fID, '!\t<%1$s21> <%1$s22> <%1$s23> <%1$s24>\n', type);
        fprintf(fID, '!\t<%1$s31> <%1$s32> <%1$s33> <%1$s34>\n', type);
        fprintf(fID, '!\t<%1$s41> <%1$s42> <%1$s43> <%1$s44>\n', type);
    otherwise
        fprintf(fID, '! FREQ');
        n_on_row = 0;
        for ir=1:N_PORTS
            for ic=1:N_PORTS
                if n_on_row==0
                    fprintf(fID, '!\t');
                else
                    fprintf(fID, ' ');
                end
                fprintf(fID, '<%s%d%d>', type, ir, ic);
                n_on_row = n_on_row + 1;
                if n_on_row==4
                    n_on_row = 0;
                    fprintf(fID, '\n');
                end
            end
        end
        if n_on_row~=0
            fprintf(fID, '\n');
        end
end

% write the data
for i=1:LENGTH
    fprintf(fID, freq_format, F(i));
    switch N_PORTS
        case 1
            [x,y] = convert_value(P(1,1,i), format);
            print_value(fID, x, y, ' ', '\n');
        case 2
            for j=1:4
                switch j
                    case 1
                        v = P(1,1,i);
                    case 2
                        v = P(2,1,i);
                    case 3
                        v = P(1,2,i);
                    case 4
                        v = P(2,2,i);
                end
                [x, y] = convert_value(v, format);
                print_value(fID, x, y, ' ');
            end
            fprintf(fID, '\n');
        case { 3, 4 }
            for ir = 1:N_PORTS
                if ir~=1
                    head = sprintf('\t');
                else
                    head = ' ';
                end
                for ic = 1:N_PORTS
                    if ic~=1
                        fprintf(fID, ' ');
                    end
                    v = P(ir, ic, i);
                    [x, y] = convert_value(v, format);
                    print_value(fID, x, y, head);
                    head = ' ';
                end
                fprintf(fID, '\n');
            end
        otherwise % 5 or more ports
            n_on_row = 0;
            for ir=1:N_PORTS
                for ic=1:N_PORTS
                    if n_on_row==0
                        fprintf(fID, '\t');
                    else
                        fprintf(fID, ' ');
                    end
                    v = P(ir, ic, i);
                    [x, y] = convert_value(v, format);
                    print_value(fID, x, y);
                    n_on_row = n_on_row + 1;
                    if n_on_row==4
                        n_on_row = 0;
                        fprintf(fID, '\n');
                    end
                end
            end
            if n_on_row~=0
                fprintf(fID, '\n');
            end
            
    end
end

% print footer
fprintf(fID, '! end of data\n');

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
        fprintf(fID, [ '%s' x_format ' ' y_format '%s'], head, x, y, tail);
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

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net