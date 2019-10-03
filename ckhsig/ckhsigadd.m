function y = ckhsigadd(varargin)

%%
%       SYNTAX: y = ckhsigadd(x);
%               y = ckhsigadd(x, dc);
%               y = ckhsigadd(x1, x2);
% 
%  DESCRIPTION: ckhsigadd(x) adds up all input signals (overlapped portion only)
%               to form one output signal.
%
%               ckhsigadd(x, dc) adds constant DC offset(s) to the input
%               signal(s).
%
%               ckhsigadd(x1, x2) adds input signal(s) in x1 and input signal(s)
%               in x2 to form one output signal.
%
%               If one of the input variables is a N-D array while another input
%               variable has only one element, then the single-element input
%               variable will be automatically expanded to a N-D array filled
%               with the same element.
%
%               Streaming signal is not supported.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Streaming signal is not supported.
%
%               - dc (N-D array of complex double)
%                   Constant DC offet(s) being added to the input signal(s).
%
%               - x1 (N-D array of struct)
%                   Signal structure(s). Streaming signal is not supported.
%
%               - x2 (N-D array of struct)
%                   Signal structure(s). Streaming signal is not supported.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Assign input arguments.
dc = [];
x2 = [];
switch nargin
case 1
    x1 = varargin{1};
case 2
    x1 = varargin{1};
    if isnumeric(varargin{2})
        dc = varargin{2};
        if isempty(dc)
            error('dc cannot be [].');
        end
    else
        x2 = varargin{2};
    end
otherwise
    error('Invalid number of input arguments.');
end


%% Check input signal type.
types = {x1(:).type};
if ~isempty(x2)
    types = [types, {x2(:).type}];
end
if any(strcmp(types, 'streaming'))
    error('Input streaming signal is not supported');
end


%% Make sure that x1, x2 (if defiend), and dc (if defined) have the same size.
desired_size = size(x1);
if numel(x2) > 1
    desired_size = size(x2);
end
if numel(dc) > 1
    desired_size = size(dc);
end
if numel(x1) == 1
    x1 = repmat(x1, desired_size);
end
if numel(x2) == 1
    x2 = repmat(x2, desired_size);
end
if numel(dc) == 1
    dc = repmat(dc, desired_size);
end
if ~isempty(x2)
    if any(size(x1) ~= size(x2))
        error('size(x1) ~= size(x2)');
    end
end
if ~isempty(dc)
    if any(size(x1) ~= size(dc))
        error('size(x1) ~= size(dc)');
    end
end


%% Special case: there is only one input signal.
if isempty(x2) && isempty(dc)
    if numel(x1) == 1
        y = x1;
        return;
    end
end


%% Handle all 3 calling syntaxes.
if isempty(x2) && isempty(dc)

    % Get time intersect of all input signals.
    x = ckhsigintersect(x1);

    % Special case: Input signals don't overlap.
    if isempty(x(1).s)
        y = x(1);
        return;
    end

    % Find out output signal type.
    types = {x(:).type};
    if any(strcmp(types, 'segment'))
        output_signal_type = 'segment';
    else
        output_signal_type = 'circular';
    end

    % Add samples.
    y      = x(1);
    y.type = output_signal_type;
    for n = 2:numel(x)
        y.s = y.s + x(n).s;
    end

elseif ~isempty(dc)
    
    % Add dc offset(s).
    for n = 1:numel(x1)
        x1(n).s = x1(n).s + dc(n);
    end
    y = x1;
    
elseif ~isempty(x2)
    
    % Add x1 and x2.
    y = x1;
    for n = 1:numel(x1)
        y(n) = ckhsigadd([x1(n), x2(n)]);
    end
    
else
    error('Unknown case.');
end


end


