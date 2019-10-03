function status = ckhsigselftestconvmtx

%%
%       SYNTAX: status = ckhsigselftestconvmtx;
%
%  DESCRIPTION: Test ckhsigconvmtx.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x.s = []. x.type = 'circular'.
x = ckhsig;
x.type = 'circular';
x.fs_Hz = 10;
x.idx = [0 -1];
[A, midx, tidx] = ckhsigconvmtx(x, [-1 0 1]);
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        ~isempty(A{1}) || ...
        ~isempty(midx{1}) || ...
        any(x.idx ~= tidx{1})
    status = 0;
end


%% Test: x.s = []. x.type = 'segment'.
x = ckhsig;
x.type = 'segment';
x.fs_Hz = 10;
x.idx = [3 2];
[A, midx, tidx] = ckhsigconvmtx(x, [-1 0 1]);
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        ~isempty(A{1}) || ...
        ~isempty(midx{1}) || ...
        any(x.idx ~= tidx{1})
    status = 0;
end


%% Test: idx = []. Crash.
x = ckhsig;
x.type = 'segment';
x.fs_Hz = 10;
x.idx = [3 2];
try                                                 %#ok<TRYNC>
    ckhsigconvmtx(x, []);
    status = 0;
end


%% Test: Not enough samples for the filter time span.
x = ckhsig;
x.type = 'segment';
x.s = 1:3;
x.fs_Hz = 10;
x.idx = [0 2];
[A, midx, tidx] = ckhsigconvmtx(x, [-1 2]);
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        ~isempty(A{1}) || ...
        ~isempty(midx{1}) || ...
        any(tidx{1} ~= [0 -1])
    status = 0;
end

x = ckhsig(1:3, 10, 'segment', [0 2]);
[A, midx, tidx] = ckhsigconvmtx(x, [-2 1]);
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        ~isempty(A{1}) || ...
        ~isempty(midx{1}) || ...
        any(tidx{1} ~= [0 -1])
    status = 0;
end

x = ckhsig(1, 10, 'segment', [0 0]);
[A, midx, tidx] = ckhsigconvmtx(x, [-2 1]);
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        ~isempty(A{1}) || ...
        ~isempty(midx{1}) || ...
        any(tidx{1} ~= [0 -1])
    status = 0;
end


%% Test: Just enough samples for the filter time span. idx = all positive.
x = ckhsig(1:3, 10, 'segment', [0 2]);
[A, midx, tidx] = ckhsigconvmtx(x, [0 2]);
ideal_A = [3 1];
ideal_midx = [3 1];
ideal_tidx = 2;
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        max(max(abs(ideal_midx - midx{1}))) > 0 || ...
        max(max(abs(ideal_A - A{1}))) > 0 || ...
        max(abs(ideal_tidx - tidx{1})) > 0 
    status = 0;
end
        
        
%% Test: Just enough samples for the filter time span. idx = all negative.
x = ckhsig(1:3, 10, 'segment', [0 2]);
[A, midx, tidx] = ckhsigconvmtx(x, [0 -2]);
ideal_A = [1 3];
ideal_midx = [1 3];
ideal_tidx = 0;
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        max(max(abs(ideal_midx - midx{1}))) > 0 || ...
        max(max(abs(ideal_A - A{1}))) > 0 || ...
        max(abs(ideal_tidx - tidx{1})) > 0 
    status = 0;
end


%% Test: Just enough samples for the filter time span. idx = both negative and
%%       positive.
x = ckhsig(1:3, 10, 'segment', [0 2]);
[A, midx, tidx] = ckhsigconvmtx(x, [-1 1]);
ideal_A = [3 1];
ideal_midx = [3 1];
ideal_tidx = 1;
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        max(max(abs(ideal_midx - midx{1}))) > 0 || ...
        max(max(abs(ideal_A - A{1}))) > 0 || ...
        max(abs(ideal_tidx - tidx{1})) > 0 
    status = 0;
end


