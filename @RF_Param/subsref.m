function varargout = subsref(obj, S)
% Subscripted reference
%   obj(idx)      - extracts the parameter matrix at the given index
%   obj(id)       - extracts the given parameter ('12', 'S12') - see Extract
%   obj(r,c)      - extracts the given parameter - see Extract
%   [data,freq] = obj(r,c)  - extracts both data and frequency
%   obj(r,c,idx)  - indexes directly into Data
%   obj.prop      - returns that property if it exists
%
%  See also: Extract
switch S(1).type
    case '()'
        N = length(S.subs);
        if N==1
			idx = S.subs{1};
			if ischar(idx) || isstring(idx)
			    varargout{1} = obj.Extract(idx);
                if nargout>1
                    varargout{2} = obj.Freq;
                end
			else
				varargout{1} = obj.Data(:,:,idx);
			end
        elseif N==2
            varargout{1} = obj.Extract(S.subs{1}, S.subs{2});
            if nargout>1
                varargout{2} = obj.Freq;
            end
        else
            varargout{1} = subsref(obj.Data, S);
        end
    otherwise
        [varargout{1:nargout}] = builtin('subsref',obj, S);
end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net