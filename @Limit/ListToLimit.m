function [F,L] = ListToLimit(segs)

Nseg = length(segs);

f_last = NaN;
L_last = NaN;

if Nseg>0
    % pull the individual segments into one array
    D = zeros(2,0);
    for i=1:Nseg
        S = segs{i};
        f1 = S(1,1);
        f2 = S(1,2);
        L1 = S(2,1);
        L2 = S(2,2);
        
        if ~isnan(f_last)
            if f1~=f_last || L1~=L_last
                % last was not a match, add a separator, then add [f1, L1]
                D(:,end+1:end+2) = [ NaN f1 ; NaN L1];
            end
        else
            D(:,end+1) = [ f1 ; L1 ]; %#ok<AGROW>
        end
        D(:,end+1) = [ f2 ; L2 ]; %#ok<AGROW>
        f_last = f2;
        L_last = L2;
    end
    
    F = D(1,:);
    L = D(2,:);
else
    F = [];
    L = [];
end