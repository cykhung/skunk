function status = ckhfirselftestfir

%%
%       SYNTAX: status = ckhfirselftestfir;
%
%  DESCRIPTION: Test ckhfir.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test.
h = ckhfir((1:3).');
if any(size(h.h) ~= [1 3]) || any(h.h ~= 1:3)
    status = 0;
end


%% Test.
h = ckhfir((1:3).', 1e3);
if any(size(h.h) ~= [1 3]) || any(h.h ~= 1:3)
    status = 0;
end


%% Test.
h = ckhfir((1:3).', 1e3, [-1 2 3].');
if any(size(h.h) ~= [1 3]) || any(h.h ~= 1:3) || ...
        any(size(h.idx) ~= [1 3]) || any(h.idx ~= [-1 2 3])
    status = 0;
end


%% Test.
h = ckhfir((1:3).', 1e3, [-1 2 3].', 1);
if any(size(h.h) ~= [1 3]) || any(h.h ~= 1:3) || ...
        any(size(h.idx) ~= [1 3]) || any(h.idx ~= [-1 2 3])
    status = 0;
end


%% Exit function.
end

