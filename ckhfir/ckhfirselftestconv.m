function status = ckhfirselftestconv

%%
%       SYNTAX: status = ckhfirselftestconv;
%
%  DESCRIPTION: Test ckhfirconv.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: Special case. Default object (i.e. h.h = 1).
h = ckhfir;
w = ckhfirconv(h);
if ~isequal(w, h)
    status = 0;
end


%% Test: Sampling rate mismatch.
h = repmat(ckhfir, 1, 2);
h(1) = ckhfir(1, 1, [], 1);
h(2) = ckhfir(1, 10, [], 1);
try                                             %#ok<TRYNC>
    ckhfirconv(h);
    status = 0;
end


%% Test: 2 FIR filter structures.
h = repmat(ckhfir, 1, 2);
h(1) = ckhfir([1 2 3], 1, [-4 -2 -1], 1);
h(2) = ckhfir([2 5 3], 1, [-5 -2 -1], 1);
w = ckhfirconv(h);
if max(abs(w.idx - (-9:-2)))
    status = 0;
end
if max(abs(w.h - conv([1 0 2 3], [2 0 0 5 3])))
    status = 0;
end


%% Test: 4 FIR filter structures.
h    = repmat(ckhfir, 1, 4);
h(1) = ckhfir([1 2 3], 1, [1 5 2], 1);
h(2) = ckhfir([4 5 6], 1, [-2 -1 3], 1);
h(3) = ckhfir([7 8], 1, [0 1], 1);
h(4) = ckhfir([9 10 11], 1, [-1 -5 -2], 1);
w = ckhfirconv(h);
if max(abs(w.idx - (-6:8)))
    status = 0;
end
h = conv([1 3 0 0 2], [4 5 0 0 0 6]);
h = conv(h, [7 8]);
h = conv(h, [10 0 0 11 9]);
if max(abs(w.h - h))
    status = 0;
end


%% Exit function.
end

