function x = ckhsighilbert(x)

%%
%       SYNTAX: y = ckhsighilbert(x);
% 
%  DESCRIPTION: Perform Hilbert Transform.
%
%               If the input signal x is centered at some high enough carrier
%               frequency such that the positive spectrum does not overlap with
%               the negative spectrum (keep in mind that x must be a real-valued
%               signal), then hilbert(x) will be a complex-valued signal
%               containing only the positive spectrum.
%
%               For example, if x = cos(2*pi*f*n), then hilbert(x) = exp(j*2*f*n).
%
%               Watch out for the transients at the beginning and at the end
%               of the signal.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Samples must be real-valued. Input 
%                   signal must not be streaming signal.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Make sure that x is real.
if any(~ckhsigisreal(x(:)))
    error('Samples must be real-valued.');
end


%% Perform Hilbert Transform.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = hilbert(x(n).s);
end


end

