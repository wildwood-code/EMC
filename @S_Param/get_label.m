function lbl = get_label(obj, ir, ic)
% GET_LABEL gets the display label for the given row, col
%   lbl = obj.GET_LABEL(row, col)
%
%   S_Param get_label() will get mixed-mode specific labels if the object
%   is mixed-mode

if obj.is_mixed
    ix = (ir-1)*4+ic;  % map it 1-16
    if obj.is_legacy
        switch ix
            case 1
                lbl = 'Sdd11';
            case 2
                lbl = 'Sdc11';
            case 3
                lbl = 'Sdd12';
            case 4
                lbl = 'Sdc12';
            case 5
                lbl = 'Scd11';
            case 6
                lbl = 'Scc11';
            case 7
                lbl = 'Scd12';
            case 8
                lbl = 'Scc12';
            case 9
                lbl = 'Sdd21';
            case 10
                lbl = 'Sdc21';
            case 11
                lbl = 'Sdd22';
            case 12
                lbl = 'Sdc22';
            case 13
                lbl = 'Scd21';
            case 14
                lbl = 'Scc21';
            case 15
                lbl = 'Scd22';
            case 16
                lbl = 'Scc22';
            otherwise
                lbl = '???';
        end
    else
        switch ix
            case 1
                lbl = 'Sdd11';
            case 2
                lbl = 'Sdd12';
            case 3
                lbl = 'Sdc11';
            case 4
                lbl = 'Sdc12';
            case 5
                lbl = 'Sdd21';
            case 6
                lbl = 'Sdd22';
            case 7
                lbl = 'Sdc21';
            case 8
                lbl = 'Sdc22';
            case 9
                lbl = 'Scd11';
            case 10
                lbl = 'Scd12';
            case 11
                lbl = 'Scc11';
            case 12
                lbl = 'Scc12';
            case 13
                lbl = 'Scd21';
            case 14
                lbl = 'Scd22';
            case 15
                lbl = 'Scc21';
            case 16
                lbl = 'Scc22';
            otherwise
                lbl = '???';
        end
    end
else
    lbl = get_label@EMC.RF_Param(obj, ir, ic);
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net