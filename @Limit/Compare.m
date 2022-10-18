function tf = Compare(obj, freq, data, compare_type)
% COMPARE   Compare limit to set of data
%

narginchk(3,4)

if nargin<4
    compare_type = obj.PassCriteria;
end

if ~ischar(compare_type)
    error('compare_type must be a character string')
else
    % get comparison function
    switch compare_type
        case 'lt'
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
end

if ~strcmpi(compare_type, obj.PassCriteria)
%    warning('Limit is ''%s'' but comparing with ''%s''', obj.PassCriteria, compare_type)
end

if ~isvector(freq) || ~isvector(data)
    error('freq and data must be vectors')
elseif length(freq) ~= length(data)
    error('freq and data must be same length')
end

tf = true;
for i=1:length(freq)
    f = freq(i);
    d = data(i);
    di = obj.LimitAt(f);
    if isnan(di)
        continue
    elseif ~compare(d, di)
        tf = false;
        break
    end
end
