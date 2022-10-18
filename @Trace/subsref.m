% SUBSREF trace subscripted reference
%   obj = RE(idx)
%   RE(idx)
%
%   ex/
%   RE(3)
%   RE(1:3)
%   RE([2 4])
%   RE(1:2).Plot()
%
%   See also: TRACE

% Kerry S. Martin, martin@wild-wood.net
function varargout = subsref(obj, S)
% Subscripted reference

switch S(1).type
    case '()'
            N = length(S(1).subs);
            if N==1
                [~,Nt] = size(obj.y);
                idx = S(1).subs{1};
                if all(idx>=1) && all(idx<=Nt)
                    out = EMC.Trace(obj.x, obj.y(:,idx), obj.Domain);
                    out.det = obj.det(idx);
                    out.name = obj.name(idx);
                    out.unit_absc = obj.unit_absc;
                    out.unit_mag = obj.unit_mag;
                    out.scale_absc = obj.scale_absc;
                else
                    throw(MException('EMC:Trace:Index', 'Index out of range'))
                end
            else
                throw(MException('EMC:Trace:Index', 'Only one index subscript allowed'))
            end
            
            if length(S)==1
                varargout{1} = out;
            else
                % Recursive reference
                [varargout{1:nargout}] = builtin('subsref', out, S(2:end));
            end
            
    otherwise
        [varargout{1:nargout}] = builtin('subsref',obj, S);
end

