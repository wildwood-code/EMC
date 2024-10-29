function [SM_SDD,SDC,SCD,SCC] = convert_to_mixed_mode(obj, is_legacy)
% CONVERT_TO_MIXED_MODE Convert 4-port single-ended S-parameters to mixed-mode
%   SM = obj.convert_to_mixed_mode()                 % extract 4-port SM
%   [SDD,SDC,SCD,SCC] = obj.convert_to_mixed_mode()  % extract all 4 2-port Sxy
%   [SDD,~] = obj.convert_to_mixed_mode()            % extract only SDD
%
%   Mixed-mode form includes differential-mode (DM) and
%   common-mode (CM) parameters and is used for measuring
%   differential-pair networks using a 4-port VNA.
%
%   The network is connected between Port1-Port2 to Port3-Port4
%     Port1 - Port2 <==NETWORK==> Port3 - Port4
%
%   Optional is_legacy argment specifies how the full mixed-mode
%   S-parameter matrix is organized:
%
%   The output S-parameters SM take the form (if is_legacy is false, default):
%      [ Sdd11 Sdd12 Sdc11 Sdc12;
%        Sdd21 Sdd22 Sdc21 Sdc22;
%        Scd11 Scd12 Scc11 Scc12;
%        Scd21 Scd22 Scc21 Scc22 ]
%   The output S-parameters SM take the form (if is_legacy is true):
%      [ Sdd11 Sdc11 Sdd12 Sdc12;
%        Scd11 Scc11 Scd12 Scc12;
%        Sdd21 Sdc21 Sdd22 Sdc22;
%        Scd21 Scc21 Scd22 Scc22 ]
%
%   Sdd = differential-mode S-parameters
%   Sdc = CM to DM mode conversion
%   Scd = DM to CM mode conversion
%   Scc = common-mode S-parameters
%
%   is_legacy has no effect if the individual matrices are extracted
%   (e.g. Sdd, Sdc, etc.)
%

if nargin<2
    is_legacy = false;
end

if obj.nPorts ~= 4
    error('This is only defined for 4-port S-parameters')
end

if obj.is_mixed
    % it is already mixed-mode and converting to mixed mode, do nothing
    SM = obj;

else
    % single-ended convert to mixed-mode
    if is_legacy
        % note, that the sqrt(2) is totally unnecessary (it divides out in the conversion)
        % I have only left it here as the original source included it
        M = [1 -1 0 0;1 1 0 0;0 0 1 -1;0 0 1 1]/sqrt(2);
    else
        M = [1 -1 0 0; 0 0 1 -1; 1 1 0 0; 0 0 1 1];
    end

    SM = EMC.S_Param(obj.Freq, obj.Data, obj.Impedance, obj.FScale);

    for i=1:SM.nPoints
        SM.Data(:,:,i) = M*SM.Data(:,:,i)/M;
    end

    SM.is_mixed = true;
    SM.is_legacy = is_legacy;
end

if nargout<2
    % full 4-port mixed-mode S-parameters
    SM_SDD = SM;
elseif SM.is_mixed
    [SM_SDD, SDC, SCD, SCC] = SM.extract();
else
    error('Only mixed-mode may be extracted to [Sdd, etc]')
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net