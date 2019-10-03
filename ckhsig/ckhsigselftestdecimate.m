function status = ckhsigselftestdecimate

%%
%       SYNTAX: status = ckhsigselftestdecimate;
%
%  DESCRIPTION: Test ckhsigdecimate.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal structure. x.type = 'segment'.
x = ckhsig;
x.idx = [1 0];
M = 1:10;
y = ckhsigdecimate(x, M);
for n = 1:length(y)
    if ~isempty(y(n).s) || ~strcmp(y(n).type, 'segment') || ...
            abs(y(n).fs - 1/M(n)) > 0
        status = 0;
    end
end


% %
% % Test: x = empty signal structure. x.type = 'streaming'.
% %
% x = ckhsig;
% x = set(x, 'idx', [2 1], 'type', 'streaming');
% M = 1:10;
% y = ckhsigdecimate(x, M);
% for n = 1:length(y)
%     u = get(y(n));
%     if ~isempty(y(n).s) || ~strcmp(y(n).type, 'segment') || abs(y(n).fs - 1/M(n)) > 0
%         status = 0;
%     end
%     if n ~= 1
%         if y(n).is_idx_default || y(n).is_type_default || y(n).is_fs_default
%             status = 0;
%         end
%     end
% end


% %
% % Test: x = empty signal structure. x.type = 'streaming'. Crash.
% %
% x = ckhsig;
% x = set(x, 'idx', [2 1], 'type', 'streaming');
% M = 1:10;
% try
%     y = ckhsigdecimate(x, M);
%     status = 0;
% end


%% Test: x = empty signal structure. x.type = 'circular'.
x = ckhsig;
x.idx = [-1 -2];
x.type = 'circular';
M = 1:10;
y = ckhsigdecimate(x, M);
for n = 1:length(y)
    if ~isempty(y(n).s) || ~strcmp(y(n).type, 'circular') || ...
            abs(y(n).fs - 1/M(n)) > 0
        status = 0;
    end
    if n ~= 1
        if any(y(n).idx ~= [0 -1])
            status = 0;
        end
    end
end


%% Test: x = non-empty signal structure but M = 1.
x = ckhsig((1:100)+1i*(10:109), 1, 'circular', []);
y = ckhsigdecimate(x, 1);
if ~isequal(x, y)
    status = 0;
end


%% Test: x = non-empty circular signal structure. M = 1:10. x.idx(1) = 0.
n = 0:999;
s = exp(1i*2*pi*0.04*n);
x = ckhsig(s, 1, 'circular', []);
y = ckhsigdecimate(x, 1:10);
y(1) = ckhsigsetidx(y(1));
for n = 1:10
    if (y(n).idx(1) ~= 0) || (length(y(n).s) ~= lcm(1000,n)/n) || ...
            (y(n).fs ~= 1/n) || ~strcmp(y(n).type, 'circular') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = non-empty circular signal structure. M = 1:10. x.idx(1) = 1.
n = 0:999;
s = exp(1i*2*pi*0.04*n);
x = ckhsig(s, 1, 'circular', [1 1000]);
y = ckhsigdecimate(x, 1:10);
y(1) = ckhsigsetidx(y(1));
for n = 1:10
    if (y(n).idx(1) ~= 1) || (length(y(n).s) ~= lcm(1000,n)/n) || ...
            (y(n).fs ~= 1/n) || ~strcmp(y(n).type, 'circular') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = non-empty segment signal structure. L = 1:10. x.idx(1) = 0.
n = 0:9999;
s = exp(1i*2*pi*0.04*n) + exp(1i*2*pi*0.03*n);
x = ckhsig(s, 1, 'segment', [0 10000-1]);
y = ckhsigdecimate(x, 1:10);
y1 = ckhsigdecimate(ckhsig, 1:10);
y(1) = ckhsigsetidx(y(1));
y1(1) = ckhsigsetidx(y1(1));
for n = 1:10
    ideal_idx = y1(n).idx;
    ideal_idx = ideal_idx(1);
    if (y(n).idx(1) ~= ideal_idx) || (y(n).fs ~= 1/n) || ...
            ~strcmp(y(n).type, 'segment') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = non-empty segment signal structure. L = 1:10. x.idx(1) = 1.
n = 0:9999;
s = exp(1i*2*pi*0.04*n) + exp(1i*2*pi*0.03*n);
x = ckhsig(s, 1, 'segment', [1 10000]);
y = ckhsigdecimate(x, 1:10);
y1 = ckhsigdecimate(ckhsig([], 1, 'segment', [1 0]), 1:10);
for n = 1:10
    ideal_idx = y1(n).idx;
    ideal_idx = ideal_idx(1);
    if (y(n).idx(1) ~= ideal_idx) || (y(n).fs ~= 1/n) || ...
            ~strcmp(y(n).type, 'segment') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = multiple non-empty signal structures.
x = repmat(ckhsig, 2, 2);
n = 0:9999;
s = exp(1i*2*pi*0.03*n) + exp(1i*2*pi*0.01*n);
x(1) = ckhsig(s, 1, 'segment', [1 10000]);
n = 0:9999;
s = exp(1i*2*pi*0.15*n) + exp(-1i*2*pi*0.01*n);
x(2) = ckhsig(s, 1, 'segment', [1 10000]);
n = 0:999;
s = exp(-1i*2*pi*0.2*n) + exp(1i*2*pi*0.14*n);
x(3) = ckhsig(s, 1, 'circular', [1 1000]);
n = 0:999;
s = exp(1i*2*pi*0.3*n) + exp(-1i*2*pi*0.2*n);
x(4) = ckhsig(s, 1, 'circular', [1 1000]);
y = ckhsigdecimate(x, 2);
if any(size(y) ~= [2 2])
    status = 0;
