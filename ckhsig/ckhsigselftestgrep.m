function status = ckhsigselftestgrep

%%
%       SYNTAX: status = ckhsigselftestgrep;
%
%  DESCRIPTION: Test ckhsiggrep.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal object. didx = [0 1]. Crash. 
x = ckhsig([], 1, 'segment', []);
didx = [0 1];
try                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = signal object. didx = [0 -2]. Crash. 
x = ckhsig([], 1, 'segment', []);
x.s = 1:5;
didx = [0 -2];
try                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = segment signal object. didx = [1 0]. y = empty. 
x = ckhsig([], 1, 'segment', []);
x.s = 1:5;
x.fs = 11;
didx = [1 0];
[y, midx] = ckhsiggrep(x, didx);
if ~isempty(y.s) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ~isempty(midx{1})
    status = 0;
end


%% Test: x = streaming signal object. didx = [1 0]. y = empty. 
x = ckhsig([], 1, 'segment', []);
x.s = 1:5;
x.fs = 11;
x.type = 'streaming';
didx = [1 0];
[y, midx] = ckhsiggrep(x, didx);
if ~isempty(y.s) || ~strcmp(y.type, 'streaming') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ~isempty(midx{1})
    status = 0;
end


%% Test: x = circular signal object. didx = [11 10]. y = empty. 
x = ckhsig([], 1, 'segment', []);
x.s = 1:5;
x.fs = 11;
x.type = 'circular';
didx = [11 10];
[y, midx] = ckhsiggrep(x, didx);
if ~isempty(y.s) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ~isempty(midx{1})
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [-10 -2].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [-10 -2];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [9 6 8 1 9 6 8 1 9];
ideal_midx = [4 1 2 3 4 1 2 3 4];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [-3 0].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [-3 0];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [1 9 6 8];
ideal_midx = [3 4 1 2];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [0 1].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [0 1];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [8 1];
ideal_midx = [2 3];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [1 4].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [1 4];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [1 9 6 8];
ideal_midx = [3 4 1 2];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [3 10].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [3 10];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [6 8 1 9 6 8 1 9];
ideal_midx = [1 2 3 4 1 2 3 4];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = circular signal object. x.idx = [-1 2]. didx = [-3 4].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = [-3 4];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [1 9 6 8 1 9 6 8];
ideal_midx = [3 4 1 2 3 4 1 2];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [-10 -2].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [-10 -2];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = streaming signal object. x.idx = [-1 2]. didx = [-3 0].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'streaming';
x.idx = [-1 2];
didx = [-3 0];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [-3 0].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [-3 0];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [0 1].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [0 1];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [8 1];
ideal_midx = [2 3];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = streaming signal object. x.idx = [-1 2]. didx = [0 1].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'streaming';
x.idx = [-1 2];
didx = [0 1];
[y, midx] = ckhsiggrep(x, didx);
ideal_s = [8 1];
ideal_midx = [2 3];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'streaming') || ...
        (y.fs ~= 11) || any(y.idx ~= didx) || ...
        (max(abs(midx{1} - ideal_midx)) > 0)
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [1 4].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [1 4];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [3 10].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [3 10];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = segment signal object. x.idx = [-1 2]. didx = [-3 4].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
didx = [-3 4];
try                                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: x = multiple signal objects. didx = [3 4].
x = repmat(ckhsig([], 1, 'segment', []), 1, 4);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'segment';
x(2).idx = [1 6];
x(3).s = [-3 5 9];
x(3).fs = 14;
x(3).type = 'segment';
x(3).idx = [2 4];
x(4).s = [-3 5 9];
x(4).fs = 14;
x(4).type = 'streaming';
x(4).idx = [2 4];
didx = [3 4];
[y, midx] = ckhsiggrep(x, didx);
if (max(abs(y(1).s - [6 8])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= didx) || ...
        (max(abs(midx{1} - [1 2])) > 0)
    status = 0;
end
if (max(abs(y(2).s - [2 9])) > 0) || ~strcmp(y(2).type, 'segment') || ...
        (y(2).fs ~= 12) || any(y(2).idx ~= didx) || ...
        (max(abs(midx{2} - [3 4])) > 0)
    status = 0;
end
if (max(abs(y(3).s - [5 9])) > 0) || ~strcmp(y(3).type, 'segment') || ...
        (y(3).fs ~= 14) || any(y(3).idx ~= didx) || ...
        (max(abs(midx{3} - [2 3])) > 0)
    status = 0;
end
if (max(abs(y(4).s - [5 9])) > 0) || ~strcmp(y(4).type, 'streaming') || ...
        (y(4).fs ~= 14) || any(y(4).idx ~= didx) || ...
        (max(abs(midx{4} - [2 3])) > 0)
    status = 0;
end


%% Test: x = circular signal object. didx = {[3 4], [-2 1]}.
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
didx = {[3 4], [-2 1]};
[y, midx] = ckhsiggrep(x, didx);
if (max(abs(y(1).s - [6 8])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= didx{1}) || ...
        (max(abs(midx{1} - [1 2])) > 0)
    status = 0;
end
if (max(abs(y(2).s - [9 6 8 1])) > 0) || ~strcmp(y(2).type, 'circular') || ...
        (y(2).fs ~= 11) || any(y(2).idx ~= didx{2}) || ...
        (max(abs(midx{2} - [4 1 2 3])) > 0)
    status = 0;
end


%% Test: x = multiple signal objects. didx = {[-2 1], [3 4], [1 2]}.
x = repmat(ckhsig([], 1, 'segment', []), 1, 3);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'segment';
x(2).idx = [1 6];
x(3).s = [4 6 2 9 5 9];
x(3).fs = 22;
x(3).type = 'streaming';
x(3).idx = [1 6];
didx = {[-2 1], [3 4], [1 2]};
[y, midx] = ckhsiggrep(x, didx);
if (max(abs(y(1).s - [9 6 8 1])) > 0) || ~strcmp(y(1).type, 'circular') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= didx{1}) || ...
        (max(abs(midx{1} - [4 1 2 3])) > 0)
    status = 0;
end
if (max(abs(y(2).s - [2 9])) > 0) || ~strcmp(y(2).type, 'segment') || ...
        (y(2).fs ~= 12) || any(y(2).idx ~= didx{2}) || ...
        (max(abs(midx{2} - [3 4])) > 0)
    status = 0;
end
if (max(abs(y(3).s - [4 6])) > 0) || ~strcmp(y(3).type, 'streaming') || ...
        (y(3).fs ~= 22) || any(y(3).idx ~= didx{3}) || ...
        (max(abs(midx{3} - [1 2])) > 0)
    status = 0;
end


%% Test new syntax: [y, midx] = ckhsiggrep(x, Nsamples). Special case: Nsamples = 0.
x      = ckhsig([], 1, 'segment', []);
x.s    = [6 8 1 9];
x.fs   = 11;
x.type = 'circular';
x.idx  = [-1 2];
y = repmat(ckhsig([], 1, 'segment', []), 1, 2);
midx = {};
[y(1), midx{1}] = ckhsiggrep(x, [-1 -2]);
[y(2), midx{2}] = ckhsiggrep(x, 0);
if ~isequal(y(1), y(2))
    status = 0;
end
if ~isequal(midx{1}, midx{2})
    status = 0;
end


%% Test new syntax: [y, midx] = ckhsiggrep(x, Nsamples).
x = repmat(ckhsig([], 1, 'segment', []), 1, 2);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'segment';
x(2).idx = [1 6];
didx = {[-1 1], [1 1], 3, 1};
[y, midx] = ckhsiggrep([x x], didx);
if (~isequal(y(1), y(3))) || (~isequal(y(2), y(4)))
    status = 0;
end
if (~isequal(midx{1}, midx{3})) || (~isequal(midx{2}, midx{4}))
    status = 0;
end


%% Test new syntax: [y, midx] = ckhsiggrep(x, Nsamples).
x = repmat(ckhsig([], 1, 'segment', []), 1, 2);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'streaming';
x(2).idx = [1 6];
didx = {[-1 1], [1 1], 3, 1};
[y, midx] = ckhsiggrep([x x], didx);
if (~isequal(y(1), y(3))) || (~isequal(y(2), y(4)))
    status = 0;
end
if (~isequal(midx{1}, midx{3})) || (~isequal(midx{2}, midx{4}))
    status = 0;
end


%% Test: x = signal object. didx = [0 2.1]. Crash. 
x = ckhsig([], 1, 'segment', []);
x.s = 1:5;
didx = [0 2.1];
try                     %#ok<TRYNC>
    ckhsiggrep(x, didx);
    status = 0;
end


%% Test: New syntax. x = segment signal object. x.idx = [-1 2]. didx = [-3 4].
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'segment';
x.idx = [-1 2];
t = [-3 4]/x.fs;
try                                     %#ok<TRYNC>
    ckhsiggrep(x, 's', t);
    status = 0;
end


%% Test: x = Single signal object. Use t.
x = ckhsig;
x(1).s = [6 8 1 9 3 2 -8 -5 -1 0];
x(1).fs = 10;
x(1).type = 'segment';
x(1).idx = [-4 5];
[y, midx] = ckhsiggrep(x, 's', [-0.49 -0.35]);
if (max(abs(y(1).s - 6)) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 10) || any(y(1).idx ~= -4) || ...
        (max(abs(midx{1} - 1)) > 0)
    status = 0;
end
[y, midx] = ckhsiggrep(x, 's', [-0.32 -0.09]);
if (max(abs(y(1).s - [8 1 9])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 10) || any(y(1).idx ~= [-3 -1]) || ...
        (max(abs(midx{1} - [2 3 4])) > 0)
    status = 0;
end
[y, midx] = ckhsiggrep(x, 's', [-0.38 -0.01]);
if (max(abs(y(1).s - [8 1 9])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 10) || any(y(1).idx ~= [-3 -1]) || ...
        (max(abs(midx{1} - [2 3 4])) > 0)
    status = 0;
end
[y, midx] = ckhsiggrep(x, 's', [-0.15 0.01]);
if (max(abs(y(1).s - [9 3])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 10) || any(y(1).idx ~= [-1 0]) || ...
        (max(abs(midx{1} - [4 5])) > 0)
    status = 0;
end
[y, midx] = ckhsiggrep(x, 's', [0.35 0.55]);
if (max(abs(y(1).s - [-1 0])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 10) || any(y(1).idx ~= [4 5]) || ...
        (max(abs(midx{1} - [9 10])) > 0)
    status = 0;
end


%% Test: x = multiple signal objects. Use t.
x = repmat(ckhsig([], 1, 'segment', []), 1, 4);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'segment';
x(2).idx = [1 6];
x(3).s = [-3 5 9 1 2 3];
x(3).fs = 14;
x(3).type = 'segment';
x(3).idx = [2 7];
x(4).s = [-3 5 9 1 2 3];
x(4).fs = 14;
x(4).type = 'streaming';
x(4).idx = [2 7];
t = [3 4]/12;
[y, midx] = ckhsiggrep(x, 's', t);
if (max(abs(y(1).s - 6)) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= 3) || ...
        (max(abs(midx{1} - 1)) > 0)
    status = 0;
end
if (max(abs(y(2).s - [2 9])) > 0) || ~strcmp(y(2).type, 'segment') || ...
        (y(2).fs ~= 12) || any(y(2).idx ~= [3 4]) || ...
        (max(abs(midx{2} - [3 4])) > 0)
    status = 0;
end
if (max(abs(y(3).s - 9)) > 0) || ~strcmp(y(3).type, 'segment') || ...
        (y(3).fs ~= 14) || any(y(3).idx ~= 4) || ...
        (max(abs(midx{3} - 3)) > 0)
    status = 0;
end
if (max(abs(y(4).s - 9)) > 0) || ~strcmp(y(4).type, 'streaming') || ...
        (y(4).fs ~= 14) || any(y(4).idx ~= 4) || ...
        (max(abs(midx{4} - 3)) > 0)
    status = 0;
end
[y, midx] = ckhsiggrep(x, 's', [3 5]/12);
if (max(abs(y(1).s - [6 8])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= [3 4]) || ...
        (max(abs(midx{1} - [1 2])) > 0)
    status = 0;
end


%% Test: x = circular signal object. didx = {[3 4], [-2 1]}.
x = ckhsig([], 1, 'segment', []);
x.s = [6 8 1 9];
x.fs = 11;
x.type = 'circular';
x.idx = [-1 2];
t = {[3 4]/x.fs, [-2 1]/x.fs};
[y, midx] = ckhsiggrep(x, 's', t);
if (max(abs(y(1).s - [6 8])) > 0) || ~strcmp(y(1).type, 'segment') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= [3 4]) || ...
        (max(abs(midx{1} - [1 2])) > 0)
    status = 0;
end
if (max(abs(y(2).s - [9 6 8 1])) > 0) || ~strcmp(y(2).type, 'circular') || ...
        (y(2).fs ~= 11) || any(y(2).idx ~= [-2 1]) || ...
        (max(abs(midx{2} - [4 1 2 3])) > 0)
    status = 0;
end


%% Test: x = multiple signal objects. t = {...}.
x = repmat(ckhsig([], 1, 'segment', []), 1, 3);
x(1).s = [6 8 1 9];
x(1).fs = 11;
x(1).type = 'circular';
x(1).idx = [-1 2];
x(2).s = [4 6 2 9 5 9];
x(2).fs = 12;
x(2).type = 'segment';
x(2).idx = [1 6];
x(3).s = [4 6 2 9 5 9];
x(3).fs = 22;
x(3).type = 'streaming';
x(3).idx = [1 6];
t = {[-2 1]/x(1).fs, [3 4]/x(2).fs, [1 2]/x(3).fs};
[y, midx] = ckhsiggrep(x, 's', t);
if (max(abs(y(1).s - [9 6 8 1])) > 0) || ~strcmp(y(1).type, 'circular') || ...
        (y(1).fs ~= 11) || any(y(1).idx ~= [-2 1]) || ...
        (max(abs(midx{1} - [4 1 2 3])) > 0)
    status = 0;
end
if (max(abs(y(2).s - [2 9])) > 0) || ~strcmp(y(2).type, 'segment') || ...
        (y(2).fs ~= 12) || any(y(2).idx ~= [3 4]) || ...
        (max(abs(midx{2} - [3 4])) > 0)
    status = 0;
end
if (max(abs(y(3).s - [4 6])) > 0) || ~strcmp(y(3).type, 'streaming') || ...
        (y(3).fs ~= 22) || any(y(3).idx ~= [1 2]) || ...
        (max(abs(midx{3} - [1 2])) > 0)
    status = 0;
end


%% Exit function.
end

