% CONVERTTO Convert the frequency scaling or unit of the trace
%   obj = CONVERTTO(obj, varargin)
%   obj = obj.CONVERTTO(varargin)
%
%   varargin = freq unit ("Hz", "kHz", "MHz", "GHz")
%              time unit ("s", "ms", "us", "ns", "ps", "min")
%              mag unit  ("dB", "dBm", "dBuV", etc)
%              detector  ("pk", "qpk", "av", "npk", "samp")
%              offset    (numeric scalar)
%
%   varargin = { frequnit, magunit, detector, offset }
%                any of the above in no order
%
%   No adjust is made for mag unit conversion. Please do this manually
%   using + or - to add/subtract a scalar value from the trace magnitude
%
%
%   See also: TRACE TRACE/PLUS TRACE/MINUS

% Kerry S. Martin, martin@wild-wood.net

function obj = ConvertTo(obj,varargin)

for i=1:length(varargin)
    
    arg = varargin{i};
    
    if isnumeric(arg) && isscalar(arg)
        % offset
        obj.y_offs = arg;
    elseif EMC.Trace.is_charstr(arg)
        [~,arg] = EMC.Trace.is_charstr(arg);
        % unit, frequency unit, or detector
        if obj.dom==EMC.Domains.FrequencyDomain && EMC.Trace.is_unitf(arg)
            [~,unitf,f_to] = EMC.Trace.is_unitf(arg);
            % Convert/scale frequency unit
            f_from = obj.scale_absc;
            obj.x = obj.x*f_from/f_to;
            obj.scale_absc = f_to;
            obj.unit_absc = unitf;
        elseif obj.dom==EMC.Domains.TimeDomain && EMC.Trace.is_unitt(arg)
            [~,unitt,t_to] = EMC.Trace.is_unitt(arg);
            % Convert/scale frequency unit
            t_from = obj.scale_absc;
            obj.x = obj.x*t_from/t_to;
            obj.scale_absc = t_to;
            obj.unit_absc = unitt;            
        elseif EMC.Trace.is_unit(arg)
            [~,unit] = EMC.Trace.is_unit(arg);
            obj.unit_mag = unit;
        elseif EMC.Trace.is_detector(arg)
            [~,det] = EMC.Trace.is_detector(arg);
            for id=1:length(obj.det)
                obj.det{id} = det;
            end
        else
            throw(MException('EMC:Trace:Setting', 'Unrecognized setting'))
        end
    else
        throw(MException('EMC:Trace:Setting', 'Unrecognized setting'))
    end
end
