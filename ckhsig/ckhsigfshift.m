function [x, actual_fc] = ckhsigfshift(x, fc, circ_lo)

%%
%       SYNTAX: [y, actual_fc] = ckhsigfshift(x, fc);
%               [y, actual_fc] = ckhsigfshift(x, fc, circ_lo);
% 
%  DESCRIPTION: Frequency shift input signal. If one of the input variables is a
%               N-D array while another input variable has only one element,
%               then the single-element input variable will be automatically
%               expanded to a N-D array filled with the same element. Streaming
%               signal is not supported.
%
%               [y, actual_fc] = ckhsigfshift(x, fc) frequency-shifts signal to
%               fc. The value for circ_lo is set to NaN.
%
%               [y, actual_fc] = ckhsigfshift(x, fc, circ_lo) frequency-shifts 
%               signal to fc and allows user to set circ_lo.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%               - fc (N-D array of real double)
%                   Normalized center frequencies. 1 implies sampling rate.
%
%               - circ_lo (N-D array of real double)
%                   Circular LO flag. Optional. If this variable is not defined
%                   or equal to NaN, then default value of 0 will be used. This
%                   flag is only effective if input signal is circularly
%                   continuous. Valid values are:
%                       1 - Automatically choose a new fc (closest to the input
%                           fc) to force the LO to be circularly continuous.
%                       0 - Do nothing. Do not adjust fc.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - actual_fc (N-D array of real double)
%                   Actual normalized center frequency being used. Set to fc
%                   when input signal object is empty.
%
%    $Revision: 10317 $
%
%        $Date: 2017-01-22 20:43:02 -0500 (Sun, 22 Jan 2017) $
%
%      $Author: khung $


%% Check x.
ckhsigisvalid(x);


%% Set circ_lo if not defined by user.
if nargin == 2
    circ_lo = NaN;
end


%% Crash if x is a streaming signal.
for n = 1:numel(x)
    switch x(n).type
    case {'segment', 'circular'}
        % Do nothing.
    case 'streaming'
        error('Streaming signal is not supported.');
    otherwise
        error('Invalid input signal type.');
    end
end    


%% Put in default value of circ_lo.
circ_lo(isnan(circ_lo)) = 0;


%% Check circ_lo.
if ~isempty(find((circ_lo ~= 0) & (circ_lo ~= 1), 1))
    error('Invalid circ_lo.');
end


%% Make sure that obj, fc, and circ_lo have the same size.
desired_size = size(x);
if length(fc) > 1
    desired_size = size(fc);
elseif length(circ_lo) > 1
    desired_size = size(circ_lo);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(fc) == 1
    fc = repmat(fc, desired_size);
end
if length(circ_lo) == 1
    circ_lo = repmat(circ_lo, desired_size);
end
if any(size(x) ~= size(fc))
    error('size(x) ~= size(fc)');
end
if any(size(x) ~= size(circ_lo))
    error('size(x) ~= size(circ_lo)');
end
if any(size(fc) ~= size(circ_lo))
    error('size(fc) ~= size(circ_lo)');
end


%% Frequency shift one signal at a time.
actual_fc = NaN(size(x));
for n = 1:numel(x)
    [x(n), actual_fc(n)] = fshift_1(x(n), fc(n), circ_lo(n));
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: fshift_1 - Frequency Shift One Signal Object.
%
%       SYNTAX: [y, fc] = fshift_1(x, fc, circ_lo);
% 
%  DESCRIPTION: Frequency shift one signal object.
%
%        INPUT: - x (struct)
%                   Signal structure.
%
%               - fc (real double)
%                   Normalized center frequency.
%
%               - circ_lo (real double)
%                   Circular LO flag.

%       OUTPUT: - y (struct)
%                   Signal structure.
%
%               - fc (real double)
%                   Actual normalized center frequency being used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, fc] = fshift_1(x, fc, circ_lo)


%% Special case: x is an empty signal structure.
if isempty(x.s)
    return;
end


%% Adjust fc to force LO to be circularly continuous.
if strcmp(x.type, 'circular') && circ_lo
    N = length(x.s);
    k = fc * N;
    if abs(round(k) - k) > eps(k)
        orig_fc = fc;
        fc = round(k) / N;
        warning('ckhsigfshift:new_fc', ...
            ['fc is changed from %f to %f to force LO to be ', ...
            'circularly continuous.'], ...
            orig_fc, fc);
    end
end


%% Check fc.
if abs(fc) > 1
    error('abs(fc) > 1.');
end


%% Shift in frequency.
tmp = ckhsigsetidx(x);
n = tmp.idx(1) : tmp.idx(2);
x.s = x.s .* exp(1i * (2 * pi * fc * n));


%% Check circular continuity of the LO if obj = circularly continuous signal.
%% Specify type of output obj accordingly.
if strcmp(x.type, 'circular')
    k = fc * length(x.s);
    if abs(round(k) - k) > eps(k)
        x.type = 'segment';
        str = ['LO is not circularly continuous. ', ...
                'Output signal type is set to ''segment''.'];
        warning('ckhsigfshift:LO', str);
    end
end


end




