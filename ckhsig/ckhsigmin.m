function [min_s, tidx] = ckhsigmin(x)

%%
%       SYNTAX: [min_s, tidx] = ckhsigmin(x);
% 
%  DESCRIPTION: Return minimum sample. In case x.s is complex, then abs(x.s) is
%               used in searching for the minimum sample.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - min_s (N-D array of real double)
%                   Minimum sample value for each input signal object. Same
%                   size as x. If x.s = [], then NaN wil be returned.
%
%               - tidx (N-D array of real double)
%                   Time index of minimum sample. This index has taken x.idx(1)
%                   into account. If there is more than one minimum sample, then
%                   only the index of the first minimum sample will be returned.
%                   We choose not to return time indexes of all minimum samples
%                   for speed reason (calling find() can be slow). In the future,
%                   we may expand this function to return all time indexes. If
%                   x.s = [], then NaN wil be returned. Same size as x.


%% Check x.
ckhsigisvalid(x);


%% Set x.idx.
x = ckhsigsetidx(x);


%% Find minimum sample.
min_s = zeros(size(x));
tidx = zeros(size(x));
for n = 1:numel(x)
    if ~isempty(x(n).s)
    
        % Minimum sample value.
        if ~isreal(x(n).s)
            [min_s(n), midx] = min(abs(x(n).s));
            min_s(n) = x(n).s(midx);
        else
            [min_s(n), midx] = min(x(n).s);
        end
        
        % Time index.
        tidx(n) = x(n).idx(1) + midx - 1;
    
    else
        min_s(n) = NaN;
        tidx(n) = NaN;        
    end
end


end




