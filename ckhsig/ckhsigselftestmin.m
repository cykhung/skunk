function  status = ckhsigselftestmin

%%
%       SYNTAX: status = ckhsigselftestmin;
%
%  DESCRIPTION: Test ckhsigmin.m.
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
[min_s, tidx] = ckhsigmin(x);
if ~isnan(min_s) || ~isnan(tidx)
    status = 0;
end
x = ckhsig;
x.idx = [2 1];
[min_s, tidx] = ckhsigmin(x);
if ~isnan(min_s) || ~isnan(tidx)
    status = 0;
end


%% Test: x.s = real. One minimum sample. 
x = ckhsig([1 2 4 3], 10, 'circular', [-1 2]);
[min_s, tidx] = ckhsigmin(x);
if (min_s ~= 1) || (tidx ~= -1)
    status = 0;
end


%% Test: x.s = real. Two minimum samples. 
x = ckhsig([-1 -2 -4 -1 -3 -4 -2], 10, 'segment', [2 8]);
[min_s, tidx] = ckhsigmin(x);
if (min_s ~= -4) || (tidx ~= 4)
    status = 0;
end


%% Test: x.s = complex. One minimum sample. 
x = ckhsig([-1 2 4 3]+1i*[2 -3 1 2], 10, 'circular', [0 3]);
[min_s, tidx] = ckhsigmin(x);
if (min_s ~= (-1+1i*2)) || (tidx ~= 0)
    status = 0;
end


%% Test: x.s = complex. Two minimum samples. 
x = ckhsig([-1 0.2 4 1]+1i*[2 -1 1 0.2], 10, 'streaming', [-3 0]);
[min_s, tidx] = ckhsigmin(x);
if (min_s ~= (0.2-1i*1)) || (tidx ~= -2)
    status = 0;
end


%% Test: x = 2x4 array.
x    = repmat(ckhsig, 2, 4);
x(2) = ckhsig([-1 2 4 3], 10, 'circular', [-1 2]);
x(3) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'segment', [-3 0]);
x(4) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'streaming', [-3 0]);
x(5) = ckhsig([-1 -2 -4 -1 -3 -4 -2], 10, 'segment', [2 8]);
x(6) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'segment', [-3 0]);
x(7) = ckhsig([], 10, 'segment', [-3 -4]);
x(8) = ckhsig([], 10, 'streaming', [3 2]);
[min_s, tidx] = ckhsigmin(x);
if any(size(min_s) ~= [2 4]) || any(size(tidx) ~= [2 4])
    status = 0;
end
for n = 1:6
    [min_s_1, tidx_1] = ckhsigmin(x(n));
    if (max(abs(min_s(n) - min_s_1)) > 0) || (max(abs(tidx(n) - tidx_1)) > 0)
        status = 0;
    end
end
for n = 7:8
    if ~isnan(min_s(n)) || ~isnan(tidx(n))
        status = 0;
    end
end


%% Exit function.
end






