function [x, midx] = ckhsiggrep(varargin)

%%
%       SYNTAX: [y, midx] = ckhsiggrep(x, didx);
%               [y, midx] = ckhsiggrep(x, 's', t);
% 
%  DESCRIPTION: ckhsiggrep(x, didx) grep samples based on sample indexes or
%               number of samples.
%
%               ckhsiggrep(x, 's', t) grep samples based on times (in seconds).
%
%               If one of the input variables is a N-D cell array while another 
%               input variable has only one element, then the single-element
%               input variable will be automatically expanded to a N-D cell
%               array filled with the same element.
%
%               In case of streaming signal, this function behaves the same if
%               the signal is a segment signal. The output signal type is also
%               streaming.
%
%        INPUT: - x (N-D array of struct)
%                   Input signal structure(s).
%
%               - didx (1-D row/col array of real double or N-D cell array of
%                       1-D row/col array of real double)
%                   Desired indexes or number of samples. If user wants to grep
%                   samples based on number of samples, then didx = scalar or 
%                   N-D cell array of scalars. If user wants to grep samples 
%                   based on indexes, then didx = vector of 2 elements or N-D
%                   cell array of vector of 2 elements. 
%
%                   User can mix "indexes" and "number of samples" in one call, 
%                   eg.
%                       didx = {};
%                       didx{1} = [0 2];
%                       didx{2} = [3];
%                       [y, midx] = grep(x, didx);
%
%                   In the special case where didx(2) = didx(1) - 1, then
%                       y = x;
%                       y.idx = didx;
%                       y.s = [];
%
%               - t (1-D row/col array of real double or N-D cell array of
%                       1-D row/col array of real double)
%                   Desired times (in seconds).
%
%       OUTPUT: - y (N-D array of struct)
%                   Output signal structure(s).
%
%               - midx (N-D cell array of 1-D row array of real double)
%                   Vector of matlab indexes of x.s for obtaining y.s. Under
%                   all circumstances, y{n}.s = x{n}.s(midx{n}).


%% Assign input arguments.
didx = {[]};
t    = {[]};
switch nargin
case 2
    x    = varargin{1};
    didx = varargin{2};
case 3
    x = varargin{1};
    t = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end
        

%% Check x.
ckhsigisvalid(x);


% %% Check signal type.
% for n = 1:numel(x)
%     switch x(n).type
%     case {'circular', 'segment'}
%         % Do nothing.
%     case 'streaming'            
%         error('Input streaming signal is not supported');
%     otherwise
%         error('Invalid signal type.');
%     end
% end


%% Turn didx into cell array.
if ~iscell(didx)
    didx = {didx};
end


%% Turn t into cell array.
if ~iscell(t)
    t = {t};
end


%% Make sure that x, didx and t have the same size.
desired_size = size(x);
if length(didx) > 1
    desired_size = size(didx);
end
if length(t) > 1
    desired_size = size(t);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(didx) == 1
    didx = repmat(didx, desired_size);
end
if length(t) == 1
    t = repmat(t, desired_size);
end
if any(size(x) ~= size(didx))
    error('size(x) ~= size(didx)');
end
if any(size(x) ~= size(t))
    error('size(x) ~= size(t)');
end


%% Turn t into didx.
if nargin == 3
    didx = cell(size(t));
    for n = 1:numel(t)
        tmp     = t{n};
        m1      = ceil(tmp(1)  * x(n).fs);
        m2      = floor(tmp(2) * x(n).fs);
        didx{n} = [m1 m2];
    end
end


%% Set default value for x.idx.
x = ckhsigsetidx(x);


%% Check didx.
for n = 1:numel(didx)
    idx = didx{n};
    if any(idx ~= fix(idx))
        error('didx must contain integers.');
    end
end


%% Handle the case of greping based on Nsamples.
for n = 1:numel(didx)
    switch length(didx{n})
    case 1
        Nsamples = didx{n};
        didx{n} = [x(n).idx(1), x(n).idx(1) + Nsamples - 1];
    case 2
        % Do nothing.
    otherwise
        error('Invalid didx.');
    end
end


%% Grep one signal at a time.
midx = cell(size(x));
for n = 1:numel(x)
    [x(n), midx{n}] = grep_1(x(n), didx{n});
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: grep_1 - Grep One Signal Object.
%
%       SYNTAX: [y, midx] = grep_1(x, didx);
% 
%  DESCRIPTION: Grep one signal object.
%
%        INPUT: - x (struct)
%                   Signal structure.
%
%               - didx (1-D row/col array of real double)
%                   Desired index. Number of elements = 2.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%
%               - midx (1-D row array of real double)
%                   Vector of matlab indexes for x.s. Can be empty matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, midx] = grep_1(x, didx)


%% Special case: didx(2) < didx(1) - 1.
if didx(2) < didx(1) - 1
    error('Invalid didx.');
end


%% Special case: check didx(2) = didx(1) - 1.
if didx(2) == didx(1) - 1
    x.idx = [];
    x.s = [];
    x.idx = didx;
    midx = [];
    return;
end


%% Check if didx is out of range.
if strcmp(x.type, 'segment') || strcmp(x.type, 'streaming')
    if (didx(1) < x.idx(1)) || (didx(2) > x.idx(2))
        error('didx is out of range.');
    end
end


%% Turn didx into Matlab index of vector x.s.
midx = didx - x.idx(1) + 1;
midx = midx(1):midx(2);


%% If x is circularly continuous, then wrap around midx.
if strcmp(x.type, 'circular')
    N          = length(x.s);
    midx       = rem(midx, N);
    mask       = (midx <= 0);
    midx(mask) = midx(mask) + N;
end


%% If x is circularly continuous, then check if output signal object is still
%% circularly continuous.
if strcmp(x.type, 'circular')
    if rem(length(midx), length(x.s)) ~= 0
        x.type = 'segment';
    end
end


%% Grep samples.
x.idx = [];
x.s   = x.s(midx);
x.idx = didx;


end

