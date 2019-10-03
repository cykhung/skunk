function status = ckhsigselftestadd

%%
%       SYNTAX: status = ckhsigselftestadd;
%
%  DESCRIPTION: Test ckhsigadd.
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
%                       SYNTAX: y = ckhsigadd(x)
% ------------------------------------------------------------------------------


%% Test: x = 1x1 empty signal structure. 
x = ckhsig([], 1e3, 'circular', [9 8]);
y = ckhsigadd(x);
if ~isequal(y, x)
    status = 0;
end


%% Test: x = 1x1 non-empty signal structure. 
x = ckhsig(1:4, 1e3, 'circular', [0 3]);
y = ckhsigadd(x);
if ~isequal(y, x)
    status = 0;
end


%% Test: x = 1x3 non-empty signal structure. Signals don't overlap.
x    = repmat(ckhsig, 1, 3);
x(1) = ckhsig(1:4, 1e3, 'segment', [0 3]);
x(2) = ckhsig(1:4, 1e3, 'segment', [0 3]+10);
x(3) = ckhsig(1:4, 1e3, 'segment', [0 3]+20);
y    = ckhsigadd(x);
if ~isempty(y.s)
    status = 0;
end


%% Test: x = 1x3 non-empty signal structure. All signals are segment signals.
%%       All signals exactly overlap each other.
rng(13, 'twister');
x         = repmat(ckhsig, 1, 3);
x(1)      = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
x(2)      = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
x(3)      = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
y         = ckhsigadd(x);
ideal_y   = x(1);
ideal_y.s = x(1).s + x(2).s + x(3).s;
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 1x3 non-empty signal structure. All signals are segment signals.
%%       Input signals partially overlap each other.
rng(13, 'twister');
x         = repmat(ckhsig, 3, 1);
x(1)      = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
x(2)      = ckhsig(randzc(1,5), 1e3, 'segment', [0 4]);
x(3)      = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
y         = ckhsigadd(x);
ideal_y   = x(1);
ideal_y.s = x(1).s + x(2).s(1:4) + x(3).s;
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 2x3 non-empty signal structure. Mix of segment signals and circular
%%       signals. Input signals partially overlap each other.
rng(13, 'twister');
x         = repmat(ckhsig, 2, 3);
x(1)      = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(2)      = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x(3)      = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(4)      = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x(5)      = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x(6)      = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
y         = ckhsigadd(x);
ideal_y   = x(1);
ideal_y.s = x(1).s + x(2).s(1:4) + x(3).s + x(4).s(2:5) + x(5).s + ...
    x(6).s([2 3 1 2]);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 1x3 non-empty signal structure. All signals are circular signals.
%%       All signals exactly overlap each other.
rng(13, 'twister');
x         = repmat(ckhsig, 1, 3);
x(1)      = ckhsig(randzc(1,3), 1e3, 'circular',  [0   2]);
x(2)      = ckhsig(randzc(1,6), 1e3, 'circular',  [0   5]);
x(3)      = ckhsig(randzc(1,3), 1e3, 'circular',  [0   2]);
y         = ckhsigadd(x);
ideal_y   = x(2);
ideal_y.s = [x(1).s, x(1).s] + x(2).s + [x(3).s, x(3).s];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 1x3 non-empty signal structure. All signals are circular signals.
%%       Input signals partially overlap each other.
rng(13, 'twister');
x            = repmat(ckhsig, 1, 3);
x(1)         = ckhsig(randzc(1,3), 1e3, 'circular',  [0   2]);
x(2)         = ckhsig(randzc(1,5), 1e3, 'circular',  [0   4]);
x(3)         = ckhsig(randzc(1,3), 1e3, 'circular',  [0   2]);
y            = ckhsigadd(x);
ideal_y      = x(1);
ideal_y.type = 'segment';
ideal_y.idx  = [0 4];
ideal_y.s    = [x(1).s, x(1).s(1:2)] + x(2).s + [x(3).s, x(3).s(1:2)];
if ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                       SYNTAX: y = ckhsigadd(x, dc)
% ------------------------------------------------------------------------------


