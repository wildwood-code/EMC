function val = LimitAt(obj, freq)
% LIMITAT  Evaluate the limit line at the given frequency/frequencies
%   val = obj.LIMITAT(freq)
%
%   freq may be a scalar or a vector of frequencies
%   freq is in Hz
%   returns NaN if there is no limit defined at the frequency

if obj.LogF
    F = log10(obj.Freq*obj.Fscale);
    freq = log10(freq);
else
    F = obj.Freq*obj.Fscale;
end

D = obj.Line;

if isa(D, 'function_handle')
    error('not yet implemented')
else
    wrap = @(freq) lim_at_freq(freq, F, D);
    val = arrayfun(wrap, freq);
end

end


function lim = lim_at_freq(f, F, D)
lim = NaN;
Np = length(F);

for i=1:Np-1
    f1 = F(i);
    f2 = F(i+1);
    
    if isnan(f1) || isnan(f2)
        continue
    elseif f>=f1 && f<=f2
        lim = D(i) + (f-f1)*(D(i+1)-D(i))/(f2-f1);
        break
    end
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net