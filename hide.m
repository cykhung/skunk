function hide(varargin)

%%
%       SYNTAX: hide var1 var2 ...
%               hide(var1, var2, ...);
%               hide(vars);
%
%  DESCRIPTION: Hide variables (in caller workspace) into a persistent variable
%               (inside brain.m).
%
%               Existing saved variables will be over-written.
%
%        INPUT: - var1, var2 (char)
%                   Variable names.
%
%               - vars (N-D cell array of char)
%                   N-D cell array of character vectors. Each cell element
%                   contains one variable name.
%
%       OUTPUT: none.
%
%     SEE ALSO: FORGET, SEEK


%% Assign input arguments.
if (nargin == 1) && iscell(varargin{1})
    varnames = varargin{1};
else
    varnames = varargin;
end


%% Create structure "in".
in = struct;
for n = 1:numel(varnames)
    varname      = varnames{n};
    in.(varname) = evalin('caller', varname);
end


%% Write to brain.
brain('write', in);


end

