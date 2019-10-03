function status = ckhsigselftestlie

%%
%       SYNTAX: status = ckhsigselftestlie;
%
%  DESCRIPTION: Test ckhsiglie.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: Integer delay. Huge DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_D = -3;
ideal_h = ckhfir(1, 10e3, 0, 1);
ideal_dc = 100*(rand(1,1)+1i*rand(1,1));
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
% y = apply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= ideal_D) || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10) || ...
        any(h(1).idx ~= ideal_h.idx) || (h(1).fs ~= 10e3) || ...
        (max(abs(dc - ideal_dc)) > 1e-12) || ...
        any(size(info.e) ~= [1 1]) || ...
        any(size(info.y_hat) ~= [1 1]) || ...
        ~isfield(info, 'cond_A') || ...
        (info.mse > 1e-26) || ...
        (info.mse_dB > -268) || ...
        (info.esr > 1e-30) || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay, FIR and Huge DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_D = -3;
ideal_h = ckhfir([3+1i*5 4-1i*2], 10e3, [-1 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y = ckhfirapply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = [-1 2];
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= ideal_D) || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10) || ...
        any(h(1).idx ~= ideal_h.idx) || (h(1).fs ~= 10e3) || ...
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


%% Test: x = empty signal object. 
x = ckhsig;
y = ckhsig;
y.s = 3;
hidx = [1 3 5];
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end


%% Test: y = empty signal object. 
x = ckhsig;
x.s = 3;
y = ckhsig;
hidx = [1 3 5];
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end


%% Test: hidx = [].
x = ckhsig;
x.s = 3;
y = ckhsig;
y.s = 4;
hidx = [];
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end


%% Test: x.fs ~= y.fs.
x = ckhsig(3, 10e3, 'segment', []);
y = ckhsig(3, 20e3, 'segment', []);
hidx = [1 3 5];
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end


%% Test: Input segment signal.
x = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
x.type = 'streaming';
hidx = 0;
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end
x = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
y.type = 'streaming';
hidx = 0;
try                     %#ok
    ckhsiglie(x, y, hidx);
    status = 0;
end


%% Test: No distortion.
lastwarn('');
orig_warn_state = warning('query', 'ckhsiglie:multiple_solutions');
warning('off', 'ckhsiglie:multiple_solutions');
x = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
hidx = 0;
ckhsiglie(x, y, hidx);
% if (D ~= 0) || ...
%         (abs(h.h - 1) > 1e-10) || (h.idx ~= 0) || (h.fs ~= 10e3) || ...
%         (max(abs(dc - 0)) > 1e-12) || ...
%         any(size(info.e) ~= [1 1]) || ...
%         any(size(info.y_hat) ~= [1 1]) || ...
%         ~isfield(info, 'cond_A') || ...
%         (info.mse > 1e-27) || ...
%         (info.mse_dB > -280) || ...
%         (info.esr > 1e-30) || ...
%         (info.esr_dB > -300)
%     status = 0;
% end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: No distortion.
x = ckhsig([0:2 5]+1i*[10:12 6], 10e3, 'segment', [0 3]);
y = x;
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 0)                             || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 0)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - 0)) > 1e-12)      || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay only. Delay = 3. x.type = 'segment'. y.type = 'segment'.
%%       Delay is introduced by signal index.
%x = ckhsig([0:3]+1i*[10:13], '', 10e3, [0 3]);
%y = ckhsig([0:3]+1i*[10:13], '', 10e3, [3 6]);
x = ckhsig([0:2 5]+1i*[10:12 6], 10e3, 'segment', [0 3]);
y = ckhsig([0:2 5]+1i*[10:12 6], 10e3, 'segment', [3 6]);
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 3)                             || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 0)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - 0)) > 1e-12)      || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
        (info.esr_dB > -300)
    status = 0;
end
        

%% Test: Integer delay only. Delay = 2. x.type = 'segment'. y.type = 'segment'.
%%       Delay is introduced by both signal sample and signal index.
rng(0, 'twister');
s = rand(1,25) + 1i*rand(1,25);
x = ckhsig(s(1:24), 10e3, 'segment', [0 23]);
y = ckhsig(s(2:25), 10e3, 'segment', [3 26]);
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 2)                             || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 0)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - 0)) > 1e-12)      || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
        (info.esr_dB > -300)
    status = 0;
end
        

