function status = ckhsigselftestisreal

%%
%       SYNTAX: status = ckhsigselftestisreal;
%
%  DESCRIPTION: Test ckhsigisreal.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal object. 
x = ckhsig;
tf = ckhsigisreal(x);
if tf ~= 1
    status = 0;
end


%% Test: x.s = real. One maximum sample. 
x = ckhsig([-1 2 4 3], 10, 'circular', [-1 2]);
tf = ckhsigisreal(x);
if tf ~= 1
    status = 0;
end


%% Test: x.s = real and imaginary part = 0.
x = ckhsig(complex([-1 -2 -4 -1 -3 -4 -2]), 10, 'segment', [2 8]);
tf = ckhsigisreal(x);
if tf ~= 1
    status = 0;
end


%% Test: x.s = complex. One maximum sample. 
x = ckhsig([-1 2 4 3]+1i*[2 -3 1 2], 10, 'circular', [0 3]);
tf = ckhsigisreal(x);
if tf ~= 0
    status = 0;
end


%% Test: x = 2x4 array.
x = cell(2, 4);
x{1} = ckhsig;
x{2} = ckhsig([-1 2 4 3],               10, 'circular',  [-1 2]);
x{3} = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'segment',   [-3 0]);
x{4} = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'streaming', [-3 0]);
x{5} = ckhsig([-1 -2 -4 -1 -3 -4 -2],   10, 'segment',   [2 8]);
x{6} = ckhsig(complex([-1 2 4 5]),      10, 'segment',   [-3 0]);
x{7} = ckhsig([],                       10, 'segment',   [-3 -4]);
x{8} = ckhsig([],                       10, 'streaming', [3 2]);
ideal_tf    = zeros(size(x));
ideal_tf(1) = 1;
ideal_tf(2) = 1;
ideal_tf(3) = 0;
ideal_tf(4) = 0;
ideal_tf(5) = 1;
ideal_tf(6) = 1;
ideal_tf(7) = 1;
ideal_tf(8) = 1;
if any(tf ~= ideal_tf)
    status = 0;
end


%% Exit function.
end






