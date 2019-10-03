function x = ckhsigbit2symbol(x)

%%
%       SYNTAX: y = ckhsigbit2symbol(x);
% 
%  DESCRIPTION: Map bits to symbols, i.e.
%                   map bit 0 to -1
%                   map bit 1 to +1
%
%        INPUT: - x ((N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y ((N-D array of struct)
%                   Signal structure(s).


%% Map bits to symbols.
for n = 1:numel(x)
    if any(~ismember(x(n).s, [0 1]))
        error('Input must be either 1 or 0.');
    end    
    x(n).s(x(n).s == 0) = -1;
end


end