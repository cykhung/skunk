function x = ckhsigimag(x)

%%
%       SYNTAX: y = ckhsigimag(x);
% 
%  DESCRIPTION: Take imaginary part of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Take imaginary part.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = imag(x(n).s);
end


end