% %
% % Test: idx is in random order. Streaming signal.
% %
% x = ckhsig(1:5, 'streaming', 10, [0 4]);
% [A, midx, tidx] = ckhsigconvmtx(x, [0 -2 1]);
% ideal_A = [2 4 1; 3 5 2];
% ideal_midx = [2 4 1; 3 5 2];
% ideal_tidx = [1 2];
% if any(size(A) ~= [1 1]) || ...
%         any(size(midx) ~= [1 1]) || ...
%         any(size(tidx) ~= [1 1]) || ...
%         max(max(abs(ideal_midx - midx{1}))) > 0 || ...
%         max(max(abs(ideal_A - A{1}))) > 0 || ...
%         max(abs(ideal_tidx - tidx{1})) > 0 
%     status = 0;
% end


%% Test: idx is in random order. Segment signal.
x = ckhsig(1:5, 10, 'segment', [0 4]);
[A, midx, tidx] = ckhsigconvmtx(x, [0 -2 1]);
ideal_A = [2 4 1; 3 5 2];
ideal_midx = [2 4 1; 3 5 2];
ideal_tidx = [1 2];
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        max(max(abs(ideal_midx - midx{1}))) > 0 || ...
        max(max(abs(ideal_A - A{1}))) > 0 || ...
        max(abs(ideal_tidx - tidx{1})) > 0 
    status = 0;
end


%% Test: idx is in random order. Circular signal.
x = ckhsig(1:3, 10, 'circular', [0 2]);
[A, midx, tidx] = ckhsigconvmtx(x, [0 -2 1]);
ideal_A = [1 3 3; 2 1 1; 3 2 2];
ideal_midx = [1 3 3; 2 1 1; 3 2 2];
ideal_tidx = [0 2];
if any(size(A) ~= [1 1]) || ...
        any(size(midx) ~= [1 1]) || ...
        any(size(tidx) ~= [1 1]) || ...
        max(max(abs(ideal_midx - midx{1}))) > 0 || ...
        max(max(abs(ideal_A - A{1}))) > 0 || ...
        max(abs(ideal_tidx - tidx{1})) > 0 
    status = 0;
end


%% Test: x = one non-empty circularly continuous signal.
%%       idx = 2x5 array.
x = ckhsig(2:8, 10, 'circular', [2 8]);
idx = {};
idx{1} = [1 2 3];
idx{2} = [1 3]';
idx{3} = [0 2];
idx{4} = 0;
idx{5} = [-2 0];
idx{6} = [-3 -2 -1];
idx{7} = [-3 -2 -1 0 2];
idx{8} = [2 5 4];
idx{9} = [-2 -4 -3];
idx{10} = [-2 -4 -3 3 0 2];
idx = reshape(idx, 2, 5);
[A, midx, tidx] = ckhsigconvmtx(x, idx);
if any(size(A) ~= [2 5]) || ...
        any(size(midx) ~= [2 5]) || ...
        any(size(tidx) ~= [2 5])
    status = 0;
end
ideal_midx = {};
ideal_midx{1} = [[7 6 5]; [1 7 6]; [2 1 7]; [3 2 1]; [4 3 2]; [5 4 3]; ...
        [6 5 4]];
ideal_midx{2} = [[7 5]; [1 6]; [2 7]; [3 1]; [4 2]; [5 3]; [6 4]];
ideal_midx{3} = [[1 6]; [2 7]; [3 1]; [4 2]; [5 3]; [6 4]; [7 5]];
ideal_midx{4} = [1; 2; 3; 4; 5; 6; 7];
ideal_midx{5} = [[3 1]; [4 2]; [5 3]; [6 4]; [7 5]; [1 6]; [2 7]];
ideal_midx{6} = [[4 3 2]; [5 4 3]; [6 5 4]; [7 6 5]; [1 7 6]; ...
        [2 1 7]; [3 2 1]];
ideal_midx{7} = [[4 3 2 1 6]; [5 4 3 2 7]; [6:-1:3 1]; [7:-1:4 2]; ...
        [1 7:-1:5 3]; [2 1 7:-1:6 4]; [3 2 1 7 5]];
