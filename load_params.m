function [F,P,TYPE,IMP,N] = load_params(filename)
% LOAD_PARAMS  Load network parameters from a touchstone file
%   [F,P,TYPE,IMP,N] = LOAD_PARAMS(filename)
%     filename = string filename to load (suffix determies number of ports)
%     F        = output frequency vector F(L,1)         L = number of freqs
%     P        = ouput network parameter P(N,N,L)       N = number of ports
%     TYPE     = type of parameters (SYZHG)
%     IMP      = source/load impedance in Ohms
%     N        = output number of ports
%
%   Loads the network parameters from the Touchstone v1.1 format
%   network parameter file (suffix .s#p where # is the # of ports)
%
%   See also: SAVE_PARAMS CONVERT_2PORT CONVERT_N_PORT

% History:
%   2018.09.18  KSM  Corrected dB conversion

% default options
has_option_line = 0;
freq_scale = 1e9;  % default = GHz
TYPE = 'S';
option_format = 'MA';
IMP = 50;

% get suffix from filename (specifies number of ports)
[~,~,ext] = fileparts(filename);
tok = regexpi(ext, '^\.s([0-9])p$', 'tokens');
if ~isempty(tok)
    N_PORTS = tok{1}{1}-'0';
    if N_PORTS<1 || N_PORTS>9
        error('Function only supports 1-9 ports')
    end
else
    error('Unrecognized extension ''%s''', ext)
end

% open the file for reading, error if it cannot be opened
fID = fopen(filename, 'r');
if fID==-1
    error('Unable to open file ''%s''', filename)
end

% define numeric regex patterns
pat_posreal = '[+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?';
pat_real = '[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?';

% initialize data matrix
N_COLS = 1+2*(N_PORTS.^2);
DATA = zeros(0, N_COLS);

% main loop
while true
    
    % read one line at a time
    line = fgetl(fID);
    if line==-1
        % encountered end of file
        break
    end
    
    % strip beginning and end whitespace and comments
    R = regexpi(line, '^(.*?)\!.*$', 'tokens');
    if ~isempty(R)
        line = R{1}{1};
    end
    line = strtrim(line);
    
    if ~isempty(regexpi(line, '\[Version.*\]'))
        error('Unable to process Touchstone Version 2.0 or later files')
    end
    
    % process line
    if ~isempty(line)
        if line(1)=='#'
            % option line (ignore if there has already been one)
            if ~has_option_line
                % process the option line
                tokens = strsplit(strtrim(line));
                last = '';
                for token = tokens
                    tok = token{1};
                    if ~isempty(last)
                        
                        if last=='R'
                            % must be a positive resistance value
                            sI = regexpi(tok, [ '^' pat_posreal '$' ]);
                            if sI
                                IMP = eval(tok);
                                last = tok;
                                continue
                            else
                                error('Unable to evaluate R <value> in option line')
                            end
                        end
                        
                        sI = regexpi(tok, '^(GHz|MHz|KHz|Hz)$');
                        if sI
                            switch upper(tok)
                                case 'GHZ'
                                    freq_scale = 1e9;
                                case 'MHZ'
                                    freq_scale = 1e6;
                                case 'KHZ'
                                    freq_scale = 1e3;
                                case 'HZ'
                                    freq_scale = 1;
                            end
                            last = tok;
                            continue
                        end
                        
                        sI = regexpi(tok, '^(S|Y|Z|H|G)$');
                        if sI
                            TYPE = tok;
                            last = tok;
                            continue
                        end
                        
                        sI = regexpi(tok, '^(DB|MA|RI)$');
                        if sI
                            option_format = upper(tok);
                            last = tok;
                            continue
                        end
                        
                        if tok=='R'
                            last = 'R';
                            continue
                        end
                    else
                        last = tok;
                    end
                end
                
            end
        elseif N_PORTS<=2
            % data line
            row = process_data(line);
            DATA = vertcat(DATA, row);
        else % 3 to 9 ports
            % data lines for N_PORTS==3 or N_PORTS==4
            
            points_read = 0;
            points_needed = N_COLS;
            
            % process first line
            [row,istart,nread] = process_data(line);
            points_read = points_read + nread;
            
            % read subsequent lines
            while points_read<points_needed
                line = fgetl(fID);
                line = strtrim(line);
                [row,istart,nread] = process_data(line, row, istart, true);
                points_read = points_read + nread;
            end
            DATA = vertcat(DATA, row);
        end
    end
end

F = DATA(:,1)*freq_scale;
K = length(F);
C = complex(zeros(K,N_PORTS*N_PORTS));
P = complex(zeros(N_PORTS,N_PORTS,K));
for i=1:N_PORTS*N_PORTS
    for j=1:K
        dval_x = DATA(j,2+(i-1)*2);
        dval_y = DATA(j,3+(i-1)*2);
        C(j,i) = convert_values(dval_x, dval_y, option_format);
    end
end
for i=1:K

    
    switch N_PORTS
        case 1
            P(1,1,i) = C(i,1);
            
        case 2
            P(1,1,i) = C(i,1);
            P(2,1,i) = C(i,2);
            P(1,2,i) = C(i,3);
            P(2,2,i) = C(i,4);
            
        otherwise
            id = 1;
            for ir=1:N_PORTS
                for ic=1:N_PORTS
                    P(ir,ic,i) = C(i,id);
                    id = id+1;
                end
            end
    end
end

N = N_PORTS;
fclose(fID);

% Nested functions
    function [row,istart,points_read] = process_data(line, row, istart, skip_freq)
        
        % sanity checking and default parameters
        narginchk(1,4)
        if nargin<4
            skip_freq = false;
        end
        if nargin<3
            istart = 1;
        end
        if nargin<2
            row = zeros(1, N_COLS);
        end
        
        points_read = 0;

        % tokenize the line
        tokens = strsplit(line);
        N = length(tokens);
        
        % Process each token to form a row of data
        for ix = 1:N
            tok = tokens{ix};
            if ~skip_freq
                if ix==1
                    pat = pat_posreal;
                else
                    pat = pat_real;
                end
            else
                pat = pat_real;
            end
            sI = regexpi(tok, [ '^' pat '$' ]);
            if sI
                v = eval(tok);
            else
                v = 0;
                warning('Invalid value on data line')
            end
            row(1,istart) = v;
            istart = istart+1;
            points_read = points_read + 1;
        end
    end
end

% Local Functions
function v = convert_values(x,y,f)
switch f
    case 'MA'
        v = complex(x*exp(1i*y*pi/180));
    case 'DB'
        v = complex((10^(x/20))*exp(1i*y*pi/180));
    case 'RI'
        v = complex(x,y);
end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net
