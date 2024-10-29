function h = plot(obj, varargin)
% PLOT  Plot RF Parameters
%   h = PLOT(obj, varargin)
%   takes same arguments as 2D plot function
%   if no output argument is specified, it will produce no output

datax = obj.Freq;

% use linear plot if 0 Hz is included, otherwise use log plot
if min(datax)>0
    islogf = true;
else
    islogf = false;
end

Nports = obj.nPorts;
p = 1;

for i=1:Nports
    for j=1:Nports

        [type, unit_lbl] = obj.get_plot_info(i,j);

        switch type
            case 'dB'
                islogy = false;
                isyabs = true;
                datay = 20*log10(abs(obj.extract(i,j)));
            case 'lin'
                islogy = false;
                isyabs = true;
                datay = abs(obj.extract(i,j));
            case 'log'
                islogy = true;
                isyabs = true;
                datay = abs(obj.extract(i,j));
        end

        subplot(Nports,Nports,p)

        if islogf
            if islogy
                loglog(datax, datay, varargin{:})
            else
                semilogx(datax, datay, varargin{:})
            end
        else
            if islogy
                semilogy(datax, datay, varargin{:})
            else
                plot(datax, datay, varargin{:})
            end
        end

        hax = gca;
        if isempty(hax.XLabel.String)
            lbl = sprintf('Frequency (%s)', get_unitf(obj.FScale));
            xlabel(lbl)
        end
        if isempty(hax.YLabel.String)
			slbl = obj.get_label(i, j);
            if isyabs
                bar = '|';
            else
                bar = '';
            end
            lbl = sprintf('%s%s%s (%s)', bar, slbl, bar, unit_lbl);
            ylabel(lbl)
        end
        p = p + 1;
    end
end

if nargout>0
    h = gcf;
end

end


function unitf = get_unitf(fscale)
switch fscale
    case 1.0e3
        unitf = 'kHZ';
    case 1.0e6
        unitf = 'MHz';
    case 1.0e9
        unitf = 'GHz';
    otherwise
        unitf = 'Hz';
end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net