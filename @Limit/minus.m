function obj = minus(obj1, obj2)

if ~isa(obj1, 'EMC.Limit')
    objt = obj1;
    obj1 = obj2;
    obj2 = objt;
    swapped = true;
else
    swapped = false;
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
                if swapped
                    obj.Line(1,i) = obj2 - obj.Line(1,i);
                else
                    obj.Line(1,i) = obj.Line(1,i) - obj2;
                end
            end
            
        case 'EMC.Limit'
            error('Subtraction of two limits not supported.')
            
        otherwise
            error('Unknown subtraction between ''EMC.Limit'' and ''%s''', class(obj2))
    end
else
    error('DEBUG: we should never hit this statement')
end