%% Test: Integer delay only.
%%       Delay = 3. x.type = 'segment'. y.type = 'segment'. This test shows
%%       that user needs to correctly choose hidx otherwise we can get totally 
%%       different result. Usually this kind of coincidence would not happen
%%       in real life since we would have random data.
x = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [0 3]);
y = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [3 6]);
hidx = 1;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 3)                             || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 1)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - (1+1i))) > 1e-12) || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay only. Delay = 3. x.type = 'segment'. y.type = 'circular'.
%%       This testcase shows that it is ok to have multiple solutions since
%%       one of the signal is circularly continuous and there is no distortion
%%       besides integer delay.
lastwarn('');
orig_warn_state = warning('query', 'ckhsiglie:multiple_solutions');
warning('off', 'ckhsiglie:multiple_solutions');
rng(0, 'twister');
s = rand(1,5) + 1i*rand(1,5);
x = ckhsig(s, 10e3, 'segment', [0 4]);
y = ckhsig(s, 10e3, 'circular', [3 7]);
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if ((D ~= -2) && (D ~= 3) && (D ~= 8))  || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 0)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - 0)) > 1e-12)      || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
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
hidx = 0;
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 3)                             || ...
        (abs(h(1).h - 1) > 1e-10)       || ...
        (h(1).idx ~= 0)                 || ...
        (h(1).fs ~= 10e3)            || ...
        (max(abs(dc - 0)) > 1e-12)      || ...
        any(size(info.e) ~= [1 1])      || ...
        any(size(info.y_hat) ~= [1 1])  || ...
        ~isfield(info, 'cond_A')        || ...
        (info.mse > 1e-27)              || ...
        (info.mse_dB > -280)            || ...
        (info.esr > 1e-30)              || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: No integer delay. FIR and DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_h = ckhfir([1+1i*2 1+1i*2], 10e3, [-2 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
y = ckhfirapply(ideal_h, x);
y.s = y.s + ideal_dc;
hidx = [-2 2];
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= 0)                                     || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10)  || ...
        any(h(1).idx ~= ideal_h.idx)            || ...
        (h(1).fs ~= 10e3)                    || ...
        (max(abs(dc - ideal_dc)) > 1e-12)       || ...
        any(size(info.e) ~= [1 1])              || ...
        any(size(info.y_hat) ~= [1 1])          || ...
        ~isfield(info, 'cond_A')                || ...
        (info.mse > 1e-27)                      || ...
        (info.mse_dB > -280)                    || ...
        (info.esr > 1e-30)                      || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: DC offset only. No integer delay and FIR filter.
%%       x.type = 'segment'. y.type = 'segment'.
%%       Huge DC offset.
lastwarn('');
orig_warn_state = warning('query', 'ckhsiglie:multiple_solutions');
warning('off', 'ckhsiglie:multiple_solutions');
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_dc = 1000+1i*1042;
y = x;
y.s = y.s + ideal_dc;
hidx = (-5:5);
[D, h, dc, info] = ckhsiglie(x, y, hidx);
ideal_D = D;
% ideal_h = full(fir(1, 1, get(x, 'fs'), -D));
ideal_h = ckhfir;
ideal_h.fs = x.fs;
m = -D + abs(min(hidx(1))) + 1;
ideal_h_h = zeros(size(hidx));
ideal_h_h(m) = 1;
ideal_h.h = ideal_h_h;
ideal_h.idx = hidx;
if (D ~= ideal_D)                               || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10)  || ...
        any(h(1).idx ~= ideal_h.idx)            || ...
        (h(1).fs ~= 10e3)                    || ...
        (max(abs(dc - ideal_dc)) > 1e-12)       || ...
        any(size(info.e) ~= [1 1])              || ...
        any(size(info.y_hat) ~= [1 1])          || ...
        ~isfield(info, 'cond_A')                || ...
        (info.mse > 1e-24)                      || ...
        (info.mse_dB > -240)                    || ...
        (info.esr > 1e-30)                      || ...
        (info.esr_dB > -300)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Integer delay, FIR and DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'segment', [0 99]);
