function status = ckhsigselftestlieiq

%%
%       SYNTAX: status = ckhsigselftestlieiq;
%
%  DESCRIPTION: Test ckhsiglieiq.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal object. 
x      = ckhsig;
y      = ckhsig;
y.s    = 3;
h1_idx = [1 3 5];
h2_idx = [1 3 5];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: y = empty signal object. 
x      = ckhsig;
x.s    = 3;
y      = ckhsig;
h1_idx = [1 3 5];
h2_idx = [1 3 5];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: h1_idx = [].
x      = ckhsig;
x.s    = 3;
y      = ckhsig;
y.s    = 4;
h1_idx = [];
h2_idx = [1 3 5];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: h2_idx = [].
x      = ckhsig;
x.s    = 3;
y      = ckhsig;
y.s    = 4;
h1_idx = [1 3 5];
h2_idx = [];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: x.fs ~= y.fs.
x      = ckhsig(3, 10e3, 'segment', []);
y      = ckhsig(3, 20e3, 'segment', []);
h1_idx = [1 3 5];
h2_idx = [2 4];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: x.type = 'streaming'.
x      = ckhsig(3, 10e3, 'streaming', []);
y      = ckhsig(3, 20e3, 'segment',   []);
h1_idx = [1 3 5];
h2_idx = [2 4];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: y.type = 'streaming'.
x      = ckhsig(3, 10e3, 'segment',   []);
y      = ckhsig(3, 20e3, 'streaming', []);
h1_idx = [1 3 5];
h2_idx = [2 4];
try                 %#ok
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
end


%% Test: No distortion. Short signal. h2_idx = 0.
x = ckhsig((0:3) + 1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
h1_idx = 0;
h2_idx = 0;
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:rank_deficient');
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
str = 'A is rank-deficient. Set h2 = 0.';
if (D ~= 0) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 0) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: No distortion. Short signal. h2_idx = [-1:1]. Sequence is too short
%%       relative to h2_idx. Convolution matrix is [].
x = ckhsig((0:3) + 1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
h1_idx = 0;
h2_idx = (-1:1);
try
    ckhsiglieiq(x, y, h1_idx, h2_idx);
    status = 0;
catch ME
    if ~strcmp(ME.message, ...
            'Solution not found due to input signals being too short.')
        status = 0;
    end
end


%% Test: No distortion. Relatively long signal.
rng(0, 'twister');
x = ckhsig(rand(1,11) + 1i*rand(1,11), 10e3, 'segment', [0 10]);
y = x;
h1_idx = 0;
h2_idx = 0;
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 1e-10) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: No distortion. Funny problem. Wrong estimation due to bad sounding 
%%       signal.
x = ckhsig((0:10) + 1i*(-11:-1:-21), 10e3, 'segment', [0 10]);
y = x;
h1_idx = 0;
h2_idx = 0;
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:rank_deficient');
warning('off', 'ckhsiglieiq:multiple_solutions');
[~, h1, h2, ~, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
% str = 'A is rank-deficient. Set h2 = 0.';
% if (D ~= 5) || ...
%    (max(abs(dc - (5-1i*5))) > 1e-12) || ...
%    ~strcmp(lastwarn, str)
if (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 0) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay only. Delay = 3. x.type = 'segment'. y.type = 'segment'.
%%       Delay is introduced by signal index.
x = ckhsig((0:3) + 1i*(10:13), 10e3, 'segment', [0 3]);
y = ckhsig((0:3) + 1i*(10:13), 10e3, 'segment', [3 6]);
h1_idx = 0;
h2_idx = 0;
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:rank_deficient');
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
str = 'A is rank-deficient. Set h2 = 0.';
if (D ~= 3) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 0) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay only. Delay = 2. x.type = 'segment'. y.type = 'segment'.
%%       Delay is introduced by both signal sample and signal index.
rng(0, 'twister');
s = rand(1,25) + 1i*rand(1,25);
x = ckhsig(s(1:24), 10e3, 'segment', [0 23]);
y = ckhsig(s(2:25), 10e3, 'segment', [3 26]);
h1_idx = 0;
h2_idx = 0;
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 2) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 1e-10) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay only.
%%       Delay = 4. x.type = 'segment'. y.type = 'segment'. This test shows
%%       that user needs to correctly choose hidx otherwise we can get totally 
%%       different result. Usually this kind of coincidence would not happen
%%       in real life since we would have random data.
x = ckhsig((0:4) + 1i*(10:14), 10e3, 'segment', [0 4]);
y = ckhsig((0:4) + 1i*(10:14), 10e3, 'segment', [4 8]);
h1_idx = 1;
h2_idx = 1;
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:rank_deficient');
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
str = 'A is rank-deficient. Set h2 = 0.';
if (D ~= 4) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 1) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 0) || (h2(1).idx ~= 1) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - (1+1i))) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay only. Delay = 3. x.type = 'segment'. y.type = 'circular'.
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:rank_deficient');
warning('off', 'ckhsiglieiq:multiple_solutions');
rng(0, 'twister');
s = rand(1,5) + 1i*rand(1,5);
x = ckhsig(s, 10e3, 'segment', [0 4]);
y = ckhsig(s, 10e3, 'circular', [3 7]);
h1_idx = 0;
h2_idx = 0;
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if ((D ~= 8) && (D ~= -2)) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 1e-10) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay only. Delay = 3. x.type = 'segment'. y.type = 'circular'.
%%       More samples.
rng(0, 'twister');
s = rand(1,35) + 1i*rand(1,35);
x = ckhsig(s, 10e3, 'segment', [0 34]);
y = ckhsig(s, 10e3, 'circular', [3 37]);
h1_idx = 0;
h2_idx = 0;
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 3) || ...
        (abs(h1(1).h - 1) > 1e-10) || (h1(1).idx ~= 0) || (h1(1).fs ~= 10e3) || ...
        (abs(h2(1).h - 0) > 1e-10) || (h2(1).idx ~= 0) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - 0)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: No integer delay. FIR filter (h1) and DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h1 = ckhfir([1+1i*2 1+1i*2], x.fs, [-2 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y = ckhfirapply(ideal_h1, x);
y.s = y.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [-2 2];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - [0 0]) > 1e-10)) || ...
        any(h2(1).idx ~= h2_idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: No integer delay. FIR filter (h2) and DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h2 = ckhfir([1+1i*2 1+1i*2], x.fs, [-2 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y = ckhfirapply(ideal_h2, ckhsigconj(x));
y.s = y.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [-2 2];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (max(abs(h1(1).h - [0 0])) > 1e-10) || ...
        any(h1(1).idx ~= h1_idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h) > 1e-10)) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: No integer delay. FIR filters (h1 and h2) and DC offset. Both filters
%%       have the same indexes.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h1 = ckhfir([1+1i*2 1+1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-2 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y1 = ckhfirapply(ideal_h1, x);
y2 = ckhfirapply(ideal_h2, ckhsigconj(x));
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [-2 2];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h) > 1e-10)) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-29) || ...
        (info.esr_dB > -290)
    status = 0;
