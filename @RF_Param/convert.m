function [obj, Sdc, Scd, Scc] = convert(obj, varargin)
% CONVERT  Perform a variety of conversions on an RF Param (type, freq)
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
%   Multiple conversions:
%     Multiple conversions may be specified in a single call to Convert
%     Conversions will be performed in the order specified
%  
%     Example:
%       % convert to S parameters with 50 ohm impedance, scaled to 'MHz'
%       obj = obj.convert('S', 50, 'MHz')
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
			m = regexpi(arg, '^(?:[A-Z.]+\.)?(Z|Y|H|G|S|T|ABCD)(?:_param)?$', 'tokens');
			if ~isempty(m)
				arg = m{1}{1};
			end
            switch upper(arg)
                case { 'Z', 'Y', 'H', 'G', 'ABCD', 'S', 'T' }
                    if idx<N && isscalar(varargin{idx+1}) && varargin{idx+1}>0
                        % passing impedance, skip next
                        obj = convert_param(obj, arg, varargin{idx+1});
                        is_skip_next = true;
                    else
                        obj = convert_param(obj, arg);
                    end
                case { 'HZ', 'KHZ', 'MHZ', 'GHZ' }
                    obj = convert_to(obj, arg);
				case { 'LEGACY' }
					is_legacy = true;
				case { 'MIXED' }
					is_mixed = true;
                otherwise
                    is_error = true;
            end
        elseif isscalar(arg) && isreal(arg)


            %%%% TODO:::: this may no longer apply (dB adjust???)
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
freq_scale = obj.FScale;

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

obj.FScale = freq_scale;

end % function convert_param


% perform conversion of frequency or unit scale, or adjustment to dB
function obj = convert_to(obj, conv_to)

isConvertFreq = false;

if ischar(conv_to) || isstring(conv_to)
    switch lower(conv_to)
        case 'hz'
            isConvertFreq = true;
            f_to = 1;
        case 'khz'
            isConvertFreq = true;
            f_to = 1e3;
        case 'mhz'
            isConvertFreq = true;
            f_to = 1e6;
        case 'ghz'
            isConvertFreq = true;
            f_to = 1e9;
    end
end

if isConvertFreq
    % scale frequency to new scale and change frequency unit
    f_from = obj.FScale;
    obj.Freq = obj.Freq*f_from/f_to;
    obj.FScale = f_to;
else
    if ischar(conv_to)
        error('Unable to convert to ''%s''', conv_to)
    else
        error('Unable to perform the specified conversion')
    end
end

end % function convert_to

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net