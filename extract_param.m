function D=extract_param(P, n1, n2)
% EXTRACT_PARAM Extracts the given network parameter
%   n1, n2 may specify coordinate like 2,1 (for S21)
%   n1 may specify as a decimal 21 => S21
%   n1 may specify as a string '21' => S21
%   n1 may specify as a string 'S21' => S21 (or G21, Y21, H21, etc)
%   n1 may specify as a string 'A', 'B', 'C', 'D' only valid for 2x2
%      'A' = '11', 'B' = '12', 'C' = '21', 'D' = '22'
%
%   P is a N x N x L array, where L is the number of ports
%   and M is the number of data points (1 <= N <= 4)
%
%   The result D is returned as a row vector
%
%   examples:
%     P is a 2 x 2 x 1000 array of S-parameters 
%     extract_param(P, 2, 1) => ans = P(2,1,:)
%     extract_param(P, '12') => ans = P(1,2,:)
%     extract_param(P, 'S11') => ans = P(1,1,:)

narginchk(2,3)
if nargin<3
    spec = n1;
    if isnumeric(spec)
        n1 = floor(spec/10);
        n2 = spec-10*n1;
    elseif ischar(spec) || isstring(spec)
        spec = upper(convertStringsToChars(spec));
        idx = regexp(spec, '^(?:S|Z|Y|G|H|T|S[CD]{2})?([1-4])([1-4])$', 'tokens', 'ONCE');
        if ~isempty(idx)
            n1 = idx{1}-'0';
            n2 = idx{2}-'0';
        elseif regexp(spec, '^[ABCD]$', 'ONCE')
            switch spec
                case 'A'
                    n1 = 1;
                    n2 = 1;
                case 'B'
                    n1 = 1;
                    n2 = 2;
                case 'C'
                    n1 = 2;
                    n2 = 1;
                case 'D'
                    n1 = 2;
                    n2 = 2;
                otherwise
                    error('Unable to interpret parameter coordinate')
            end
                    
        end
    else
        error('Unable to interpret parameter coordinate')
    end
end

if n1<=0 || n1>4 || n2<=0 || n2>4
    error('Index must be between 1 and 4')
end

[R,C,L] = size(P);
if R<1 || R>4 || R~=C || L<=0
    error('Invalid dimensions for P. Must be N x N x L')
end

if n1>R || n2>R
    error('Specified parameter coordinate exceeds parameter dimension')
end

D = zeros(1,L);
for i=1:L
   D(1,i) = P(n1, n2, i); 
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net