end


%% Test: No integer delay. FIR filters (h1 and h2) and DC offset. Both filters
%%       have different indexes.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h1 = ckhfir([1+1i*2 1+1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-3 4], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y1 = ckhfirapply(ideal_h1, x);
y2 = ckhfirapply(ideal_h2, ckhsigconj(x));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [-3 4];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h) > 1e-10)) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end

rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h1 = ckhfir([1+1i*2 1+1i*2], x.fs, [-3 4], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-2 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y1 = ckhfirapply(ideal_h1, x);
y2 = ckhfirapply(ideal_h2, ckhsigconj(x));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-3 4];
h2_idx = [-2 2];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= 0) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h) > 1e-10)) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: DC offset only. No integer delay and FIR filter.
%%       x.type = 'segment'. y.type = 'segment'.
%%       Huge DC offset.
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:multiple_solutions');
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
y = x;
ideal_dc = 1000+1i*1042;
y.s = y.s + ideal_dc;
h1_idx = (-4:4);
h2_idx = (-4:4);
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
ideal_h1 = ckhfir;
ideal_h1.fs = x.fs;
m = -D + abs(min(h1_idx(1))) + 1;
ideal_h1.h = zeros(size(h1_idx));
ideal_h1.h(m) = 1;
ideal_h1.idx = h1_idx;
ideal_h2 = ckhfir([zeros(1,4), 0, zeros(1,4)], x.fs, (-4:4), 1);
if (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-24) || ...
        (info.mse_dB > -240) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay, 2 FIR filters and DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_D = -3;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-1 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-2 1], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-1 2];
