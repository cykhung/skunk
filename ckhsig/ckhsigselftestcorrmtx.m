function status = ckhsigselftestcorrmtx

%%
%       SYNTAX: status = ckhsigselftestcorrmtx;
%
%  DESCRIPTION: Test ckhsigcorrmtx.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Special case: x.s = []. x.type = 'circular'.
x = ckhsig([], 10, 'circular', [0 -1]);
R = ckhsigcorrmtx(x, 5);
if any(size(R) ~= [1 1]) || ~isempty(R{1})
    status = 0;
end


%% Special case: x.s = []. x.type = 'segment'.
x = ckhsig([], 10, 'segment', [3 2]);
R = ckhsigcorrmtx(x, 5);
if any(size(R) ~= [1 1]) || ~isempty(R{1})
    status = 0;
end


%% Special case: M > length(x.s). Crash.
x = ckhsig(1:4, 10, 'segment', [0 3]);
try                                         %#ok<TRYNC>
    ckhsigcorrmtx(x, 5);
    status = 0;
end


%% Special case: M < 1. Crash.
x = ckhsig(1:4, 10, 'segment', [0 3]);
try                                         %#ok<TRYNC>
    ckhsigcorrmtx(x, 0);
    status = 0;
end
try                                         %#ok<TRYNC>
    ckhsigcorrmtx(x, -3);
    status = 0;
end


%% Special case: Streaming. Crash.
x = ckhsig(1:100, 10, 'streaming', [0 99]);
try                                         %#ok<TRYNC>
    ckhsigcorrmtx(x, 3);
    status = 0;
end


%% Test: x = circularly continuous signal.
x = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'circular', [2 5]);
R = ckhsigcorrmtx(x, 4);
if any(size(R) ~= [1 1])
    status = 0;
end
ideal_r = zeros(1, 4);
ideal_r(1) = sum(x.s .* conj(x.s)) / 4;
ideal_r(2) = sum([x.s(2:end) x.s(1)] .* conj(x.s)) / 4;
ideal_r(3) = sum([x.s(3:end) x.s(1:2)] .* conj(x.s)) / 4;
ideal_r(4) = sum([x.s(4) x.s(1:3)] .* conj(x.s)) / 4;
if max(abs(toeplitz(ideal_r) - R{1})) > 0
    status = 0;
end


%% Test: x = segment signal.
x = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
R = ckhsigcorrmtx(x, 4);
if any(size(R) ~= [1 1])
    status = 0;
end
ideal_r = zeros(1, 4);
ideal_r(1) = sum(x.s .* conj(x.s)) / 4;
ideal_r(2) = sum(x.s(2:end) .* conj(x.s(1:3))) / 3;
ideal_r(3) = sum(x.s(3:end) .* conj(x.s(1:2))) / 2;
ideal_r(4) = sum(x.s(4) .* conj(x.s(1))) / 1;
if max(abs(toeplitz(ideal_r) - R{1})) > 0
    status = 0;
end


%% Test: x = 2x3 array of signal objects. M = 2.
x    = repmat(ckhsig, 2, 3);
x(1) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(2) = ckhsig((4:10)-sqrt(-1)*(-10:-4), 10, 'circular', [4 10]);
x(3) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(4) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(5) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(6) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
R = ckhsigcorrmtx(x, 2);
if any(size(R) ~= [2 3])
    status = 0;
end
for n = 1:6
    ideal_R = ckhsigcorrmtx(x(n), 2);    
    if max(abs(ideal_R{1} - R{n})) > 0
        status = 0;
    end
end


%% Test: x = 1x1 array of signal objects. M = 2x3.
x = ckhsig((2:10)-sqrt(-1)*(12:20), 10, 'segment', [2 10]);
M = [1 3 5; 6 9 4];
R = ckhsigcorrmtx(x, M);
if any(size(R) ~= [2 3])
    status = 0;
end
for n = 1:6
    ideal_R = ckhsigcorrmtx(x, M(n));    
    if max(abs(ideal_R{1} - R{n})) > 0
        status = 0;
    end
end


%% Test: x = 2x3 array of signal objects. M = 2x3 array.
x = repmat(ckhsig, 2, 3);
x(1) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(2) = ckhsig((4:10)-sqrt(-1)*(-10:-4), 10, 'circular', [4 10]);
x(3) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(4) = ckhsig([2:10]-sqrt(-1)*[12:20], 10, 'segment', [2 10]);
x(5) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
x(6) = ckhsig((2:5)-sqrt(-1)*(12:15), 10, 'segment', [2 5]);
M = [1 3 4; 6 9 2];
R = ckhsigcorrmtx(x, M);
if any(size(R) ~= [2 3])
    status = 0;
end
for n = 1:6
    ideal_R = ckhsigcorrmtx(x(n), M(n));    
    if max(abs(ideal_R{1} - R{n})) > 0
        status = 0;
    end
end


%% Exit function.
end

