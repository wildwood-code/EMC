% LT < trace comparison
%   tf = LT(obj1, obj2)
%   tf = obj1 < obj2
%
%   See also: TRACE LIMIT TRACE/GT TRACE/LE TRACE/GE COMPARE_TRACE

% Kerry S. Martin, martin@wild-wood.net
function tf = lt(obj1, obj2)

if isa(obj1, 'EMC.Trace')
    switch class(obj2)
        case  { 'EMC.Trace', 'EMC.Limit', 'double' }
            tf = EMC.Trace.compare_trace(obj1, obj2, 'lt');
        otherwise
            str = sprintf('Unable to compare to ''%s''', class(obj2));
            throw(MException('EMC:Trace:Compare', str))
    end
elseif isa(obj2, 'EMC.Trace')
    switch class(obj1)
        case  { 'EMC.Trace', 'EMC.Limit', 'double' }
            tf = EMC.Trace.compare_trace(obj2, obj1, 'gt');
        otherwise
            str = sprintf('Unable to compare to ''%s''', class(obj1));
            throw(MException('EMC:Trace:Compare', str))
    end        
end

