function ckhsigplot(varargin)

%%
%       SYNTAX: ckhsigplot(x);
%               ckhsigplot(x, linetype);
%               ckhsigplot(x, linetype, xunit);
% 
%  DESCRIPTION: Time domain plot.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). x.s must not be empty.
%
%               - linetype (char or 1-D row/col cell array of char)
%                   Line types. Optional. Set to '' or {} for default values.
%                   Default = {'r', 'b', 'g', 'c', 'm', 'y', 'k'}. If number of
%                   line types < numel(x), then line types will be reused.
%
%               - xunit (char)
%                   Unit of the x-axis (i.e. time). Optional. Valid units are:
%                   'idx', 's', 'ms', 'us', 'ns'. Default = 'idx'. Select 'idx'
%                   for plotting against sample index. Note that a warning
%                   message will be generated if 'idx' is selected and input
%                   signal objects have different sampling rates. Set to '' or
%                   {} for default values.
%
%       OUTPUT: none.


%% Assign input arguments.
options = [];
switch nargin
case 1
    x                = varargin{1};
case 2
    x                = varargin{1};
    options.linetype = varargin{2};
case 3
    x                = varargin{1};
    options.linetype = varargin{2};
    options.xunit    = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end
clear varargin


%% Check x.
ckhsigisvalid(x);


%% Check for empty signal.
for n = 1:numel(x)
    if isempty(x(n).s)
        error('x.s = [].');
    end
end


%% Assign default values to options.
if ~isfield(options, 'linetype') || isempty(options.linetype)
    options.linetype = {'r', 'b', 'g', 'c', 'm', 'y', 'k'};
end
if ~isfield(options, 'xunit') || isempty(options.xunit)
    options.xunit = 's';
end


%% Convert linetype from string to cell array of strings.
if ~iscell(options.linetype)
    options.linetype = {options.linetype};
end


%% Define x-axis scaling factor and xlabel string.
switch options.xunit
case 'idx'
    xlabelstr = 'Sample Index';
case 's'
    xscale = 1;
    xlabelstr = 'Time (s)';
case 'ms'
    xscale = 1e3;
    xlabelstr = 'Time (ms)';
case 'us'
    xscale = 1e6;
    xlabelstr = 'Time (us)';
case 'ns'
    xscale = 1e9;
    xlabelstr = 'Time (ns)';
otherwise
    error('Invalid xunit.');
end


%% Check sampling rates if options.xunit == 'idx'.
if strcmp(options.xunit, 'idx')
    if length(unique([x(:).fs])) ~= 1
        warning('ckhsigplot:fs', ...
                'Input signal objects have different sampling rates.');
    end
end


%% Do actual plotting.
x = ckhsigsetidx(x);
linetype_idx = 1;
isAnySignalComplex = any(~ckhsigisreal(x));
for n = 1:numel(x)
    
    % Plot.
    if strcmp(options.xunit, 'idx')
        tscale = (x(n).idx(1) : x(n).idx(2));
    else
        tscale = (x(n).idx(1) : x(n).idx(2)) * (xscale / x(n).fs);
    end
    if isAnySignalComplex
        subplot(311)
        holdstate = ishold;     % Remember hold state.
        plot(tscale, abs(x(n).s), options.linetype{linetype_idx});
        hold on
        subplot(312)
        holdstate(2) = ishold;  % Remember hold state.
        plot(tscale, real(x(n).s), options.linetype{linetype_idx});
        hold on
        subplot(313)
        holdstate(3) = ishold;  % Remember hold state.
        plot(tscale, imag(x(n).s), options.linetype{linetype_idx});
        hold on
    else
        holdstate = ishold;     % Remember hold state.
        plot(tscale, x(n).s, options.linetype{linetype_idx});
        hold on
    end
    
    % Increment linetype index.
    linetype_idx = linetype_idx + 1;
    if linetype_idx > length(options.linetype)
        linetype_idx = 1;
    end
    
end
if isAnySignalComplex
    for n = 1:3
        subplot(3,1,n)
        if holdstate(n)     % Restore hold state.
            hold on
        else
            hold off
        end
        xlabel(xlabelstr);
        ylabel('Amplitude');
        switch n
        case 1
            title('Time Domain: ABS(X)');
        case 2
            title('Time Domain: REAL(X)');
        case 3
            title('Time Domain: IMAG(X)');
        otherwise
            error('Invalid n.');
        end
        grid on
        pan xon
        zoom on
        legend
    end
    linkaxes([subplot(311), subplot(312), subplot(313)], 'x')
else
    if holdstate        % Restore hold state.
        hold on
    else
        hold off
    end
    xlabel(xlabelstr);
    ylabel('Amplitude');
    title('Time Domain');
    grid on
    pan xon
    zoom on
    legend
end

end