ideal_D = -3;
ideal_h = ckhfir([3+1i*5 4-1i*2], 10e3, [-1 2], 1);
ideal_dc = 0.1*(rand(1,1)+1i*rand(1,1));
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y = ckhfirapply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = [-1 2];
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= ideal_D)                               || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10)  || ...
        any(h(1).idx ~= ideal_h.idx)            || ...
        (h(1).fs ~= 10e3)                    || ...
        (max(abs(dc - ideal_dc)) > 1e-12)       || ...
        any(size(info.e) ~= [1 1])              || ...
        any(size(info.y_hat) ~= [1 1])          || ...
        ~isfield(info, 'cond_A')                || ...
        (info.mse > 1e-27)                      || ...
        (info.mse_dB > -280)                    || ...
        (info.esr > 1e-30)                      || ...
        (info.esr_dB > -300)
    status = 0;
end


%% Test: Integer delay, FIR and DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h = ckhfir([3.4+1i*5 2-1i*0.45], 10e3, [-2 3], 1);
ideal_dc = rand(1,1)+1i*rand(1,1);
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y = ckhfirapply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = [-2 3];
[D, h, dc, info] = ckhsiglie(x, y, hidx);
if (D ~= ideal_D)                               || ...
        (max(abs(h(1).h - ideal_h.h)) > 1e-10)  || ...
        any(h(1).idx ~= ideal_h.idx)            || ...
        (h(1).fs ~= 10e3)                    || ...
        (max(abs(dc - ideal_dc)) > 1e-12)       || ...
        any(size(info.e) ~= [1 1])              || ...
        any(size(info.y_hat) ~= [1 1])          || ...
        ~isfield(info, 'cond_A')                || ...
        (info.mse > 1e-27)                      || ...
        (info.mse_dB > -280)                    || ...
        (info.esr > 1e-30)                      || ...
        (info.esr_dB > -300)
    status = 0;
end


% %% Test: Integer delay, FIR and DC offset.
% %%       x.type = 'circular'. y.type = 'circular'.
% %%       hidx is over-modelled and more DC offset.
% %%
% %%       Here we have multiple solutions because a different value of D combined
% %%       with a different delay in the FIR filter gives us the same overall
% %%       integer delay.
% lastwarn('');
% orig_warn_state = warning('query', 'ckhsiglie:multiple_solutions');
% warning('off', 'ckhsiglie:multiple_solutions');
% rng(0, 'twister');
% s = rand(1,100) + 1i*rand(1,100);
% x = ckhsig(s, 'circular', 10e3, [0 99]);
% ideal_D = -13;
% ideal_h = fir([3.4+1i*3.5 2.2-1i*2.45], 1, [], [-2 3]);
% ideal_dc = 10*(rand(1,1)+1i*rand(1,1));
% h_delay = fir(1, 1, [], ideal_D);
% y = apply(h_delay, x);
% y = apply(ideal_h, y);
% y.s = y.s + ideal_dc;
% hidx = (-5:5);
% [D, h, dc, info] = ckhsiglie(x, y, hidx);
% 
% if isempty(lastwarn)
%     status = 0;
% end
% warning(orig_warn_state);
% 
% % I encountered a very interesting problem in running the exact same code with
% % same Matlab version but on different machines. One machine is a P3 laptop and
% % another machine is a Atholon desktop. I got two different results from these
% % two machines. However, both results make sense because hidx is over-modelled.
% ideal_h = full(ideal_h);
% ideal_h.idx = [];
% if (D == -11)
%     ideal_h.h = [zeros(1,1), ideal_h.h, zeros(1,4)];
% elseif (D == -12)
%     ideal_h.h = [zeros(1,2), ideal_h.h, zeros(1,3)];
% elseif (D == -13)
%     ideal_h.h = [zeros(1,3), ideal_h.h, zeros(1,2)];
% elseif (D == -14)
%     ideal_h.h = [zeros(1,4), ideal_h.h, zeros(1,1)];
% elseif (D == -15)
%     ideal_h.h = [zeros(1,5), ideal_h.h];
% else
%     status = 0;
% end
% ideal_h.idx = (-5:5);
% if (max(abs(h.h - ideal_h.h)) > 1e-10) || ...
%         any(h.idx ~= ideal_h.idx) || (h.fs ~= 10e3) || ...
%         (max(abs(dc - ideal_dc)) > 1e-12) || ...
%         any(size(info.e) ~= [1 1]) || ...
%         any(size(info.y_hat) ~= [1 1]) || ...
%         ~isfield(info, 'cond_A') || ...
%         (info.mse > 1e-27) || ...
%         (info.mse_dB > -280) || ...
%         (info.esr > 1e-30) || ...
%         (info.esr_dB > -300)
%     status = 0;
% end


