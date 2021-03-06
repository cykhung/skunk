function varargout = ckhsigpsd(varargin)

%%
%       SYNTAX: X = ckhsigpsd(x);
%               X = ckhsigpsd(x, linetype);
%               X = ckhsigpsd(x, linetype, fftlen);
%               X = ckhsigpsd(x, linetype, fftlen, xunit);
%               X = ckhsigpsd(x, linetype, fftlen, xunit, win, norm);
%               ckhsigpsd(...);
% 
%  DESCRIPTION: Power spectral density. Note that calling this function without
%               output argument will plot the PSD of all input signal
%               structures.
%
%               Use PSD to calculate average power:
%               >> [~, avg_pwr_dB_time] = ckhsigpkavg(x);
%               >> X = ckhsigpsd(x, '', 8192, 'Hz', kaiser(8192, 19), 'none');
%               >> avg_pwr_dB_freq = 10*log10(sum(X.psd * X.fs / length(X.psd)))
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). x.s must not be [].
%
%               - linetype (char or 1-D row/col cell array of char)
%                   Line types. Optional. Set to '' or {} for default value.
%                   Default = {'r', 'b', 'g', 'c', 'm', 'y', 'k'}. If number
%                   of line types < numel(x), then line types will be reused.
%
%               - fftlen (real double)
%                   FFT length. Optional. Set to [] for default value. Default =
%                   2^17.
%
%               - xunit (char)
%                   Unit of the x-axis (i.e. frequency). Optional. Valid units
%                   are: 'Hz', 'kHz', 'MHz', 'GHz'. By default, this function
%                   will choose the unit based on sampling rate of the first
%                   input signal. This field only affects plotting.
%
%               - win (1-D row/col array of real double or
%                      N-D cell array of 1-D row/col array of real double)
%                   Window. Optional. Default is kaiser window with beta = 19 
%                   and window length is:
%
%                       if length(x.s) >= 8192
%                           window length = 8192
%                       else
%                           if x.type == 'circular'    
%                               window length = 8192
%                           else
%                               window length = length(x.s)
%                           end
%                       end
%                       
%                   For user-defined window, assign the window vector to this
%                   field. Regardless of whether the window is automatically
%                   generated by this function or user defined, the window
%                   length must be <= length(x.s) and window length must also be
%                   <= FFT length otherwise this function will crash. Although
%                   Matlab PSD function allows these two conditions, it is the
%                   author's opinion that this would case misleading PSD result
%                   and should not be allowed.
%
%                   In case of multiple input signals, user can use cell array
%                   to specify different windows for different input signals.
%
%                   If x is a N-D array while win has only one element, then
%                   win will be automatically expanded to a N-D array filled
%                   with the same element.
%
%               - norm (string)
%                   Normalization type. Optional. Default = 'none'. Valid types
%                   are:
%                       'none'    - No normalization.
%                       'sum_psd' - Normalize psd by its sum(psd).
%                       'max'     - Normalize psd by its maximum value. 
%                   In case of multiple input signal objects, same nomalization
%                   method is applied to each signal and each signal is
%                   normalized independently.
%
%       OUTPUT: - X (struct)
%                   PSD stucture. Valid fields are:
%
%                   - psd (2-D array of real double)
%                       Power spectral density in linear scale. Each column of 
%                       the matrix corresponds to one signal.
%
%                   - f (2-D array of real double)
%                       Frequency in Hz. Each column of the matrix corresponds 
%                       to one signal.


%% Assign input arguments.
x       = varargin{1};
options = [];
switch nargin
case 1
    % Do nothing.
case 2
    options.linetype = varargin{2};
case 3
    options.linetype = varargin{2};
    options.fftlen   = varargin{3};
case 4
    options.linetype = varargin{2};
    options.fftlen   = varargin{3};
    options.xunit    = varargin{4};
case 6
    options.linetype = varargin{2};
    options.fftlen   = varargin{3};
    options.xunit    = varargin{4};
    options.win      = varargin{5};
    options.norm     = varargin{6};
otherwise
    error('Invalid number of input arguments.');
end


%% Check x.
ckhsigisvalid(x);


%% Check for empty signal object.
for n = 1:numel(x)
    if isempty(x(n).s)
        error('x.s = [].');
    end
end


%% Assign default values to options.
if ~isfield(options, 'fftlen') || isempty(options.fftlen)
    options.fftlen = 2^17;
end
if ~isfield(options, 'linetype') || isempty(options.linetype)
    options.linetype = {'r', 'b', 'g', 'c', 'm', 'y', 'k'};
end
if ~isfield(options, 'xunit') || isempty(options.xunit)
    if x(1).fs < 1e3
        options.xunit = 'Hz';
    elseif x(1).fs < 1e6
        options.xunit = 'kHz';
    elseif x(1).fs < 1e9
        options.xunit = 'MHz';
    else
        options.xunit = 'GHz';
    end
