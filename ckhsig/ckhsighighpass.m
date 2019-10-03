function [x, h] = ckhsighighpass(x, Ntaps, fstop, fpass)

%%
%       SYNTAX: [y, h] = ckhsighighpass(x, Ntaps, fstop, fpass);
% 
%  DESCRIPTION: Apply highpass filtering to input signal(s). The highpass filter
%               is a Parks-McClellan optimal equiripple FIR filter.
%
%               We may have different FIR filters because the sampling rate of
%               each input signal can be different.
%
%               Example: x.fs_Hz = 2000.
%               >> [y, h] = ckhsighighpass(x, 101, 500, 600); ckhfirfreq(h)
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Signal can be empty.
%
%               - Ntaps (real double)
%                   Number of FIR filter taps.
%
%               - fstop (real double)
%                   Stopband frequency in Hz.
%
%               - fpass (real double)
%                   Passband frequency in Hz.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - h (N-D array of struct)
%                   FIR filter structure(s).


%% Loop through each signal.
h = repmat(ckhfir, size(x));
for n = 1:numel(x)
    
    % Construct highpass FIR filter structure.
    f    = [0, fstop, fpass, 0.5*x(n).fs];  % Unit = Hz.
    a    = [0 0 1 1];
    w    = [80 1];
    mode = 1;
    idx  = [];
    h(n) = ckhfir('remez', Ntaps, f, x(n).fs, a, w, mode, idx);

    % Apply FIR filtering.
    [x(n), h(n)] = ckhfirapply(h(n), x(n));
    
end


end

