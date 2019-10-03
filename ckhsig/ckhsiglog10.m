function x = ckhsiglog10(x)

%%
%       SYNTAX: y = ckhsiglog10(x);
% 
%  DESCRIPTION: Take log10 of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Take log10.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = log10(x(n).s);
end


end