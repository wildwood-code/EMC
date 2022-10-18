function h = SmithChart(varargin)
% SMITHCHART   Impedance or admittance Smith chart
%  SmithChart               % blank impedance chart
%  SmithChart('y')          % blank admittance chart
%  SmithChart(R,X)          % impedance chart plotting R+jX
%  SmithChart(R,X,'z')      % 'z' is optional (impedance is default)
%  SmithChart(G,B,'y')      % admittance chart plotting G+jB
%  SmithChart(Z)            % impedance chart with complex Z
%  SmithChart(Y,'y')        % admittance chart with complex Y
%  SmithChart(R,X,'b-','LineWidth',2)    % plot parameters may be passed
%
%  If a single R,X (or Z, or G,B, or Y) is provided, it is plotted as a
%  red 'x' by default, or with a different line/point stle if passed as an
%  argument.
%
%  Only one set of data may be plotted in a given call to SmithChart()
%  However, multiple sets may be added to the same chart using "hold on"
%  Example:
%     hold off
%     SmithChart(R1,X1)    % first set of data is plotted default as 'r-'
%     hold on
%     SmithChart(R2,X2,'b-')
%     SmithChart(R3,X3,'g-')
%
%  h = SmithChart(...)     % returns handle to figure

narginchk(0,inf)

isImpedance = true;