end
if ~isfield(options, 'win') || isempty(options.win)
    options.win = cell(size(x));
    for n = 1:numel(x)
        if length(x(n).s) >= 8192
            options.win{n} = getkaiser(19, 8192);
        else
            if strcmp(x(n).type, 'circular')
                options.win{n} = getkaiser(19, 8192);
            else
                if length(x(n).s) == 1
                    error(['Signal has only one sample. ', ...
                           'Not supported by Kaiser window.']);
                end
                options.win{n} = getkaiser(19, length(x(n).s));
            end
        end
    end
end
if ~isfield(options, 'norm') || isempty(options.norm)
    options.norm = 'none';
end


%% Make sure that win is a cell arrray and length(win) = length(x).
if ~iscell(options.win)
    options.win = {options.win};
end
if (numel(x) > 1) && (numel(options.win) == 1)
    % Automatically expand win to N-D cell array.
    options.win = repmat(options.win, size(x));
end
if any(size(x) ~= size(options.win))
    error('size(x) ~= size(options.win)');
end


%% Check fft length.
if ~real(options.fftlen)
    error('fftlen must be a real number.');
elseif options.fftlen <= 0
    error('fftlen must be greater than zero');
elseif options.fftlen ~= fix(options.fftlen)
    error('fftlen must be an integer.')
end


%% For circularly continuous signal, repeat the signal to exceed integer
%% multiple of fftlen. Note that the new repeated signal may not be circularly
%% continuous anymore.
for n = 1:numel(x)
    N   = length(x(n).s);
    Nwin = length(options.win{n});
    if strcmp(x(n).type, 'circular') && (N < Nwin)
        N = ceil(N / Nwin) * Nwin;
        x(n) = ckhsiggrep(x(n), N);
    end
end


%% Check window length.
for n = 1:numel(x)
    if length(options.win{n}) > options.fftlen
        error('length(win) > options.fftlen');
    end
    if length(options.win{n}) > length(x(n).s)
        error('length(win) > length(x.s).');
    end
end


%% Initialize both X.psd and X.f to zeros(fftlen, Nsignals).
X = [];
X.psd = zeros(options.fftlen, numel(x));
X.f   = X.psd;
X.fs  = zeros(1, numel(x));


%% Calculate PSD.
for n = 1:numel(x)
    [PSD, f]    = psd_1(x(n).s, x(n).fs, options.fftlen, options.win{n}, ...
                        options.norm);
    X.psd(:, n) = PSD(:);
    X.f(:, n)   = f(:) * x(n).fs;
    X.fs(n)     = x(n).fs;
end


%% Plot PSD.
if nargout == 0
    psd_plot(X, options.xunit, options.linetype, options.win);
    return;
end
    

%% Assign output arguments and exit function.
varargout = {X};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Syntax: [PSD, f] = psd_1(s, fs, fft_len, win, norm_type);
% 
%  Description: Calculate PSD of one signal vector using Matlab function psd().
%
%        Input: - s (1-D row/col array of complex double)
%                   Vector of samples
%
%               - fs (real double)
%                   Sampling rate in Hz.
%
%               - fft_len (real double)
%                   FFT length.
%
%               - win (1-D row/col array of real double)
%                   Window.
%
%               - norm_type (string)
%                   Normalization type. Valid types are:
%                       'sum_psd' - Normalize psd by its sum(psd).
%                       'max' - Normalize psd by its maximum value. 
%                       'none' - No normalization.
%
%       Output: - PSD (1-D col array of real double)
%                   Estimated power spectral density in linear scale (not dB)
%                   The spectral density is flipped by fftshift(). Same 
%                   dimension as vector s.
%
%               - f (1-D col array of real double)
%                   Vector of normalized frequencies (real). Same dimension as 
%                   vector s.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PSD, f] = psd_1(s, fs, fft_len, win, norm_type)


%% Force s and win to be column vectors.
s = s(:);
win = win(:);


%% Calculate KMU (from Matlab PSD).
k   = fix(length(s) / length(win));
KMU = k * (norm(win) ^ 2) * fs;


%% Calculate PSD.
Nblocks = fix(length(s) / length(win));
midx    = 1:length(win);
PSD     = zeros(fft_len, 1);
for m = 1:Nblocks    
    PSD  = PSD + abs(fft(s(midx) .* win, fft_len)) .^ 2;
    midx = midx + length(win);
end
PSD = fftshift(PSD);


%% Scale PSD by KMU.
PSD = PSD * (1/KMU);


%% Normalize psd.
switch norm_type
case 'max'
   PSD = PSD / max(PSD);
case 'sum_psd'
   PSD = PSD / sum(PSD);
