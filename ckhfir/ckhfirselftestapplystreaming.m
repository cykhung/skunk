function status = ckhfirselftestapplystreaming

%%
%       SYNTAX: status = ckhfirselftestapplystreaming;
%
%  DESCRIPTION: Test apply_streaming.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal structure.
h = ckhfir;
x = ckhsig([], 1, 'streaming', []);
[y, h1] = ckhfirapply(h, x);
ideal_y = x;
ideal_y.idx = [0 -1];
if ~isequal(y, ideal_y)
    status = 0;
end
ideal_zi = ckhsig([], 1, 'segment', [0 -1]);
if ~isequal(h1.zi, ideal_zi)
    status = 0;
end


%% Test: Crash. Sampling rate mismatch between x and h.zi.
h = ckhfir([1 2], 10, [0 1], 1);
x = ckhsig((1:4)+1i*(11:14), 10, 'streaming', []);
[~, h] = ckhfirapply(h, x);
x.fs = 11;
try                                                         %#ok<TRYNC>
    ckhfirapply(h, x);
    status = 0;
end


%% Test: Crash. Index mismatch between x and h.zi.
h = ckhfir([1 2], 10, [0 1], 1);
x = ckhsig((1:4)+1i*(11:14), 10, 'streaming', []);
[~, h] = ckhfirapply(h, x);
try                                                         %#ok<TRYNC>
    ckhfirapply(h, x);
    status = 0;
end

h = ckhfir([1 2], 10, [0 1], 1);
x = ckhsig([], 10, 'streaming', [1 0]);
[~, h] = ckhfirapply(h, x);
try                                                         %#ok<TRYNC>
    x = ckhsig(1, 10, 'streaming', [2 2]);
    ckhfirapply(h, x);
    status = 0;
end


%% Test: h = 1 tap.
h = ckhfir(1, 1e3, 2, 1);
x = ckhsig((1:4)+1i*(11:14), 1e3, 'streaming', [-1 2]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([], 1e3, 'segment', [3 2]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = x.idx + 2;
if ~isequal(y, ideal_y)
    status = 0;
end

x = ckhsig([], 1e3, 'streaming', [3 2]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([], 1e3, 'segment', [3 2]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = [5 4];
if ~isequal(y, ideal_y)
    status = 0;
end

x = ckhsig((1:4)+1i*(11:14), 1e3, 'streaming', [3 6]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([], 1e3, 'segment', [7 6]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = x.idx + 2;
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = 2 taps (sparse). Not enough samples in x to fill h.zi.
h = ckhfir([1 2], 1, [2 4], 1);
x = ckhsig(-3+1i*2, 1, 'streaming', [-1 -1]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([0 x.s], 1, 'segment', [-2 -1]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = [1 1];
if ~isequal(y, ideal_y)
    status = 0;
end

x = ckhsig(-3+1i*3, 1, 'streaming', [0 0]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([-3+1i*2, -3+1i*3], 1, 'segment', [-1 0]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = [2 2];
if ~isequal(y, ideal_y)
    status = 0;
end

x = ckhsig([], 1, 'streaming', [1 0]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([-3+1i*2, -3+1i*3], 1, 'segment', [-1 0]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.idx = [3 2];
if ~isequal(y, ideal_y)
    status = 0;
end

x = ckhsig([-5+1i*8 3-1i*7.5], 1, 'streaming', [1 2]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([-5+1i*8 3-1i*7.5], 1, 'segment', [1 2]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.s = [(-5+1i*8)+2*(-3+1i*2), (3-1i*7.5)+2*(-3+1i*3)];
ideal_y.idx = [3 4];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: h = 3 taps (sparse). Use streaming filtering to perform circularly
%%       continuous filtering.
h = ckhfir([1+1i*2 0.2-1i*4 5+1i*2], 1, [-1 0 2], 1);
x = ckhsig((1:100)+1i*(11:110), 1, 'circular', [1 100]);
[y, h] = ckhfirapply(h, x);
x = ckhsig((1:100)+1i*(11:110), 1, 'streaming', [1 100]);
[y1, h] = ckhfirapply(h, x);
x.idx = x.idx + 100;
[y2, h] = ckhfirapply(h, x);
x.idx = x.idx + 100;
y3 = ckhfirapply(h, x);
y = ckhsiggrep(y, [0 300]);
y.type = 'segment';
y1.type = 'segment';
y2.type = 'segment';
y3.type = 'segment';
idx = [3 99];
if ~isequal(ckhsiggrep(y, idx), ckhsiggrep(y1, idx))
    status = 0;
end
idx = [100 199];
if ~isequal(ckhsiggrep(y, idx), ckhsiggrep(y2, idx))
    status = 0;
end
idx = [200 299];
if ~isequal(ckhsiggrep(y, idx), ckhsiggrep(y3, idx))
    status = 0;
end


%% Test: mode switching.
h = ckhfir([1 2], 1, [2 4], -1);
x = ckhsig(-3+1i*2, 1, 'streaming', [-1 -1]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([0 x.s], 1, 'segment', [-2 -1]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
if ~isequal(y, ideal_y)
    status = 0;
end

h.mode = 0;
x = ckhsig(-2+1i*4, 1, 'streaming', [0 0]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([-3+1i*2 -2+1i*4], 1, 'segment', [-1 0]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.s = zeros(size(x.s));
if ~isequal(y, ideal_y)
    status = 0;
end

h.mode = 1;
x = ckhsig(-1.2+1i*3.4, 1, 'streaming', [1 1]);
[y, h] = ckhfirapply(h, x);
ideal_zi = ckhsig([-2+1i*4 -1.2+1i*3.4], 1, 'segment', [0 1]);
if ~isequal(h.zi, ideal_zi)
    status = 0;
end
ideal_y = x;
ideal_y.s = 2*(-3+1i*2) + (-1.2+1i*3.4);
ideal_y.idx = [3 3];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Exit function.
end