h2_idx = [-2 1];
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= ideal_D) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay, FIR and DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [0 3], 1);
ideal_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [0 3];
[D, h1, h2, ~, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= ideal_D) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay, 2 FIR filters and DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
%%       h1_idx and h2_idx are over-modelled and more DC offset.
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:multiple_solutions');
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-3 1], 1);
ideal_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = (-3:4);
h2_idx = (-4:3);
[D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
tmp = ckhfirfull(ideal_h1);
ideal_h1 = ckhfir([zeros(1,1), tmp.h, zeros(1,2)], x.fs, (-3:4), 1);
tmp = ckhfirfull(ideal_h2);
ideal_h2 = ckhfir([zeros(1,1), tmp.h, zeros(1,2)], x.fs, (-4:3), 1);
if (D == -13)
    if (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
            any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
            (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
            any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3)
        status = 0;
    end    
elseif (D == -14)
    if (max(abs(h1(1).h - [0, ideal_h1.h(1:end-1)])) > 1e-10) || ...
            any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
            (max(abs(h2(1).h - [0, ideal_h2.h(1:end-1)])) > 1e-10) || ...
            any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3)
        status = 0;
    end
elseif (D == -15)
    if (max(abs(h1(1).h - [0, 0, ideal_h1.h(1:end-2)])) > 1e-10) || ...
            any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
            (max(abs(h2(1).h - [0, 0, ideal_h2.h(1:end-2)])) > 1e-10) || ...
            any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3)
        status = 0;
    end
elseif (D == -12)
    if (max(abs(h1(1).h - [ideal_h1.h(2:end) 0])) > 1e-10) || ...
            any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
            (max(abs(h2(1).h - [ideal_h2.h(2:end) 0])) > 1e-10) || ...
            any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3)
        status = 0;
    end
else
    status = 0;
end
if (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -280) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Check the default value of D_offset.
%%       Integer delay, FIR and DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
%%       hidx is over-modelled and more DC offset.
lastwarn('');
orig_warn_state = warning;
warning('off', 'ckhsiglieiq:multiple_solutions');
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [-3 1], 1);
ideal_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = (-3:4);
h2_idx = (-4:3);
[D1, h1, h2, dc1, info1] = ckhsiglieiq(x, y, h1_idx, h2_idx);
[D2, g1, g2, dc2, info2] = ckhsiglieiq(x, y, h1_idx, h2_idx, (-5:1:5));
if (D1 ~= D2) || ~isequal(h1, g1) || ~isequal(h2, g2) || ...
        (max(abs(dc1 - dc2)) > 1e-12) || ~isequal(info1, info2)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Inverse modelling. No delay. Both FIRs are single-tap filters.