end
for n = 1:4
    ideal_y = ckhsigdecimate(x(n), 2);
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Test: x = very short segment signal structure. M = 2:10.
x = ckhsig;
x.s = (1:10);
x.idx = [1 10];
M = (2:10);
y = ckhsigdecimate(x, M);
y1 = ckhsigdecimate(ckhsig([], 10, 'segment', [1 0]), M);
for n = 1:9
    ideal_idx = y1(n).idx;
    ideal_idx = ideal_idx(1);
    if (y(n).idx(1) ~= ideal_idx) || (y(n).fs ~= 1/M(n)) || ...
            ~strcmp(y(n).type, 'segment') || ~isempty(y(n).s)
        status = 0;
    end
end


%% Test: x = short (not enough for more than one FIR filtering) segment signal
%%       structure.
x = ckhsig;
x.s = (1:600);
x.idx = [1 600];
M = [4 6 8 10];
y = ckhsigdecimate(x, M);
y1 = ckhsigdecimate(ckhsig([], 10, 'segment', [1 0]), M);
for n = 1:length(M)
    ideal_idx = y1(n).idx;
    ideal_idx = ideal_idx(1);
    if (y(n).idx(1) ~= ideal_idx) || (y(n).fs ~= 1/M(n)) || ...
            ~strcmp(y(n).type, 'segment') || ~isempty(y(n).s)
        status = 0;
    end
end


%% Test: Combination of ckhsigdecimate with interp. 
%%       x = circular.
%%       Interp followed by ckhsigdecimate.
n = 0:9999;
s = exp(1i*2*pi*0.03*n) + exp(1i*2*pi*0.01*n);
x = ckhsig(s, 7, 'circular', [1 10000]);
for M = 1:10
    x_up = ckhsiginterp(x, M);
    x_down = ckhsigdecimate(x_up, M);
    e = x;
    e.s = x.s - x_down.s;
    [~, x_avg_pwr_dB] = ckhsigpkavg(x);
    [~, e_avg_pwr_dB] = ckhsigpkavg(e);
    if ~strcmp(x_down.type, 'circular') || any(x_down.idx ~= [1 10000]) || ...
            ((x_avg_pwr_dB - e_avg_pwr_dB) < 57) || ...
            (x_down.fs ~= 7)
        status = 0;
    end
end


%% Test: Combination of ckhsigdecimate with ckhsigInterp. 
%%       x = circular.
%%       Decimate followed by ckhsigInterp.
n = 0:9999;
s = exp(1i*2*pi*0.03*n) + exp(1i*2*pi*0.01*n);
x = ckhsig(s, 7, 'circular', [1 10000]);
for M = 1:10
    x_down = ckhsigdecimate(x, M);
    x_up = ckhsiginterp(x_down, M);
    if ~strcmp(x_up.type, 'circular')
        status = 0;
    end
    x_up = ckhsiggrep(x_up, [1 10000]);
    e = x;
    e.s = x.s - x_up.s;
    [~, x_avg_pwr_dB] = ckhsigpkavg(x);
    [~, e_avg_pwr_dB] = ckhsigpkavg(e);
    if ((x_avg_pwr_dB - e_avg_pwr_dB) < 55) || (x_up.fs ~= 7)
        status = 0;
    end
end


%% Test: Combination of ckhsigdecimate with ckhsigInterp. 
%%       x = segment.
%%       Interp followed by ckhsigdecimate.
n = 0:9999;
s = exp(1i*2*pi*0.03/7*n) + exp(1i*2*pi*0.01/7*n);
x = ckhsig(s, 7, 'segment', [3 10000+2]);
for M = 1:10
    x_up = ckhsiginterp(x, M);
    x_down = ckhsigdecimate(x_up, M);
    [x_intersect, x_down_intersect] = ckhsigintersect([x, x_down], 'list');
    e = x_intersect;
    e.s = x_intersect.s - x_down_intersect.s;
    [~, x_intersect_avg_pwr_dB] = ckhsigpkavg(x_intersect);
    [~, e_avg_pwr_dB] = ckhsigpkavg(e);
    if ~strcmp(x_down_intersect.type, 'segment') || ...
            ((x_intersect_avg_pwr_dB - e_avg_pwr_dB) < 57) || ...
            (x_down_intersect.fs ~= 7)
        status = 0;
    end
end


%% Test: Combination of ckhsigdecimate with ckhsigInterp. 
%%       x = segment.
%%       Decimate followed by ckhsigInterp.
n = 0:19999;
s = exp(1i*2*pi*0.03/7*n) + exp(1i*2*pi*0.01/7*n);
x = ckhsig(s, 7, 'segment', [3 20000+2]-5);
for M = 1:10
    x_down = ckhsigdecimate(x, M);
    x_up = ckhsiginterp(x_down, M);
    [x_intersect, x_up_intersect] = ckhsigintersect([x, x_up], 'list');
    if isempty(x_intersect.s)
        status = 0;
    end
    if isempty(x_up_intersect.s)
        status = 0;
    end
    e = x_intersect;
    e.s = x_intersect.s - x_up_intersect.s;
    [~, x_intersect_avg_pwr_dB] = ckhsigpkavg(x_intersect);
    [~, e_avg_pwr_dB] = ckhsigpkavg(e);
    if ~strcmp(x_up_intersect.type, 'segment') || ...
            ((x_intersect_avg_pwr_dB - e_avg_pwr_dB) < 57) || ...
            (x_up_intersect.fs ~= 7)
        status = 0;
    end
end


%% Exit function.
end

