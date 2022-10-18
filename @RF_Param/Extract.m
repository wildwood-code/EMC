function [P1,P2] = Extract(obj, n1, n2)
% EXTRACT   Extract RF parameter data from the object to an array
%   P = obj.Extract(n1, n2)
%   P = obj.Extract(id)
%   [F,P] = obj.Extract(n1, n2)
%   [F,P] = obj.Extract(id)
%
%    n1, n2 are indices into the parameter set (e.g., 1, 2 for S12)
%    id is an abbreviated index (e.g., 12, '12', or "12", 'S12' for S12)
%    id may be 'A', 'B', 'C', or 'D' to extract ABCD parameter

narginchk(2,3)
if nargin==2
    P = EMC.extract_param(obj.Data, n1);
else
    P = EMC.extract_param(obj.Data, n1, n2);
end
if nargout<2
    P1 = P;
else
    P1 = obj.Freq;
    P2 = P;
end
end

% Copyright (c) 2022, Kerry S. Martin, martin@wild-wood.net