%%       Reasonable DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
fwd_D = 0;
fwd_h1 = ckhfir(4-1i*2, x.fs, 0, 1);
fwd_h2 = ckhfir(3-1i*2, x.fs, 0, 1);
fwd_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, fwd_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(fwd_h1, y);
y2 = ckhfirapply(fwd_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + fwd_dc;
[~, inv_h1, inv_h2, inv_dc, info] = ckhsiglieiq(y, x, 0, 0);
h_delay = ckhfir(1, x.fs, fwd_D, 1);
x_hat = ckhfirapply(h_delay, y);
x1 = ckhfirapply(inv_h1, x_hat);
x2 = ckhfirapply(inv_h2, ckhsigconj(x_hat));
[x1, x2] = ckhsigintersect([x1, x2], 'list');
x_hat = x1;
x_hat.s = x1.s + x2.s + inv_dc;
e = x.s - x_hat.s;
esr_dB = 10*log10(mean(abs(e).^2) / mean(abs(x.s).^2));
if (esr_dB > -290) || (abs(info.esr_dB - esr_dB) > 1e-12)
    status = 0;
end


%% Test: Inverse modelling. With delay. Both FIRs are single-tap filters.
%%       Reasonable DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
fwd_D = 10;
fwd_h1 = ckhfir(4-1i*5.2, x.fs, 0, 1);
fwd_h2 = ckhfir(3.3-1i*2, x.fs, 0, 1);
fwd_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, fwd_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(fwd_h1, y);
y2 = ckhfirapply(fwd_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + fwd_dc;
[inv_D, inv_h1, inv_h2, inv_dc, info] = ckhsiglieiq(y, x, 0, 0);
h_delay = ckhfir(1, x.fs, inv_D, 1);
x_hat = ckhfirapply(h_delay, y);
x1 = ckhfirapply(inv_h1, x_hat); 
x2 = ckhfirapply(inv_h2, ckhsigconj(x_hat));
[x1, x2] = ckhsigintersect([x1, x2], 'list');
x_hat = x1;
x_hat.s = x1.s + x2.s + inv_dc;
e = x.s - x_hat.s;
esr_dB = 10*log10(mean(abs(e).^2) / mean(abs(x.s).^2));
if (esr_dB > -290) || (abs(info.esr_dB - esr_dB) > 1e-12)
    status = 0;
end


%% Test: Inverse modelling. With delay. Both FIRs are single-tap filters.
%%       Reasonable DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
fwd_D = 10;
fwd_h1 = ckhfir(1.4-1i*2, x.fs, 0, 1);
fwd_h2 = ckhfir(3-1i*2.2, x.fs, 0, 1);
fwd_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, x.fs, fwd_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(fwd_h1, y);
y2 = ckhfirapply(fwd_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + fwd_dc;
[inv_D, inv_h1, inv_h2, inv_dc, info] = ckhsiglieiq(y, x, 0, 0);
h_delay = ckhfir(1, x.fs, inv_D, 1);
x_hat = ckhfirapply(h_delay, y);
x1 = ckhfirapply(inv_h1, x_hat); 
x2 = ckhfirapply(inv_h2, ckhsigconj(x_hat));
[x1, x2] = ckhsigintersect([x1, x2], 'list');
x_hat = x1;
x_hat.s = x1.s + x2.s + inv_dc;
e = x.s - x_hat.s;
esr_dB = 10*log10(mean(abs(e).^2) / mean(abs(x.s).^2));
if (esr_dB > -290) || (abs(info.esr_dB - esr_dB) > 1e-12)
    status = 0;
end


%% Test: Integer delay, FIR and huge DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [0 3], 1);
ideal_dc = (rand(1,1)+1i*rand(1,1))*100;
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [0 3];
[D, h1, h2, ~, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= ideal_D) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-27) || ...
        (info.mse_dB > -270) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay, FIR and huge DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(10, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_D = -13;
ideal_h1 = ckhfir([3+1i*5 4-1i*2], x.fs, [-2 2], 1);
ideal_h2 = ckhfir([3-1i*2 -2.5+1i*2.8], x.fs, [0 3], 1);
ideal_dc = (rand(1,1)+1i*rand(1,1))*100;
h_delay = ckhfir(1, x.fs, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y1 = ckhfirapply(ideal_h1, y);
y2 = ckhfirapply(ideal_h2, ckhsigconj(y));
[y1, y2] = ckhsigintersect([y1, y2], 'list');
y = y1;
y.s = y1.s + y2.s + ideal_dc;
h1_idx = [-2 2];
h2_idx = [0 3];
[D, h1, h2, ~, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
if (D ~= ideal_D) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-26) || ...
        (info.mse_dB > -260) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: User wants to specify the integer delay (just one scalar value).
rng(123, 'twister');
s = rand(1,1e4) + 1i*rand(1,1e4);
x = ckhsig(s, 10e3, 'circular', [0 (1e4 - 1)]);
ideal_h1 = ckhfir;
ideal_h1.h = 1;
ideal_h1.fs = x.fs;
ideal_h2 = ckhfir;
ideal_h2.h = 0.2*exp(1i * deg2rad(30));
ideal_h2.fs = x.fs;
y1 = ckhfirapply(ideal_h1, x);
y2 = ckhfirapply(ideal_h2, ckhsigconj(x));
y  = y1;
y.s = y1.s + y2.s;
[D, h1, h2, ~, info] = ckhsiglieiq(x, y, 0, 0, 0, 0);
if (D ~= 0) || ...
        (max(abs(h1(1).h - ideal_h1.h)) > 1e-10) || ...
        any(h1(1).idx ~= ideal_h1.idx) || (h1(1).fs ~= 10e3) || ...
        (max(abs(h2(1).h - ideal_h2.h)) > 1e-10) || ...
        any(h2(1).idx ~= ideal_h2.idx) || (h2(1).fs ~= 10e3) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-26) || ...
        (info.mse_dB > -260) || ...
        (info.esr > 10e-28) || ...
        (info.esr_dB > -280)
    status = 0;
end


end



