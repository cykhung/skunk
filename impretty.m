function impretty(varargin)


%% Assign input arguments.
switch nargin
case 0
    f = gcf;
case 1
    f = varargin{1};
otherwise
    error('Invalid number of input arguments.');
end


%%
if numel(f.Children) ~= 1
    error('Only one child is allowed.');
end
if ~isa(f.Children, 'matlab.graphics.axis.Axes')
    error('Child must be axes.');
end


%%
c = f.Children.Children;
for n = 1:numel(c)
    if isa(c(n), 'matlab.graphics.primitive.Image')
        set(c(n), 'Interpolation', 'bilinear');
        set(f.Children, 'Units',    'normalized');
        set(f.Children, 'Position', [0 0 1 1]);
    end
end


%% Set figure's width and height.
p = f.Position;
for n = 1:numel(c)
    if isa(c(n), 'matlab.graphics.primitive.Image')
        p(3) = size(c(n).CData, 2);
        p(4) = size(c(n).CData, 1);
        break;
    end
end
M               = get(0, 'MonitorPositions');
minMonitorWidth = min(M(:,3));
% maxMonitorWidth = max(M(:,3));
minMonitorHeight = min(M(:,4));
% maxMonitorHeight = max(M(:,4));
if (p(3) > minMonitorWidth) || (p(4) > minMonitorHeight)
    scaleWidth  = minMonitorWidth  / p(3) * 0.8;    % 0.8 = fudge factor.
    scaleHeight = minMonitorHeight / p(4) * 0.8;
    scale       = min([scaleWidth scaleHeight]);
    p(3)        = p(3) * scale;
    p(4)        = p(4) * scale;
end


%% Set figure's bottom.
height = p(4);
margin = 100;
bottom = minMonitorHeight - height - margin;
p(2)   = bottom;


%% Set figure position.
f.Position = p;


%%
set(f.Children, 'Visible', 'on');
set(f.Children, 'XTick',   [])
set(f.Children, 'YTick',   [])
set(f.Children, 'Units',   'pixels');


%%
plotedit on


end


