function [x, h] = ckhsigbandpass(x, Ntaps, B)

%%
%       SYNTAX: [y, h] = ckhsigbandpass(x, Ntaps, B);
% 
%  DESCRIPTION: Apply bandpass filtering to input signal(s). The bandpass filter
%               is a Parks-McClellan optimal equiripple FIR filter. The bandpass
%               filter can have multiple bands.
%
%               We may have different FIR filters because the sampling rate of
%               each input signal can be different.
%
%               CAUTION: In order to avoid weird magnitude response in the
%                        transition band, make sure that the two transition
%                        bands have the same width in frequency.
%
%               Example: Single band bandpass filter.
%                   >> x = ckhsig(randn(1,1e5), 200);
%                   >> B = [0 10 0; 15 25 1; 30 100 0];
%                   >> [y, h] = ckhsigbandpass(x, 201, B); ckhfirfreq(h)
%
%               Example: Dual band bandpass filter.
%                   >> x = ckhsig(randn(1,1e5), 200);
%                   >> B = [0 10 0; 15 25 1; 30 35 0; 40 45 1; 50 100 0];
%                   >> [y, h] = ckhsigbandpass(x, 201, B); ckhfirfreq(h)
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Signal can be empty.
%
%               - Ntaps (real double)
%                   Number of FIR filter taps.
%
%               - B (2-D array of real double)
%                   Band matrix. Each row represents one band. Format is:
%                       column 1: band start frequency in Hz.
%                       column 2: band stop  frequency in Hz.
%                       column 3: Either 1 (passband) or 0 (stopband).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - h (N-D array of struct)
%                   FIR filter structure(s).


%% Calculate vector f.
f = B(:,1:2).';
f = f(:).';


%% Calculate vector a.
a = repmat(B(:,3)', 2, 1);
a = a(:).';


%% Calculate vector w.
w = B(:,3)';
if any(~ismember(w, [0 1]))
    error('Invalid values in B(:,3).');
end
w(w == 0) = 80;


%% Loop through each signal.
h = repmat(ckhfir, size(x));
for n = 1:numel(x)
    
    % Construct bandpass FIR filter structure.
    mode   = 1;
    idx    = [];
    h(n)   = ckhfir('remez', Ntaps, f, x(n).fs, a, w, mode, idx);

    % Apply FIR filtering.
    [x(n), h(n)] = ckhfirapply(h(n), x(n));
    
end


end

