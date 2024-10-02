function h = Plot(obj)
% PLOT Plot a FD_Signal signal or signals

if obj.nPoints==0
    error('Object is empty')
else
    fscale = EMC.FD_Signal.GetFreqUnits(obj.FreqUnits);
    datax = obj.Freq/fscale;
    datay = obj.Data;
    
    if ~isreal(datay)
        datay = abs(datay);
        isabs = true;
    else
        isabs = false;
    end
    
    nSignals = obj.nSignals;
    
    if nSignals==1
        if obj.isLog
            semilogx(datax, datay);
        else
            plot(datax, datay);
        end
    else
        hsave = ishold;
        hold on
        linespec = { 'r-', 'g-', 'b-', 'y-', 'm-', 'c-' };
        nspec = length(linespec);
        
        for i=1:nSignals
            if obj.isLog
                semilogx(datax, datay(:,i), linespec{1+mod(i-1,nspec)})
            else
                plot(datax, datay(:,i), linespec{1+mod(i-1,nspec)})
            end
        end
        
        if ~hsave
            hold off
        end
    end
    
    xlabel(obj.FreqUnits)
    if ~isempty(obj.MagUnits)
        if isabs
            ylabel([ '|' obj.MagUnits '|'])
        else
            ylabel(obj.MagUnits)
        end
    elseif isabs
        ylabel('|.|')
    end
    
    if nargout>0
        h = gcf;
    end
    
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net