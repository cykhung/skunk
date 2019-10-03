function status = ckhsigselftestintersect

%%
%       SYNTAX: status = ckhsigselftestintersect;
%
%  DESCRIPTION: Test ckhsigintersect.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = 1 signal object. y = x. 
x = ckhsig([1 2 3], 10, 'circular', [-1 1]);
[y, midx] = ckhsigintersect(x);
if ~isequal(x, y) || any(midx{1} ~= [1 2 3])
    status = 0;
end
x = ckhsig([1 2 3], 10, 'segment', [3 5]);
[y, midx] = ckhsigintersect(x);
if ~isequal(x, y) || any(midx{1} ~= [1 2 3])
    status = 0;
end
x = ckhsig([4 5 9], 10, 'segment', [3 5]);
[y, midx] = ckhsigintersect(x);
if ~isequal(x, y) || any(midx{1} ~= [1 2 3])
    status = 0;
end


%% Test: x = array of 2 signal objects. Crash due to different sampling rates.
x = [ckhsig([], 10, 'circular', [-1 -2]), ...
     ckhsig([1 2 3], 11, 'circular', [-1 1])];
try                                                     %#ok<TRYNC>
    ckhsigintersect(x);
    status = 0;
end


%% Test: x = array of 2 signal objects. Crash due to input streaming signal.
x = [ckhsig([], 10, 'circular', [-1 -2]), ...
     ckhsig([1 2 3], 11, 'streaming', [-1 1])];
try                                                     %#ok<TRYNC>
    ckhsigintersect(x);
    status = 0;
end


