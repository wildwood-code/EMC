% MINUS subtract scalar from a trace or removes sub-traces
% for a trace, a scalar may be subtracted from the trace data
% may also be used to remove one or more traces from a trace
% ex/
%   RE = Trace.Load('trace.trc');
%   REx = RE-(RE(1)+RE(2)); % REx has RE(1) and RE(2) removed from RE
%   REx = REx-107;  % subtracts 107dB from the traces
%
%   See also: TRACE TRACE/PLUS

% Kerry S. Martin, martin@wild-wood.net
function obj = minus(obj1, obj2)

if ~isa(obj1, 'EMC.Trace')
    objt = obj1;
    obj1 = obj2;
    obj2 = objt;
    swapped = true;
else
    swapped = false;
end

if isa(obj1, 'EMC.Trace')
    switch class(obj2)
        case  'double'
            if ~isscalar(obj2)
                throw(MException('EMC:Trace:Math', 'Only operates with a scalar value'))
            end
            obj = obj1;
            [Np,Nt] = size(obj.y);
            for i=1:Nt
                for j=1:Np
                    if swapped
                        obj.y(j,i) = obj2 - obj.y(j,i);
                    else
                        obj.y(j,i) = obj.y(j,i) - obj2;
                    end
                end
            end
        case 'EMC.Trace'
            % If one is a subset of the other, remove those that overlap
            if obj1.dom~=obj2.dom
                throw(MException('EMC:Trace:Domain', 'Incompatible domains'))
            end
            if ~isequal(obj1.UnitF,obj2.UnitF)
                obj2 = obj2.ConvertTo(obj1.UnitF);
            end
            if ~isequal(obj1.Unit,obj2.Unit)
                obj2 = obj2.ConvertTo(obj1.Unit);
            end
            if ~isequal(obj1.x,obj2.x)
                throw(MException('EMC:Trace:Data', 'Frequency mismatch'))
            end
            if size(obj2.y,2)>size(obj1.y)
                % make sure obj1 is the set with more traces
                objt = obj1;
                obj1 = obj2;
                obj2 = objt;
            end
            N1 = size(obj1.y,2);
            N2 = size(obj2.y,2);
            uselist = zeros(1,N2);
            dellist = zeros(1,N1);
            for i=1:N1
                for j=1:N2
                    if isequal(obj1.y(:,i),obj2.y(:,j))
                        dellist(i) = 1;
                        uselist(j) = 1;
                    end
                end
            end
            if ~all(uselist)
                throw(MException('EMC:Trace:Data', 'Unable to delete some/all traces'))
            end
            for i=N1:-1:1
                if dellist(i)
                    obj1.y(:,i) = [];
                    obj1.det(i) = [];
					obj1.name(i) = [];
                    obj1.notes(i) = [];
                end
            end
            obj = obj1;
 
        otherwise
            str = sprintf('Unable to subtract with ''%s''', class(obj2));
            throw(MException('EMC:Trace:Math', str))
    end      
end

