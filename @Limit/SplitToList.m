function segments = SplitToList(varargin)
% SPLITTOLIST   Split limit specification to a list of segments
%
% format of each argument is:
%    [freq;limit] where freq, limit are row vectors
%
% output is a cell array of [fstart fend;limstart limend]

narginchk(1,inf)

L = varargin{1};

if nargin>1
    % concatenate the limit lists. separating them by NaN's
    for i=2:nargin
        L = [ L , [NaN;NaN] , varargin{i} ]; %#ok<AGROW>
    end
end

% break into list of segments
%   segments may be separated by NaN or contiguous
%   initially segments separated by NaN need not be in order
[~,Npoints] = size(L);
segments = cell(1,0);
fstart = zeros(1,0);

i = 1;
while i<=Npoints
    if isnan(L(1,i))
        % skip to the next
        i = i + 1;
    else
        if i==Npoints
            % at the end - we are done
            i = Npoints + 1; % next loop will exit
        elseif isnan(L(1,i+1))
            % end of this segment, continue to next
            i = i + 2;
        else
            f1 = L(1,i);
            f2 = L(1,i+1);
            if f2<=f1
                error('Frequency values for a segment are out-of-order')
            end
            seg = L(:,i:i+1);
            segments{end+1} = seg; %#ok<AGROW>
            fstart(end+1) = f1; %#ok<AGROW>
            i = i + 1;
        end  
    end 
end

% sort each segment by start frequency
[~,idx] = sort(fstart);
segments = segments(idx);



