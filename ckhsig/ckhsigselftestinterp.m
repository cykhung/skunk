function status = ckhsigselftestinterp

%%
%       SYNTAX: status = ckhsigselftestinterp;
%
%  DESCRIPTION: Test ckhsiginterp.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


% %
% % Test: x = empty signal structure. 
% %
% x = sig;
% y = interp(x, [2 3 5 7]);
% for n = 1:length(y)
%     u = get(y(n));
%     if ~isempty(u.s) || ~u.is_type_default || ~u.is_fs_default || ...
%             ~u.is_idx_default || ~strcmp(u.type, 'segment') || ...
%             (u.fs ~= 1) || any(u.idx ~= [0 -1])
%         status = 0;
%     end
% end


%% Test: x = empty signal structure. x.idx(1) = +ve.
x = ckhsig;
x.idx = [1 0];
L = [2 3 5 7];
y = ckhsiginterp(x, L);
tmpy = ckhsiginterp(ckhsig((1:2e3), 1, 'segment', [1 2e3]), L);
for n = 1:numel(y)
    ideal_idx = [tmpy(n).idx(1) tmpy(n).idx(1)-1];
    if ~isempty(y(n).s) || ...
            ~strcmp(y(n).type, 'segment') || ...
            (y(n).fs ~= L(n)) || any(y(n).idx ~= ideal_idx)
        status = 0;
    end
end


%% Test: x = empty signal structure. x.idx(1) = 0.
x = ckhsig;
x.idx = [0 -1];
L = [2 3 5 7];
y = ckhsiginterp(x, L);
tmpy = ckhsiginterp(ckhsig((1:2e3), 1, 'segment', [0 2e3-1]), L);
for n = 1:numel(y)
    ideal_idx = [tmpy(n).idx(1) tmpy(n).idx(1)-1];
    if ~isempty(y(n).s) || ...
            ~strcmp(y(n).type, 'segment') || ...
            (y(n).fs ~= L(n)) || any(y(n).idx ~= ideal_idx)
        status = 0;
    end
end


%% Test: x = empty signal structure. x.idx(1) = -ve.
x = ckhsig;
x.idx = [-2 -3];
L = [2 3 5 7];
y = ckhsiginterp(x, L);
tmpy = ckhsiginterp(ckhsig((1:2e3), 1, 'segment', -2 + [0 2e3-1]), L);
for n = 1:numel(y)
    ideal_idx = [tmpy(n).idx(1) tmpy(n).idx(1)-1];
    if ~isempty(y(n).s) || ...
            ~strcmp(y(n).type, 'segment') || ...
            (y(n).fs ~= L(n)) || any(y(n).idx ~= ideal_idx)
        status = 0;
    end
end


%% Test: x = non-empty signal structure but L = 1.
x = ckhsig((1:100)+1i*(10:109), 1, 'circular', []);
y = ckhsiginterp(x, 1);
if ~isequal(x, y)
    status = 0;
end


%% Test: x = non-empty circular signal structure. L = 1:10.
n = 0:999;
s = exp(1i*2*pi*0.3*n) + exp(1i*2*pi*0.1*n);
x = ckhsig(s, 1, 'circular', []);
y = ckhsiginterp(x, 1:10);
y(1) = ckhsigsetidx(y(1));
for n = 1:10
    if (y(n).idx(1) ~= 0) || (y(n).idx(2) ~= (1000*n - 1)) || ...
            (y(n).fs ~= n) || ~strcmp(y(n).type, 'circular') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(y(n).s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = non-empty circular signal structure. L = 1:10. Check index.
n = 0:999;
s = exp(1i*2*pi*0.3*n) + exp(1i*2*pi*0.1*n);
x = ckhsig(s, 1, 'circular', [1 1000]);
y = ckhsiginterp(x, 1:10);
y1 = ckhsiginterp(ckhsig([], 1, 'circular', [1 0]), 1:10);
y(1) = ckhsigsetidx(y(1));
y1(1) = ckhsigsetidx(y1(1));
for n = 1:10
    ideal_idx = y1(n).idx;
    ideal_idx(2) = ideal_idx(1) + length(y(n).s) - 1;
    if (y(n).idx(1) ~= 1*n) || (y(n).idx(2) ~= (1*n + 1000*n - 1)) || ...
            any(ideal_idx ~= y(n).idx) || ...
            (y(n).fs ~= n) || ~strcmp(y(n).type, 'circular') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = non-empty segment signal structure. L = 1:10.
n = 0:9999;
s = exp(1i*2*pi*0.3*n) + exp(1i*2*pi*0.1*n);
x = ckhsig(s, 1, 'segment', [1 10000]);
y = ckhsiginterp(x, 1:10);
y1 = ckhsiginterp(ckhsig([], 1, 'segment', [1 0]), 1:10);
for n = 1:10
    ideal_idx = y1(n).idx;
    ideal_idx(2) = ideal_idx(1) + length(y(n).s) - 1;
    if (y(n).fs ~= n) || ~strcmp(y(n).type, 'segment') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1) || ...
            any(ideal_idx ~= y(n).idx)
        status = 0;
    end
end