%% Test: x = array of 2 signal objects. x(1) = empty. y = empty signal
%%       structures. 
x = [ckhsig([], 10, 'circular', [-1 -2]), ...
     ckhsig([1 2 3], 10, 'circular', [-1 1])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [-1 -2];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end
x = [ckhsig([], 10, 'segment', [3 2]); ...
     ckhsig([1 2 3], 10, 'circular', [-1 1])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [2 1]) || any(size(midx) ~= [2 1])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [3 2];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end
x = [ckhsig([], 10, 'segment', [3 2]); ...
     ckhsig([1 2 3], 10, 'segment', [-1 1])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [2 1]) || any(size(midx) ~= [2 1])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [3 2];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end


%% Test: x = array of 2 signal objects. No intersection. y = empty signal 
%%       structures. 
x = [ckhsig([-3 4 9 8 0], 10, 'segment', [-3 1]), ...
     ckhsig([1 2 3], 10, 'segment', [2 4])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [2 1];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end
x = [ckhsig([9 8 0], 10, 'segment', [-6 -4]), ...
     ckhsig([1 3], 10, 'segment', [3 4])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [3 2];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end


%% Test: x = 2x3 array of signal objects. No intersection. y = empty signal 
%%       structures. 
x = [ckhsig([-3 4 9 8 0], 10, 'circular', [-3 1]),      ...
     ckhsig([1 2 3], 10, 'circular', [2 4]),            ...
     ckhsig([-9 8 5 -3], 10, 'circular', [100 103]),    ...
     ckhsig([1 2 3], 10, 'segment', [12 14]),           ...
     ckhsig([1 2 3], 10, 'segment', [25 27]),           ...
     ckhsig([1 2 3], 10, 'segment', [25 27])];
x = reshape(x, 2, 3);
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [2 3]) || any(size(midx) ~= [2 3])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [];
    ideal.idx = [25 24];
    if ~isequal(ideal, y(n)) || ~isempty(midx{n})
        status = 0;
    end
end


%% Test: x = array of 2 circular signal objects. Intersection exists.
%%       x(1) = circular, has N samples.
%%      x(2) = circular, has N samples.
%%       y = circular signal structures. 
x = [ckhsig([-3 4 9 8 0], 10, 'circular', [-3 1]), ...
     ckhsig([1 2 3 4 5], 10, 'circular', [2 6])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    ideal.idx = [];
    ideal.s = [x(n).s, x(n).s];
    ideal.idx = [-3 6];
    if ~isequal(ideal, y(n)) || any(midx{n} ~= [1:5, 1:5])
        status = 0;
    end
end


%% Test: x = array of 2 circular signal objects. Intersection exists.
%%       x(1) = circular, has N samples.
%%       x(2) = circular, has N samples.
%%       y = segment signal structures (not circularly continuous due to gap in
%%           time).
x = [ckhsig([-3 4 9 8 0], 10, 'circular', [-3 1]), ...
     ckhsig([1 2 3 4 5], 10, 'circular', [3 7])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    if n == 1
        ideal.idx = [];
        ideal.s = [x(n).s, x(n).s, x(n).s(1)];
        ideal.idx = [-3 7];
        ideal.type = 'segment';
        ideal_midx = [1:5, 1:5, 1];
    else
        ideal.idx = [];
        ideal.s = [x(n).s(end), x(n).s, x(n).s];
        ideal.idx = [-3 7];
        ideal.type = 'segment';
        ideal_midx = [5, 1:5, 1:5];
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: x = array of 2 circular signal objects. Intersection exists.
%%       x(1) = circular, has N samples.
%%       x(2) = circular, has 1.5*N samples.
%%       y = segment signal structures.
x = [ckhsig([-3 4 9 8 0 9], 10, 'circular', [-3 2]), ...
     ckhsig([1 2 3], 10, 'circular', [4 6])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    if n == 1
        ideal.idx = [];
        ideal.s = [x(n).s, x(n).s(1:4)];
        ideal.idx = [-3 6];
        ideal.type = 'segment';
        ideal_midx = [1:6, 1:4];
    else
        ideal.idx = [];
        ideal.s = [x(n).s(end), x(n).s, x(n).s, x(n).s];
        ideal.idx = [-3 6];
        ideal.type = 'segment';
        ideal_midx = [3, 1:3, 1:3, 1:3];
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: x = array of 2 circular signal objects. Intersection exists.
%%       x(1) = circular.
%%       x(2) = circular.
%%       y(1) = segment.
%%       y(2) = circular.
x = [ckhsig([-3 4 9 8 0 9], 10, 'circular', [-3 2]), ...
     ckhsig([2 3], 10, 'circular', [5 6])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    if n == 1
        ideal.idx = [];
        ideal.s = [x(n).s, x(n).s(1:4)];
        ideal.idx = [-3 6];
        ideal.type = 'segment';
        ideal_midx = [1:6, 1:4];
    else
        ideal.idx = [];
        ideal.s = [x(n).s, x(n).s, x(n).s, x(n).s, x(n).s];
        ideal.idx = [-3 6];
        ideal.type = 'circular';
        ideal_midx = [1:2, 1:2, 1:2, 1:2, 1:2];
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: x = array of 2 signal objects. Intersection exists.
%%       x(1) = segment.
%%       x(2) = segment.
%%       y(1) = segment.
%%       y(2) = segment.
x = [ckhsig([-3 4 9 8 0 9], 10, 'segment', [-3 2]), ...
     ckhsig([2 3 9 7 -9], 10, 'segment', [0 4])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    if n == 1
        ideal.idx = [];
        ideal.s = x(n).s(4:6);
        ideal.idx = [0 2];
        ideal.type = 'segment';
        ideal_midx = (4:6);
    else
        ideal.idx = [];
        ideal.s = x(n).s(1:3);
        ideal.idx = [0 2];
        ideal.type = 'segment';
        ideal_midx = 1:3;
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: x = array of 2 signal objects. Intersection exists.
%%       x(1) = segment.
%%       x(2) = circular.
%%       y(1) = segment.
%%       y(2) = segment.
x = [ckhsig([-3 4 9 8 0 9], 10, 'segment', [-3 2]), ...
     ckhsig([2 3 9 7 -9], 10, 'circular', [0 4])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [1 2]) || any(size(midx) ~= [1 2])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    if n == 1
        ideal.idx = [];
        ideal.s = x(n).s;
        ideal.idx = [-3 2];
        ideal.type = 'segment';
        ideal_midx = 1:6;
    else
        ideal.idx = [];
        ideal.s = [x(n).s(3:5), x(n).s(1:3)];
        ideal.idx = [-3 2];
        ideal.type = 'segment';
        ideal_midx = [3:5, 1:3];
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: x = 4x1 array of signal objects. Intersection exists.
%%       x(1) = circular.
%%       x(2) = circular.
%%       x(3) = segment.
%%       x(4) = segment.
x = [ckhsig([-3 4 9 8], 10, 'circular', [-4 -1]);   ...
     ckhsig([2 3 -4], 10, 'circular', [1 3]);       ...
     ckhsig(1:13, 10, 'segment', [-6 6]);           ...
     ckhsig(-4:3, 10, 'segment', [-4 3])];
[y, midx] = ckhsigintersect(x);
if any(size(y) ~= [4 1]) || any(size(midx) ~= [4 1])
    status = 0;
end
for n = 1:numel(x)
    ideal = x(n);
    switch n
    case 1
        ideal.idx = [];
        ideal.s = [x(n).s, x(n).s];
        ideal.idx = [-4 3];
        ideal.type = 'circular';
        ideal_midx = [1:4, 1:4];
    case 2
        ideal.idx = [];
        ideal.s = [x(n).s(2:3), x(n).s, x(n).s];
        ideal.idx = [-4 3];
        ideal.type = 'segment';
        ideal_midx = [2:3, 1:3, 1:3];
    case 3
        ideal.idx = [];
        ideal.s = x(n).s(3:10);
        ideal.idx = [-4 3];
        ideal.type = 'segment';
        ideal_midx = (3:10);
    case 4
        ideal.idx = [];
        ideal.s = x(n).s;
        ideal.idx = [-4 3];
        ideal.type = 'segment';
        ideal_midx = 1:8;
    end        
    if ~isequal(ideal, y(n)) || any(midx{n} ~= ideal_midx)
        status = 0;
    end
end


%% Test: Output is a list of signal objects.
%%       x = 4x1 array of signal objects. Intersection exists.
%%       x(1) = circular.
%%       x(2) = circular.
%%       x(3) = segment.
%%       x(4) = segment.
x = [ckhsig([-3 4 9 8], 10, 'circular', [-4 -1]);   ...
     ckhsig([2 3 -4], 10, 'circular', [1 3]);       ...
     ckhsig(1:13, 10, 'segment', [-6 6]);           ...
     ckhsig(-4:3, 10, 'segment', [-4 3])];
[y, midx] = ckhsigintersect(x, 'array');
[y1, y2, y3, y4, midx1] = ckhsigintersect(x, 'list');
if ~isequal(y(1), y1) || ~isequal(y(2), y2) || ~isequal(y(3), y3) || ...
        ~isequal(y(4), y4) || ~isequal(midx, midx1)
    status = 0;
end


%% Exit function.
end

