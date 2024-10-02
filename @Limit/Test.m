function [tf, margin, failures] = Test(obj, freq, data)
% TEST  Determine if the data meets the limit
%   [tf, margin, failures] = obj.Test(freq, data)
%   [tf, margin, failures] = obj.Test(Trace)
%   [tf, margin, failures] = obj.Test(RF_Param)
%
%   freq may be a scalar or a vector of frequencies
%   freq is in Hz
%
%   margin is the closest delta between the data and limit
%   margin is positive if it meets the limit or negative if not
%   failures is a struct of freq, data points that did not meet the limit

narginchk(2,3)

% convert RF_Param or Trace to freq, data
% TODO: this is work in progress - need to index param or trace, etc.
if isa(freq, 'RF_Param')
    warning('RF_Param support is experimental')
    if nargin>2
        warning('Ignoring data after RF_Param')
    end
    P = freq;
    freq = P.FreqHz;
    data = 20*log10(abs(P.Data));  % convert complex data to dB
elseif isa(freq, 'Trace')
    warning('Trace support is experimental')
    if nargin>2
        warning('Ignoring data after Trace')
    end
    T = freq;
    freq = T.FreqHz;
    data = T.Data;
end

% freq must be scalar or vector
if ~isvector(freq)
    error('freq must be a scalar or vector')
end

if ~isvector(data) || length(data)~=length(freq)
    error('data must be a scalar or vector and match the length of freq')
end

% get the limit at the frequencies and pass/fail criteria
lim = obj.LimitAt(freq);
pc = lower(obj.PassCriteria);

% compute margin delta vector
switch pc
    case { 'gt', 'ge' }
        del = data-lim;
    otherwise
        del = lim-data;
end

margin = min(del);

% compute pass/fail
switch pc
    case { 'ge', 'le' }
        % 0 margin is a pass
        if margin>=0
            tf = true;
        else
            tf = false;
        end

    otherwise
        % 0 margin is a fail
        if margin>0
            tf = true;
        else
            tf = false;
        end
end

% compute failed data points
failures = struct('F', [], 'D', []);
if ~tf && nargout >=3
    for i=1:length(freq)
        switch pc
            case { 'ge', 'le' }
                if del(i)<0
                    failures.F(end+1) = freq(i);
                    failures.D(end+1) = del(i);
                end
            otherwise
                if del(i)<=0
                    failures.F(end+1) = freq(i);
                    failures.D(end+1) = del(i);
                end
        end
    end
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net