%% Test: x = non-empty streaming signal structure. L = 1:10.
n = 0:9999;
s = exp(1i*2*pi*0.3*n) + exp(1i*2*pi*0.1*n);
x = ckhsig(s, 1, 'segment', [1 10000]);
y = ckhsiginterp(x, 1:10);
for n = 1:10
    ideal_u = ckhsiginterp(x, n);
    if ~isequal(y(n), ideal_u) || ...
            (y(n).fs ~= n) || ~strcmp(y(n).type, 'segment') || ...
            (abs(10*log10(mean(abs(y(n).s).^2)) - ...
            10*log10(mean(abs(x.s).^2))) > 0.1)
        status = 0;
    end
end


%% Test: x = multiple non-empty signal structures.
x = repmat(ckhsig, 2, 2);
n = 0:9999;
s = exp(1i*2*pi*0.3*n) + exp(1i*2*pi*0.1*n);
x(1) = ckhsig(s, 1, 'segment', [1 10000]);
n = 0:9999;
s = exp(1i*2*pi*0.15*n) + exp(-1i*2*pi*0.1*n);
x(2) = ckhsig(s, 1, 'segment', [1 10000]);
n = 0:999;
s = exp(-1i*2*pi*0.3*n) + exp(1i*2*pi*0.4*n);
x(3) = ckhsig(s, 1, 'circular', [1 1000]);
n = 0:999;
s = exp(1i*2*pi*0.3*n) + exp(-1i*2*pi*0.2*n);
x(4) = ckhsig(s, 1, 'circular', [1 1000]);
y = ckhsiginterp(x, 2);
if any(size(y) ~= [2 2])
    status = 0;
end
for n = 1:4
    ideal_y = ckhsiginterp(x(n), 2);
    if ~isequal(ideal_y, y(n))
        status = 0;
    end
end


%% Test: Check the lowpass filters.
folder    = fileparts(which('ckhsig.m'));
folder    = fullfile(folder, 'private');
threshold = 1e-8;
% v = ver('matlab');
% switch v.Version
% case {'7.3', '7.6', '7.10', '7.11', '7.14'}
%     threshold = 1e-8;
% otherwise
%     threshold = 1e-10;
% end

% L = 2.
h = remez(1000, [0 0.5/2 (0.5/2)+0.005 0.5]/0.5, [1 1 0 0], [1 80]);    
tmp = load(fullfile(folder, 'interp_fir_2.mat'));
if max(abs(h - tmp.h)) > threshold
    status = 0;
end

% L = 3.
h = remez(1000, [0 0.5/3 (0.5/3)+0.005 0.5]/0.5, [1 1 0 0], [1 80]);
tmp = load(fullfile(folder, 'interp_fir_3.mat'));
if max(abs(h - tmp.h)) > threshold
    status = 0;
end

% L = 5.
h = remez(2500, [0 0.5/5 (0.5/5)+0.002 0.5]/0.5, [1 1 0 0], [1 80]);
tmp = load(fullfile(folder, 'interp_fir_5.mat'));
if max(abs(h - tmp.h)) > threshold
    status = 0;
end

% L = 7.
h = remez(2500, [0 0.5/7 (0.5/7)+0.002 0.5]/0.5, [1 1 0 0], [1 80]);
tmp = load(fullfile(folder, 'interp_fir_7.mat'));
if max(abs(h - tmp.h)) > threshold
    status = 0;
end


%% Test: x = very short segment signal structure. L = 1:10.
x = ckhsig;
x.s = (1:10);
x.idx = [1 10];
L = (2:10);
y = ckhsiginterp(x, L);
y1 = ckhsiginterp(ckhsig([], 1, 'segment', [1 0]), L);
for n = 1:9
    ideal_idx = y1(n).idx;
    if (y(n).fs ~= L(n)) || ~strcmp(y(n).type, 'segment') || ...
            ~isempty(y(n).s) || any(y(n).idx ~= ideal_idx) 
        status = 0;
    end
end


%% Test: x = short (not enough for more than one FIR filtering) segment signal
%%       structure. L = 1:10.
x = ckhsig;
x.s = (1:600);
x.idx = [1 600];
L = [4 6 8 10];
y = ckhsiginterp(x, L);
tmpy = ckhsiginterp(ckhsig((1:2e3), 1, 'segment', [1 2e3]), L);
for n = 1:length(L)
    ideal_idx = [tmpy(n).idx(1) tmpy(n).idx(1)-1];
    if (y(n).fs ~= L(n)) || ~strcmp(y(n).type, 'segment') || ...
            ~isempty(y(n).s) || any(y(n).idx ~= ideal_idx)
        status = 0;
    end
end


%% Test: x = streaming signal. Crash
clear y
x = ckhsig;
x.s = (1:10);
x.idx = [1 10];
x.type = 'streaming';
L = (2:10);
try                                         %#ok<TRYNC>
    ckhsiginterp(x, L);
    status = 0;
end


%% Test: Check with ideal complex exponential.
fs = 20;
t  = (0:1e4)/fs;
fc = 4.3;
x  = exp(1i*2*pi*fc*t);
x  = ckhsig(x, fs);
y  = ckhsiginterp(x, 2);

fs = 40;
t  = (y.idx(1):y.idx(2))/fs;
z  = exp(1i*2*pi*fc*t);
z  = ckhsig(z, fs, 'segment', y.idx);   % Ideal signal.

if max(abs(y.s - z.s)) > 4.5e-4
    status = 0;
end




end

