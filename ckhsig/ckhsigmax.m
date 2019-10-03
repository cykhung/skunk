function [max_s, tidx] = ckhsigmax(x)

%%
%       SYNTAX: [max_s, tidx] = ckhsigmax(x);
% 
%  DESCRIPTION: Return maximum sample. In case x.s is complex, then abs(x.s) is
%               used in searching for the maximum sample.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - max_s (N-D array of real double)
%                   Maximum sample value for each input signal object. Same
%                   size as x. If x.s = [], then NaN wil be returned.
%
%               - tidx (N-D array of real double)
%                   Time index of maximum sample. This index has taken x.idx(1)
%                   into account. If there is more than one maximum sample, then
%                   only the index of the first maximum sample will be returned.
%                   We choose not to return time indexes of all maximum samples
%                   for speed reason (calling find() can be slow). In the future,
%                   we may expand this function to return all time indexes. If
%                   x.s = [], then NaN wil be returned. Same size as x.


%% Check x.
ckhsigisvalid(x);


%% Set x.idx.
x = ckhsigsetidx(x);


%% Find maximum sample.
max_s = zeros(size(x));
tidx = zeros(size(x));
for n = 1:numel(x)
    if ~isempty(x(n).s)
    
        % Maximum sample value.
        if ~isreal(x(n).s)
            [max_s(n), midx] = max(abs(x(n).s));
            max_s(n) = x(n).s(midx);
        else
            [max_s(n), midx] = max(x(n).s);
        end
        
        % Time index.
        tidx(n) = x(n).idx(1) + midx - 1;
            
    else
        max_s(n) = NaN;
        tidx(n) = NaN;        
    end
end


end



