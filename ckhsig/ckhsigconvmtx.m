function [A, midx, tidx] = ckhsigconvmtx(x, idx)

%%
%       SYNTAX: [A, midx, tidx] = ckhsigconvmtx(x, idx);
% 
%  DESCRIPTION: Return convolution matrix. A*h(:) = filter output samples where
%                   idx(1) = time index of the filter tap h(1)
%                   idx(2) = time index of the filter tap h(2)
%                   ...
%
%               In the special case where x.s = [], then A = [], midx = [] and
%               tidx = x.idx.
%
%               In the special case where x is not circularly continuous and
%               the span of the FIR filter is too long such that there is no
%               valid output sample, then A = [], midx = [] and tidx(1) = 
%               x.idx(1) and tidx(2) = tidx(1) - 1.
%
%               Array inputs for x and idx must have the same size, which is
%               also the size of output A. A single-element array input for
%               x and idx is expanded to a constant N-D array with the same
%               sizes as other inputs.
%
%        INPUT: - x (N-D array of struct)
%                   Input signal structure(s). Either circularly continuous or
%                   segment signal. Streaming signal is not supported.
%
%               - idx (1-D row/col array of real double or N-D cell array of 
%                      1-D row/col array of real double)
%                   Indexes of the impulse response of FIR filter(s). The
%                   elements in idx does not need to be in sorted order, i.e.
%                   the elements can be in ascending order, descending order
%                   or random. idx cannot be [].
%
%       OUTPUT: - A (N-D cell array of 2-D array of complex double)
%                   Convolution matrices.
%
%               - midx (N-D cell array of 2-D array of real double)
%                   Matlab indexes of the samples from x.s, i.e. A = x.s(midx).
%
%               - tidx (N-D cell array of 1-D row array of real double)
%                   Indexes of the first sample and the last sample in A*h(:).


%% Make sure that idx is a cell array.
if ~iscell(idx)
    idx = {idx};
end


%% Check x.
ckhsigisvalid(x);


%% Check signal type.
for n = 1:numel(x)
    switch x(n).type
    case {'circular', 'segment'}
        % Do nothing.
    case 'streaming'
        error('Input streaming signal is not supported');
    otherwise
        error('Invalid signal type.');
    end
end


%% Make sure that x and idx have the same size.
desired_size = size(x);
if length(idx) > 1
    desired_size = size(idx);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(idx) == 1
    idx = repmat(idx, desired_size);
end
if any(size(x) ~= size(idx))
    error('size(x) ~= size(idx)');
end


%% Check idx.
for n = 1:numel(idx)
    if isempty(idx{n})
        error('Idx is [].');
    end
end


%% Set x.idx.
x = ckhsigsetidx(x);


%% Obtain convolution matrix. 
A = cell(size(x));
midx = cell(size(x));
tidx = cell(size(x));
for n = 1:numel(x)
    
    % Special case: x.s = [].
    if isempty(x(n).s)
        A{n} = [];
        midx{n} = [];
        tidx{n} = x(n).idx;
        continue;
    end
    
    % Special case: x is not circularly continuous and the span of the FIR 
    %               filter is too long such that there is no valid output
    %               sample.
    idx_span = max(idx{n}) - min(idx{n}) + 1;
    if ~strcmp(x(n).type, 'circular') && (length(x(n).s) < idx_span)
        A{n} = [];
        midx{n} = [];
        tidx{n} = x(n).idx;
        tidx{n}(2) = tidx{n}(1) - 1;
        continue;
    end
    
    % Here we assume that the input signal is circularly continuous.
    type = x(n).type;
    x(n).type = 'circular';
    [A{n}, midx{n}] = convmtx_circular(x(n), idx{n});
    tidx{n} = x(n).idx;
    x(n).type = type;
    
    % In case the input signal is not circularly continuous, then we need to
    % truncate the top and bottom of A.
    if ~strcmp(x(n).type, 'circular')
        
        % Truncate the top.
        if all(idx{n} <= 0)
            % Do nothing.
        else
            N1 = max(idx{n});
            A{n}(1:N1, :) = [];
            midx{n}(1:N1, :) = [];
            tidx{n}(1) = tidx{n}(1) + N1;
        end
        
        % Truncate the bottom.
        if all(idx{n} >= 0)
            % Do nothing.
        else
            N2 = max(-idx{n});
            A{n}(end-N2+1:end, :) = [];
            midx{n}(end-N2+1:end, :) = [];
            tidx{n}(2) = tidx{n}(2) - N2;
        end
        
    end

end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: [A, midx] = convmtx_circular(x, idx);
% 
%  DESCRIPTION: Return convolution matrix. Note that in the special case where
%               x.s = [], then A = [] and midx = [].
%
%        INPUT: - x (struct)
%                   Input signal structure. Must be circularly continuous.
%
%               - idx (1-D row/col array of real double)
%                   Indexes of the impulse response of FIR filter. idx cannot be
%                   [].
%
%       OUTPUT: - A (2-D array of complex double)
%                   Convolution matrix.
%
%               - midx (2-D array of real double)
%                   Matlab indexes of the samples from x.s, i.e. A = x.s(midx).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, midx] = convmtx_circular(x, idx)


%% Check x.
if ~strcmp(x.type, 'circular')
    error('Input signal is not a circularly continuous signal.');
end
if isempty(x.s)
    error('Input signal cannot be empty.');
end


%% Form index matrix. index starts from 0 and does not wrap around.
idx_matrix = ones(length(x.s), length(idx));
idx_matrix(1,:) = -idx(:).';
idx_matrix = cumsum(idx_matrix);


%% Circularly wrap any out-of-range index.
k = find(idx_matrix < 0);        % k = index of out-of-range indexes.
if ~isempty(k)
   idx_matrix(k) = rem(idx_matrix(k), length(x.s)) + length(x.s);
end
k = find(idx_matrix > (length(x.s)-1));
if ~isempty(k)
   idx_matrix(k) = rem(idx_matrix(k), length(x.s));
end


%% Set midx.
midx = idx_matrix+1;


%% Form the circular convolution matrix.
if size(midx, 2) == 1 
    % Make sure that if midx is a column vector, then A is also a column vector.
    A = x.s(midx);
    A = A(:);
else
    A = x.s(midx);
end    


end
