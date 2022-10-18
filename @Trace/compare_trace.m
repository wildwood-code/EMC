% COMPARE_TRACE compares a trace to another trace, limit, or scalar
%   tf = COMPARE_TRACE(trace, trace2, compare_type)
%   tf = COMPARE_TRACE(trace, limit, compare_type)
%   tf = COMPARE_TRACE(trace, scalar, compare_type)
%
%     compare_type = 'lt', 'gt', 'le', 'ge'
%
%   See also: TRACE LIMIT TRACE/LT TRACE/GT TRACE/LE TRACE/GE

% Kerry S. Martin, martin@wild-wood.net
function tf = compare_trace(trace, obj, compare_type)

narginchk(3,3)
if ~isa(trace,'EMC.Trace')
    throw(MException('EMC:Trace:NonTrace', 'Not an EMC.Trace'))
elseif isempty(trace.x)
%    warning('trace is empty. returning false')
    tf = false;
    return
end

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
        
switch class(obj)
    case 'EMC.Limit'
        [~,Nt] = size(trace.y);
        tf = true(1,Nt);
        for i=1:Nt
            tf(i) = obj.Compare(trace.x*trace.scale_absc, trace.y(:,i), compare_type);
        end
    case 'EMC.Trace'
        [Np1,Nt1] = size(trace.y);
        [Np2,Nt2] = size(obj.y);
        if Nt1~=1 || Nt2~=1
            error('only single trace objects can be compared')
        end
        if Np1~=Np2
            error('traces must be the same length with matching frequency')
        else
            for i=1:Np1
                if abs(trace.x(i,1)-obj.x(i,1))>1e-4
                    error('traces must be the same length with matching frequency')
                end
            end
        end
        tf = true;
        for i=1:Np1
            if ~compare(trace.y(i,1),obj.y(i,1))
                tf = false;
                break;
            end
        end
        
    case 'double'
        if ~isscalar(obj)
            error('for comparison to double, only a scalar is allowed')
        end
        [Np,Nt] = size(trace.y);
        tf = true(1,Nt);
        for j=1:Nt
            tf_value = true;
            for i=1:Np
                if ~compare(trace.y(i,j),obj)
                    tf_value = false;
                    break;
                end
            end
            tf(1,j) = tf_value;
        end
        
    otherwise
        error('Unknown comparison with type ''%s''', class(obj))
end