function status = ckhsigselftestdelay

%%
%       SYNTAX: status = ckhsigselftestdelay;
%
%  DESCRIPTION: Test ckhsigdelay.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: D = 0. For all 3 signal types.
D       = 0;
x       = ckhsig;
x(1)    = ckhsig([1 2 3], 1, 'segment',   [1 3]);
x(2)    = ckhsig([1 2 3], 1, 'circular',  [-1 1]);
x(3)    = ckhsig([1 2 3], 1, 'streaming', [-4 -2]);
ideal_y = x;
y       = ckhsigdelay(x, D);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: D = 2. For all 3 signal types. 
D              = 2;
x              = ckhsig;
x(1)           = ckhsig([1 2 3], 10, 'segment',   [1 3]);
x(2)           = ckhsig([1 2 3], 1,  'circular',  [-1 1]);
x(3)           = ckhsig([1 2 3], 1,  'streaming', [-4 -2]);
ideal_y        = x;
ideal_y(1).idx = [1 3] + 2;
ideal_y(2).s   = [2 3 1];
ideal_y(3).idx = [-4 -2] + 2;
y              = ckhsigdelay(x, D);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: D = 3.45. Ntaps = [NaN 101 NaN]. For all 3 signal types. 
Ntaps          = 101;
D              = 3.45 - fix(3.45);  % 0.45; very tiny difference.
mode           = 1;
fs             = 1;
% idx            = [];
% h              = ckhfir('lagrangefd', Ntaps, D, mode, fs, idx);
[h, i0]        = designFracDelayFIR(D, Ntaps);
h              = ckhfir(h, fs, 0:(length(h)-1), mode);
h.idx          = h.idx - i0;
rng(0, 'twister');
x              = ckhsig;
x(1)           = ckhsig(rand(1,1000), 1, 'segment', [1 1000]);
x(2)           = ckhsig(rand(1,20) + 1i*rand(1,20), 1, 'circular', [-4 15]);
x(3)           = ckhsig(rand(1,2000) + 1i*rand(1,2000), 1, 'streaming', [-2200 -201]);
ideal_y        = x;
ideal_y(1).idx = [1 1000] + 3;
ideal_y(2).s   = [x(2).s(end-2:end), x(2).s(1:end-3)];
ideal_y(3).idx = [-2200 -201] + 3;
ideal_y        = ckhfirapply(h, ideal_y);
D              = 3.45;
y              = ckhsigdelay(x, D, [NaN 101 NaN]);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: D = -3. For all 3 signal types. 
D              = -3;
x              = ckhsig;
x(1)           = ckhsig([1 2 3], 10, 'segment',   [1 3]);
x(2)           = ckhsig([1 2 3], 10, 'circular',  [-1 1]);
x(3)           = ckhsig([1 2 3], 10, 'streaming', [-4 -2]);
ideal_y        = x;
ideal_y(1).idx = [1 3] - 3;
ideal_y(3).idx = [-4 -2] - 3;
y = ckhsigdelay(x, D);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: D = -3.29. Ntaps = [101 NaN NaN]. For all 3 signal types. 
Ntaps          = 101;
D              = -3.29 - fix(-3.29) + 1;
mode           = 1;
fs             = 10;
% idx            = [];
% h              = ckhfir('lagrangefd', Ntaps, D, mode, fs, idx);
[h, i0]        = designFracDelayFIR(D, Ntaps);
h              = ckhfir(h, fs, 0:(length(h)-1), mode);
h.idx          = h.idx - i0 - 1;
rng(0, 'twister');
x              = ckhsig;
x(1)           = ckhsig(rand(1,1000), 10, 'segment', [1 1000]);
x(2)           = ckhsig(rand(1,20) + 1i*rand(1,20), 10, 'circular', [-4 15]);
x(3)           = ckhsig(rand(1,2000) + 1i*rand(1,2000), 10, 'streaming', [-2200 -201]);
ideal_y        = x;
ideal_y(1).idx = [1 1000] - 3;
ideal_y(2).s   = [x(2).s(4:end), x(2).s(1:3)];
ideal_y(3).idx = [-2200 -201] - 3;
ideal_y        = ckhfirapply(h, ideal_y);
D              = -3.29;
y              = ckhsigdelay(x, D, [101 NaN NaN]);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: D = -3.29. Ntaps = 51. For all 3 signal types. 
Ntaps          = 51;
D              = -3.29 - fix(-3.29) + 1;
mode           = 1;
fs             = 10;
[h, i0]        = designFracDelayFIR(D, Ntaps);
h              = ckhfir(h, fs, 0:(length(h)-1), mode);
h.idx          = h.idx - i0 - 1;
rng(0, 'twister');
x              = ckhsig;
x(1)           = ckhsig(rand(1,1000), 10, 'segment', [1 1000]);
x(2)           = ckhsig(rand(1,20) + 1i*rand(1,20), 10, 'circular', [-4 15]);
x(3)           = ckhsig(rand(1,2000) + 1i*rand(1,2000), 10, 'streaming', [-2200 -201]);
ideal_y        = x;
ideal_y(1).idx = [1 1000] - 3;
ideal_y(2).s   = [x(2).s(4:end), x(2).s(1:3)];
ideal_y(3).idx = [-2200 -201] - 3;
ideal_y        = ckhfirapply(h, ideal_y);
D              = -3.29;
y              = ckhsigdelay(x, D, 51);
if ~isequal(y, ideal_y)
    status = 0;
end


%% Exit function.
end

