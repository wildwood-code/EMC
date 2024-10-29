function S = convert_from_mixed_mode(obj)
% CONVERT_FROM_MIXED_MODE Convert 4-port mixed-mode S-parameters to single-ended
%   S = obj.convert_from_mixed_mode()
%
%   Mixed-mode form includes differential-mode (DM) and
%   common-mode (CM) parameters and is used for measuring
%   differential-pair networks using a 4-port VNA.
%
%   The network is connected between Port1-Port2 to Port3-Port4
%     Port1 - Port2 <==NETWORK==> Port3 - Port4
%

% TODO: future improvements
%       allow other combinations of SE port:
%          '1234' '1-2,3-4', '12 34' etc. default
%          '1324' etc could be used as an alternate combination

if obj.nPorts ~= 4
    error('This is only defined for 4-port S-parameters')
end

if obj.is_mixed
    % it is mixed-mode but converting to single-ended
    S = EMC.S_Param(obj.Freq, obj.Data, obj.Impedance, obj.FScale);

    if obj.is_legacy
        % note, that the sqrt(2) is totally unnecessary (it divides out in the conversion)
        % I have only left it here as the original source included it
        M = inv([1 -1 0 0;1 1 0 0;0 0 1 -1;0 0 1 1]/sqrt(2));
    else
        M = inv([1 -1 0 0; 0 0 1 -1; 1 1 0 0; 0 0 1 1]);
    end
    for i=1:S.nPoints
        S.Data(:,:,i) = M*S.Data(:,:,i)/M;
    end
    S.is_mixed = false;
    S.is_legacy = false;
else
    % single-ended already
    S = obj;
end

end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net