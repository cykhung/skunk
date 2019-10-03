function R = ckhsigcorrmtx(x, M)

%%
%       SYNTAX: R = ckhsigcorrmtx(x, M);
% 
%  DESCRIPTION: Return correlation matrix.
%
%               In the special case where x.s = [], then R = [].
%
%               A single-element array input for x and M is expanded to a
%               constant N-D array with the same sizes as other inputs.
%
%        INPUT: - x (N-D array of struct)
%                   Input signal structure(s). Either circularly continuous or
%                   segment signal. Streaming signal is not supported.
%
%               - M (N-D array of real double)
%                   Size of the correlation matrix. 1 <= M <= length(x.s).
%
%       OUTPUT: - R (N-D cell array of 2-D array of complex double)
%                   Correlation matrices. A correlation matrix is both
%                   Hermitian and Toeplitz. Size is M-by-M.


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


%% Make sure that x and M have the same size.
desired_size = size(x);
if length(M) > 1
    desired_size = size(M);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(M) == 1
    M = repmat(M, desired_size);
end
if any(size(x) ~= size(M))
    error('size(x) ~= size(M)');
end


%% Set x.idx.
x = ckhsigsetidx(x);


%% Obtain correlation matrix.
R = cell(size(x));
for n = 1:numel(x)
    R{n} = corrmtx_1(x(n), M(n));
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: corrmtx_1 - Return One Correlation Matrix.
%
%       SYNTAX: R = corrmtx_1(x, M);
% 
%  DESCRIPTION: Return convolution matrix.
%
%        INPUT: - x (struct)
%                   Input signal object.
%
%               - M (real double)
%                   Matrix size.
%
%       OUTPUT: - R (2-D array of complex double)
%                   Correlation matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function R = corrmtx_1(x, M)


%% Special case: s = [].
if isempty(x.s)
    R = [];
    return;
end


%% Check M.
if M < 1
    error('M < 1.');
end
if M > length(x.s)
    error('M > length(x.s)');
end


%% Calculate correlation vector = [r(0), r(1), ..., r(M-1)].
r = zeros(1,M);
switch x.type
case 'circular'
    for m = 1:M
        if m == 1
            u = x.s(1:end);
        else
            u = [x.s(m:end), x.s(1:m-1)];
        end
        r(m) = (u * x.s') / length(x.s);
    end
case 'segment'
    for m = 1:M
        u = x.s(m:end);
        v = x.s(1:end-m+1);
        r(m) = (u * v') / length(u);
    end
otherwise
    error('Invalid type.');
end
    

%% Form correlation matrix.
R = toeplitz(r);


end


