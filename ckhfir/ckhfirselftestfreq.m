function status = ckhfirselftestfreq

%%
%       SYNTAX: status = ckhfirselftestfreq;
%
%  DESCRIPTION: Test ckhfirfreq.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: Default FIR filter structure (i.e. h.h = 1). fftlen = 4.
h          = ckhfir;
fftlen     = 4;
H          = ckhfirfreq(h, '', '', fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    ideal_H(:,n)    = ones(4,1);
    ideal_f_Hz(:,n) = ((0:fftlen-1)' / fftlen - 0.5) * h(n).fs;
    ideal_Gd(:,n)   = zeros(4,1);
end
if max(max(abs(H.H -    ideal_H)))    > 0   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 0   || ...
   max(max(abs(H.Gd -   ideal_Gd)))   > 0
    status = 0;
end


% %% Test: Default FIR filter structure (i.e. h.h = 1). options.fftlen = 4. 
% %%       options.norm = ''.
% h = {ckhfir};
% options = [];
% options.fftlen = 4;
% options.norm = '';
% H = ckhfirfreq(h, options);
% ideal_H = NaN(options.fftlen, numel(h));
% ideal_f_Hz = ideal_H;
% ideal_Gd = ideal_H;
% for n = 1:numel(h)
%     ideal_H(:,n) = ones(4,1);
%     ideal_f_Hz(:,n) = ((0:options.fftlen-1)' / options.fftlen - 0.5) * ...
%         h{n}.fs;
%     ideal_Gd(:,n) = zeros(4,1);
% end
% if max(max(abs(H.H - ideal_H))) > 0 || ...
%         max(max(abs(H.f_Hz - ideal_f_Hz))) > 0 || ...
%         max(max(abs(H.Gd - ideal_Gd))) > 0
%     status = 0;
% end


%% Test: Default FIR filter structure (i.e. h.h = 1). fftlen = 4. norm = 'none'.
h          = ckhfir;
fftlen     = 4;
norm       = 'none';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    ideal_H(:,n)    = ones(4,1);
    ideal_f_Hz(:,n) = ((0:fftlen-1)' / fftlen - 0.5) * h(n).fs;
    ideal_Gd(:,n)   = zeros(4,1);
end
if max(max(abs(H.H -    ideal_H)))    > 0   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 0   || ...
   max(max(abs(H.Gd -   ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = 4. options.fftlen = 4. options.norm = 'dc'.
h          = ckhfir;
h(1).h     = 4;
fftlen     = 4;
norm       = 'dc';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    ideal_H(:,n)    = ones(4,1);
    ideal_f_Hz(:,n) = ((0:fftlen-1)' / fftlen - 0.5) * h(n).fs;
    ideal_Gd(:,n)   = zeros(4,1);
end
if max(max(abs(H.H    - ideal_H)))    > 0   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 0   || ...
   max(max(abs(H.Gd   - ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = 4. h.idx = 3. options.fftlen = 5. options.norm = 'dc'.
h          = ckhfir(4, 11, 3, 1);
fftlen     = 5;
norm       = 'dc';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    f               = (0:fftlen-1)' / fftlen;
    ideal_H(:,n)    = fftshift(exp(-1i*2*pi*f*3));
    ideal_f_Hz(:,n) = (-2:2)'/5 * h(n).fs;
    ideal_Gd(:,n)   = ones(5,1)*3;
end
if max(max(abs(H.H -    ideal_H)))    > 1e-12   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 1e-12   || ...
   max(max(abs(H.Gd -   ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = 4. h.idx = -4. options.fftlen = 5. options.norm = 'none'.
h          = ckhfir(4, 11, -4, 1);
fftlen     = 5;
norm       = 'none';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    f               = (0:fftlen-1)' / fftlen;
    ideal_H(:,n)    = fftshift(exp(-1i*2*pi*f*(-4))) * 4;
    ideal_f_Hz(:,n) = (-2:2)'/5 * h(n).fs;
    ideal_Gd(:,n)   = ones(5,1)*(-4);
end
if max(max(abs(H.H    - ideal_H)))    > 1e-12   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 1e-12   || ...
   max(max(abs(H.Gd   - ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = [0 0 1]. options.fftlen = 5. options.norm = 'none'.
h          = ckhfir([0 0 1], 11, [0 1 2], 1);
fftlen     = 5;
norm       = 'none';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    f               = (0:fftlen-1)' / fftlen;
    ideal_H(:,n)    = fftshift(exp(-1i*2*pi*f*(2)));
    ideal_f_Hz(:,n) = (-2:2)'/5 * h(n).fs;
    ideal_Gd(:,n)   = ones(5,1)*(2);
end
if max(max(abs(H.H    - ideal_H)))    > 1e-12   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 1e-12   || ...
   max(max(abs(H.Gd   - ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = 4. h.idx = -4. options = [].
h          = ckhfir(4, 11, -4, 1);
H          = ckhfirfreq(h, '', '', [], '', '');
fftlen     = 8192;
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    f               = (0:fftlen-1)' / fftlen;
    ideal_H(:,n)    = fftshift(exp(-1i*2*pi*f*(-4))) * 4;
    ideal_f_Hz(:,n) = (f - 0.5) * h.fs;
    ideal_Gd(:,n)   = ones(fftlen,1)*(-4);
end
if max(max(abs(H.H    - ideal_H)))    > 1e-12   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 1e-12   || ...
   max(max(abs(H.Gd   - ideal_Gd)))   > 0
    status = 0;
end


%% Test: h.h = 4. h.idx = -4. options.fftlen = []. options.norm = 'none'.
h          = ckhfir(4, 11, -4, 1);
fftlen     = [];
norm       = 'none';
H          = ckhfirfreq(h, '', norm, fftlen, '', '');
fftlen     = 8192;
ideal_H    = NaN(fftlen, numel(h));
ideal_f_Hz = ideal_H;
ideal_Gd   = ideal_H;
for n = 1:numel(h)
    f               = (0:fftlen-1)' / fftlen;
    ideal_H(:,n)    = fftshift(exp(-1i*2*pi*f*(-4))) * 4;
    ideal_f_Hz(:,n) = (f - 0.5) * h.fs;
    ideal_Gd(:,n)   = ones(fftlen,1)*(-4);
end
if max(max(abs(H.H    - ideal_H)))    > 1e-12   || ...
   max(max(abs(H.f_Hz - ideal_f_Hz))) > 1e-12   || ...
   max(max(abs(H.Gd   - ideal_Gd)))   > 0
    status = 0;
end


%% Test: h(1).h = 1:8000. h(1).idx = [0:7999].
%%       h(2).h = [1:8000, zeros(1, 2000)]. h(2).idx = [0:9999].
%%       options.fftlen = []. options.norm = 'none'.
h      = repmat(ckhfir, 1, 2, 1);
h(1)   = ckhfir(1:8000, 11, 0:7999);
h(2)   = ckhfir([1:8000, zeros(1, 2000)], 21, 0:9999, 1);
fftlen = [];
norm   = 'none';
H      = ckhfirfreq(h, '', norm, fftlen, '', '');
if size(H.H, 1) ~= 16384                                    || ...
    max(max(abs(H.H(:,1)       - H.H(:,2))))       > 1e-12  || ...
    max(max(abs(H.f_Hz(:,1)/11 - H.f_Hz(:,2)/21))) > 1e-12  || ...
    max(max(abs(H.Gd(:,1)      - H.Gd(:,2))))      > 0    
    status = 0;
end
ideal_Gd = fftshift(grpdelay((1:8000), 1, 16384, 'whole'));
if max(abs(ideal_Gd(:) - H.Gd(:,1))) > 0
    status = 0;
end


%% Exit function.
end

