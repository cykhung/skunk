function x = ckhsigconj(x)

%%
%       SYNTAX: y = ckhsigconj(x);
% 
%  DESCRIPTION: Take complex conjugate of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Take complex conjuate.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = conj(x(n).s);
end


end
