function [h, status] = lagrangefd(params)

%%
%       SYNTAX: [h, status] = lagrangefd(params);
%
%  DESCRIPTION: Generate a bank of Lagrange fractional delay filter impulse 
%               responses. The impulse response is given as [1],
%
%                             N-1     D - k
%                    h(n) = product ----------  for n = 0, 1, 2, ... N-1
%                            k = 0    n - k
%                            k ~= n
%
%                    where D = total delay = integer delay + fractional delay.
%
%        INPUT: - params (struct)
%                   Parameter structure. Valid fields are:
%
%                   - Ntaps (real int)
%                       Number of filter taps (or length of the impulse
%                       response). All generated filters have the same number of
%                       taps.
%
%                   - delay (real float row/col vector or real float)
%                       Either fractional delay or total delay.
%                    
%                       If params.delay_type = 'fractional', then each element
%                       will be treated as fractional delay and the total delay
%                       D is,
%                               Ntaps = odd  => D = (Ntaps-1)/2 + delay
%                               Ntaps = even => D = (Ntaps/2) - 1 + delay
%
%                       In this case, each element must be in the range [-1. 1]
%                       otherwise an error message will be generated. Also a
%                       combination of the Lagrange fractional delay filter
%                       followed by an integer delay of -(Ntaps-1)/2 (for odd
%                       Ntaps) or -(Ntaps/2)+1 (for even Ntaps) would provide
%                       a pure fractional delay (i.e. the integer part is 0).
%                       Strictly speaking, the frequency response of the
%                       Lagrange fractional delay filter degrades when
%                       abs(delay) > 0.5 (for odd Ntaps) or delay < 0 (for even
%                       Ntaps). However, if Ntaps is reasonably large (eg. Ntaps
%                       = 51) and the input signal has relatively small 
%                       bandwidth, then the above equation works well. Refer to
%                       equation 2.1 on pp. 35 of [1] for the best relationship
%                       between D and Ntaps. 
%
%                       If params.delay_type = 'total', then each element in
%                       in this vector will be treated as total delay.
%
%                       This field can also be a scalar or vector. If this
%                       field is a scalar, then only one filter will be
%                       returned. If this field is a vector, then a bank of
%                       Lagrange fractional delay filters with different total
%                       delays will be returned. Number of filters = number of
%                       elements in this vector.
%
%                   - implementation_method (string)
%                       Implementation method. This field is only useful for 
%                       testing purpose. Default value is used if this field is
%                       not defined or equal to an empty matrix. Valid strings
%                       are:
%                           'vectorized' - Use vectorized code. Default.
%                           'loop' - Use for-loop implementation.
%
%                   - delay_type (string)
%                       Delay type. Default value is used if this field is not
%                       defined or equal to an empty matrix. Valid types are:
%                           'fractional' - Each element in p is treated as
%                                          fractional delay. Default.
%                           'total' - Each element in p is treated as total
%                                     delay.
%
%       OUTPUT: - h (real float vector or real float matrix)
%                   Lagrange fractional delay filter impulse responses. If
%                   params.delay is a scalar, then h will be a column vector, 
%                   i.e.
%
%                                h = [h(0), h(1), ... h(Ntaps-1)]'
%
%                   If params.delay is a vector, then h will be a matrix, i.e.
%
%                                h = [ h1(0)        h2(0)          ...
%                                      h1(1)        h2(1)          ...
%                                       ...          ...
%                                      h1(Ntaps-1)  h2(Ntaps-1)    ... ]
%
%                       where h1 = fractional delay filter corresponds to 
%                                  params.delay(1).
%                             h2 = fractional delay filter corresponds to 
%                                  params.delay(2).
%                             etc.
%
%               - status (struct)
%                   Status structure. Valid fields are:
%
%                   - D (real float row/col vector or real float)
%                      Total delay of each Lagrange fractional delay filter.
%                      Same dimension as params.delay.
%
%         NOTE: - The vectorized code can use a lot of memory depending on the
%                 filter length (Ntaps) and the number of filters being 
%                 generated. There are 4 large 3D arrays plus a few relatively
%                 small intermediate variables. The total memory usage of the
%                 4 3D arrays is [4 * (Ntaps-1) * Ntaps * Nfilters] * 8 bytes.
%
%    REFERENCE: [1] "Splitting the Unit Delay", IEEE Signal Processing Magazine,
%                   January, 1999. pp. 30-60.
%
%    $Revision: 7258 $
%
%        $Date: 2014-11-03 19:22:39 -0500 (Mon, 03 Nov 2014) $
%
%      $Author: khung $


%% Initialize undefined parameters.
if ~isfield(params, 'implementation_method') || ...
        isempty(params.implementation_method)
    params.implementation_method = 'vectorized';
end
if ~isfield(params, 'delay_type') || isempty(params.delay_type)
    params.delay_type = 'fractional';
end


%% Check Ntaps.
if params.Ntaps <= 0
    error('Number of filter taps must be greater than 0.');
