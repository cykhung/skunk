function status = ckhfirselftestsetidx

%%
%       SYNTAX: status = ckhfirselftestsetidx;
%
%  DESCRIPTION: Test ckhfirsetidx.
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
h = ckhfirsetidx(h);
if (h.mode ~= 1) || (h.h ~= 1) || (h.fs ~= 1) || (h.idx ~= 0) || ...
        ~isempty(h.zi)
    status = 0;
end


%% Test: h.h = [1 1].
h   = ckhfir;
h.h = [1 1];
h = ckhfirsetidx(h);
if (h.mode ~= 1) || any(h.h ~= [1 1]) || (h.fs ~= 1) || ...
        any(h.idx ~= [0 1]) || ~isempty(h.zi)
    status = 0;
end


%% Test: h.h = [1 1 1].
h   = ckhfir;
h.h = [1 1 1];
h = ckhfirsetidx(h);
if (h.mode ~= 1) || any(h.h ~= [1 1 1]) || (h.fs ~= 1) || ...
        any(h.idx ~= [-1 0 1]) || ~isempty(h.zi)
    status = 0;
end


%% Test: h = cell array.
h = repmat(ckhfir, 2, 3);
h(1).h   = [1 1 1];
h(1).idx = [0 2 5];
h = ckhfirsetidx(h);
if (h(1).mode ~= 1) || any(h(1).h ~= [1 1 1]) || (h(1).fs ~= 1) || ...
        any(h(1).idx ~= [0 2 5]) || ~isempty(h(1).zi)
    status = 0;
end


%% Exit function.
end

