function obj = plus(obj1, obj2)

if ~isa(obj1, 'EMC.Limit')
    objt = obj1;
    obj1 = obj2;
    obj2 = objt;
end

if isa(obj1, 'EMC.Limit')
    switch class(obj2)
        case  'double'
            if ~isscalar(obj2)
                error('can only operate with a scalar value')
            end
            obj = obj1;
            [~,Np] = size(obj.Line);
            for i=1:Np
                obj.Line(1,i) = obj.Line(1,i) + obj2;
            end
            
        case 'EMC.Limit'
            error('Addition of two limits not supported. Try ''and'' to combine.')
            
        otherwise
            error('Unknown addition between ''EMC.Limit'' and ''%s''', class(obj2))
    end
else
    error('DEBUG: we should never hit this statement')
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net