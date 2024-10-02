function tf = IsMetBy(obj, freq, data)
% MEETS Does data meet the limit pass criteria?
%   tf = obj.(freq, data)
%
%     freq is in Hz

narginchk(2,3)

if nargin==3
    tf = obj.Compare(freq, data, obj.PassCriteria);
elseif nargin==2 && isa(freq, 'EMC.Trace')
    switch obj.PassCriteria
        case { 'lt', '' }
            compare = @(x,y) x<y;
        case 'gt'
            compare = @(x,y) x>y;
        case 'le'
            compare = @(x,y) x<=y;
        case 'ge'
            compare = @(x,y) x>=y;
        otherwise
            error('Unknown comparison type ''%s''', compare_type)
    end
    
    % Use the trace comparison functions
    tf = compare(freq, obj);
else
    error('Invalid arguments')
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net