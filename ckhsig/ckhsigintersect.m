function varargout = ckhsigintersect(x, type)

%%
%       SYNTAX: [y, midx] = ckhsigintersect(x);
%               [y1, y2, ..., yN, midx] = ckhsigintersect(x, type);
% 
%  DESCRIPTION: Get time interection of all input signal structures.
%
%        INPUT: - x (N-D array of struct)
%                   Input signal structure(s). All input signls must have 
%                   identical sampling rates. Either circularly continuous or
%                   segment signal. Streaming signal is not supported.
%
%               - type (string)
%                   Type of varargout. Optional. Default = 'array'. Valid types
%                   are:
%                       'array' - All output signal structures are returned in
%                                 one array. In this case, varargout = {y, info}
%                                 where y is a N-D array of signal structures
%                                 having the same size as x. Typical calling
%                                 syntaxes are:
%                                   [y, midx] = ckhsigintersect(x, 'array');
%                                   y = ckhsigintersect(x, 'array');
%                       'list' - Output signal structures are returned in a 
%                                comma separated list, i.e. varargout = 
%                                {y1, y2, ..., yN, status} where y1, y2, 
%                                ..., yN is one signal object. Typical
%                                calling syntaxes are:
%                                   [y1, y2, midx] = ckhsigintersect(x, 'list');
%                                   [y1, y2] = ckhsigintersect(x, 'list');
%
%       OUTPUT: - y (N-D array of struct)
%                   Output signal structure(s). Same size as x.
%
%               - y1, y2, ..., yN (sig)
%                   Single output signal structure(s). 
%
%               - midx (N-D cell array of 1-D row array of real double)
%                 Vector of matlab indexes of x.s for obtaining y.s. Under
%                 all circumstances, y(n).s = x(n).s(midx{n}).


%% Check x.
ckhsigisvalid(x);


%% Assign default value for type.
if nargin == 1
    type = 'array';
end


%% Make sure that all input signals have identical sampling rates.
fs = ckhsiggetfs(x);
if length(unique(fs(:))) ~= 1
    error('Input signals do not have identical sampling rates.');
end


%% Check signal type.
types = ckhsiggettype(x);
if any(strcmp(types(:), 'streaming'))
    error('Input streaming signal is not supported');
end


%% Set x.idx.
x = ckhsigsetidx(x);


%%
% Based on segment signal only, find start and stop indexes of the intersection.
% We try to get the smallest intersection. 
%
% All possible values of intersect_idx:
%   (1) If there is no segment signal, then intersect_idx = [-Inf, Inf].
%   (2) If there is one segment signal and it is empty, then intersect_idx(2) =
%       intersect_idx(1) - 1.
%   (3) If there is more than one segment signal but they don't overlap, then
%       intersect_idx(2) <= (intersect_idx(1) - 1). 
%   (4) If there is more than one segment signal but they overlap, then
%       intersect_idx(2) >= intersect_idx(1). 
%
intersect_idx = [-Inf, Inf];
for n = 1:numel(x)
    if strcmp(x(n).type, 'segment')
        if isempty(x(n).s)
            intersect_idx = x(n).idx;
            break;
        else
            intersect_idx(1) = max(intersect_idx(1), x(n).idx(1));
            intersect_idx(2) = min(intersect_idx(2), x(n).idx(2));
        end
    end
end


%% Based on circularly continuous signals only.
if all(isinf(intersect_idx))
    
    % There is no segment signal. Find biggest intersection among all circularly
    % continuous signals.
    intersect_idx = [Inf, -Inf];
    for n = 1:numel(x)
        if strcmp(x(n).type, 'circular')
            if isempty(x(n).s)
                intersect_idx = x(n).idx;
                break;
            else
                intersect_idx(1) = min(intersect_idx(1), x(n).idx(1));
                intersect_idx(2) = max(intersect_idx(2), x(n).idx(2));
            end
        end
    end
    
elseif intersect_idx(2) <= (intersect_idx(1) - 1)
    
    % There is segment signal but they don't overlap. No need to go through the
    % circularly continuous signals.
    
else
    
    % There is segment signal and they overlap. The intersection of all segment
    % signals determine the intersection of all signals (including the
    % circularly continuous signals). No need to go through the circularly
    % continuous signals.

end


%% Handle the special case when there is no intersection. Note that grep will
%% handle the case when intersect_idx(2) = intersect_idx(1) - 1.
if intersect_idx(2) < intersect_idx(1) - 1
    intersect_idx(2) = intersect_idx(1) - 1;
end


%% Grep signal samples based on interection index.
[x, info] = ckhsiggrep(x, intersect_idx);


%% Assign output arguments and exit function.
switch type
case 'array'
    varargout = {x, info};
case 'list'
    for n = 1:numel(x)
        varargout{n} = x(n);
    end
    varargout{end+1} = info;
otherwise
    error('Invalid type.');
end


end


