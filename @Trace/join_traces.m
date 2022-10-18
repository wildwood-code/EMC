% JOIN_TRACES join two traces into a continuous frequency span
%   [freq, data] = JOIN_TRACES(freq1, data1, freq2, data2)
%
%   Traces are joined into a continuous frequency span.
%   If the end element overlaps, it is averaged between the two data sets
%
%   See also: TRACE

% Kerry S. Martin, martin@wild-wood.net
function [freq, data] = join_traces(freq1, data1, freq2, data2)

if isempty(freq1)
    freq = freq2;
    data = data2;
elseif isempty(freq2)
    freq = freq1;
    data = daa1;
elseif freq1(end,1)==freq2(1,1)
    %  average the overlap
    data2(1,:) = 0.5*(data1(end,:)+data2(1,:));
    freq = [freq1(1:end-1,1);freq2(1:end)];
    data = [data1(1:end-1,:);data2(1:end,:)];
else
    freq = [freq1; freq2];
    data = [data1; data2];
end