function status = ckhfirselftestfull

%%
%       SYNTAX: status = ckhfirselftestfull;
%
%  DESCRIPTION: Test ckhfirfull.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: Special case. Default structure (i.e. h.h = 1).
h = ckhfir;
h = ckhfirfull(h);
if (h.mode ~= 1)        || ...
        (h.h ~= 1)      || ...
        (h.idx ~= 0)    || ... 
        (h.fs ~= 1) 
    status = 0;
end


%% Test: Input h is full already but h.idx is not in ascending nor
%%       descending order.
h = repmat(ckhfir, 1, 3);
h(1).h = [1 2 3];
h(2).h = 1:4;
h(3).h = 10:13;
h(1).idx = [-10 -8 -9];
h(2).idx = [-2 -1 0 1];
h(3).idx = [5 7 8 6];
h = ckhfirfull(h);
if any(size(h) ~= [1 3])
    status = 0;
end
for n = 1:numel(h)
    switch n
    case 1
        ideal_h = [1 3 2];
        ideal_idx = [-10 -9 -8];
    case 2
        ideal_h = 1:4;
        ideal_idx = [-2 -1 0 1];
    case 3
        ideal_h = [10 13 11 12];
        ideal_idx = [5 6 7 8];
    otherwise
        error('Invalid n.');
    end
    if (h(n).mode ~= 1)                 || ...
            any(h(n).h ~= ideal_h)      || ...
            any(h(n).idx ~= ideal_idx)  || ...
            (h(n).fs ~= 1)
        status = 0;
    end
end


%% Test: Input h is sparse.
h = repmat(ckhfir, 1, 3);
h(1) = ckhfir([6 4 3 7], 1, [-3 -8 -5 -6], 1);
h(2) = ckhfir([1 5 9 6], 1, [-1 2 -3 0], 1);
h(3) = ckhfir([7 2 4], 1, [5 9 3], 1);
h = h(:);
h = ckhfirfull(h);
if any(size(h) ~= [3 1])
    status = 0;
end
for n = 1:numel(h)
    switch n
    case 1
        ideal_h = [4 0 7 3 0 6];
        ideal_idx = (-8:-3);
    case 2
        ideal_h = [9 0 1 6 0 5];
        ideal_idx = (-3:2);
    case 3
        ideal_h = [4 0 7 0 0 0 2];
        ideal_idx = (3:9);
    otherwise
        error('Invalid n.');
    end
    if (h(n).mode ~= 1)                 || ...
            any(h(n).h ~= ideal_h)      || ...
            any(h(n).idx ~= ideal_idx)  || ...
            (h(n).fs ~= 1)
        status = 0;
    end
end


%% Exit function.
end

