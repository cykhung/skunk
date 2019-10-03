function x = ckhsigdecimate(x, M)

%%
%       SYNTAX: y = ckhsigdecimate(x, M);
% 
%  DESCRIPTION: Decimate input signal structure(s). If one of the input 
%               variables is a N-D array while another input variable has only
%               one element, then the single-element input variable will be
%               automatically expanded to a N-D array filled with the same
%               element.
%
%               In the special case where x = empty signal structure, y.idx and
%               y.fs will still be modified by this function accordingly.
%
%               In the special case where L = 1, y = x (except that the output
%               type is set to 'segment' for input streaming signal).
%
%        INPUT: - x (struct or N-D cell array of struct)
%                   Signal structure(s). Either circularly continuous or segment
%                   signal. Streaming signal is not supported. Can be empty.
%
%               - M (N-D array of real double)
%                   Decimation factors. Valid values are: 1 to 10. Must be
%                   integer.
%
%       OUTPUT: - y (struct or N-D cell array of struct)
%                   Decimated signal structure(s).


%% Check x.
ckhsigisvalid(x);


%% Check M.
if any(M ~= fix(M))
    error('M is not an integer.');
end
if any(M < 1) || any(M > 10)
    error('M is out of range.');
end


%% Check signal type.
type = ckhsiggettype(x);
if any(strcmp(type(:), 'streaming'))
    error('Input streaming signal is not supported');
end


%% Make sure that x and M have the same size.
desired_size = size(x);
if length(M) > 1
    desired_size = size(M);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(M) == 1
    M = repmat(M, desired_size);
end
if any(size(x) ~= size(M))
    error('size(x) ~= size(M)');
end


%% Decimate one signal at a time.
for n = 1:numel(x)
    x(n) = decimate_1(x(n), M(n));
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: y = decimate_1(x, M);
% 
%  DESCRIPTION: Decimate one signal structure.
%
%        INPUT: - x (struct)
%                   Signal structure. x.s can be empty.
%
%               - M (real double)
%                   Decimation factor.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = decimate_1(x, M)


%% Decimate.
switch M
case 1
    % Do nothing.
case 2
    x = decimate_1_special(x, 2);
case 3
    x = decimate_1_special(x, 3);
case 4
    for n = 1:2
        x = decimate_1_special(x, 2);
    end
case 5
    x = decimate_1_special(x, 5);
case 6
    x = decimate_1_special(x, 2);
    x = decimate_1_special(x, 3);
case 7
    x = decimate_1_special(x, 7);
case 8
    for n = 1:3
        x = decimate_1_special(x, 2);
    end
case 9
    for n = 1:2
        x = decimate_1_special(x, 3);
    end
case 10
    x = decimate_1_special(x, 2);
    x = decimate_1_special(x, 5);
otherwise
    error('Invalid M.');
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: y = decimate_1_special(x, M);
% 
%  DESCRIPTION: Decimate one signal object with special decimation factor.
%
%        INPUT: - x (struct)
%                   Signal structure. Can be empty.
%
%               - M (real double)
%                   Decimation factor. Valid values are: 2, 3, 5 and 7.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = decimate_1_special(x, M)


%% Apply lowpass filter.
switch M
case 2
    h = load('interp_fir_2.mat');
    h = h.h;
case 3
    h = load('interp_fir_3.mat');
    h = h.h;
case 5
    h = load('interp_fir_5.mat');
    h = h.h;
case 7
    h = load('interp_fir_7.mat');
    h = h.h;
otherwise
    error('Invalid M.');
end
dc_gain_dB = 20*log10(abs(sum(h)));
if abs(dc_gain_dB) > 0.1
    error('abs(dc_gain_dB) > 0.1.');
end
h1    = ckhfir;
h1.h  = h;
h1.fs = x.fs;
x     = ckhfirapply(h1, x);


%% Set x.idx.
x = ckhsigsetidx(x);


%% Calculate offset. This block of code can handle empty signal object.
offset = 0;
while 1
    if rem(x.idx(1) + offset, M) == 0
        break;
    else
        offset = offset + 1;
    end
end


%% Calculate start_idx (time index and not Matlab index).
start_idx = x.idx(1) + offset;


%% Downsample signal.
if isempty(x.s)
    x.idx = [start_idx/M, (start_idx/M)-1];
    x.fs = x.fs / M;
else
    switch x.type
    case 'circular'
        Nsamples = lcm(length(x.s), M);
        idx      = x.idx;
        idx(1)   = start_idx;
        idx(2)   = idx(1) + Nsamples - 1;
        x        = ckhsiggrep(x, idx);
        s        = x.s;
        s        = s(1:M:end);
        idx      = x.idx;
        idx(1)   = idx(1) / M;
        idx(2)   = idx(1) + length(s) - 1;
        fs       = x.fs / M;
        x.idx    = [];
        x.s      = s;
        x.idx    = idx;
        x.fs     = fs;
    case 'segment'
        idx = x.idx;
        idx(1) = start_idx;
        x      = ckhsiggrep(x, idx);
        s      = x.s;
        s      = s(1:M:end);
        idx    = x.idx;
        idx(1) = idx(1) / M;
        idx(2) = idx(1) + length(s) - 1;
        fs     = x.fs / M;
        x.idx  = [];
        x.s    = s;
        x.idx  = idx;
        x.fs   = fs;
    case 'streaming'
        error('Streaming signal is not supported.');
    otherwise
        error('Invalid type.');
    end
end


end


