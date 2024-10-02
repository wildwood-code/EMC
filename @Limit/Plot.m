function h = Plot(obj, varargin)
if ~ishold
    if obj.LogF
        h = semilogx(obj.Freq, obj.Line, varargin{:});
        %hold on
        %patch([obj.Freq flip(obj.Freq)], [obj.Line-4 flip(obj.Line)], 0.85*[1 1 1])
    else
        h = plot(obj.Freq, obj.Line, varargin{:});
    end
    %hold off
else
    h = gca;
    switch h.XScale
        case 'log'
            h = semilogx(obj.Freq, obj.Line, varargin{:});
        case 'linear'
            h = semilogx(obj.Freq, obj.Line, varargin{:});
    end
end

hax = gca;
if isempty(hax.XLabel.String)
    lbl = sprintf('Frequency (%s)', obj.UnitF);
    xlabel(lbl)
end
if isempty(hax.YLabel.String)
    lbl = sprintf('Magnitude (%s)', obj.Unit);
    ylabel(lbl)
end

if nargout==0
    clear h
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net