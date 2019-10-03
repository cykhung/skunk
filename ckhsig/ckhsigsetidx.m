function x = ckhsigsetidx(x)

%%
%       SYNTAX: y = ckhsigsetidx(x);
%
%  DESCRIPTION: Set x.idx.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Set x.idx.
for n = 1:numel(x)
    if isempty(x(n).idx)
        x(n).idx = [0, length(x(n).s) - 1];
    end
end


end