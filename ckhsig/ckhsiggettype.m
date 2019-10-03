function type = ckhsiggettype(x)

%%
%       SYNTAX: type = ckhsiggettype(x);
%
%  DESCRIPTION: Get x.type.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - type (N-D cell array of string)
%                   N-D cell array of types.

type = reshape({x(:).type}, size(x));

end
