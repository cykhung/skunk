function [x, actual_fc] = ckhsigdqm(x, fc, circ_lo)

%%
%       SYNTAX: [y, actual_fc] = ckhsigdqm(x, fc);
%               [y, actual_fc] = ckhsigdqm(x, fc, circ_lo);
% 
%  DESCRIPTION: Perform digital quadrature modulation. For the details of fc and
%               circ_lo, refer to sig.fshift().
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Streaming signal is not supported.
%
%               - fc (N-D array of real double)
%                   Normalized center frequencies. 1 implies sampling rate.
%
%               - circ_lo (N-D array of real double)
%                   Circular LO flag. Refer to sig.fshift().
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).
%
%               - actual_fc (N-D array of real double)
%                   Actual normalized center frequency being used. Set to fc
%                   when input signal object is empty.


%% Check x.
ckhsigisvalid(x);


%% Set circ_lo if not specified by user.
if nargin == 2
    circ_lo = NaN;
end


%% Perform frequency shift.
[x, actual_fc] = ckhsigfshift(x, fc, circ_lo);


%% Take real part.
x = ckhsigreal(x);


end


