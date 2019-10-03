function varargout = ckhfirfreq(varargin)

%%
%       SYNTAX: H = ckhfirfreq(h);
%               H = ckhfirfreq(h, linetype);
%               H = ckhfirfreq(h, linetype, norm);
%               H = ckhfirfreq(h, linetype, norm, fftlen, item, xunit);
%               ckhfirfreq(...);
%
%  DESCRIPTION: Compute frequency response of FIR filter. Calling this function
%               without output argument will plot the frequency response of
%               the FIR filter.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%               - linetype (char or 1-D row/col cell array of char)
%                   Line types. Optional. Set to '' or {} for default values.
%                   Default = {'r', 'b', 'g', 'c', 'm', 'y', 'k'}. If number
%                   of line types < numel(h), then line types will be reused.
%
%               - norm (char)
%                   Normalization type. Optional. Set to '' for default value.
%                   Default = 'none'. Valid types are:
%                       'none' - No normalization.
%                       'dc' - Normalize h.h by sum(h.h).
%
%               - fftlen (real double)
%                   FFT length. Optional. Set to [] for default value. Default
%                   value is calculated as follows:
%                       fftlen = 8192;
%                       if any one of the filter lengths > 8192
%                           fftlen = next integer power of 2 of the longest
%                                    FIR filter.
%                       end
%
%               - item (char)
%                   Frequency response item to be calculated and plotted. 
%                   Optional. Set to '' for default value. Valid strings are:
%                       'mag_grpdelay' - Magnitude response and group delay
%                                        response. Default.
%                       'mag' - Magnitude response only.
%                       'grpdelay' - Group delay response only.
%
%               - xunit (char)
%                   Unit of the x-axis (i.e. frequency). Optional. Valid units
%                   are: 'Hz', 'kHz', 'MHz', 'GHz'. By default, this function
%                   will choose the unit based on sampling rate of the first
%                   input FIR filter. This field only affects plotting.
%
%       OUTPUT: - H (struct)
%                   Frequency response stucture. Valid fields are:
%
%                   - H.H (2-D array of complex double)
%                       Frequency response (both magnitude and phase). Note that
%                       the phase response is adjusted according to h.idx.
%                       FFTSHIFT is already applied. Each column of the matrix
%                       corresponds to one FIR filter structure.
%
%                   - H.Gd (2-D array of real double)
%                       Group delay response. Note that group delay response is
%                       adjusted according to info.idx. FFTSHIFT is already
%                       applied. Each column of the matrix corresponds to one
%                       FIR filter structure. All matrix elements equal to NaN
%                       if group delay response is not calculated.
%
%                   - H.f_Hz (2-D array of real double)
%                       Frequency in Hz. Each column of the matrix corresponds 
%                       to one FIR filter structure. Note that although the same
%                       FFT length is used for all FIR filter structures, the
%                       frequency vector for each structure can still be 
%                       different due to different sampling rate of each filter
%                       structure.


%% Assign input arguments.
options = [];
switch nargin
case 1
    h                = varargin{1};
case 2
    h                = varargin{1};
    options.linetype = varargin{2};
case 3
    h                = varargin{1};
    options.linetype = varargin{2};
    options.norm     = varargin{3};
case 6
    h                = varargin{1};
    options.linetype = varargin{2};
    options.norm     = varargin{3};
    options.fftlen   = varargin{4};
    options.item     = varargin{5};
    options.xunit    = varargin{6};
otherwise
    error('Invalid number of input arguments.');
end
clear varargin


%% Check h.
ckhfirisvalid(h);


%% Get the full impulse response of each input structure.
h = ckhfirfull(h);


%% Set all fields in structure "options".
if ~isfield(options, 'linetype') || isempty(options.linetype)
    options.linetype = {'r', 'b', 'g', 'c', 'm', 'y', 'k'};
end
if ~iscell(options.linetype)
    options.linetype = {options.linetype};
end
if ~isfield(options, 'norm') || isempty(options.norm)
    options.norm = 'none';
end
if ~isfield(options, 'fftlen') || isempty(options.fftlen)
    options.fftlen = 8192;
    N = NaN(1, numel(h));
    for n = 1:numel(h)
        N(n) = length(h(n).h);
    end
    if max(N) > options.fftlen
        options.fftlen = 2^ceil(log2(max(N)));      % next integer power of 2.
    end
end
if ~isfield(options, 'item') || isempty(options.item)
    options.item = 'mag_grpdelay';
