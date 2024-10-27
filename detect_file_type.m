function type = detect_file_type(filename)
% DETECT_FILE_TYPE Reads file to try to determine its type (EMC related)
%   type  = DETECT_FILE_TYPE(filename)
%     filename = string filename to load
%     type     = detected type
%                ''            -> unknown
%                'Touchstone'  -> Touchstone parameter file
%                'LTspice'     -> LTspice data file
%
%   See also: READ_LTSPICE_TXT_FILE READ_LTSPICE_PARAM_TXT_FILE

% History:
%   2024.10.26  KSM  Initial version
type = '';

[~,~,ext] = fileparts(filename);

fID = fopen(filename, 'r');
if fID==-1
    error('Unable to open file ''%s''', filename)
end

lines = {};

% check LTspice format
while strcmpi(ext, '.txt')  % one pass loop with test (treat it as 'if')
    lines{end+1} = fgetl(fID); %#ok<AGROW> 
    if ~ischar(lines{end}), break, end
    if ~regexpi(lines{1}, '^(?:time|Freq\.)(?:\s+[A-Za-z0-9\(\)]+)+\s*$'), break, end
    lines{end+1} = fgetl(fID); %#ok<AGROW>
    if ~ischar(lines{end}), break, end % break out of loop if line is EOF
    if ~regexpi(lines{2}, '^[0-9e+-\.]+(?:\s+[0-9edB,()+-\.°]+)+\s*$'), break, end
    type = 'LTspice';
    break
end

% check Touchstone format
if isempty(type) && regexpi(ext, '^\.s[1-9]p$')
    i = 0;  % index to lines{} for current line
    while true
        i = i + 1;
        if i<=length(lines)
            line = lines{i};
        else
            line = fgetl(fID);
            lines{end+1} = line; %#ok<AGROW> 
        end
        if ~ischar(line), break, end % break out of loop if line is EOF

        % skip comment lines
        if regexp(line, '^!'), continue, end

        % detect option line
        if regexpi(line, '^#\s+[KMG]?HZ\s+[SYZGH]\s+(?:MA|DB|RI)\s+R\s*(?:[-+0-9\.]+)\s*$')
            type = 'Touchstone';
            break
        end

        % terminate after so many lines
        if i>=50, break, end
    end
end

fclose(fID);

end

% LTspice txt
%   Suffix = .txt
%   First line format:  ^(?:time|Freq\.)(?:\s+[A-Za-z0-9\(\)]+)+\s*$
%   Second line format: ^[0-9e+-\.]+(?:\s+[0-9edB,()+-\.°]+)+\s*$

% Touchstone format
%   Suffix = .sNp   N=1-9
%   Comment lines:    ^!
%   Option line:      ^#\s+[KMG]?HZ\s+[SYZGH]\s+(?:MA|DB|RI)\s+R\s*(?:[-+0-9\.]+)\s*$

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net