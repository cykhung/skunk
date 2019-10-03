function x = ckhsigzeros(x)

%%
%       SYNTAX: y = ckhsigzeros(x);
% 
%  DESCRIPTION: Set all samples in all input signals to zeros.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Zero out all samples
for n = 1:numel(x)
    x(n).s = zeros(size(x(n).s));
end


end