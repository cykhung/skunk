function x = ckhsigreal(x)

%%
%       SYNTAX: y = ckhsigreal(x);
% 
%  DESCRIPTION: Take real part of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Take real part.
% ckhsigisvalid(x);
for n = 1:numel(x)
    x(n).s = real(x(n).s);
end


end
