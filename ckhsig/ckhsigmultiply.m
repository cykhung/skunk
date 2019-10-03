function y = ckhsigmultiply(varargin)

%%
%       SYNTAX: y = ckhsigmultiply(x);
%               y = ckhsigmultiply(x, G);
%               y = ckhsigmultiply(x1, x2);
% 
%  DESCRIPTION: ckhsigmultiply(x) multiplies all input signals (overlapped 
%               portion only) to form one output signal.
%
%               ckhsigmultiply(x, G) mulitplies the input signal(s) with G.
%
%               ckhsigmultiply(x1, x2) multiplies input signal(s) in x1 with
%               input signal(s) in x2 to form one output signal.
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
%               - G (N-D array of complex double)
%                   Gain(s).
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
G  = [];
x2 = [];
switch nargin
case 1
    x1 = varargin{1};
case 2
    x1 = varargin{1};
    if isnumeric(varargin{2})
        G = varargin{2};
        if isempty(G)
            error('G cannot be [].');
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


%% Make sure that x1, x2 (if defiend), and G (if defined) have the same size.
desired_size = size(x1);
if numel(x2) > 1
    desired_size = size(x2);
end
if numel(G) > 1
    desired_size = size(G);
end
if numel(x1) == 1
    x1 = repmat(x1, desired_size);
end
if numel(x2) == 1
    x2 = repmat(x2, desired_size);
end
if numel(G) == 1
    G = repmat(G, desired_size);
end
if ~isempty(x2)
    if any(size(x1) ~= size(x2))
        error('size(x1) ~= size(x2)');
    end
end
if ~isempty(G)
    if any(size(x1) ~= size(G))
        error('size(x1) ~= size(G)');
    end
end


%% Special case: there is only one input signal.
if isempty(x2) && isempty(G)
    if numel(x1) == 1
        y = x1;
        return;
    end
end


%% Handle all 3 calling syntaxes.
if isempty(x2) && isempty(G)

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
        y.s = y.s .* x(n).s;
    end

elseif ~isempty(G)
    
    % Scale by G.
    for n = 1:numel(x1)
        x1(n).s = x1(n).s * G(n);
    end
    y = x1;
    
elseif ~isempty(x2)
    
    % Multiply x1 with x2.
    y = x1;
    for n = 1:numel(x1)
        y(n) = ckhsigmultiply([x1(n), x2(n)]);
    end
    
else
    error('Unknown case.');
end


end


