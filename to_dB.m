function dB = to_dB(x, quantity)
% TO_DB  Convert quantity to decibels
%   dB = TO_DB(rp)       % default is root power quantity
%   dB = TO_DB(p, 'p')   % power quantity
%   dB = TO_DB(rp, 'rp') % root-power quantity
%
% See also: TO_DBP  TO_DBRP

narginchk(1,2)

if nargin<2
    isRootPower = true;
elseif ischar(quantity)
    switch lower(quantity)
        case { 'root-power', 'root', 'rp', 'root power' }
            isRootPower = true;
        case { 'power', 'p' }
            isRootPower = false;
        otherwise
            error('unknown quantity ''%s''', quantity)
    end
else
    error('''quantity'' must be ''power'' or ''root-power''')
end

if isRootPower
    % root-power quantity
    dB = 20*log10(abs(x));
else
    % power quantity
    dB = 10*log10(abs(x));
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net