ideal_midx{8} = [[6 3 4]; [7 4 5]; [1 5 6]; [2 6 7]; [3 7 1]; ...
        [4 1 2]; [5 2 3]];
ideal_midx{9} = [[3 5 4]; [4 6 5]; [5 7 6]; [6 1 7]; [7 2 1]; ...
        [1 3 2]; [2 4 3]];
ideal_midx{10} = [[3 5 4 5 1 6]; [4 6 5 6 2 7]; [5 7 6 7 3 1]; ...
        [6 1 7 1 4 2]; [7 2 1 2 5 3]; [1 3 2 3 6 4]; ...
        [2 4 3 4 7 5]];
for n = 1:numel(A)
    ideal_A = x.s(ideal_midx{n});
    if (size(ideal_A, 1) == 1) || (size(ideal_A, 2) == 1)
        ideal_A = ideal_A(:);
    end
    ideal_tidx = [2 8];
    if max(max(abs(ideal_midx{n} - midx{n}))) > 0 || ...
            max(max(abs(ideal_A - A{n}))) > 0 || ...
            max(abs(ideal_tidx - tidx{n})) > 0 
        status = 0;
    end
end


%% Test: x = one non-empty segment signal.
%%       idx = 2x5 array.
x = ckhsig(2:8, 10, 'segment', [2 8]);
idx = {};
idx{1} = [1 2 3];
idx{2} = [1 3]';
idx{3} = [0 2];
idx{4} = 0;
idx{5} = [-2 0];
idx{6} = [-3 -2 -1];
idx{7} = [-3 -2 -1 0 2];
idx{8} = [2 5 4];
idx{9} = [-2 -4 -3];
idx{10} = [-2 -4 -3 3 0 2];
idx = reshape(idx, 2, 5);
[A, midx, tidx] = ckhsigconvmtx(x, idx);
if any(size(A) ~= [2 5]) || ...
        any(size(midx) ~= [2 5]) || ...
        any(size(tidx) ~= [2 5])
    status = 0;
end
ideal_midx = {};
ideal_midx{1} = [[3 2 1]; [4 3 2]; [5 4 3]; [6 5 4]];
ideal_midx{2} = [[3 1]; [4 2]; [5 3]; [6 4]];
ideal_midx{3} = [[3 1]; [4 2]; [5 3]; [6 4]; [7 5]];
ideal_midx{4} = [1; 2; 3; 4; 5; 6; 7];
ideal_midx{5} = [[3 1]; [4 2]; [5 3]; [6 4]; [7 5]];
ideal_midx{6} = [[4 3 2]; [5 4 3]; [6 5 4]; [7 6 5]];
ideal_midx{7} = [[6:-1:3 1]; [7:-1:4 2]];
ideal_midx{8} = [[4 1 2]; [5 2 3]];
ideal_midx{9} = [[3 5 4]; [4 6 5]; [5 7 6]];
ideal_midx{10} = [];
ideal_tidx = {};
ideal_tidx{1} = [5 8];
ideal_tidx{2} = [5 8];
ideal_tidx{3} = [4 8];
ideal_tidx{4} = [2 8];
ideal_tidx{5} = [2 6];
ideal_tidx{6} = [2 5];
ideal_tidx{7} = [4 5];
ideal_tidx{8} = [7 8];
ideal_tidx{9} = [2 4];
ideal_tidx{10} = [2 1];
for n = 1:numel(A)
    ideal_A = x.s(ideal_midx{n});
    if (size(ideal_A, 1) == 1) || (size(ideal_A, 2) == 1)
        ideal_A = ideal_A(:);
    end
    if isempty(ideal_A)
        if ~isempty(A{n}) || ~isempty(midx{n}) || ...
                max(abs(ideal_tidx{n} - tidx{n})) > 0 
            status = 0;
        end
    else        
        if max(max(abs(ideal_midx{n} - midx{n}))) > 0 || ...
                max(max(abs(ideal_A - A{n}))) > 0 || ...
                max(abs(ideal_tidx{n} - tidx{n})) > 0 
            status = 0;
        end
    end
