function [obj, Sdc, Scd, Scc] = convert(obj, varargin)
% CONVERT  Perform a variety of conversions on an RF Param (type, freq, unit)
%
%   Convert to another type of parameter:
%     obj = obj.convert(dest_type)
%     obj = obj.convert(dest_type, Z)
%  
%     dest_type may be 'Z', 'Y', 'H', 'G', 'ABCD', 'S', or 'T'
%     Z is only used when converting to/from S or T-parameters
%     Z is a positive, real scalar
%
%   Convert to mixed-mode S-parameters:
%     obj = obj.convert('mixed')             [ [Sdd], [Sdc]; [Scd], [Scc] ] order where [Sij] = [ M11, M12; M21, M22 ]
%     obj = obj.convert('mixed', 'legacy')   [ [M11], [M12]; [M21], [M22] ] order where [Mij] = [ Sdd, Sdc; Scd; Scc ]
%     [Sdd, Sdc, Scd, Scc] = obj.convert('mixed')
%
%     obj must be a 4-port S-parameter
%
%   Convert frequency unit:
%     obj = obj.convert(frequnit)
%  
%     frequnit may be 'Hz', 'kHz', 'MHz', or 'GHz'
%  
%   Convert to decibels:
%     obj = obj.convert(dbunit)
%  
%     dbunit may be 'dB', '+dB', or '-dB'   (with -dB, the data is negated)
%     only S-parameters may be converted to decibels
%  
%   Add adjustment/offset to decibels:
%     obj = obj.convert(dbadjust)
%  
%     dbadjust is a real scalar, obj must already be in decibels
%  
%   Multiple conversions:
%     Multiple conversions may be specified in a single call to Convert
%     Conversions will be performed in the order specified
%  
%     Example:
%       % convert to S parameters with 50 ohm impedance, scaled to 'MHz',
%       % expressed in decibel loss, with an adjustment of +6.0 dB
%       obj = obj.convert('S', 50, 'MHz', '-dB', 6.0)
%
%   See also RF_PARAM

is_mixed = false;
is_legacy = false;
is_skip_next = false;
is_error = false;
N = length(varargin);

for idx = 1:N
    if ~is_skip_next
        arg = varargin{idx};
        if ischar(arg) || isstring(arg)
            switch upper(arg)
                case { 'Z', 'Y', 'H', 'G', 'ABCD', 'S', 'T' }
                    if idx<N && isscalar(varargin{idx+1}) && varargin{idx+1}>0
                        % passing impedance, skip next
                        obj = convert_param(obj, arg, varargin{idx+1});
                        is_skip_next = true;
                    else
                        obj = convert_param(obj, arg);
                    end
                case { 'HZ', 'KHZ', 'MHZ', 'GHZ', 'DB', '+DB', '-DB' }
                    obj = convert_to(obj, arg);
				case { 'LEGACY' }
					is_legacy = true;
				case { 'MIXED' }
					is_mixed = true;
                otherwise
                    is_error = true;
            end
        elseif isscalar(arg) && isreal(arg)
            obj = convert_to(obj, arg);
        else
            is_error = true;
        end

        if is_error
            error('Unable to perform the specified conversion')
        end
    else
        % skipping the impedance argument
        is_skip_next = false;
    end
end

if is_mixed
	if nargout>1
		[Sdd, Sdc, Scd, Scc] = obj.convert_to_mixed_mode(is_legacy);
		obj = Sdd;
	else
		obj = obj.convert_to_mixed_mode(is_legacy);
	end
elseif nargout>1
	error('Multiple output arguments is only compatible with ''mixed'' conversion')
end

end


% perform conversion between parameter types
function obj = convert_param(obj, dest_type, Z)

if ~strcmp(obj.Unit, 'complex')
    error('Only complex data may be converted to other parameter types')
end

dest_type = upper(dest_type);
switch dest_type
    case { 'Z', 'Y', 'S' }
    case { 'H', 'G', 'ABCD', 'T' }
        if obj.nPorts ~=2
            error('Conversion to %s-Parameters is only valid for 2-ports', dest_type)
        end
    otherwise
        error('Unrecognized dest_type')
end

if nargin<3
    switch obj.Type
        case { 'S', 'T' }
            Z = obj.Impedance;
        otherwise
            Z = 50;
    end
end

Pout = EMC.convert_n_port(obj.Type, dest_type, obj.Data, Z);

% save these for later
freq_unit = obj.UnitF;
freq_scale = obj.Fscale;

switch dest_type
    case 'Z'
        obj = EMC.Z_Param(obj.Freq, Pout);
    case 'Y'
        obj = EMC.Y_Param(obj.Freq, Pout);
    case 'H'
        obj = EMC.H_Param(obj.Freq, Pout);
    case 'G'
        obj = EMC.G_Param(obj.Freq, Pout);
    case 'S'
        obj = EMC.S_Param(obj.Freq, Pout, Z);
    case 'T'
        obj = EMC.T_Param(obj.Freq, Pout, Z);
    case 'ABCD'
        obj = EMC.ABCD_Param(obj.Freq, Pout);
end

obj.UnitF = freq_unit;
obj.Fscale = freq_scale;

end % function convert_param


% perform conversion of frequency or unit scale, or adjustment to dB
function obj = convert_to(obj, conv_to)

isConvertFreq = false;
isConvertMag = false;
isAdjustMag = false;

if ischar(conv_to) || isstring(conv_to)
    switch lower(conv_to)
        case 'hz'
            isConvertFreq = true;
            f_to = 1;
            unit_to = 'Hz';
        case 'khz'
            isConvertFreq = true;
            f_to = 1e3;
            unit_to = 'kHz';
        case 'mhz'
            isConvertFreq = true;
            f_to = 1e6;
            unit_to = 'MHz';
        case 'ghz'
            isConvertFreq = true;
            f_to = 1e9;
            unit_to = 'GHz';
        case { 'db', '+db' }
            isConvertMag = true;
            dB_adj = 0;
            dB_scale = 1;
            unit_to = 'dB';
        case { '-db' }
            isConvertMag = true;
            dB_adj = 0;
            dB_scale = -1;
            unit_to = 'dB';
    end
elseif isscalar(conv_to) && isreal(conv_to)
    % simply adjust magnitude by given amount without chaning unit label
    isAdjustMag = true;
    dB_adj = conv_to;
end

if isConvertMag
    % adjust magnitude by adjustment and change unit
    if ~strcmp(obj.Type, 'S')
        error('Unable to convert non-S-parameters to dB')
    end
    switch lower(obj.Unit)
        case 'db'
            obj.Data = dB_scale*obj.Data + dB_adj;
        case 'complex'
            obj.Data = dB_scale*20*log10(abs(obj.Data)) + dB_adj;
        otherwise
            error('Unable to convert from ''%s'' to decibels', obj.Unit)
    end
    obj.Unit = unit_to;
elseif isAdjustMag
    switch obj.Unit
        case 'complex'
            error('Please convert to decibels before applying adjustment')
    end
    obj.Data = obj.Data + dB_adj;
elseif isConvertFreq
    % scale frequency to new scale and change frequency unit
    f_from = obj.Fscale;
    obj.Freq = obj.Freq*f_from/f_to;
    obj.Fscale = f_to;
    obj.UnitF = unit_to;
else
    if ischar(conv_to)
        error('Unable to convert to ''%s''', conv_to)
    else
        error('Unable to perform the specified conversion')
    end
end

end % function convert_to

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net