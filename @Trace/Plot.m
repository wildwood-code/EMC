% PLOT plots a set of traces
%   trace.PLOT()
%   h = trace.PLOT(varargin)
%
%   standard plot parameters may be passed to PLOT
%
%   See also: TRACE

% Kerry S. Martin, martin@wild-wood.net
function h = Plot(obj, varargin)
if ~ishold
    % new plot - create it and add a legend if the trace has names
    hp = plot(obj.x, obj.y+obj.y_offs, varargin{:});
    if ~isempty(obj.name{1})
        legend(obj.name)
    end
else
    % append plot
    hax = gca;
    switch hax.XScale
        case 'log'
            hp = semilogx(obj.x, obj.y+obj.y_offs, varargin{:});
        case 'linear'
            hp = plot(obj.x, obj.y+obj.y_offs, varargin{:});
    end
    if isempty(hax.Legend)   % was .String
        if ~isempty(obj.name{1})
            % append legend to empty list
            N = length(hax.Children);
            leg = cell(1,N);
            leg(1:N) = { '' };
            legend([leg obj.name])
        end
    else
        if ~isempty(obj.name{1})
            % legend was present, names were added -> replace them
            leg = hax.Legend.String;
            N = length(obj.name);
            M = length(leg);
            leg(M-N+1:M) = obj.name;
            legend(leg)
        end
    end
end

% Add x and y labels if they are blank
hax = gca;
if isempty(hax.XLabel.String)
    if obj.dom==EMC.Domains.TimeDomain
        sdomain = 'Time';
    else
        sdomain = 'Frequency';
    end
    
    lbl = sprintf('%s (%s)', sdomain, obj.unit_absc);
    xlabel(lbl)
end
if isempty(hax.YLabel.String)
    lbl = sprintf('Magnitude (%s)', obj.unit_mag);
    ylabel(lbl)
end

if nargout>0
    h = hp;
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net