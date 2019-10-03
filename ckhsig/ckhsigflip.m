function x = ckhsigflip(x)

%%
%       SYNTAX: y = ckhsigflip(x);
% 
%  DESCRIPTION: Flip signal left-right around n = 0.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Set x.idx.
x = ckhsigsetidx(x);


%% Flip signal.
% ckhsigisvalid(x);
for n = 1:numel(x)
    
    % Flip s.
    x(n).s = fliplr(x(n).s);
    
    % Flip idx.
    x(n).idx = [-x(n).idx(2), -x(n).idx(1)];
    
end


end