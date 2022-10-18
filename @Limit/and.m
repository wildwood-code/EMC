function obj = and(obj1, obj2)

% requirements:
%   1. if both specify a criteria other than '', they both must match
%   2. if both specify a freqscale other than '', they both must match
%   3. if both specify a frequnit other than '', they both must match
%   2. if both specify a limitscale other than '', they both must match

[tf, criteria] = EMC.Limit.TestParamEquality(obj1.PassCriteria, obj2.PassCriteria);
if ~tf
    error('and: incompatible criteria')
elseif isempty(criteria)
    %warning('plus: no criteria specified. defaulting to ''lt'' (<)')
    criteria = 'lt';
end

[tf, logF] = EMC.Limit.TestParamEquality(obj1.LogF, obj2.LogF);
if ~tf
    error('and: incompatible freq scale')
end

if isempty(obj1.Fscale) && isempty(obj2.Fscale)
    % both are empty, leave them that way
    unitf = '';
elseif isempty(obj2.Fscale)
    unitf = obj1.UnitF;
elseif isempty(obj1.Fscale)
    unitf = obj2.UnitF;
else
    % both are specified, normalize to obj1
    unitf = obj1.UnitF;
    f_to = obj1.Fscale;
    f_from = obj2.Fscale;
    obj2.Freq = obj2.Freq*f_from/f_to;
end

switch criteria
    case { 'lt', 'le' }
        isAbove = false;
    case { 'gt', 'ge' }
        isAbove = true;
    otherwise
        error('Unrecognized criteria')
end

% combine the limits and break into segments, sorted by start freq of each
segments = EMC.Limit.SplitToList([obj1.Freq;obj1.Line],[obj2.Freq;obj2.Line]);

Nseg = length(segments);
if Nseg>1
    isChanged = true;
    newsegs = cell(1,0);
    while isChanged
        isChanged = false;

        for i=1:Nseg-1
            for j=i+1:Nseg
                [tf,segs] = EMC.Limit.Resegment(segments{i}, segments{j}, logF, isAbove);
                if tf
                    isChanged = true;
                end
                L = length(segs);
                newsegs(end+1:end+L) = segs(:);
            end
        end
        
        if isChanged
            segments = newsegs;
            Nseg = length(segments);
        end
        
    end
end

% Stuff the segments back into  a limit
[F, L] = EMC.Limit.ListToLimit(segments);

if logF
    swF = 'logf';
else
    swF = 'linf';
end

% create the new object
obj = EMC.Limit(F, L, criteria, swF, unitf);