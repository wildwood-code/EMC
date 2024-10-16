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
        
        if strcmp(obj.Unit, 'complex')
            datay = 20*log10(abs(obj.extract(i,j)));
        else
            datay = obj.extract(i,j);
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
			slbl = obj.get_label(i, j);
            lbl = sprintf('|%s| (%s)', slbl, 'dB');
            ylabel(lbl)
        end
        p = p + 1;
    end
end

if nargout>0
    h = gcf;
end


% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net