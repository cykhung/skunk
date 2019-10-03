function status = ckhsigselftestcorr

%%
%       SYNTAX: status = ckhsigselftestcorr;
%
%  DESCRIPTION: Test ckhsigcorr.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty.
x = ckhsig;
p = ckhsig;
p.s = [1 2];
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: p = empty.
x = ckhsig;
x.s = [1 2];
p = ckhsig;
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: x = array of sig. One of its elements is empty.
x = [ckhsig, ckhsig];
x(1).s = 4;
p = ckhsig;
p.s = [1 2];
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: p = array of ckhsig. One of its elements is empty.
x = ckhsig;
x.s = [1 2];
p = {ckhsig; ckhsig};
p{1}.s = 3;
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: x.fs ~= p.fs.
x = ckhsig;
x.s = [1 2];
x.fs = 3;
p = ckhsig;
p.s = [1 2];
p.fs = 5;
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: x.type = 'streaming'.
x = ckhsig;
x.s = [1 2];
x.fs = 3;
x.type = 'streaming';
p = ckhsig;
p.s = [1 2];
p.fs = 5;
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: p.type = 'streaming'.
x = ckhsig;
x.s = [1 2];
x.fs = 3;
p = ckhsig;
p.s = [1 2];
p.fs = 5;
p.type = 'streaming';
try                 %#ok
    ckhsigcorr(x, p);
    status = 0;
end


%% Test: x = real, segment.
%%       p = real, segment.
%%       Define both x.idx and p.idx.
x = ckhsig;
x.s = [1 2 3];
x.idx = [1 3];
x.fs = 4;
p = ckhsig;
p.s = [4 5];
p.idx = [2 3];
p.fs = 4;
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.s = [5 14 23 12];
ideal_y.idx = [-2 1];
ideal_y.fs = 4;
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = real, segment.
%%       p = real, segment.
%%       Neither x.idx and p.idx are defined.
x = ckhsig;
x.s = [1 2 3];
p = ckhsig;
p.s = [4 5];
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.s = [5 14 23 12];
ideal_y.idx = [-1 2];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = real, segment.
%%       p = real, segment.
%%       Define x.idx but not p.idx.
x = ckhsig;
x.s = [1 2 3];
x.idx = [-2 0];
p = ckhsig;
p.s = [4 5];
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.s = [5 14 23 12];
ideal_y.idx = [-3 0];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = real, segment.
%%       p = real, segment.
%%       Define p.idx but not x.idx.
x = ckhsig;
x.s = [1 2 3];
p = ckhsig;
p.s = [4 5];
p.idx = [-2 -1];
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.s = [5 14 23 12];
ideal_y.idx = [1 4];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = complex, segment.
%%       p = complex, segment.
%%       Define p.idx and x.idx.
x = ckhsig;
x.s = [1 2 3] + sqrt(-1)*[6 7 -8];
x.idx = [-1 1];
p = ckhsig;
p.s = [4 5] + sqrt(-1)*[9 -4];
p.idx = [-1 0];
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
j = sqrt(-1);
ideal_y.s = [-19+j*34, 40+j*58, 118-j*18, -60-j*59];
ideal_y.idx = [-1 2];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = real, circular.
%%       p = real, segment.
%%       Define p.idx and x.idx.
x = ckhsig;
x.s = [1 2 3];
x.idx = [1 3];
x.fs = 4;
x.type = 'circular';
p = ckhsig;
p.s = [4 5];
p.idx = [2 3];
p.fs = 4;
p.type = 'segment';
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.s = [17 14 23];
ideal_y.idx = [1 3];
ideal_y.fs = 4;
ideal_y.type = 'circular';
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x = complex, circular.
%%       p = complex, segment.
%%       Define p.idx and x.idx.
x = ckhsig;
x.s = [1 2 3] + sqrt(-1)*[6 7 -8];
x.idx = [-1 1];
x.type = 'circular';
p = ckhsig;
p.s = [4 5] + sqrt(-1)*[9 -4];
p.idx = [-1 0];
y = ckhsigcorr(x, p);
ideal_y = ckhsig;
ideal_y.type = 'circular';
j = sqrt(-1);
ideal_y.s = [-79-j*25 40+j*58 118-j*18];
ideal_y.idx = [-1 1];
if ~isequal(y, ideal_y)
    status = 0;
end


%% Test: x(1) = complex, segment.
%%       x(2) = complex, segment.
%%
%%       p = single object, complex, segment.
p = ckhsig;
p.s = [10+j*20, 20-j*30];
p.idx = [-4 -3];
p.fs = 5;
p.type = 'segment';

x = ckhsig;
x(1).s = [1+j*2, 2+j, 3-j*2, 4+j*3];
x(1).idx = [-2 1];
x(1).fs = 5;
x(1).type = 'segment';
s = [x(1).s(1) * p.s(2)', x(1).s(1:2) * p.s', x(1).s(2:3) * p.s', ...
    x(1).s(3:4) * p.s', x(1).s(4) * p.s(1)'];
ideal_y = [ckhsig, ckhsig];
ideal_y(1).s = s;
ideal_y(1).idx = [1 5];
ideal_y(1).fs = 5;
ideal_y(1).type = 'segment';

x(2).s = [1+j*2, 2+j, 3-j*2, 4+j*3];
x(2).idx = [0 3];
x(2).fs = 5;
x(2).type = 'segment';
s = [x(2).s(1) * p.s(2)', x(2).s(1:2) * p.s', x(2).s(2:3) * p.s', ...
    x(2).s(3:4) * p.s', x(2).s(4) * p.s(1)'];
ideal_y(2) = ckhsig;
ideal_y(2).s = s;
ideal_y(2).idx = [3 7];
ideal_y(2).fs = 5;
ideal_y(2).type = 'segment';

y = ckhsigcorr(x, p);
for n = 1:numel(x)
    if ~isequal(y(n), ideal_y(n))
        status = 0;
    end
end


%% Exit function.
end

