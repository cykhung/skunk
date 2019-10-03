function status = ckhsigselftestmax

%%
%       SYNTAX: status = ckhsigselftestmax;
%
%  DESCRIPTION: Test ckhsigmax.m.
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
[max_s, tidx] = ckhsigmax(x);
if ~isnan(max_s) || ~isnan(tidx)
    status = 0;
end
x = ckhsig;
x.idx = [2 1];
[max_s, tidx] = ckhsigmax(x);
if ~isnan(max_s) || ~isnan(tidx)
    status = 0;
end


%% Test: x.s = real. One maximum sample. 
x = ckhsig([-1 2 4 3], 10, 'circular', [-1 2]);
[max_s, tidx] = ckhsigmax(x);
if (max_s ~= 4) || (tidx ~= 1)
    status = 0;
end


%% Test: x.s = real. Two maximum samples. 
x = ckhsig([-1 -2 -4 -1 -3 -4 -2], 10, 'segment', [2 8]);
[max_s, tidx] = ckhsigmax(x);
if (max_s ~= -1) || (tidx ~= 2)
    status = 0;
end


%% Test: x.s = complex. One maximum sample. 
x = ckhsig([-1 2 4 3]+1i*[2 -3 1 2], 10, 'circular', [0 3]);
[max_s, tidx] = ckhsigmax(x);
if (max_s ~= (4+1i*1)) || (tidx ~= 2)
    status = 0;
end


%% Test: x.s = complex. Two maximum samples. 
x = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'streaming', [-3 0]);
[max_s, tidx] = ckhsigmax(x);
if (max_s ~= (2-1i*5)) || (tidx ~= -2)
    status = 0;
end


%% Test: x = 2x4 array.
x    = repmat(ckhsig, 2, 4);
x(1) = ckhsig;
x(2) = ckhsig([-1 2 4 3], 10, 'circular', [-1 2]);
x(3) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'segment', [-3 0]);
x(4) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'streaming', [-3 0]);
x(5) = ckhsig([-1 -2 -4 -1 -3 -4 -2], 10, 'segment', [2 8]);
x(6) = ckhsig([-1 2 4 5]+1i*[2 -5 1 2], 10, 'segment', [-3 0]);
x(7) = ckhsig([], 10, 'segment', [-3 -4]);
x(8) = ckhsig([], 10, 'streaming', [3 2]);
[max_s, tidx] = ckhsigmax(x);
if any(size(max_s) ~= [2 4]) || any(size(tidx) ~= [2 4])
    status = 0;
end
for n = 1:6
    [max_s_1, tidx_1] = ckhsigmax(x(n));
    if (max(abs(max_s(n) - max_s_1)) > 0) || (max(abs(tidx(n) - tidx_1)) > 0)
        status = 0;
    end
end
for n = 7:8
    if ~isnan(max_s(n)) || ~isnan(tidx(n))
        status = 0;
    end
end


%% Exit function.
end