if ~isempty(varargin)
    i = 1;
    
    while i<=numel(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case { 'z', 'impedance' }
                    isImpedance = true;
                    varargin = varargin(i+1:end);
                case { 'y', 'admittance' }
                    isImpedance = false;
                    varargin = varargin(i+1:end);
                otherwise
                    i = i + 1;
            end
        else
            i = i + 1;
        end
    end
end

if isempty(varargin)
    R = [];
    X = [];
elseif numel(varargin)==1
    if isfloat(varargin{1})
        R = varargin{1};
        varargin = cell(0,0);
        if isreal(R)
            X = zeros(size(R));
        else
            % order is important here
            X = imag(R);
            R = real(R);
        end
    else
        % must pass the rest to plot
        R = [];
        X = [];
    end
else  % numel(varargin)>=2
    if isfloat(varargin{1})
        R = varargin{1};
        varargin = varargin(2:end);
        if isreal(R)
            if isfloat(varargin{1}) && isreal(varargin{1})
                X = varargin{1};
                varargin = varargin(2:end);
            else
                X = zeros(size(R));
            end
        else
            % order is important here
            X = imag(R);
            R = real(R);
        end
    end
end

if length(R) ~= length(X) || numel(R) ~= numel(X)
    error('R and X must be same size')
end

% use light lines
gray_line = [1 1 1]*0.8;
gray_weight = 0.25;
dark_gray_line = [1 1 1]*0.5;
dark_gray_weight = 0.25;

hold_state = ishold;

if ~ishold
    % only plot the Smith chart grid if the current plot is not HOLD

    Rcir = [0.1:.1:.9 1.2:.2:2 3:1:5 20 50];
    for i=1:length(Rcir)
        [x,y] = circle_r(Rcir(i),10);
        if isImpedance
            plot(x,y,'Color',gray_line,'LineWidth',gray_weight)
        else
            plot(-x,-y,'Color',gray_line,'LineWidth',gray_weight)
        end
        if i==1
            hold on
        end
    end
    
    Rcir = [0 1 10];
    for i=1:length(Rcir)
        [x,y] = circle_r(Rcir(i));
        if isImpedance
            plot(x,y,'Color',dark_gray_line,'LineWidth',dark_gray_weight)
        else
            plot(-x,-y,'Color',dark_gray_line,'LineWidth',dark_gray_weight)
        end
    end
    
    Xarc = [ -50 -20 -5:1:-2 -1.8:.2:-1.2 -.9:.1:-.1 .1:.1:.9 1.2:.2:1.8 2:1:5 20 50];
    for i=1:length(Xarc)
        [x,y] = arc_x(Xarc(i),10);
        if isImpedance
            plot(x,y,'Color',gray_line,'LineWidth',gray_weight)
        else
            plot(-x,-y,'Color',gray_line,'LineWidth',gray_weight)
        end
    end
    
    Xarc = [ -10 -1 0 1 10];
    for i=1:length(Xarc)
        [x,y] = arc_x(Xarc(i));
        if isImpedance
            plot(x,y,'Color',dark_gray_line,'LineWidth',dark_gray_weight)
        else
            plot(-x,-y,'Color',dark_gray_line,'LineWidth',dark_gray_weight)
        end
    end
    
    % keep the circle aspect ratio, remove the grids, and embellish the plot
    axis equal
    axis([-1 1 -1 1])
    hax = gca;
    hax.XAxis.Visible = 'off';
    hax.YAxis.Visible = 'off';
    %title('Smith Chart')
    
    hfg = gcf;
    if isImpedance
        hfg.Tag = 'impedance';
    else
        hfg.Tag = 'admittance';
    end
else
    % figure is held, check to see if tag matches;
    hfg = gcf;
    switch lower(hfg.Tag)
        case ''
            warning('Plotting on a chart that is not tagged as a Smith chart')
        case 'impedance'
            if ~isImpedance
                warning('Plotting admittance on an impedance chart')
            end
        case 'admittance'
            if isImpedance
                warning('Plotting impedance on an admittance chart')
            end
    end
end

if ~isempty(R)
    % Plot the specified data. First, transform it into cartesian points
    [x,y] = smith_transform(R,X);
    
    N = length(x);
    
    % clear any that are outside of the circle. NaN will break the line.
    for i=1:N
        if x(i)^2 + y(i)^2 > 1
            x(i) = NaN;
            y(i) = NaN;
        end
    end
    
    if ~isImpedance
        % change to admittance plot
        x = -x;
        y = -y;
    end
    
    if isempty(varargin)
        % use default plot parameters red line or red x
        if N==1
            h = plot(x,y,'rx');
        else
            h = plot(x,y,'r-');
        end
    else
        % use given plot parameters
        h = plot(x,y,varargin{:});
    end
end

if ~hold_state
    hold off
end

if nargout==0
    clear h
end

end % function SmithChart


% ------------------------------
% Local functions
% ------------------------------

function [x,y] = circle_r(R, Xend)
% CIRCLE_R  calculate circles of constant resistance
%  (x - R/(R+1))^2 + y^2 == (1/(R+1))^2
%    radius = 1/(R+1)
%    center = (R/(R+1), 0)

narginchk(0,2)
if nargin<2
    Xend = Inf;
else
    Xend = abs(Xend);
end
if nargin<1
    R = 0;
end

% radius = 1/(R+1)
% center = (R/(R+1), 0)
radius = 1/(R+1);
xcenter = R/(R+1);

% find the termination (end) angle
if isfinite(Xend)
    [x1,y1] = smith_intersection(R,Xend);
    theta1 = atan2(y1,x1-xcenter);
else
    theta1 = 0;
end

% get the length of the arc and use it to find the number of segments
% required to keep it from looking segmented
len_arc = 4*(pi-theta1)*radius;
nsegs = max(32, ceil(256/(len_arc/(2*pi))));
del_ang = 2*(pi-theta1)/nsegs;

% preallocate the solution vectors
x = zeros(1,nsegs+1);
y = zeros(1,nsegs+1);

% calculate the endpoints of the segments
for i=1:nsegs+1
    ang = -theta1 - del_ang*(i-1);
    xx = xcenter + radius*cos(ang);
    yy = radius*sin(ang);
    x(i) = xx;
    y(i) = yy;
end

end


function [x,y] = arc_x(X, Rstart)
% ARC_X  calculate arcs of constant reactance
%  (x - 1)^2 + (y - 1/X)^2 == (1/X)^2

narginchk(0,2)
if nargin<2
    Rstart = Inf;
end
if nargin<1
    X = 0;
end

% length of arc
if X==0
    % special case is a straight line when X==0
    [x1,y1] = smith_intersection(Rstart, 0);
    x = [x1 -1];
    y = [y1 0];
elseif isfinite(X)
    % two intersections with circle for R=0
    [x1, y1] = smith_intersection(Rstart, abs(X));
    [x2, y2] = smith_intersection(0, abs(X));
    
    % radius is |1/X|
    % center is at (1,1/X), but consider X>0 now and we'll compensate for X < 0 later
    radius = abs(1/X);
    x_cen = 1;
    y_cen = abs(1/X);
    
    % calculate the angles of intersection
    theta2 = atan2(y2-y_cen, x2-x_cen);
    theta1 = atan2(y1-y_cen, x1-x_cen);
    theta = theta1-theta2;
    
    % coerce theta to be in the range 0 <= theta < 2*pi
    while theta < 0
        theta = theta + 2.*pi;
    end
    while theta >= (2*pi)
        theta = theta - 2.*pi;
    end
    
    % if nsegs has not been specified, calculate it based upon arc length
    % longer arc -> more segments, shorter arc -> fewer segments
    arc_len = theta*abs(1/X);
    nsegs = max(16, ceil(arc_len*64));

    % preallocate the solution vectors
    x = zeros(1,nsegs+1);
    y = zeros(1,nsegs+1);
    
    if theta2-theta1<pi
        del_theta = (theta2-theta1)/nsegs;
    else
        del_theta = (theta2-theta1-2*pi)/nsegs;
    end
    
    % now, compensate for negative reactance
    if X>=0
        theta = theta1;
    else
        theta = -theta1;
        del_theta = -del_theta;
        y_cen = -y_cen;
    end
    
    % calculate the endpoints of the segments
    for i=1:nsegs+1
        xx = x_cen + radius*cos(theta);
        yy = y_cen + radius*sin(theta);
        x(i) = xx;
        y(i) = yy;
        theta = theta + del_theta;
    end
else % X is +/- Inf
    % solution is a single point at (1,0)... just return nothing
    x = [];
    y = [];
end

end


function [x,y] = smith_intersection(R,X)
% one intersection is always at (x,y) = (1,0)
% this calculates the other for a given R and X

if R<0
    R = 0;
end

den = R.^2 + 2.*R + X.^2 + 1;

if isinf(den)
    x = 1;
    y = 0;
else
    x = (R.^2 + X.^2 - 1)/den;
    y = 2.*X./den;
end

end

function [x,y] = smith_transform(R, X)
% SMITH_TRANSFORM  transform R+jX into cartesian coordinates on the Smith chart
%   x = (R^2 + X^2 -1)/(R^2 + 2*R + X^2 +1)
%   y = 2*X/(R^2 + 2*R + X^2 +1)

% preallocate the solution vectors
N = numel(R);
x = zeros(1,N);
y = zeros(1,N);

% calculate each R,X pair
for i=1:N
    rr = R(i);
    xx = X(i);
    den = rr^2 + 2*rr + xx^2 + 1;
    if isfinite(den)
        x(i) = (rr^2 + xx^2 - 1)/den;
        y(i) = (2*xx)/den;
    elseif den==0
        x(i) = NaN;
        y(i) = NaN;
    else
        x(i) = 1;
        y(i) = 0;
    end
end

end

% Copyright (c) 2018, Kerry S. Martin, martin@wild-wood.net
