function h = Plot(obj, varargin)
% PLOT Plot a TD_Signal signal or signals

if obj.nPoints==0
    error('Object is empty')
else
    datax = obj.Time;
    datay = obj.Data;

    nSignals = obj.nSignals;

    if nSignals==1
        plot(datax, datay);
    else
        hsave = ishold;
        hold on
        linespec = { 'r-', 'g-', 'b-', 'y-', 'm-', 'c-' };
        nspec = length(linespec);
        for i=1:nSignals
            plot(datax/obj.Tscale, datay(:,i), linespec{1+mod(i-1,nspec)})
        end
        
        xlabel(obj.UnitT)
        if ~isempty(obj.Unit)
            ylabel(obj.Unit)
        end
        
        if ~hsave
            hold off
        end
    end

    if nargout>0
        h = gcf;
    end
    
end
    
% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net