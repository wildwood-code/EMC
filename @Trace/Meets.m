% MEETS compare a trace to a limit to make sure it passes the limit criteria
%   tf = MEETS(trace, limit)
%   tf = trace.MEETS(limit)
%
%   See also: TRACE LIMIT

% Kerry S. Martin, martin@wild-wood.net
function tf = Meets(obj1, obj2)

if isa(obj1, 'EMC.Trace')
    switch class(obj2)
        case  'EMC.Limit'
            if isempty(obj2.PassCriteria)
                pc = 'lt';
            else
                pc = obj2.PassCriteria;
            end
            tf = EMC.Trace.compare_trace(obj1, obj2, pc);
        otherwise
            throw(MException('EMC:Trace:Compare', 'Meets is used to compare a Trace to a Limit'))
    end
else
    throw(MException('EMC:Trace:Compare', 'Meets is used to compare a Trace to a Limit'))
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net