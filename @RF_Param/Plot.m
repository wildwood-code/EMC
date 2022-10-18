function h = Plot(obj, varargin)
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
        
        if strcmp(obj.Unit, 'complex')
            datay = 20*log10(abs(obj.Extract(i,j)));
        else
            datay = obj.Extract(i,j);
        end
        subplot(Nports,Nports,p)

        if islogf
            semilogx(datax, datay, varargin{:})
        else
            plot(datax, datay, varargin{:})
        end

        hax = gca;
        if isempty(hax.XLabel.String)
            lbl = sprintf('Frequency (%s)', obj.UnitF);
            xlabel(lbl)
        end
        if isempty(hax.YLabel.String)
            lbl = sprintf('|%s%d%d| (%s)', obj.Type, i, j, 'dB');
            ylabel(lbl)
        end
        p = p + 1;
    end
end

if nargout>0
    h = gcf;
end


% Copyright (c) 2022, Kerry S. Martin, martin@wild-wood.net