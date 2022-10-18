function varargout = subsref(obj, S)
% Subscripted reference
%   obj(idx)      - extracts the specified signal
%   [data,time] = obj(idx)  - extracts both data and frequency
%   obj.prop      - returns that property if it exists
%
%  See also: Extract
switch S(1).type
    case '()'
        N = length(S.subs);
        if N==1
            varargout{1} = obj.Data(:,S.subs{1});
            if nargout>1
                varargout{2} = obj.Time;
            end
        else
            varargout{1} = subsref(obj.Data, S);
        end
    otherwise
        [varargout{1:nargout}] = builtin('subsref',obj, S);
end
end