end


%% Convert params.delay to total delay D.
switch params.delay_type
case 'fractional'
    if any(abs(params.delay) > 1)
        error('Fractional delay cannot be greater than 1.');
    end
    if mod(params.Ntaps,2) == 0
        D = params.Ntaps/2 - 1 + params.delay;
    else
        D = (params.Ntaps-1)/2 + params.delay;
    end
case 'total'
    D = params.delay;
end


%% Generate filter taps.
switch params.implementation_method
case 'vectorized'
    h = lagrangefd_vector(params.Ntaps, D(:));
case 'loop'
    h = lagrangefd_loop(params.Ntaps, D(:));
otherwise
    error('Invalid implementation method.');
end


%% Status.
status.D = D;


%% Exit function.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    FUNCTION: lagrangefd_vector - Generate filter impulse responses using 
%                                  vectorized code.
%
%      SYNTAX: h = lagrangefd_vector(N, D);
% 
% DESCRIPTION: Generate filter impulse responses using vectorized code.
%
%       INPUT: - Ntaps (real int)
%                    Number of filter taps.
%
%              - D (real float vector or real float)
%                    Fractional delay. 
%
%      OUTPUT: - h (real float vector or real float matrix)
%                    Lagrange fractional delay filter impulse responses.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = lagrangefd_vector(Ntaps, D)


%% Find number of filters.
Nfilters = length(D);


%% Form the 3D array k_3d_array. Each page is for one filter. Each column 
%% (within one page) is one value of n.
%
% For example , if N = 5 and Nfilters = 2, then
%
%        k (page 1) = [ 1     0     0     0     0
%                       2     2     1     1     1
%                       3     3     3     2     2
%                       4     4     4     4     3 ]
%
%        k (page 2) = [ 1     0     0     0     0
%                       2     2     1     1     1
%                       3     3     3     2     2
%                       4     4     4     4     3 ]
%
A = repmat((0:Ntaps-1)', 1, Ntaps);
% Use linear indexing to get rid of the diagonal elements.
linear_idx_of_diag_element = (1:Ntaps) + (0:Ntaps:(Ntaps-1)*Ntaps);
A(linear_idx_of_diag_element) = [];    % After this line, A is a column vector.
k_matrix = reshape(A, Ntaps-1, Ntaps);
k_3d_array = repmat(k_matrix, [1, 1, Nfilters]);


%% Form the 3D array D_3d_array. Each page is for one filter.
%
% For example , if N = 5 and Nfilters = 2, then
%
%        D (page 1) = [ D1    D1    D1    D1    D1
%                       D1    D1    D1    D1    D1
%                       D1    D1    D1    D1    D1
%                       D1    D1    D1    D1    D1 ]
%
%        D (page 2) = [ D2    D2    D2    D2    D2
%                       D2    D2    D2    D2    D2
%                       D2    D2    D2    D2    D2
%                       D2    D2    D2    D2    D2 ]
%
%D = (Ntaps-1)/2 + p;     % column vector.
A = permute(D, [3 2 1]);
D_3d_array = repmat(A, Ntaps-1, Ntaps);


%% Form the 3D array n_3d_array. Each page is for one filter.
%
% For example , if N = 5 and Nfilters = 2, then
%
%        n (page 1) = [ 0    1    2    3    4
%                       0    1    2    3    4
%                       0    1    2    3    4
%                       0    1    2    3    4 ]
%
%        n (page 2) = [ 0    1    2    3    4
%                       0    1    2    3    4
%                       0    1    2    3    4
%                       0    1    2    3    4 ]
%
A = repmat((0:Ntaps-1), Ntaps-1, 1);
n_3d_array = repmat(A, [1 1 Nfilters]);


%% Find filter taps.
A = (D_3d_array - k_3d_array) ./ (n_3d_array - k_3d_array);
B = prod(A, 1);
h = permute(B, [2 3 1]);


%% Exit function.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    FUNCTION: lagrangefd_loop - Generate filter impulse responses using loops.
%
%      SYNTAX: h = lagrangefd_loop(N, D);
% 
% DESCRIPTION: Generate filter impulse responses using loops.
%
%       INPUT: - Ntaps (real int)
%                    Number of filter taps.
%
%              - D (real float vector or real float)
%                    Fractional delay. 
%
%      OUTPUT: - h (real float vector or real float matrix)
%                    Lagrange fractional delay filter impulse responses.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = lagrangefd_loop(Ntaps, D)


%% Generate filter taps.
h = NaN( Ntaps, length(D));
for m = 1:length(D)
    %D = (Ntaps-1)/2 + p(m);
    one_filter = ones(1, Ntaps, 1);
    for n = 0:Ntaps-1
        for k = 0:Ntaps-1
            if k ~= n
                one_filter(n+1) = one_filter(n+1) * (D(m) - k) / (n - k);
            end
        end
    end
    h(:,m) = one_filter;
end


%% Exit function.
end