%% Test: x = 1x1 empty signal structure. 
x = ckhsig([], 1e3, 'circular', [9 8]);
y = ckhsigadd(x);
if ~isequal(y, x)
    status = 0;
end


%% Test: x = 1x1 signal structure. dc = scalar.
rng(13, 'twister');
x         = ckhsig(randzc(1,3), 1e3, 'circular', [0 2]);
dc        = 2 + sqrt(-1)*3;
y         = ckhsigadd(x, dc);
ideal_y   = x;
ideal_y.s = ideal_y.s + dc;
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 1x1 signal structure. dc = 2x3 matrix.
rng(13, 'twister');
x         = ckhsig(randzc(1,3), 1e3, 'circular', [0 2]);
dc        = randzc(2,3);
y         = ckhsigadd(x, dc);
ideal_y   = repmat(x, 2, 3);
for n = 1:numel(dc)
    ideal_y(n).s = ideal_y(n).s + dc(n);
end
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 2x3 signal structure. dc = scalar.
rng(103, 'twister');
x       = repmat(ckhsig, 2, 3);
x(1)    = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(2)    = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x(3)    = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(4)    = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x(5)    = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x(6)    = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
dc      = randzc(1);
y       = ckhsigadd(x, dc);
ideal_y = x;
for n = 1:numel(x)
    ideal_y(n).s = ideal_y(n).s + dc;
end
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = 3x2 signal structure. dc = 3x2 matrix.
rng(203, 'twister');
x       = repmat(ckhsig, 3, 2);
x(1)    = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(2)    = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x(3)    = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x(4)    = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x(5)    = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x(6)    = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
dc      = randzc(3,2);
y       = ckhsigadd(x, dc);
ideal_y = x;
for n = 1:numel(x)
    ideal_y(n).s = ideal_y(n).s + dc(n);
end
if ~isequal(y, ideal_y)
    status = 0;
end


% ------------------------------------------------------------------------------
%                       SYNTAX: y = ckhsigadd(x1, x2)
% ------------------------------------------------------------------------------


%% Test: x1 = 1x1 empty signal structure. x2 = 1x1 empty signal structure. 
x1 = ckhsig([], 1e3, 'circular', [9 8]);
x2 = ckhsig([], 1e3, 'circular', [9 8]);
y = ckhsigadd(x1, x2);
if ~isequal(y, x1)
    status = 0;
end


%% Test: x1 = 1x1 segment signal. x2 = 2x3 signals.
rng(203, 'twister');
x1    = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
x2    = repmat(ckhsig, 3, 2);
x2(1) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x2(2) = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x2(3) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x2(4) = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x2(5) = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x2(6) = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
y     = ckhsigadd(x1, x2);
for n = 1:numel(x2)
    ideal_y = ckhsigadd(x1, x2(n));
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Test: x1 = 2x3 signals. x2 = 1x1 segment signal.
rng(203, 'twister');
x2    = ckhsig(randzc(1,4), 1e3, 'segment', [0 3]);
x1    = repmat(ckhsig, 3, 2);
x1(1) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x1(2) = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x1(3) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x1(4) = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x1(5) = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x1(6) = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
y     = ckhsigadd(x1, x2);
for n = 1:numel(x1)
    ideal_y = ckhsigadd(x1(n), x2);
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Test: x1 = 2x3 signals. x2 = 2x3 signals.
rng(203, 'twister');
x1    = repmat(ckhsig, 3, 2);
x1(1) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x1(2) = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x1(3) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x1(4) = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x1(5) = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x1(6) = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
x2    = repmat(ckhsig, 3, 2);
x2(1) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x2(2) = ckhsig(randzc(1,5), 1e3, 'segment',  [0   4]);
x2(3) = ckhsig(randzc(1,4), 1e3, 'segment',  [0   3]);
x2(4) = ckhsig(randzc(1,6), 1e3, 'segment',  [-1  4]);
x2(5) = ckhsig(randzc(1,4), 1e3, 'circular', [-4 -1]);
x2(6) = ckhsig(randzc(1,3), 1e3, 'circular', [2   4]);
y     = ckhsigadd(x1, x2);
for n = 1:numel(x1)
    ideal_y = ckhsigadd(x1(n), x2(n));
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Exit function.
end