%% Test: Integer and fractional delay. No DC offset.
%%       x.type = 'segment'. y.type = 'segment'.
rng(0, 'twister');
s = rand(1,1000) + 1i*rand(1,1000);
x = ckhsig(s, 10e3, 'segment', [0 999]);
ideal_D = 5;
ideal_h = ckhfir('lagrangefd', 101, 0.23, 1, 10e3, []);
ideal_dc = 0;
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y = ckhfirapply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = (-10:10);
[D, h, dc, info] = ckhsiglie(x, y, hidx);
H = ckhfirfreq(h);
k = find((H.f_Hz > -3000) & (H.f_Hz < 3000));
if (D ~= ideal_D)                                   || ...
        (abs(20*log10(mean(abs(H.H(k))))) > 3e-4)   || ...
        (abs(mean(H.Gd(k)) - 0.23) > 0.002)         || ...
        (max(abs(dc - ideal_dc)) > 2e-4)            || ...
        any(size(info.e) ~= [1 1])                  || ...
        any(size(info.y_hat) ~= [1 1])              || ...
        ~isfield(info, 'cond_A')                    || ...
        (info.mse > 2e-6)                           || ...
        (info.mse_dB > -56)                         || ...
        (info.esr > 3e-6)                           || ...
        (info.esr_dB > -55)
    status = 0;
end


%% Test: Check the default value of D_offset.
%%       Integer delay, FIR and DC offset.
%%       x.type = 'circular'. y.type = 'circular'.
%%       hidx is over-modelled and more DC offset.
lastwarn('');
orig_warn_state = warning('query', 'ckhsiglie:multiple_solutions');
warning('off', 'ckhsiglie:multiple_solutions');
rng(0, 'twister');
s = rand(1,100) + 1i*rand(1,100);
x = ckhsig(s, 10e3, 'circular', [0 99]);
ideal_D = -13;
ideal_h = ckhfir([3.4+1i*3.5 2.2-1i*2.45], 10e3, [-2 3], 1);
ideal_dc = 10*(rand(1,1)+1i*rand(1,1));
h_delay = ckhfir(1, 10e3, ideal_D, 1);
y = ckhfirapply(h_delay, x);
y = ckhfirapply(ideal_h, y);
y.s = y.s + ideal_dc;
hidx = (-5:5);
[D, h, dc, info] = ckhsiglie(x, y, hidx);
[D1, h1, dc1, info1] = ckhsiglie(x, y, hidx, (-5:1:5));
if (D ~= D1) || ~isequal(h, h1) || (max(abs(dc - dc1)) > 1e-12) || ...
        ~isequal(info, info1)
    status = 0;
end
if isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Test: Short sequence but relatively long hidx. The convolution matrix
%%       (returned by convmtx.m) is [].
x = ckhsig((0:4)+1i*(10:14), 10e3, 'segment', [0 4]);
y = x;
hidx = [0 1];
orig_warn_state = warning('query', 'MATLAB:rankDeficientMatrix');
warning('off', 'MATLAB:rankDeficientMatrix');
% warning('off', 'all')   % Turn off warning on rank deficient.
[D, h, dc, info] = ckhsiglie(x, y, hidx);
% warning('on', 'all')
if (D ~= 0)                                 || ...
        any(abs(h(1).h - [1 0]) > 1e-10)    || ...
        any(h(1).idx ~= [0 1])              || ...
        (h(1).fs ~= 10e3)                || ...
        (max(abs(dc - 0)) > 1e-12)          || ...
        any(size(info.e) ~= [1 1])          || ...
        any(size(info.y_hat) ~= [1 1])      || ...
        ~isfield(info, 'cond_A')            || ...
        (info.mse > 1e-27)                  || ...
        (info.mse_dB > -280)                || ...
        (info.esr > 1e-30)                  || ...
        (info.esr_dB > -300)
    status = 0;
end
warning(orig_warn_state);


%% Test: No distortion. Crash due to signal being too short.
x = ckhsig((0:3)+1i*(10:13), 10e3, 'segment', [0 3]);
y = x;
h_idx = (-1:1);
try
    ckhsiglie(x, y, h_idx);
    status = 0;
catch err
    str = 'Solution not found due to input signals being too short.';
    if ~strcmp(err.message, str)
        status = 0;
    end
end


end

