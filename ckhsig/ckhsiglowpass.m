function [x, h] = ckhsiglowpass(x, Ntaps, fpass, fstop)

%%
%       SYNTAX: [y, h] = ckhsiglowpass(x, Ntaps, fpass, fstop);
% 
%  DESCRIPTION: Apply lowpass filtering to input signal(s). The lowpass filter
%               is a Parks-McClellan optimal equiripple FIR filter.
%
%               We may have different FIR filters because the sampling rate of
%               each input signal can be different.
%
%               Example: x.fs_Hz = 2000.
%               >> [y, h] = ckhsiglowpass(x, 101, 500, 600); ckhfirfreq(h)
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Signal can be empty.
%
%               - Ntaps (real double)
%                   Number of FIR filter taps.
%
%               - fpass (real double)
%                   Passband frequency in Hz.
%
%               - fstop (real double)
%                   Stopband frequency in Hz.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - h (N-D array of struct)
%                   FIR filter structure(s).


%% Loop through each signal.
h = repmat(ckhfir, size(x));
for n = 1:numel(x)
    
    % Construct lowpass FIR filter structure.
    f_Hz = [0, fpass, fstop, 0.5*x(n).fs];
    a    = [1 1 0 0];
    w    = [1 80];
    mode = 1;
    idx  = [];
    h(n) = ckhfir('remez', Ntaps, f_Hz, x(n).fs, a, w, mode, idx);

    % Apply FIR filtering.
    [x(n), h(n)] = ckhfirapply(h(n), x(n));
    
end


end

