function [x, h] = ckhfirapply(h, x)

%%
%       SYNTAX: [y, h] = ckhfirapply(h, x);
% 
%  DESCRIPTION: Apply FIR filter to input signals. N-D inputs for h and x
%               must be the same size. A scalar input is expanded to a constant
%               N-D array with the same dimension as the other inputs.
%
%               In the special case when x = empty signal structure, then y is 
%               also an empty signal structure with y.idx being set accordingly.
%
%               In case of circularly input signal, y.idx is always equal to
%               x.idx.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%               - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - h (N-D array of struct)
%                   FIR filter structure(s).


%% Check h.
ckhfirisvalid(h);


%% Check x.
ckhsigisvalid(x);


%% Make sure that h and x have the same size.
desired_size = size(h);
if length(x) > 1
    desired_size = size(x);
end
if length(h) == 1
    h = repmat(h, desired_size);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if any(size(h) ~= size(x))
    error('size(h) ~= size(x)');
end


%% Check for sampling rate mismatch.
for n = 1:numel(h)
    if h(n).fs ~= x(n).fs
        error('Sampling rate mismatch.');
    end
end


%% Perform FIR filtering.
for n = 1:numel(h)
    switch x(n).type
    case 'streaming'
        [x(n), h(n)] = apply_streaming(h(n), x(n));
    case 'circular'
        [x(n), h(n)] = apply_circular(h(n), x(n));
    case 'segment'
        [x(n), h(n)] = apply_segment(h(n), x(n));
    otherwise
        error('Invalid type.');
    end
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: apply_segment - Apply FIR Filter For Input Segment Signal.
%
%       SYNTAX: [y, h] = apply_segment(h, x);
% 
%  DESCRIPTION: Apply FIR filter to input segment signal.
%
%        INPUT: - h (struct)
%                   FIR filter structure.
%
%               - x (struct)
%                   Input signal structure. Type must be 'segment'. x.s can be
%                   [].
%
%       OUTPUT: - y (struct)
%                   Output signal structure.
%
%               - h (struct)
%                   FIR filter structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, h] = apply_segment(h, x)


%% Special case: h.mode = -1 or 0.
switch h.mode
case 1
    % Do nothing.
case 0
    x.s = zeros(size(x.s));
    return;
case -1
    return;
otherwise
    error('Invalid mode.');
end
    

%% Get full impulse response.
fullh = ckhfirfull(h);


%% Set x.idx.
x = ckhsigsetidx(x);


%% Calculate output signal sample.
if isempty(x.s)
    ys = [];
else
    ys = filter(fullh.h, 1, x.s);
    N = length(fullh.h) - 1;
    if N > length(ys)
        ys = [];
    else
        ys(1:N) = [];
    end
    if isempty(ys)
        ys = [];
    end
end


%% Calculate output signal index.
idx = fullh.idx;
yidx = [];
yidx(1) = x.idx(1) - (-idx(end));
yidx(2) = yidx(1) + length(ys) - 1;


%% Reuse x to form output signal structure.
x.idx = [];
x.s = ys;
x.idx = yidx;


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: apply_circular - Apply FIR Filter For Input Circularly 
%                                Continuous Signal.
%
%       SYNTAX: [y, h] = apply_circular(h, x);
% 
%  DESCRIPTION: Apply FIR filter to input circularly continuous signal.
%
%        INPUT: - h (struct)
%                   FIR filter structure.
%
%               - x (struct)
%                   Input signal structure. Type must be 'circular'. x.s can be
%                   [].
%
%       OUTPUT: - y (struct)
%                   Output signal structure.
%
%               - h (struct)
%                   FIR filter structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, h] = apply_circular(h, x)


%% Special case: x = empty signal structure. Note that in filtering of 
%%               circularly continuous signal, y.idx is always equal to x.idx.
if isempty(x.s)
    return;
end


%% Special case: h.mode = -1 or 0.
switch h.mode
case 1
    % Do nothing.
case 0
    x.s = zeros(size(x.s));
    return;
case -1
    return;
otherwise
    error('Invalid mode.');
end


%% Set x.idx.
x = ckhsigsetidx(x);


%% Remember the original idx of x.
orig_idx = x.idx;


%% Prepend signal samples at the beginning.
fullh = ckhfirfull(h);
N = length(fullh.h);
idx = [x.idx(1) - (N - 1), x.idx(2)];
x = ckhsiggrep(x, idx);


%% Apply segment filtering.
x.type = 'segment';
[x, h] = apply_segment(h, x);
x.type = 'circular';
if length(x.s) ~= (orig_idx(2) - orig_idx(1) + 1)
    error('Length mismatch.');
end


%% Only return samples in the original index range.
x = ckhsiggrep(x, orig_idx);
if ~strcmp(x.type, 'circular')
    error('Output signal is not circular.');
end
    

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: apply_streaming - Apply FIR Filter For Input Streaming Signal.
%
%       SYNTAX: [y, h] = apply_streaming(h, x);
% 
%  DESCRIPTION: Apply FIR filter to input streaming signal.
%
%        INPUT: - h (struct)
%                   FIR filter structure.
%
%               - x (struct)
%                   Input signal structure. Type must be 'streaming'. x.s can be
%                   [].
%
%       OUTPUT: - y (struct)
%                   Output signal structure.
%
%               - h (struct)
%                   FIR filter structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, h] = apply_streaming(h, x)


%% Set x.idx.
x = ckhsigsetidx(x);


%% Construct h.zi.
if isempty(h.zi)
    h.zi     = ckhsig;
    tmp      = ckhfirfull(h);
    Nzeros   = length(tmp.h) - 1;
    h.zi.fs  = x.fs;
    h.zi.idx = [];
    h.zi.s   = zeros(1,Nzeros);
    h.zi.idx = [x.idx(1)-Nzeros, x.idx(1)-1];
end


%% Check for mismatch between x.fs and h.zi.fs.
if x.fs ~= h.zi.fs
    error('Mismatch between x.fs and h.zi.fs.');
end


%% Check for clitch between x.idx and h.zi.idx.
if x.idx(1) ~= (h.zi.idx(2) + 1)
    error('Clitch between x.idx and h.zi.idx.');
end


% %% Special case: x = empty signal structure.
% if isempty(x.s)
%     return;
% end


%% Prepend h.zi to input signal x.
x_prepend = x;
x_prepend.idx = [];
x_prepend.s   = [h.zi.s, x.s];
x_prepend.idx = [h.zi.idx(1), x.idx(2)];
x_prepend.type = 'segment';


%% Use segment filtering to perform streaming filtering.
switch h.mode
case 1
    [x, h] = ckhfirapply(h, x_prepend);
    x.type = 'streaming';
case 0
    x.s = zeros(size(x.s));
case -1
    % Do nothing.
otherwise
    error('Invalid mode.');
end
% x_prepend.type = 'segment';
% [x, h] = apply(h, x_prepend);
% x.type = 'streaming';


%% Update h.zi.
tmp = ckhfirfull(h);
N = length(tmp.h) - 1;
idx = [x_prepend.idx(2)-N+1, x_prepend.idx(2)];
h.zi = ckhsiggrep(x_prepend, idx);
h.zi.type = 'segment';


end







