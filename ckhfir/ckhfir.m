function h = ckhfir(varargin)

%%
%       SYNTAX: h = ckhfir;
%               h = ckhfir(h);
%               h = ckhfir(h, fs);
%               h = ckhfir(h, fs, idx);
%               h = ckhfir(h, fs, idx, mode);
%               h = ckhfir('lagrangefd', Ntaps, delay, mode, fs, idx);
%               h = ckhfir('remez', Ntaps, f, fs, a, w, mode, idx);
%
%  DESCRIPTION: Construct FIR filter structure.
%
%               h = ckhfir('lagrangefd', Ntaps, delay, mode, fs, idx);
%               constructs one Lagrange fractional delay FIR filter.
%
%               h = ckhfir('remez', Ntaps, f, fs, a, w, mode, idx);
%               constructs one remez FIR filter. Example:
%
%               >> h = ckhfir('remez', 51, [0 20 40 50], 100, [1 1 0 0], [1 80], 1, []);
%
%               h = ckhfir constructs a "default" FIR filter structure with the
%               following fields:
%                   h.mode = 1;
%                   h.h    = 1;
%                   h.fs   = 1;
%                   h.idx  = [];
%                   h.zi   = [];
%
%               h = ckhfir(h, fs) constructs a FIR filter structure with the
%               following fields:
%                   h.mode = 1;
%                   h.h    = h;
%                   h.fs   = fs;
%                   h.idx  = [];
%                   h.zi   = [];
%
%        INPUT: - h (1-D row/col array of complex double)
%                   Vector of FIR filter impulse response. Refer to h.h in the
%                   output argument.
%
%               - mode (real double)
%                   Operating mode. Refer to h.mode in the output argument.
%
%               - fs (real double)
%                   Sampling rate of the filter impulse response in Hz. Refer to
%                   h.fs in the output argument.
%
%               - idx (1-D row/col array of real double)
%                   Tap indices. Refer to h.idx in the output argument.
%
%               - Ntaps (real double)
%                   Number of taps.
%
%               - delay (real double)
%                   Fractional delay(s). Range is [-1 1].
%
%               - f (1-D row/col array of real double)
%                   Vector of pairs of frequency points. Unit = Hz. The
%                   frequencies must be in increasing order. Each frequency
%                   band is characterized by 2 frequency points. This vector
%                   must have even number of elements. The highest frequency
%                   point is 0.5 * fs. Optional. Default = 1.
%
%               - a (1-D row/col array of real double)
%                   Vector of desired amplitudes at the points specified in 
%                   f. Each vector must have even number of elements.
%                   length(f) = length(a).
%
%               - w (1-D row/col array of real double)
%                   Weight vector used to weight the fit in each frequency 
%                   band. The length of vector w is half the length of
%                   vector f and vector a, so there is exactly one weight
%                   per band.
%
%       OUTPUT: - h (struct)
%                   FIR filter structure. Valid fields are:
%
%                   - mode (real double)
%                       Operating mode. This field only affects ckhfirApply.m. 
%                       Valid values are:
%                           1 - Normal mode. Enable filtering.
%                           0 - Zero mode. Output = zeros(size(input)). h.zi
%                               will not modified. Not supported for input
%                               streaming signal.
%                           -1 - Bypass mode. Output = input. h.zi will not be
%                                modified. Not supported for input streaming
%                                signal.
%
%                   - h (1-D row array of complex double)
%                       Filter impulse response. The time index of each tap is
%                       specified in h.idx. Cannot be [].
%
%                   - fs (real double)
%                       Sampling rate of the filter impulse response in Hz. 
%                       h.fs > 0.
%
%                   - idx (1-D row array of real double)
%                       Tap indices. length(h.idx) = length(h.h). Indices can be
%                       positive, negative and zero. Set to [] for default
%                       value. Default = [1:length(h.h)] - ceil(length(h.h)/2).
%                       Note that in order to do zero-delay filtering, use the
%                       default index.
%
%                   - zi (struct)
%                       Initial condition for filtering streaming signal. During
%                       construction, this field will be initialized to []. If
%                       h.zi ~= [], then h.zi.type is always 'segment'. 


%% Create FIR filter structure.
switch nargin
case 0
    h      = [];
    h.mode = 1;
    h.h    = 1;
    h.fs   = 1;
    h.idx  = [];
case 1
    h      = [];
    h.mode = 1;
    h.h    = varargin{1};
    h.fs   = 1;
    h.idx  = [];
case 2
    h      = [];
    h.mode = 1;
    h.h    = varargin{1};
    h.fs   = varargin{2};
    h.idx  = [];
case 3
    h      = [];
    h.mode = 1;
    h.h    = varargin{1};
    h.fs   = varargin{2};
    h.idx  = varargin{3};
case 4
    h      = [];
    h.mode = varargin{4};
    h.h    = varargin{1};
    h.fs   = varargin{2};
    h.idx  = varargin{3};
case 6
    params       = [];
    params.Ntaps = varargin{2};
    params.delay = varargin{3};
    h            = [];
    h.h          = lagrangefd(params);
    h.h          = h.h(:).';
    h.mode       = varargin{4};
    h.fs         = varargin{5};
    h.idx        = varargin{6};
case 8
    Ntaps   = varargin{2};
    f       = varargin{3};
    fs      = varargin{4};
    a       = varargin{5};
    w       = varargin{6};
    mode    = varargin{7};
    idx     = varargin{8};
    h       = [];
    h.mode  = mode;
    f       = f(:).' / (0.5*fs);
    h.h     = remez(Ntaps - 1, f, a(:).', w(:).');
    h.fs = fs;
    h.idx   = idx;
otherwise
    error('Invalid number of input arguments.');
end
if ~isempty(h.h)
    h.h = h.h(:).';
end
if ~isempty(h.idx)
    h.idx = h.idx(:)';
end
h.zi = [];


%% Is h valid?
ckhfirisvalid(h);


end

