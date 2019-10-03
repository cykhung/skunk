function ckhsigisvalid(x)

%%
%       SYNTAX: ckhsigisvalid(x);
%
%  DESCRIPTION: Check if signal structure is valid. If it is not valid, then 
%               this function will crash and generate an error message.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: none.


%% Check x.type.
if any(~ismember({x(:).type}, {'streaming', 'circular', 'segment'}))
    error('Invalid type.');
end


%% Check x.fs.
for n = 1:numel(x)
    if isempty(x(n).fs) || (x(n).fs <= 0)
        error('Invalid fs.');
    end
end


%% Check x.s and x.idx.
for n = 1:numel(x)
    if ~isempty(x(n).idx)
        if length(x(n).s) ~= (x(n).idx(2) - x(n).idx(1) + 1)
            error('Invalid idx.');
        end
    end
end


end