end


%% Test: x = 2x3 array of signal objects.
%%       idx = 2x3 array.
x = repmat(ckhsig, 2, 3);
x(1) = ckhsig([], 10, 'circular', [0 -1]);
x(2) = ckhsig([], 10, 'segment', [3 2]);
x(3) = ckhsig(2:8, 10, 'segment', [2 8]);
x(4) = ckhsig(2:8, 10, 'circular', [2 8]);
x(5) = ckhsig(2:8, 10, 'segment', [2 8]);
x(6) = ckhsig([], 10, 'segment', [3 2]);
idx = {};
idx{1} = [1 2 3];
idx{2} = [1 3]';
idx{3} = [0 2];
idx{4} = 0;
idx{5} = [-2 0];
idx{6} = [-3 -2 -1];
idx = reshape(idx, 2, 3);
[A, midx, tidx] = ckhsigconvmtx(x, idx);
if any(size(A) ~= [2 3]) || any(size(midx) ~= [2 3]) || ...
        any(size(tidx) ~= [2 3])
    status = 0;
end
ideal_midx = {};
ideal_midx{1} = [];
ideal_midx{2} = [];
ideal_midx{3} = [[3 1]; [4 2]; [5 3]; [6 4]; [7 5]];
ideal_midx{4} = [1; 2; 3; 4; 5; 6; 7];
ideal_midx{5} = [[3 1]; [4 2]; [5 3]; [6 4]; [7 5]];
ideal_midx{6} = [];
ideal_tidx = {};
ideal_tidx{1} = [0 -1];
ideal_tidx{2} = [3 2];
ideal_tidx{3} = [4 8];
ideal_tidx{4} = [2 8];
ideal_tidx{5} = [2 6];
ideal_tidx{6} = [3 2];
for n = 1:numel(A)
    ideal_A = x(n).s(ideal_midx{n});
    if (size(ideal_A, 1) == 1) || (size(ideal_A, 2) == 1)
        ideal_A = ideal_A(:);
    end
    if isempty(ideal_A)
        if ~isempty(A{n}) || ~isempty(midx{n}) || ...
                max(abs(ideal_tidx{n} - tidx{n})) > 0 
            status = 0;
        end
    else        
        if max(max(abs(ideal_midx{n} - midx{n}))) > 0 || ...
                max(max(abs(ideal_A - A{n}))) > 0 || ...
                max(abs(ideal_tidx{n} - tidx{n})) > 0 
            status = 0;
        end
    end
end


%% Test: x = circularly continuous. Compared with conv.
x = ckhsig(0:6, 10, 'circular', [0 6]);
h = [2 4 -8 5 3.8];
idx = [-2 1 0 2 -3];
A = ckhsigconvmtx(x, idx);
y = A{1}*h(:);
y_conv = conv([5:6, 0:6, 0:2], [3.8 2 0 -8 4 5]);
y_conv(1:5) = [];
y_conv(end-4:end) = [];
y_conv = y_conv(:);
if max(abs(y - y_conv)) > 1e-14
    status = 0;
end


%% Test: x = segment. Compared with conv.
x = ckhsig(0:9, 10, 'segment', [0 9]);
h = [2 4 -8 5 3.8];
idx = [-2 1 0 2 -3];
A = ckhsigconvmtx(x, idx);
y = A{1}*h(:);
y_conv = conv(0:9, [3.8 2 0 -8 4 5]);
y_conv(1:5) = [];
y_conv(end-4:end) = [];
y_conv = y_conv(:);
if max(abs(y - y_conv)) > 1e-14
    status = 0;
end


%% Test: Crash due to input streaming signal.
x = ckhsig(1:3, 10, 'streaming', [0 2]);
try                                                 %#ok<TRYNC>
    ckhsigconvmtx(x, [0 -2]);
    status = 0;
end


%% Exit function.
end

