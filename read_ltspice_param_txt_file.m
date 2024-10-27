function [F,P,TYPE] = read_ltspice_param_txt_file(filename)
% READ_LTSPICE_PARAM_TXT_FILE Read network parameters from LTspice data file
%   [F,P,TYPE] = READ_LTSPICE_PARAM_TXT_FILE(filename)
%     filename = string filename to load
%     F        = output frequency vector 1xN array (Hz)
%     P        = output param data 2x2xN array
%     TYPE     = parameter type 'S', 'H', 'Y', or 'Z"
%
%   LTspice can do 2-port network analysis.
%   This fuction reads the data file and checks if it contains network
%   parameter data (S,H,Z, or Y). THe file must contain all 4 parameters
%   (e.g. S11, S12, S21, S22) to be read successfully.
%
%   See also: READ_LTSPICE_TXT_FILE DETECT_FILE_TYPE

% History:
%   2024.10.26  KSM  Initial version

[f,d,h] = EMC.read_ltspice_txt_file(filename);

% data must be frequency domain
if ~strcmp(h{1}, 'Freq.')
    error('LTspice data must be frequency domain')
end

% search variables for 'S', 'H', 'Y', or 'Z' (those generated by LTspice
% .net analysis. They must have the form 'Xnn(ref)'
% the first parameter found is the one that will be extracted
M = length(h)-1;
Ptype = [];
for i=1:M
    tok = regexpi(h{i+1}, '^([HSYZ])[12]{2}\(.+\)$', 'tokens');
    if ~isempty(tok)
        Ptype = upper(tok{1}{1});
        break
    end
end
if isempty(Ptype)
    error('LTspice data must contain S, H, Y, or Z parameter data')
end

% search to find all 4 parameter elements: X11, X12, X21, X22 (X=SHYZ)
Pidx = zeros(1,4);  % 1=X11, 2=X12, 3=X21, 4=X22
for i=1:M
    pat = ['^' Ptype '([12])([12])\(.+\)$'];
    tok = regexpi(h{i+1}, pat, 'tokens');
    if ~isempty(tok)
        r = str2double(tok{1}{1});
        c = str2double(tok{1}{2});
        idx = (r-1)*2+c; % maps 1-4: 11->1, 12->2, 21->3, 22->4
        Pidx(idx) = i;  % index into d array
    end
end
if any(Pidx==0)
    error('LTspice data must contain all four parameters: %s11 $s12 $s21 %s22', Ptype, Ptype, Ptype, Ptype)
end

% everything seems good, so extract the data
TYPE = Ptype;
F = f;
N = length(f);
P = zeros([2 2 N]);
for i=1:N
    P(1,1,i) = d(i,Pidx(1));
    P(1,2,i) = d(i,Pidx(2));
    P(2,1,i) = d(i,Pidx(3));
    P(2,2,i) = d(i,Pidx(4));
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net