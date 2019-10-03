function status = ckhfirselftestapplysegment

%%
%       SYNTAX: status = ckhfirselftestapplysegment;
%
%  DESCRIPTION: Test apply_segment.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


% ------------------------------------------------------------------------------
%                                   Single Tap
% ------------------------------------------------------------------------------


%% Test: x = default signal structure (i.e. empty).
h = ckhfir;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.idx = x.idx;
ideal_y.s = [];
ideal_y = ckhsigsetidx(ideal_y);
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.s = []. x.idx = +ve. h.idx = +ve.
h = ckhfir(2.5, 5, 2, 1);
x = ckhsig([], 5, 'segment', [2 1]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [4 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.s = []. x.idx = +ve. h.idx = 0.
h = ckhfir;
h.h = 2.5;
h.fs = 5;
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.s = []. x.idx = -ve. h.idx = -ve.
h = ckhfir(3.5, 5, -3, 1);
x = ckhsig([], 5, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-8 -9];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = +ve. h.idx = -ve.
h = ckhfir(3.5, 5, -3, 1);
x = ckhsig([], 5, 'segment', [5 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = 15;
h.mode = 0;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = 3;
h.mode = 0;
x = ckhsig([1 2 3], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = zeros(size(ideal_y.s));
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x = empty.
h = ckhfir;
h.h = -4;
h.mode = -1;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x ~= empty.
h = ckhfir;
h.h = 9;
h.mode = -1;
x = ckhsig([1 3 5], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: Sampling rate mismatch.
for mode = [-1 0 1]
    h = ckhfir(4, 10, 3, mode);
    x = ckhsig([1 3 5], 9, 'segment', [2 4]);
    try                                             %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: x.idx = +ve. h.idx = +ve.
h = ckhfir(2.5, 5, 2, 1);
x = ckhsig([1 2 3], 5, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 2.5*ideal_y.s;
ideal_y.idx = [4 6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = +ve and -ve. h.idx = 0.
h = ckhfir;
h.h = 2.5;
x = ckhsig([1 2 3 4], 1, 'segment', [-2 1]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 2.5*ideal_y.s;
ideal_y.idx = [-2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = -ve. h.idx = -ve.
h = ckhfir(3.5, 5, -3, 1);
x = ckhsig([1 2 3 4], 5, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 3.5*ideal_y.s;
ideal_y.idx = [-8 -5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = +ve. h.idx = -ve.
h = ckhfir(3.5, 5, -3, 1);
x = ckhsig([1 2 3 4], 5, 'segment', [5 8]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 3.5*ideal_y.s;
ideal_y.idx = [2 5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                                   Two Taps
% ------------------------------------------------------------------------------


%% Test: x = default signal structure (i.e. empty).
h = ckhfir;
h.h = [1 2];
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = [1 2];
h.mode = 0;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = [1 2];
h.mode = 0;
x = ckhsig([1 2 3], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = zeros(size(ideal_y.s));
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x = empty.
h = ckhfir;
h.h = [1 2];
h.mode = -1;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x ~= empty.
h = ckhfir;
h.h = [1 2];
h.mode = -1;
x = ckhsig([1 3 5], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: Sampling rate mismatch.
for mode = [-1 0 1]
    h = ckhfir([2 4], 10, [1 3], mode);
    x = ckhsig([1 3 5], 9, 'segment', [2 4]);
    try                                                 %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [2 3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [4 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 2], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5], 1, [3 2], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-2 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-2 -3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-3 -2], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-3 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 1], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [1 0], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 5, [-1 0], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -1], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-1 0], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-5 -6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [5 3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [6 5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 3], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-1 -3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-5 -3], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-4 -5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [3 0], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [4 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 2], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-2 0], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-5 -6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. y = [] due to small number of samples in x.
h = ckhfir([2.5 3], 5, [2 3], 1);
x = ckhsig(1, 5, 'segment', [0 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.idx = [];
ideal_y.s = [];
ideal_y.idx = [3 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [2 3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [4 6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 2], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5], 1, [3 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-2 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-2 -3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-3 -2], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-3 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 1, [-7 -6], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-11 -9];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 1], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [1 0], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 1, [0 1], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-4 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 5, [-1 0], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -1], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-1 0], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, x.s);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. y = [] due to small number of samples in x.
h = ckhfir([2.5 3], 5, [2 4], 1);
x = ckhsig([11 12], 5, 'segment', [1 2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.idx = [];
ideal_y.s = [];
ideal_y.idx = [5 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [5 3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 2.5], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [6 7];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 3], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5], 1, [4 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-1 -3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 2.5], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-5 -3], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-4 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 1, [-5 -3], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-8 -7];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [3 0], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 0 2.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [4 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 2], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 1, [0 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-3 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 0 2.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 5, [-2 0], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-2 0], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                                   Three Taps
% ------------------------------------------------------------------------------


%% Test: x = default signal structure (i.e. empty).
h = ckhfir;
h.h = [1 2 3];
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = 0;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = ckhsig;
ideal_y.s = [];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = 0;
x = ckhsig([1 2 3], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = zeros(size(ideal_y.s));
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x = empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = -1;
x = ckhsig;
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = -1. x ~= empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = -1;
x = ckhsig([1 3 5], 1, 'segment', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: Sampling rate mismatch.
for mode = [-1 0 1]
    h = ckhfir([2 4 5], 10, [1 3 4], mode);
    x = ckhsig([1 3 5], 9, 'segment', [2 4]);
    try                                             %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [2 3 4], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [5 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [1 2 3], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([3 2.5 1], 1, [3 1 2], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-2 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 1], 5, [-2 -3 -1], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1], 5, [-3 -2 -1], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-2 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 2.1], 5, [0 1 2], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [3 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 -2.1], 5, [1 0 2], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.6], 1, [0 1 2], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-3 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.8], 5, [-2 -1 0], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [-2 0 -1], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2], 1, [-2 -1 0], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-5 -6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = +ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.8], 5, [-1 0 1], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [1 -1 0], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.s = []. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2], 1, [-1 0 1], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-4 -5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2], 5, [5 2 3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [6 5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = +ve.
h = ckhfir([2.5 3 1.5], 5, [1 3 4], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [3 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5 1.2], 1, [4 1 2], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 1.2 3], 5, [-4 -1 -3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.2], 5, [-5 -3 -2], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-3 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.1], 1, [-5 -3 -2], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-7 -8];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3 1.1], 5, [3 0 2], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [4 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.4], 5, [0 2 3], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 3.8], 1, [0 2 3], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-2 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [-1 0 -3], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 1.2 3], 5, [ -3 -2 0], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.9], 1, [-3 -2 0], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-5 -6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = +ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [1 0 -2], 1);
x = ckhsig([], 5, 'segment', [1 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 1.2 3], 5, [-2 0 1], 1);
x = ckhsig([], 5, 'segment', [-1 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [0 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.s = []. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.9], 1, [-2 0 1], 1);
x = ckhsig([], 1, 'segment', [-5 -6]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-4 -5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. y = [] due to small number of samples in x.
h = ckhfir([2.5 3 1], 5, [2 3 4], 1);
x = ckhsig(1, 5, 'segment', [0 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.idx = [];
ideal_y.s = [];
ideal_y.idx = [4 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [2 3 4], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [5 6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [1 2 3], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([3 2.5 1], 1, [3 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-2 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 1], 5, [-2 -3 -1], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5 1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3 1], 5, [-3 -2 -1], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-2 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.2], 1, [-7 -6 -5], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1.2], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-10 -9];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 2.1], 5, [0 1 2], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [3 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 -2.1], 5, [1 0 2], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5 -2.1], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.6], 1, [0 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1.6], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-3 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.8], 5, [-2 -1 0], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.8], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [-2 0 -1], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3.1 3], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2], 1, [-2 -1 0], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.8], 5, [-1 0 1], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.8], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [1 -1 0], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 3.1 2.5], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2], 1, [-1 0 1], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2], 1, x.s);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-4 -3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. y = [] due to small number of samples in x.
h = ckhfir([2.5 3 1], 5, [2 4 5], 1);
x = ckhsig([11 12], 5, 'segment', [1 2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.idx = [];
ideal_y.s = [];
ideal_y.idx = [6 5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2], 5, [5 2 3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2 0 2.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [6 6];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3 1.5], 5, [1 3 4], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [3 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5 1.2], 1, [4 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1.2 0 3], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 -1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 1.2 3], 5, [-4 -1 -3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 0 1.2], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.2], 5, [-5 -3 -2], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.2], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-3 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.1], 1, [-5 -3 -2], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.1], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-7 -7];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3 1.1], 5, [3 0 2], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 1.1 2.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [4 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.4], 5, [0 2 3], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.4], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 3.8], 1, [0 2 3], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 3.8], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-2 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [-1 0 -3], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.1 0 2.5 3], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 1.2 3], 5, [ -3 -2 0], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1.2 0 3], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.9], 1, [-3 -2 0], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 0 2.9], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -5];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [1 0 -2], 1);
x = ckhsig([1 2 3 4], 5, 'segment', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.1 0 3 2.5], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [2 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 1.2 3], 5, [-2 0 1], 1);
x = ckhsig(1:5, 5, 'segment', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 1.2 3], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [0 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.9], 1, [-2 0 1], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 2.9], 1, x.s);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-4 -4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = 1 FIR filter. x = 3 signal structures. Output h = 3 FIR filters.
h = ckhfir([2.5 3 2.9], 1, [-2 0 1], 1);
x = ckhsig([1 2 3 4], 1, 'segment', [-5 -2]);
x = repmat(x, 1, 3);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= size(x)) || any(size(h1) ~= size(x))
    status = 0;
end


%% Exit function.
end

