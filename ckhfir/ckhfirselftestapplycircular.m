function status = ckhfirselftestapplycircular

%%
%       SYNTAX: status = ckhfirselftestapplycircular;
%
%  DESCRIPTION: Test ckhfirapply_circular.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


% ------------------------------------------------------------------------------
%                                   Single Tap
% ------------------------------------------------------------------------------


%% Test: x = empty circular signal.
h = ckhfir;
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = 15;
h.mode = 0;
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = 3;
h.mode = 0;
x = ckhsig([1 2 3], 1, 'circular', [2 4]);
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
x.type = 'circular';
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
x = ckhsig([1 3 5], 1, 'circular', [2 4]);
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
    x = ckhsig([1 3 5], 9, 'circular', [2 4]);
    try                                                 %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: x.idx = +ve. h.idx = +ve.
h = ckhfir(2.5, 5, 2, 1);
x = ckhsig([1 2 3], 5, 'circular', [2 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 2.5*[2 3 1];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = +ve and -ve. h.idx = 0.
h = ckhfir;
h.h = 2.5;
h.fs = 5;
x = ckhsig([1 2 3 4], 5, 'circular', [-2 1]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 2.5*ideal_y.s;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = -ve. h.idx = -ve.
h = ckhfir(3.5, 5, -3, 1);
x = ckhsig([1 2 3 4], 5, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 3.5*[4 1 2 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x.idx = +ve. h.idx = -ve.
h = ckhfir(3.5, 5, -4, 1);
x = ckhsig([1 2 3 4], 5, 'circular', [5 8]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 3.5*ideal_y.s;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                                   Two Taps
% ------------------------------------------------------------------------------


%% Test: x = empty circular signal structure.
h = ckhfir;
h.h = [1 2];
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = [1 2];
h.mode = 0;
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = [1 2];
h.mode = 0;
x = ckhsig([1 2 3], 1, 'circular', [2 4]);
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
x.type = 'circular';
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
x = ckhsig([1 3 5], 1, 'circular', [2 4]);
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
    x = ckhsig([1 3 5], 9, 'circular', [2 4]);
    try                                                 %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: h = non-sparse. Small number of samples in x.
h = ckhfir([2.5 3], 5, [2 3], 1);
x = ckhsig(1, 5, 'circular', [0 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = 5.5;
ideal_y.idx = [0 0];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [2 3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(4) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:4) ys(1:2)];
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 2], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = [-1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5], 1, [5 4], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-2 -3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-3 -2], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end-1:end) ys(1:end-2)];
ideal_y.idx = [-1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 1, [-7 -6], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = [-5 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 1], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [1 0], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 1, [0 1], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [-5 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 5, [-1 0], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -1], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = [-1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-1 0], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3], 1, [x.s(end) x.s]);
ys(1) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = [-5 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. Small number of samples in x.
h = ckhfir([2.5 3], 5, [2 4], 1);
x = ckhsig([11 12], 5, 'circular', [1 2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = [1 2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [5 3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 2.5], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = [1 4];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3], 5, [1 3], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = [-1 3];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5], 1, [4 2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end-1:end) ys(1:end-2)];
ideal_y.idx = [-5 -2];
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [-1 -3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 2.5], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3], 5, [-5 -3], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3], 1, [-5 -3], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [3 0], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 0 2.5], 1, [x.s x.s]);
ys(1:4) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 5, [0 6], 1);
x = ckhsig(1:3, 5, 'circular', [-1 1]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 zeros(1,5) 3], 1, repmat(x.s, 1, 3));
ys(1:6) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3], 1, [0 2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s x.s]);
ys(1:4) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3], 5, [0 -4], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 0 0 2.5], 1, [x.s x.s]);
ys(1:4) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 5, [-2 0], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3], 1, [-2 0], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                                   Three Taps
% ------------------------------------------------------------------------------


%% Test: x = empty signal structure.
h = ckhfir;
h.h = [1 2 3];
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x = empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = 0;
x = ckhsig;
x.type = 'circular';
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h.mode = 0. x ~= empty.
h = ckhfir;
h.h = [1 2 3];
h.mode = 0;
x = ckhsig([1 2 3], 1, 'circular', [2 4]);
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
x.type = 'circular';
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
x = ckhsig([1 3 5], 1, 'circular', [2 4]);
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
    x = ckhsig([1 3 5], 9, 'circular', [2 4]);
    try                                             %#ok<TRYNC>
        ckhfirapply(h, x);
        status = 0;
    end
