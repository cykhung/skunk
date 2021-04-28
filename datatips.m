function varargout = datatips(varargin)

%%
%       SYNTAX: datatips(fig,   x);
%               datatips(ax,    x);
%               datatips(lines, x);
%
%               datatips(fig,   x, y);
%               datatips(ax,    x, y);
%               datatips(lines, x, y);
%
%               datatips(fig,   P);
%               datatips(ax,    P);
%               datatips(lines, P);
%
%               datatips(fig,   P, xrange);
%               datatips(ax,    P, xrange);
%               datatips(lines, P, xrange);
%
%               T = datatips(fig);
%               T = datatips(ax);
%               T = datatips(lines);
%
%  DESCRIPTION: Create or query datatip(s).
%
%        INPUT: - fig (Figure or real double)
%                   Single figure object or figure window number. If the figure 
%                   window contains more than one line, then this function will
%                   create or query datatip(s) on all lines.
%
%               - ax (Axes)
%                   Single axes object. If the axes contains more than one line,
%                   then this function will create or query the datatip(s) on
%                   all lines.
%
%               - lines (N-D array of Line)
%                   Line object(s). Input line objects can belong to different
%                   axes in different figure windows.
%
%               - P (char)
%                   If P = 'max', then one datatip will be placed at the maximum
%                   y-value. To put datatips on the largest two y-values, use
%                   'max2'.
%                   If P = 'min', then one datatip will be placed at the minimum
%                   y-value.  To put datatips on the smallest two y-values, use
%                   'min2'.
%                   If P = 'peak', then one datatip will be placed at the peak
%                   of y-value. To put datatips on the two peaks, use 'peak2'.
%                   In case of multiple line objects, this input variable P will
%                   be applied to all lines.
%
%               - x (1-D array of any data type)
%                   Vector of x-coordinates of datatips.
%
%               - y (1-D array of any data type)
%                   Vector of y-coordinates of datatips. Use this for images.
%
%               - xrange (2-D array of any data type)
%                   Specify multiple ranges where we look for max or min. Each
%                   row represents one range. Format is:
%                       xrange(1,1) = starting x-value
%                       xrange(1,2) = ending x-value
%                   Set to [] for no limiting. The data type of xrange should be
%                   identical to the data type of the x-axis.
%
%       OUTPUT: - T (table)
%                   TBD.


%% Special case.
if (nargin == 1) && ~ischar(varargin{1})
    T = datatippos(varargin{1});
    varargout = {T};
    commandwindow
    return;             % Early exit.
end


%% Special case.
if (nargin == 3) && ischar(varargin{2}) && (size(varargin{3}, 1) > 1)
    xrange = varargin{3};
    for n = 1:size(varargin{3}, 1)
        datatips(varargin{1}, varargin{2}, xrange(n,:));
    end
    return;             % Early exit.
end