case 'none'
   % Do nothing.
otherwise
   error('Invalid norm_type.');
end

   
%% Calculate FFT frequencies (after fftshift). Note that fftshift will shift
%% f = 0.5 to f = -0.5.
f = fftshift((0:fft_len-1)/fft_len);
mask = f > 0.5 - 1e-10;     % We need to include 0.5.
f(mask) = f(mask) - 1;


%% Exit function.
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Syntax: psd_plot(X, xunit, linetype);
% 
%  Description: Plot PSD.
%
%        Input: - X (struct)
%                   PSD stucture. Valid fields are:
%
%                   - psd (2-D array of real double)
%                       Power spectral density in linear scale. Each column of 
%                       the matrix corresponds to one signal.
%
%                   - f (2-D array of real double)
%                       Frequency in Hz. Each column of the matrix corresponds 
%                       to one signal.
%
%                   - fs (1-D row array of real double)
%                       Sampling rate in Hz of each signal.
%
%               - xunit (string)
%                   Unit of the x-axis (i.e. frequency).
%
%               - linetype (string or 1-D row/col cell array of strings)
%                   Line types. Optional. Set to '' or {} for default values.
%                   If number of line types < number of columns in X.psd, then
%                   line types will be reused.
%
%       Output: none.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psd_plot(X, xunit, linestyle, win)


%% Force linestyle to be cell array.
if ~iscell(linestyle)
    linestyle = {linestyle};
end


%% Define x-axis scaling factor and xlabel string.
switch xunit
case 'Hz'
    xscale = 1;
    xlabelstr = 'Frequency (Hz)';
case 'kHz'
    xscale = 1e-3;
    xlabelstr = 'Frequency (kHz)';
case 'MHz'
    xscale = 1e-6;
    xlabelstr = 'Frequency (MHz)';
case 'GHz'
    xscale = 1e-9;
    xlabelstr = 'Frequency (GHz)';
otherwise
    error('Invalid xunit.');
end


%% Plot PSD.
linestyle_idx = 1;
for k = 1:size(X.psd,2)
    
    % Plot.
    holdstate = ishold;     % Remember hold state.
    plot(X.f(:,k)*xscale, 10*log10(X.psd(:,k)), linestyle{linestyle_idx});
    hold on
    
    % Increment color index.
    linestyle_idx = linestyle_idx + 1;
    if linestyle_idx > length(linestyle)
        linestyle_idx = 1;
    end
    
end
if holdstate    % Restore hold state.
    hold on
else
    hold off
end
xlabel(xlabelstr);
ylabel('PSD (dB/Hz)');
title_str = sprintf('Power Spectral Density. WIN =');
tmp = cell(size(win));
for n = 1:numel(win)
    tmp{n} = num2str(length(win{n}));
end
tmp = unique(tmp, 'stable');
if numel(tmp) == 1
    title_str = sprintf('%s %s.', title_str, tmp{1});
else
    tmp       = strjoin(tmp, ', ');
    title_str = sprintf('%s [%s].', title_str, tmp);
end
if all(X.fs == X.fs(1))
    % All signals have the same sampling rate.
    switch xunit
    case 'Hz'
        title_str = sprintf('%s Fs = %g Hz.', title_str, X.fs(1) * xscale);
    case 'kHz'
        title_str = sprintf('%s Fs = %g kHz.', title_str, X.fs(1) * xscale);
    case 'MHz'
        title_str = sprintf('%s Fs = %g MHz.', title_str, X.fs(1) * xscale);
    case 'GHz'
        title_str = sprintf('%s Fs = %g GHz.', title_str, X.fs(1) * xscale);
    otherwise
        error('Invalid xunit.');
    end
else
    % Different signals have different sampling rates.
    title_str = sprintf('%s Fs =', title_str);
    tmp = cell(size(X.fs));
    for n = 1:numel(X.fs)
        switch xunit
        case 'Hz'
            tmp{n} = sprintf('%g Hz', X.fs(n) * xscale);
        case 'kHz'
            tmp{n} = sprintf('%g kHz', X.fs(n) * xscale);
        case 'MHz'
            tmp{n} = sprintf('%g MHz', X.fs(n) * xscale);
        case 'GHz'
            tmp{n} = sprintf('%g GHz', X.fs(n) * xscale);
        otherwise
            error('Invalid xunit.');
        end
    end
    tmp       = strjoin(tmp, ', ');
    title_str = sprintf('%s [%s].', title_str, tmp);    
end

% title_str = [title_str, ']'];
title(title_str);
grid on
pan xon
zoom on
xticks = get(gca, 'xtick');
half   = (xticks(2) - xticks(1)) / 2;
set(gca, 'xlim', [xticks(1) - half, xticks(end) + half])
legend


%% Assign output arguments and exit function.
end