end
if ~isfield(options, 'xunit') || isempty(options.xunit)
    if h(1).fs < 1e3
        options.xunit = 'Hz';
    elseif h(1).fs < 1e6
        options.xunit = 'kHz';
    elseif h(1).fs < 1e9
        options.xunit = 'MHz';
    else
        options.xunit = 'GHz';
    end
end


%% Perform normalization.
switch options.norm
case 'none'
    % Do nothing.
case 'dc'    
    for n = 1:numel(h)
        h(n).h = h(n).h / sum(h(n).h);
    end
otherwise
    error('Invalid norm.');
end


%% Calculate H.f_Hz (after FFTSHIFT).
f = fftshift((0:options.fftlen-1) / options.fftlen);
mask = f > 0.5 - 1e-10;     % We need to include 0.5.
f(mask) = f(mask) - 1;
H.f_Hz = NaN(options.fftlen, numel(h));
for n = 1:numel(h)
    H.f_Hz(:,n) = f(:) * h(n).fs;
end


%% Calculate frequency response. Note that x(n-N) <--> exp(-j*w*N)*X(w). To undo
%% the offset, we need to multiply H(w) by exp(j*w*N) where N = offset_to_zero.
H.H = NaN(options.fftlen, numel(h));
for n = 1:numel(h)
    if length(h(n).h) > options.fftlen
        error('FFT length too short.');
    end
    H.H(:,n) = fftshift(fft(h(n).h, options.fftlen));
    offset_to_zero = -min(h(n).idx);
    f = H.f_Hz(:,n) / h(n).fs;
    H.H(:,n) = H.H(:,n) .* exp(1i * 2 * pi * f * offset_to_zero);
end


%% Calculate group delay response.
H.Gd = NaN(options.fftlen, numel(h));
switch options.item
case 'mag'
    % Do nothing.
case {'mag_grpdelay', 'grpdelay'}
    for n = 1:numel(h)
        H.Gd(:,n) = grpdelay(h(n).h, 1, options.fftlen, 'whole');
        offset_to_zero = -min(h(n).idx);
        H.Gd(:,n) = fftshift(H.Gd(:,n)) - offset_to_zero;
    end
otherwise
    error('Invalid options.item.');
end


%% Plot response.
if nargout == 0
    freq_plot(H, options.item, options.xunit, options.linetype);
    return;
end


%% Assign output arguments and exit function.
varargout = {H};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: freq_plot - Plot Frequency Response.
%
%       Syntax: freq_plot(H, item, xunit, linetype);
% 
%  Description: Plot PSD.
%
%        Input: - H (struct)
%                   Frequency response stucture. See above for valid fields.
%
%               - item (char)
%                   Item to be plotted. See above for valid strings.
%
%               - xunit (char)
%                   Unit of the x-axis (i.e. frequency).
%
%               - linetype (1-D row/col cell array of strings)
%                   Line types.
%
%       Output: none.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function freq_plot(H, item, xunit, linetype)


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


%% Plot magnitude response.
linetype_idx = 1;
for k = 1:size(H.H,2)
    if strcmp(item, 'mag_grpdelay')
        subplot(211)
    end
    plot(H.f_Hz(:,k)*xscale, 20*log10(abs(H.H(:,k))), linetype{linetype_idx});
    linetype_idx = linetype_idx + 1;
    if linetype_idx > length(linetype)
        linetype_idx = 1;
    end
    hold on
end
hold off
xlabel(xlabelstr);
ylabel('Magnitude (dB)');
title(sprintf('Magnitude Response [%d FFT]', size(H.H,1)));
zoom on
grid on


%% Plot group delay response.
if strcmp(item, 'mag_grpdelay') || strcmp(item, 'grpdelay')
    linetype_idx = 1;
    for k = 1:size(H.H,2)
        if strcmp(item, 'mag_grpdelay')
            subplot(212)
        end
        plot(H.f_Hz(:,k)*xscale, H.Gd(:,k), linetype{linetype_idx});
        linetype_idx = linetype_idx + 1;
        if linetype_idx > length(linetype)
            linetype_idx = 1;
        end
        hold on
    end
    hold off
    xlabel(xlabelstr);
    ylabel('Delay (sample)');
    title(sprintf('Group Delay Response [%d FFT]', size(H.Gd,1)));
    zoom on
    grid on
end


%% Link axis handles.
if strcmp(item, 'mag_grpdelay')
    linkaxes([subplot(211), subplot(212)], 'x');
end


end