end


%% Test: h = non-sparse. Small number of samples in x.
h = ckhfir([2.5 3 1], 5, [2 3 4], 1);
x = ckhsig(1, 5, 'circular', [0 0]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ideal_y.s = sum([2.5 3 1]);
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [2 3 4], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3 1], 5, [1 2 3], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([3 2.5 1], 1, [3 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 1], 5, [-2 -3 -1], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5 1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3 1], 5, [-3 -2 -1], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end-1:end) ys(1:end-2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.2], 1, [-5 -4 -3], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1.2], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 2.1], 5, [0 1 2], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 -2.1], 5, [1 0 2], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2.5 -2.1], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.6], 1, [0 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 1.6], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.8], 5, [-2 -1 0], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.8], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end-1:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [-2 0 -1], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3.1 3], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2], 1, [-2 -1 0], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:end) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.8], 5, [-1 0 1], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2.8], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = +ve and -ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 3.1], 5, [1 -1 0], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 3.1 2.5], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = non-sparse. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2], 1, [-1 0 1], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 2], 1, [x.s(end-1:end) x.s]);
ys(1:2) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:end) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. Small number of samples in x.
h = ckhfir([2.5 3 1], 5, [2 4 5], 1);
x = ckhsig([11 12], 5, 'circular', [1 2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1], 1, [x.s x.s x.s]);
ys(1:4) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2], 5, [5 2 3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 2 0 2.5], 1, [x.s x.s]);
ys(1:4) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:4) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve.
h = ckhfir([2.5 3 1.5], 5, [1 3 4], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.5], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve.
%%       h.h is in reverse order.
h = ckhfir([3 2.5 1.2], 1, [4 1 2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1.2 0 3], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(end) ys(1:end-1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = -ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 1.2 3], 5, [-4 -1 -3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 0 1.2], 1, [x.s(2:4) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.2], 5, [-5 -3 -2], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.2], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = -ve.
h = ckhfir([2.5 3 1.1], 1, [-5 -3 -2], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.1], 1, [x.s(2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(2:4) ys(1)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and +ve.
%%       h.h is in reverse order.
h = ckhfir([2.5 3 1.1], 5, [3 0 2], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([3 0 1.1 2.5], 1, [x.s(2:4) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 1.4], 5, [0 2 3], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 1.4], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and +ve.
h = ckhfir([2.5 3 3.8], 1, [0 2 3], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 3.8], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = ys;
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = 0 and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [-1 0 -3], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.1 0 2.5 3], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(4) ys(1:3)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 1.2 3], 5, [-3 -2 0], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 1.2 0 3], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(4:5) ys(1:3)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = 0 and -ve.
h = ckhfir([2.5 3 2.9], 1, [-3 -2 0], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 3 0 2.9], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(4) ys(1:3)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve. h.idx = +ve and -ve.
%%       h.h is not in right order.
h = ckhfir([2.5 3 2.1], 5, [1 0 -2], 1);
x = ckhsig([1 2 3 4], 5, 'circular', [1 4]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.1 0 3 2.5], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:4) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = +ve and -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 1.2 3], 5, [-2 0 1], 1);
x = ckhsig(1:5, 5, 'circular', [-1 3]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 1.2 3], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:5) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = sparse. x.idx = -ve. h.idx = +ve and -ve.
h = ckhfir([2.5 3 2.9], 1, [-2 0 1], 1);
x = ckhsig([1 2 3 4], 1, 'circular', [-5 -2]);
[y, h1] = ckhfirapply(h, x);
if any(size(y) ~= [1 1])
    status = 0;
end
ideal_y = x;
ys = filter([2.5 0 3 2.9], 1, [x.s(end-2:end) x.s]);
ys(1:3) = [];
ideal_y.idx = [];
ideal_y.s = [ys(3:4) ys(1:2)];
ideal_y.idx = x.idx;
if ~isequal(h1, h) || ~isequal(y, ideal_y)
    status = 0;
end


%% Exit function.
end

