function [isChanged, segs] = Resegment(S1, S2, logF, isAbove)

% 'segs' will be 1 to 4 segments
%
% S1, S2 are input segments
%
% segment format: [f1 f2; L1 L2]
% assumptions: f1>f2 in each segment
%
% isAbove = flag true = limit is gt/ge, false = limit is lt/le
%

narginchk(2,4)
if nargin<4
    isAbove = false;
end
if nargin<3
    logF = false;
end

% quick test to see if they don't overlap at all
if S1(1,1)>=S2(1,2) || S2(1,1)>=S1(1,2)
    % there is no overlap, just return both, with no change
    isChanged = false;
    segs = { S1, S2 };
    return
else
    % there is overlap, so a change will necessarily occur
    isChanged = true;
    % processing continues below
end

% convert log scales to linear for this operation (will convert back when done)
% negate the limit if isAbove flag is set (simplifies isAbove limit logic)
if logF
    S1(1,:) = log(S1(1,:));
    S2(1,:) = log(S2(1,:));
end
if isAbove
    S1(2,:) = -S1(2,:);
    S2(2,:) = -S2(2,:);
end

% get the boundary frequencies for S1, S2
f1 = S1(1,1);
f2 = S1(1,2);
f3 = S2(1,1);
f4 = S2(1,2);

% calculate slopes and line equations for S1, S2
L1 = S1(2,1);
L2 = S1(2,2);
L3 = S2(2,1);
L4 = S2(2,2);
m1 = (L2-L1)/(f2-f1);
line1 = @(f) L1+(f-f1).*m1;
m2 = (L4-L3)/(f4-f3);
line2 = @(f) L3+(f-f3).*m2;

% check to see if the lines intersect
if m1==m2
    % there is not intersection, so the point set is just the segment ends
    X = [f1, f2, f3, f4];
else
    % the intersection may not be within the overlapped range
    % find the intersection
    fi = (L3-L1+m1*f1-m2*f3)/(m1-m2);
    
    % see if it is is within a range that intersects
    if fi<f3 || fi<f1 || fi>f2 || fi>f4
        % the point set does not include the intersection
        X = [f1, f2, f3, f4];
    else
        % the point set includes the intersection
        X = [f1, f2, f3, f4, fi];
    end
end

% sort these from smallest frequency to largest
X = sort(X);

% start a blank list of segments
segs = cell(1,0);

% last chosen: 0 = none (first call), 1 = S1, 2 = S2
last_chosen = 0;

% process each of the inter-segments
for i=1:length(X)-1
    % get the endpoints of the inter-segment and calculate the midpoint
    x1 = X(i);
    x2 = X(i+1);
    xm = 0.5*(x1+x2);
    
    % test to see if the midpoint is within the bounds of S1 and S2
    isS1 = f1<xm && xm<f2;
    isS2 = f3<xm && xm<f4;
    
    % logic to choose which limit line is lower
    if isS1 && isS2
        if line1(xm)==line2(xm) && m1==0 && m2==0
            % when they are equal and flat, chose the last one if one has
            % already been chosen
            if chosen==0
                chosen = 1;
            else
                chosen = last_chosen;
            end
        elseif line1(xm)<=line2(xm)
            chosen = 1;
        else
            chosen = 2;
        end
    elseif isS1
        chosen = 1;
    elseif isS2
        chosen = 2;
    else
        % we may hit this if combining two identical segments
        % just choose #1
        chosen = 1;
        %error('DEBUG: we should never hit this statement')
    end
    
    if chosen==last_chosen
        % extend the last segment
        Si = segs{end};
        Si(1,2) = x2;
        switch chosen
            case 1
                Si(2,2) = line1(x2);
            case 2
                Si(2,2) = line2(x2);
        end
        segs{end} = Si;
    else
        % add a new segment
        switch chosen
            case 1
                Si = [x1 x2;line1(x1) line1(x2)];
            case 2
                Si = [x1 x2;line2(x1) line2(x2)];
        end
        segs{end+1} = Si; %#ok<AGROW>
    end
        
    last_chosen = chosen;
end


for i=1:length(segs)
    % convert back to original scales
    % ORDER IS IMPORTANT HERE, REVERSE THE ORIGINAL ORDER
    Si = segs{i};
    if isAbove
        Si(2,:) = -Si(2,:);
    end
    if logF
        Si(1,:) = exp(Si(1,:));
    end
    segs{i} = Si;
end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net