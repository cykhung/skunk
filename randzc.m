function X = randzc(varargin)

%%
%       SYNTAX: X = randzc(...);
%
%  DESCRIPTION: Generate complex-valued uniformly distributed random numbers
%               where the real part is in range (-1.0, 1.0) using RAND and the
%               imaginary part is in (-1.0, 1.0) using RAND.
%
%        INPUT: Refer to RAND for input arguments.
%
%       OUTPUT: - X (N-D array of complex double)
%                   Complex-valued uniformly distributed random numbers in range
%                   (-1.0, 1.0).

I = rand(varargin{:});
Q = rand(varargin{:});

I = (I - 0.5) * 2;
Q = (Q - 0.5) * 2;

X = complex(I, Q);

end
