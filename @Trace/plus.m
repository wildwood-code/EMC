% PLUS adds scalar to a trace or combines sub-traces
% for a trace, a scaler may be added to the trace data
% may also be used to append one or more traces to a trace (same freq's)
% or join multiple traces end-to-end (different freq's)
% ex/
% RE1 = Trace.Load('trace1.trc');
% RE2 = Trace.Load('trace2.trc');
% RE = RE1+RE2; % combines two traces into one
% RE = RE+107;  % adds 107dB to the traces in the set
%
%   See also: TRACE TRACE/MINUS

% Kerry S. Martin, martin@wild-wood.net
function obj = plus(obj1, obj2)

if ~isa(obj1, 'EMC.Trace')
    objt = obj1;
    obj1 = obj2;
    obj2 = objt;
end

if isa(obj1, 'EMC.Trace')
    switch class(obj2)
        case  'double'
            if ~isscalar(obj2)
                error('can only operate with a scalar value')
            end
            obj = obj1;
            [Np,Nt] = size(obj.y);
            for i=1:Nt
                for j=1:Np
                    obj.y(j,i) = obj.y(j,i) + obj2;
                end
            end
        case 'EMC.Trace'
            % If the two traces have the same frequency data, then append
            % them. Otherwise error.
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
                % Sort first, then join using join_traces
                if obj1.x(1)>=obj2.x(end)
                    objt = obj1;
                    obj1 = obj2;
                    obj2 = objt;
                end
                [xt, yt] = EMC.Trace.join_traces(obj1.x, obj1.y, obj2.x, obj2.y);
                obj1.x = xt;
                obj1.y = yt;
                obj = obj1;
            else
                obj = obj1;
                obj.y = horzcat(obj.y,obj2.y);
                obj.det = horzcat(obj.det,obj2.det);
				obj.name = horzcat(obj.name,obj2.name);
                obj.notes = horzcat(obj.notes,obj2.notes);
            end
            
        otherwise
            str = sprintf('Unable to add with ''%s''', class(obj2));
            throw(MException('EMC:Trace:Math', str))
    end      
else
    error('DEBUG: we should never hit this statement')
end

