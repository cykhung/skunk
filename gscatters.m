function gscatters(X, varargin)

%%
%       SYNTAX: gscatters(X);
%               gscatters(X, g);
%               gscatters(X, g, colors);
%               gscatters(X, g, colors, types);
%               gscatters(__, Name, Value);
%
%  DESCRIPTION: Work similar to MATLAB gscatter.
%
%               Examples:
%               >> gscatters(rand(10,2), randi([1 2], 10, 1))
%               >> gscatters(rand(10,2), randi([1 2], 10, 1), 'br', 'ox', ...
%                                           'LineWidth', 4, 'MarkerSize', 40)
%
%        INPUT: - X (2-D array of real double)
%                   Input data matrix. Each row is a data point. Number of
%                   columns must be 1 (for 1-D data), 2 (for 2-D data) or 3 (for
%                   3-D data).
%
%               - g (1-D col array of real double or
%                    1-D col array of categorical or
%                    1-D col array of string      or
%                    1-D col cell array of char   or
%                    char)
%                   Grouping vector.
%
%       OUTPUT: none.


%% Parse input arguments.
%
% * Name value pairs show up at the end.
%
g          = [];
colors     = [];
types      = [];
namevalues = {};
allnames   = {'LineWidth', 'MarkerSize'};
for k = 1:length(varargin)
    if ischar(varargin{k}) && ismember(lower(varargin(k)), lower(allnames))
        % Found the first name value.
        namevalues = varargin(k : end);
        varargin   = varargin(1 : (k-1));
        break
    end
end
if any(~ismember(namevalues(1:2:end), allnames))
    error('Unsupported name value pairs.');
end 
switch length(varargin)
case 0
    % Do nothing.
case 1
    g = varargin{1};
case 2
    g      = varargin{1};
    colors = varargin{2};
case 3
    g      = varargin{1};
    colors = varargin{2};
    types  = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end


%% Use default values.
if isempty(g)
    % Arbitrarily assign group 1 to all data points.
    g                = ones(size(X,1), 1);
    userspecifygroup = 0;
else
    userspecifygroup = 1;
end
if isempty(colors)
    colors = [0         0           1;          % Blue
              1         0           0;          % Red
              0         1           1;          % Cyan
              0         0           0;          % Black
              0         1           0;          % Green
              0.4660,   0.6740,     0.1880;
              0.9290,   0.6940,     0.1250;
              0,        0.4470,     0.7410;
              1         0           0];         % Red
end
if isempty(types)
    types = 'xoopopp^x';
end


%% Check input arguments.
if ~ismember(size(X,2), 1:3)
    error("The matrix X must have 1, 2 or 3 columns.")
end
if size(X,1) ~= size(g,1)
    error("Vectors X and g must have the same number of rows")
end
if iscell(g) && ~iscellstr(g)
    error("The argument g must be a double, categorical, string or cellstr.")
end
if ischar(g)
    g = categorical({g});
elseif ~isnumeric(g)
    g = categorical(g);
end
if ~isnumeric(colors)
    colors = colors(:);
end
types  = types(:);


%% Plot.
ISHOLD = ishold;
if ISHOLD == 0
    m = 1;
else
    m = numel(get(gca, 'children')) + 1;
end
for k = unique(g)'
    c = circread(colors, m);
    t = circread(types, m);
    p = {'LineStyle',   'none',     ...
         'Color',       c,          ...
         'Marker',      t,          ...
         'LineWidth',   1.5,        ...
         namevalues{:}};        %#ok<CCAT>
    if ismissing(k)
        mask = ismissing(g);
    else
        mask = (g==k);
    end
    switch size(X, 2)
    case 1
        S = plot(X(mask,1), zeros(size(X(mask,1))), p{:});
    case 2
        S = plot(X(mask,1), X(mask,2), p{:});
    case 3
        S = plot3(X(mask,1), X(mask,2), X(mask,3), p{:});
        zlabel('X_3', 'FontWeight', 'bold')
    otherwise
        error("Data must be two or three dimensional.")
    end
    S.DataTipTemplate.DataTipRows(end+1) = ...
                                    dataTipTextRow("Observation", find(mask));
    if userspecifygroup == 1
        S.DataTipTemplate.DataTipRows(end+1) = ...
                                            dataTipTextRow("Group", g(mask));
        switch class(k)
        case 'categorical'
            S.DisplayName = char(k);
        case 'double'
            S.DisplayName = ['Group ', num2str(k)];
        otherwise
            error('Invalid data type.');
        end
    end
    hold on
    m = m + 1;
end
if ISHOLD == 0
    hold off
end
xlabel('X_1', 'FontWeight', 'bold')
ylabel('X_2', 'FontWeight', 'bold')
legend('Location', 'Best')
% if userspecifygroup == 1
%     switch class(g)
%     case 'categorical'
%         legend(char(unique(g)), 'Location', 'Best')
%     case 'double'
%         tmp                 = string(unique(g));
%         tmp(ismissing(tmp)) = "NaN";
%         legend("Group " + tmp, 'Location', 'Best')
%     end
% end


end


function y = circread(A, rowidx)

%% Wrap around rowidx.
row = mod(rowidx-1, size(A,1)) + 1;

%% Extract row.
y = A(row,:);

end




