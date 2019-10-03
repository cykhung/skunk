function x = ckhsigabs(x)

%%
%       SYNTAX: y = ckhsigabs(x);
% 
%  DESCRIPTION: Take absolute value of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Take abs.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = abs(x(n).s);
end


end