%% Assign input arguments.
if isgraphics(varargin{1}, 'figure') || isnumeric(varargin{1})
    if isnumeric(varargin{1})
        fig = figure(varargin{1});
    else
        fig = varargin{1};
    end
    children = fig.Children;
    lines    = gobjects(0);
    for child = children(:)'
        if isgraphics(child, 'axes')
            lines = [lines, child.Children'];   %#ok<AGROW>
        end
    end
elseif isgraphics(varargin{1}, 'axes')
    ax    = varargin{1};
    lines = ax.Children;
elseif isgraphics(varargin{1}, 'line')
    lines = varargin{1};
else
    error('Invalid data type for first input argument.');
end
switch nargin
case 2
    if ischar(varargin{2})
        Pin    = varargin{2};
        xrange = [];
    else
        Pin = varargin(2);
    end
case 3
    if ischar(varargin{2})
        Pin    = varargin{2};
        xrange = varargin{3};
    else
        Pin = varargin(2:3);
    end
end


%% Add datatips for all line objects in "lines".
for line = lines(:)'
    
    % Handle the case when P = 'max*' or 'min*'.
    if ischar(Pin)
        if any(strcmp(Pin(1:3), {'max', 'min'}))
            
            if length(Pin) == 3
                k = 1;
            else
                k = str2double(Pin(4:end));
            end
            xdata = ruler2num(line.XData, get(line.Parent, 'XAxis'));
            ydata = ruler2num(line.YData, get(line.Parent, 'YAxis'));
            if ~isempty(xrange)
                xrange = ruler2num(xrange, get(line.Parent, 'XAxis'));
                if xrange(1) > xrange(2)
                    error('xrange(1) > xrange(2)');
                end
                mask = (xdata < xrange(1)) | (xdata > xrange(2));
                if all(mask)
                    % Early exit and generate warning if no peak is found.
                    if strcmp(Pin(1:3), 'max')
                        warning('datatips:noMax', ...
                                'Max not found. No datatip is created.');
                    end
                    if strcmp(Pin(1:3), 'min')
                        warning('datatips:noMin', ...
                                'Min not found. No datatip is created.');
                    end
                    return;
                end
                if strcmp(Pin(1:3), 'max')
                    ydata(mask) = -Inf;
                else
                    ydata(mask) = Inf;
                end
            end
            if strcmp(Pin(1:3), 'max')
                [y, m] = maxk(ydata, k);
            else
                [y, m] = mink(ydata, k);
            end
            x = xdata(m);
            
        elseif strcmp(Pin(1:4), 'peak')

            %% Notes
            %
            % * The new algorithm always uses findpeaks() on the entire vector
            %   y. This means that xrange is only used to return the peaks in
            %   the range specified by xrange.
            
            %% Use islocalmax() to find peaks.
            if length(Pin) == 4
                NPeaks = 1;
            else
                NPeaks = str2double(Pin(5:end));
            end
            x       = ruler2num(line.XData, get(line.Parent, 'XAxis'));
            y       = ruler2num(line.YData, get(line.Parent, 'YAxis'));
            [TF, Q] = islocalmax(y);
            locs    = find(TF);
            p       = Q(TF);

            % %% Double check.
            % [~, tmplocs, ~, tmpp] = findpeaks(y);
            % if max(abs(tmplocs - locs)) > 0
            %     error('Mismatch between findpeaks() and islocalmax().');
            % end
            % if max(abs(tmpp - p)) > 0
            %     error('Mismatch between findpeaks() and islocalmax().');
            % end

            %% Only return the peaks between xrange(1) and xrange(2).
            if ~isempty(locs) && ~isempty(xrange)
                xrange = ruler2num(xrange, get(line.Parent, 'XAxis'));
                if xrange(1) > xrange(2)
                    error('xrange(1) > xrange(2)');
                end
                mask   = (x(locs) >= xrange(1)) & (x(locs) <= xrange(2));
                p      = p(mask);
                locs   = locs(mask);
            end
            if isempty(locs)
                % Early exit and generate warning if no peak is found.
                warning('datatips:noPeak', ...
                        'Peak not found. No datatip is created.');
                return;
            else
                [~, idx] = sort(p, 'descend');
                P        = {x(locs(idx(1:NPeaks))), y(locs(idx(1:NPeaks)))};
            end
            
            % %% Use islocalmax() to find peaks.
            % if length(Pin) == 4
            %     NPeaks = 1;
            % else
            %     NPeaks = str2double(Pin(5:end));
            % end
            % x = line.XData;
            % y = line.YData;
            % if ~isempty(xrange)
            %     mask = (x >= xrange(1)) & (x <= xrange(2));
            %     x    = x(mask);
            %     y    = y(mask);
            % end
            % [TF, Q]  = islocalmax(y);
            % locs     = find(TF);
            % p        = Q(TF);
            % [~, idx] = sort(p, 'descend');
            % P        = {x(locs(idx(1:NPeaks))), y(locs(idx(1:NPeaks)))};
            % 
            % %% Double check.
            % [~, tmplocs, ~, tmpp] = findpeaks(y);
            % if max(abs(tmplocs - locs)) > 0
            %     error('Mismatch between findpeaks() and islocalmax().');
            % end
            % if max(abs(tmpp - p)) > 0
            %     error('Mismatch between findpeaks() and islocalmax().');
            % end
            
        else
            error('Invalid value of P.');
        end
        if strcmp(Pin(1:3), 'max') || strcmp(Pin(1:3), 'min')
            m(isinf(y)) = [];
            y(isinf(y)) = [];            
            P           = {x(:), y(:)};
        end
    else
        P = Pin;
    end
    
    % Get x-coordinates and y-coordinates of all datatips.
    if isnumeric(P{1})
        x = double(P{1});
    else
        x = ruler2num(P{1}, get(line.Parent, 'XAxis'));
    end
    if length(P) == 1
        y = NaN(size(x));
        for n = 1:numel(y)
            xdata    = ruler2num(line.XData, get(line.Parent, 'XAxis'));
            [~, idx] = min(abs(x(n) - xdata));    % Find closet point.
            y(n)     = ruler2num(line.YData(idx), get(line.Parent, 'YAxis'));
        end
    else
        if isnumeric(P{2})
            y = double(P{2});
        else
            y = ruler2num(P{2}, get(line.Parent, 'YAxis'));
        end
    end
    
    % Temporarily set EdgeDetailLimit. Geck 2299283.
    origEdgeDetailLimit  = line.EdgeDetailLimit;
    line.EdgeDetailLimit = length(line.XData);

    % Add datatips.
    dcmobj = datacursormode(line.Parent.Parent);
    for n = 1:numel(x)
        hPDT          = dcmobj.createDatatip(line);
        hPDT.Position = [x(n), y(n), 0];
    end
    % for n = 1:numel(x)
    %     if isempty(line.ZData)
    %         datatip(line, x(n), y(n))
    %     else
    %         datatip(line, x(n), y(n), 0)
    %     end
    % end
    
    % Restore EdgeDetailLimit.
    line.EdgeDetailLimit = origEdgeDetailLimit;
    
end


%% Move focus back to command window.
commandwindow


end



function T = datatippos(varargin)

%%
%       SYNTAX: T = datatippos(lines);
%
%  DESCRIPTION: Get x-coordinates and y-coordinates of data tips.
%
%        INPUT: - fig (Figure or real double)
%                   Single figure object. If the figure window contains more
%                   than one line, then this function will get the datatip(s) on
%                   all lines.
%
%               = ax (Axes)
%                   Single axes object. If the axes contains more than one line,
%                   then this function will get the datatip(s) on all lines.
%
%               - lines (N-D array of Line)
%                   Line object(s). Input line objects can belong to different
%                   axes in different figure windows.
%
%       OUTPUT: - T (table)
%                   TBD.


%% Assign input arguments.
if isgraphics(varargin{1}, 'figure') || isnumeric(varargin{1})
    if isnumeric(varargin{1})
        fig = figure(varargin{1});
    else
        fig = varargin{1};
    end
    children = fig.Children;
    lines    = gobjects(0);
    for child = children(:)'
        if isgraphics(child, 'axes')
            lines = [lines, child.Children'];
        end
    end
elseif isgraphics(varargin{1}, 'axes')
    ax    = varargin{1};
    lines = ax.Children;
elseif isgraphics(varargin{1}, 'line')
    lines = varargin{1};
else
    error('Invalid data type for first input argument.');
end


%% Get datatips' positions for all line objects in "lines".
T = table;
for line = lines(:)'
    fig = line.Parent.Parent;
    d   = datacursormode(fig);
    s   = d.getCursorInfo;  % numel(s) = total number of data cursors in figure.
    T1  = table;
    for m = 1:numel(s)
        if isequal(s(m).Target, line)
            %P    = sortrows(reshape([s(m).Position], 2, []).');
            P    = s(m).Position;
            T2   = table;
            T2.x = num2ruler(P(:,1), get(line.Parent, 'XAxis'));
            T2.y = P(:,2);
            if length(P) == 3
                T2.z = P(:,3);
            end
            T1   = [T1; T2];
        end
    end
    if ~isempty(T1)
        T1      = sortrows(T1, 'x');
        T1.line = repmat(line, length(T1.x), 1);
        T       = [T; T1];
    end
end


%% Add line color.
T.color = repmat(categorical({''}), size(T,1), 1);
for n = 1:size(T,1)
    if isprop(T.line(n), 'Color')
        color = T.line(n).Color;
        if all(color == [1 0 0])
            T.color(n) = 'r';
        elseif all(color == [0 1 0])
            T.color(n) = 'g';
        elseif all(color == [0 0 1])
            T.color(n) = 'b';
        elseif all(color == [0 1 1])
            T.color(n) = 'c';            
        elseif all(color == [1 0 1])
            T.color(n) = 'm';
        elseif all(color == [1 1 0])
            T.color(n) = 'y';
        elseif all(color == [0 0 0])
            T.color(n) = 'k';
        elseif all(color == [1 1 1])
            T.color(n) = 'w';
        elseif all(color == [0 0.4470 0.7410])
            T.color(n) = '[0 0.4470 0.7410]';
        elseif all(color == [0.8500 0.3250 0.0980])
            T.color(n) = '[0.8500 0.3250 0.0980]';
        elseif all(color == [0.9290 0.6940 0.1250])
            T.color(n) = '[0.9290 0.6940 0.1250]';
        elseif all(color == [0.4940 0.1840 0.5560])
            T.color(n) = '[0.4940 0.1840 0.5560]';
        elseif all(color == [0.4660 0.6740 0.1880])
            T.color(n) = '[0.4660 0.6740 0.1880]';
        elseif all(color == [0.3010 0.7450 0.9330])
            T.color(n) = '[0.3010 0.7450 0.9330]';
        elseif all(color == [0.6350 0.0780 0.1840])
            T.color(n) = '[0.6350 0.0780 0.1840]';
        end
    end
end


end
