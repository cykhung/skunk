function status = ckhsigselftestpsd

%%
%       SYNTAX: status = ckhsigselftestpsd;
%
%  DESCRIPTION: Test ckhsigpsd.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: Rectangular window. Positive tone frequency. Odd FFT length. 
x         = ckhsig([], 1, 'segment', []);
x.s       = exp(1i*2*pi*(2/5)*(0:4));
x.fs      = 10;
fftlen    = 5;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [0 0 0 0 5]' / x.fs;
ideal_f   = [-4 -2 0 2 4]';
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Rectangular window. Positive tone frequency. Even FFT length. 
x         = ckhsig([], 1, 'segment', []);
x.s       = exp(1i*2*pi*(2/4)*(0:3));
x.fs      = 10;
fftlen    = 4;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [4 0 0 0]' / x.fs;
ideal_f   = [-5 -2.5 0 2.5]';
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Rectangular window. Negative tone frequency. Odd FFT length. 
x         = ckhsig([], 1, 'segment', []);
x.s       = exp(1i*2*pi*(-1/5)*(0:4));
x.fs      = 10;
fftlen    = 5;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [0 5 0 0 0]' / x.fs;
ideal_f   = [-4 -2 0 2 4]';
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Rectangular window. Negative tone frequency. Even FFT length. 
x         = ckhsig([], 1, 'segment', []);
x.s       = exp(1i*2*pi*(-1/4)*(0:3));
x.fs      = 10;
fftlen    = 4;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [0 4 0 0]' / x.fs;
ideal_f   = [-5 -2.5 0 2.5]';
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Rectangular window. Real-valued signal. Odd FFT length.
x         = ckhsig([], 1, 'segment', []);
x.s       = cos(2*pi*(2/5)*(0:4));
x.fs      = 10;
fftlen    = 5;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [5/4 0 0 0 5/4]' / x.fs;
ideal_f   = (-2:2)'/5*10;
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Rectangular window. Real-valued signal. Even FFT length.
x         = ckhsig([], 1, 'segment', []);
x.s       = cos(2*pi*(2/6)*(0:5));
x.fs      = 10;
fftlen    = 6;
win       = ones(1,fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
ideal_psd = [0 1.5 0 0 0 1.5]' / x.fs;
ideal_f   = (-3:2)'/6*10;
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test: Check default value.
x      = ckhsig([], 1, 'segment', []);
x.s    = (1:30000) + 1i*(200:30199);
x.fs   = 10;
fftlen = 2^17;
win    = getkaiser(19, 8192);
NORM   = 'none';
X1     = ckhsigpsd(x, '', fftlen, '', win, NORM);
X2     = ckhsigpsd(x);
if (max(abs(X1.psd - X2.psd)) > 0) || (max(abs(X1.f - X2.f)) > 0)
    status = 0;
end


%% Test: Check input argument list.
%%       Rectangular window. Real-valued signal. Even FFT length.
x         = ckhsig([], 1, 'segment', []);
x.s       = cos(2*pi*(2/6)*(0:5));
x.fs      = 10;
X         = ckhsigpsd(x, '', 6, 'Hz', ones(1,6), '');
ideal_psd = [0 1.5 0 0 0 1.5]' / x.fs;
ideal_f   = (-3:2)'/6*10;
if (max(abs(X.psd - ideal_psd))   > 1e-15) || ...
   (max(abs(X.f - ideal_f)) > 1e-15)
    status = 0;
end


%% Test. Crash. x = empty.
try     %#ok<TRYNC>
    x      = ckhsig([], 1, 'segment', []);
    ckhsigpsd(x, '', 32768, 'GHz', '', '');
    status = 0;
end
x      = repmat({ckhsig([], 1, 'segment', [])}, 1, 2);
x{1}.s = 1:10;
try     %#ok<TRYNC>
    ckhsigpsd(x, '', 32768, 'GHz', '', '');
    status = 0;
end


%% Test. Crash. length(win) > length(x.s).
x      = ckhsig([], 1, 'segment', []);
x.s    = 1:300;
fftlen = 2048;
NORM   = 'none';
% try     %#ok<TRYNC>
%     win = [];
%     ckhsigpsd(x, '', fftlen, '', win, NORM);
%     status = 0;
% end
try     %#ok<TRYNC>
    win = ones(1, 2000);
    ckhsigpsd(x, '', fftlen, '', win, NORM);
    status = 0;
end


%% Test. Crash. length(win) > FFT length.
x      = ckhsig([], 1, 'segment', []);
x.s    = 1:300;
fftlen = 128;
win    = ones(1, 200);
NORM   = 'none';
try     %#ok<TRYNC>
    ckhsigpsd(x, '', fftlen, '', win, NORM);
    status = 0;
end


%% Test. length(win) < length(x.s). length(win) = fftlen.
x         = ckhsig([], 1, 'segment', []);
x.s       = 1:300;
x.fs      = 10;
fftlen    = 256;
win       = getkaiser(19, fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
Nblocks   = 1;
w         = getkaiser(19, 256);
KMU       = Nblocks * (norm(w) ^ 2) * x.fs;
ideal_PSD = abs(fftshift(fft( w .* x.s(1:256) ))) .^ 2;
ideal_PSD = ideal_PSD * (1/KMU);
if max(abs(ideal_PSD(:) - X.psd)) > 0
    status = 0;
end

x         = ckhsig([], 1, 'segment', []);
x.s       = (1:600) + 1i*(600:-1:1);
x.fs      = 10;
fftlen    = 256;
win       = getkaiser(19, fftlen);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
Nblocks   = 2;
w         = getkaiser(19, 256);
KMU       = Nblocks * (norm(w) ^ 2) * x.fs;
ideal_PSD = abs(fftshift(fft( w .* x.s(1:256) )))   .^ 2 + ...
            abs(fftshift(fft( w .* x.s(257:512) ))) .^ 2;
ideal_PSD = ideal_PSD * (1/KMU);
if max(abs(ideal_PSD(:) - X.psd)) > 0
    status = 0;
end


%% Test. length(win) < length(x.s). length(win) < fftlen.
x         = ckhsig([], 1, 'segment', []);
x.s       = 1:300;
x.fs      = 10;
fftlen    = 256;
win       = getkaiser(19, 200);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
Nblocks   = 1;
w         = getkaiser(19, 200);
KMU       = Nblocks * (norm(w) ^ 2) * x.fs;
ideal_PSD = abs(fftshift(fft( w .* x.s(1:200), 256 ))) .^ 2;
ideal_PSD = ideal_PSD * (1/KMU);
if max(abs(ideal_PSD(:) - X.psd)) > 0
    status = 0;
end

x         = ckhsig([], 1, 'segment', []);
x.s       = (1:580) + 1i*(580:-1:1);
x.fs      = 10;
fftlen    = 256;
win       = getkaiser(19, 200);
X         = ckhsigpsd(x, '', fftlen, '', win, '');
Nblocks   = 2;
w         = getkaiser(19, 200);
KMU       = Nblocks * norm(w)^2 * x.fs;
ideal_PSD = abs(fftshift(fft( w .* x.s(1:200), 256 )))   .^ 2 + ...
            abs(fftshift(fft( w .* x.s(201:400), 256 ))) .^ 2;
ideal_PSD = ideal_PSD * (1/KMU);
if max(abs(ideal_PSD(:) - X.psd)) > 0
    status = 0;
end


%% Test: x = 2x3 array of signal objects.
v = (1:3000);
x = repmat(ckhsig([], 1, 'segment', []), 2, 3);
for n = 1:6
    x(n).s = v + n*10;
    x(n).fs = n*2;
end
x(2).s = (1:3000) + 1i*(1:3000);
fftlen = 2048;
win    = getkaiser(19, fftlen/2);
X      = ckhsigpsd(x, '', fftlen, '', win, 'none');
for n = 1:6
    ideal_X = ckhsigpsd(x(n), '', fftlen, '', win, 'none');
    if (max(abs(X.psd(:,n) - ideal_X.psd))   > 0) || ...
       (max(abs(X.f(:,n) - ideal_X.f)) > 0)
        status = 0;
    end
end


%% Test: length(win) > length(x.s) but x is circular.
x = ckhsig((0:999), 1, 'circular', []);
x = [x, x];
X = ckhsigpsd(x, '', 8192);
ideal_X = ckhsigpsd(ckhsiggrep(x, [0 2999]), '', 8192);
if ~isequal(X, ideal_X)
    status = 0;
end
ideal_X = ckhsigpsd(ckhsiggrep(x, [0 8191]), '', 8192);
if ~isequal(X, ideal_X)
    status = 0;
end


%% Test: Default values.
x       = ckhsig((0:999), 1, 'segment', []);
X       = ckhsigpsd(x);
ideal_X = ckhsigpsd(x, '', 2^17, '', getkaiser(19, 1000), 'none');
if ~isequal(X, ideal_X)
    status = 0;
end
x       = ckhsig((0:8191), 1, 'segment', []);
X       = ckhsigpsd(x);
ideal_X = ckhsigpsd(x, '', 2^17, '', getkaiser(19, 8192), 'none');
if ~isequal(X, ideal_X)
    status = 0;
end
x       = ckhsig((0:999), 1, 'circular', []);
X       = ckhsigpsd(x);
ideal_X = ckhsigpsd(x, '', 2^17, '', getkaiser(19, 8192), 'none');
if ~isequal(X, ideal_X)
    status = 0;
end
x       = ckhsig((0:8191), 1, 'circular', []);
X       = ckhsigpsd(x);
ideal_X = ckhsigpsd(x, '', 2^17, '', getkaiser(19, 8192), 'none');
if ~isequal(X, ideal_X)
    status = 0;
end


%% Exit function.
end

