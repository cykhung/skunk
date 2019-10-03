function status = ckhsigselftestflip

%%
%       SYNTAX: status = ckhsigselftestflip;
%
%  DESCRIPTION: Test ckhsigflip.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal structure. x.idx = [0 -1].
x = ckhsig;
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [1 0];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x = empty signal structure. x.idx = [2 1].
x = ckhsig;
x.idx = [2 1];
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [-1 -2];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x = empty signal object. x.idx = [-1 -2].
x = ckhsig;
x.idx = [-1 -2];
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = [];
ideal_y.idx = [2 1];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x.s = 1 element. x.idx = [1 1].
x = ckhsig(1, 2, 'circular', [1 1]);
y = ckhsigflip(x);
ideal_y = x;
ideal_y.idx = [-1 -1];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x.s = 3 elements. x.idx = [0 2].
x = ckhsig(1:3, 2, 'streaming', [0 2]);
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = fliplr(1:3);
ideal_y.idx = [-2 0];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x.s = 3 elements. x.idx = [-4 -2].
x = ckhsig(1:3, 2, 'segment', [-4 -2]);
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = fliplr(1:3);
ideal_y.idx = [2 4];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x.s = 4 elements. x.idx = [-1 2].
x = ckhsig(1:4, 2, 'streaming', [-1 2]);
y = ckhsigflip(x);
ideal_y = x;
ideal_y.s = fliplr(1:4);
ideal_y.idx = [-2 1];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x = 2x3 array.
x = repmat(ckhsig, 2, 3);
x(1) = ckhsig(1:4, 2, 'streaming', [-1 2]);
x(2) = ckhsig(1:3, 2, 'segment', [-4 -2]);
x(3) = ckhsig(1:3, 2, 'circular', [0 2]);
x(4) = ckhsig;
x(5) = ckhsig([], 2, 'streaming', [1 0]);
x(6) = ckhsig([], 2, 'streaming', [-1 -2]);
y = ckhsigflip(x);
for n = 1:6
    ideal_y = ckhsigflip(x(n));
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Exit function.
end

