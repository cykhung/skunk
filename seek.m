function varargout = seek(varargin)

%%
%       SYNTAX: T = seek;
%
%               seek var1 var2 ...
%               seek(var1, var2, ...);
%               seek(vars);
%
%               s = seek(var1, var2, ...);
%               s = seek(vars);
%
%  DESCRIPTION: T = seek returns a table that lists all saved variables.
%
%               "seek var1 var2" retreives variables and writes them back into
%               caller workspace (with the same variable names). Existing
%               variables (in the caller workspace) will be over-written.
%
%               s = seek(var1, var2) returns variables in an output structure.
%
%        INPUT: - var1, var2 (char)
%                   Variable names.
%
%               - vars (N-D cell array of char)
%                   N-D cell array of character vectors. Each cell element
%                   contains one variable name.
%
%       OUTPUT: - T (table)
%                   Table containing the WHOS of all saved variables.
%
%               - s (struct)
%                   Structure containing saved data.
%
%     SEE ALSO: HIDE, FORGET


%% Special case: list.
if nargin == 0
    varargout = {brain('list')};
    return;
end


%% Assign input arguments.
if (nargin == 1) && iscell(varargin{1})
    varnames = varargin{1};
else
    varnames = varargin;
end


%% Read from brain.
s = brain('read', varnames);


%% Assign output arguments.
if nargout == 0
    for n = 1:numel(varnames)
        varname = varnames{n};
        assignin('caller', varname, s.(varname));
    end
else
    varargout = {s};
end


end

