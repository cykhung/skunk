function [D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx, D_offsets, D_coarse)

%%
%       SYNTAX: [D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx);
%               [D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx, D_offsets);
%               [D, h1, h2, dc, info] = ckhsiglieiq(x, y, h1_idx, h2_idx, D_offsets, D_coarse);
% 
%  DESCRIPTION: Perform linear impairment estimation for IQ imbalance. 
%
%               If one of the input variables is a N-D array while another
%               input variable has only one element, then the single-element
%               input variable will be automatically expanded to a N-D array
%               filled with the same element.
%
%               The objective is to minimize the MSE between y_hat and y where
%               y_hat is obtained as follows,
%
%      x --> Integer Delay --> FIR Filter -------> Add --> DC Offset --> y_hat
%                           |     (h1)              |
%                           |                       |
%                          --> Conj --> FIR Filter -->
%                                          (h2)
%
%               Both x.fs_Hz and y.fs_Hz must be identical.
%
%               Both x.idx and y.idx will be taken into account.
%
%               Here is the explanation of how Integer Delay is calculated:
%
%                       Candidate Integer Delays = D_coarse + D_offsets
%
%               Notes: (1) D_coarse = coarse integer delay. It is always a 
%                          scalar. If D_coarse is NaN or not speecified by user,
%                          then this function will estimate D_coarse based on
%                          correlation betweeen x and y.
%
%                      (2) D_offsets = vector of delay offsets. The purpose of
%                          D_offsets is to allow this function to perform a grid
%                          search over the Candidate Integer Delays to find the
%                          best integer delay (since integer delay estimation
%                          can be significanly affected by the distortion caused
%                          by the FIR filter and DC offset). The best delay will
%                          be returned in the output variable D.
%
%               Case 1: User wants this function to automatically calculate the
%                       D_coarse. User can use either first or second calling
%                       syntax. In case of the first calling syntax, D_offsets
%                       uses default value (see below).
%
%               Case 2: User wants this function to automatically calculate the
%                       D_coarse but does not want this function to do the grid
%                       search. User shall use the second calling syntax and set
%                       D_offsets = 0. In this case, the output variable D will
%                       be equal to D_coarse.
%
%               Case 3: User does not want this function to calculate the
%                       D_coarse and does not want this function to do the grid
%                       search. In other words, user wants to specify the output
%                       variable D (i.e. the final integer delay). User shall
%                       use the third syntax and set D_offsets = 0 and D_coarse
%                       = desired integer delay.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). Cannot be empty. Either circularly 
%                   continuous or segment signal. Streaming signal is not
%                   supported.
%
%               - y (N-D array of struct)
%                   Signal structure(s). Cannot be empty. Either circularly 
%                   continuous or segment signal. Streaming signal is not
%                   supported.
%
%               - h1_idx (1-D row/col array of real double or 
%                         N-D cell array of 1-D row/col of real double)
%                   Indexes of the FIR filter (h1) impulse response. Cannot be
%                   empty. Setting hidx can be challenging especially when we
%                   have no idea about the impairment (or the channel). In this
%                   case, we need to do some trial-and-error.
%                       Step 1: Set h1_idx = 0 (i.e. one tap). 
%                       Step 2: Run this function and look at info.esr_dB.
%                       Step 3: Set h1_idx = [-1 0 1] (i.e. 3 taps).
%                       Step 4: Run this function and look at info.esr_dB.
%                               Compare this with step 2. Is it better?
%                       Step 5: Try setting h1_idx = [-2 0 2] (i.e. 3 sparse
%                               taps).
%                       Note that if hidx is too long (i.e. we over-model the
%                       channel), then we may get a warning message from this
%                       function saying that there are multiple solutions.
%
%               - h2_idx (1-D row/col array of real double or 
%                         N-D cell array of 1-D row/col of real double)
%                   Indexes of the FIR filter (h2) impulse response. Cannot be
%                   empty. Similar argument as h1_idx.
%
%               - D_offsets (1-D row/col array of real double or 
%                           N-D cell array of 1-D row/col array of real double)
%                   Delay offsets. Optional. Default = [-5:1:5].
%
%               - D_coarse (real double or N-D array of real double)
%                   Coarse delay. Optional. Default = NaN. If D_coarse = NaN, 
%                   then this function will automatically calculate D_coarse.
%
%       OUTPUT: - D (N-D array of real double)
%                   Integer delay(s). D can be negative.
%
%               - h1 (N-D array of struct)
%                   FIR filter structure(s).
%
%               - h2 (N-D array of struct)
%                   FIR filter structure(s).
%
%               - dc (N-D array of real double)
%                   DC offset(s).
%
%               - info (struct)
%                   Miscellaneous information structure. Valid fields are:
%
%                   - info.e (N-D array of struct)
%                       Error signal structure(s). Definition: e = y - y_hat.
%
%                   - info.y_hat (N-D array of struct)
%                       Signal structure(s) storing y_hat.
%
%                   - info.cond_A (N-D array of real double)
%                       Condition number(s) of A in the joint estimation of FIR
%                       filter taps and DC offset.
%
%                   - info.mse (N-D array of real double)
%                       MSE between y and y_hat, i.e. mean(abs(e).^2).
%
%                   - info.mse_dB (N-D array of real double)
%                       MSE between y and y_hat in dB, i.e. 10*log10(mse).
%
%                   - info.esr (N-D array of real double)
%                       Error-to-signal ratio, i.e. mean(abs(e).^2) / 
%                       mean(abs(y).^2).
%
%                   - info.esr_dB (N-D array of real double)
%                       Error-to-signal ratio in dB, i.e. 10*log10(esr).


%% Check x and y.
ckhsigisvalid(x);
ckhsigisvalid(y);


%% Assign default value for D_offsets and D_coarse.
switch nargin
case 4
    D_offsets = [];
    D_coarse = NaN;
case 5
    D_coarse = NaN;
end


%% Check signal type.
for n = 1:numel(x)
    switch x(n).type
    case {'segment', 'circular'}
        % Do nothing.
    case 'streaming'
        error('Input streaming signal is not supported');
    otherwise
        error('Invalid signal type.');
    end
end
for n = 1:numel(y)
    switch y(n).type
    case {'segment', 'circular'}
        % Do nothing.
    case 'streaming'
        error('Input streaming signal is not supported');
    otherwise
        error('Invalid signal type.');
    end
end


%% Make sure that both h1_idx and h2_idx are cell arrays.
if ~iscell(h1_idx)
    h1_idx = {h1_idx};
end
if ~iscell(h2_idx)
    h2_idx = {h2_idx};
end


%% Make sure that D_offsets is a cell array. Set default value.
if ~iscell(D_offsets)
    D_offsets = {D_offsets};
end
for n = 1:numel(D_offsets)
    if isempty(D_offsets{n})
        D_offsets{n} = (-5:1:5);
    end
end


%% Make sure that x, y, h1_idx, h2_idx and D_offset have the same size.
desired_size = size(x);
if length(y) > 1
    desired_size = size(y);
elseif length(h1_idx) > 1
    desired_size = size(h1_idx);
elseif length(h2_idx) > 1
    desired_size = size(h2_idx);
elseif length(D_offsets) > 1
    desired_size = size(D_offsets);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(y) == 1
    y = repmat(y, desired_size);
end
if length(h1_idx) == 1
    h1_idx = repmat(h1_idx, desired_size);
end
if length(h2_idx) == 1
    h2_idx = repmat(h2_idx, desired_size);
end
if length(D_offsets) == 1
    D_offsets = repmat(D_offsets, desired_size);
end
if length(D_coarse) == 1
    D_coarse = repmat(D_coarse, desired_size);
end
if any(size(x) ~= size(y))
    error('size(x) ~= size(y)');
end
if any(size(x) ~= size(h1_idx))
    error('size(x) ~= size(h1_idx)');
end
if any(size(x) ~= size(h2_idx))
    error('size(x) ~= size(h2_idx)');
end
if any(size(x) ~= size(D_offsets))
    error('size(x) ~= size(D_offsets)');
end
if any(size(x) ~= size(D_coarse))
    error('size(x) ~= size(D_coarse)');
end


%% Perform estimation for one pair of signals at a time.
size_x      = size(x);
D           = NaN(size_x);
h1          = repmat(ckhfir, size_x);
h2          = repmat(ckhfir, size_x);
dc          = NaN(size_x);
info        = [];
info.e      = repmat(ckhsig, size_x);
info.y_hat  = repmat(ckhsig, size_x);
info.cond_A = NaN(size_x);
info.mse    = NaN(size_x);
info.mse_dB = NaN(size_x);
info.esr    = NaN(size_x);
info.esr_dB = NaN(size_x);
for n = 1:numel(x)
    [D(n), h1(n), h2(n), dc(n), info.e(n), info.y_hat(n), info.cond_A(n), ...
            info.mse(n), info.mse_dB(n), info.esr(n), info.esr_dB(n)] = ...
        lieiq_1(x(n), y(n), h1_idx{n}, h2_idx{n}, D_offsets{n}, D_coarse(n));
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: lieiq_1 - Perform Linear Impairment Estimation For IQ Imbalance
%                         For One Pair Of Signals.
%
%       SYNTAX: [...] = lieiq_1(x, y, h1_idx, h2_idx, D_offset);
% 
%  DESCRIPTION: Perform linear impairment estimation for IQ imbalance for one
%               pair of signals.
%
%        INPUT: - x (struct)
%                   Signal structure.
%
%               - y (struct)
%                   Signal structure.
%
%               - h1_idx (1-D row/col array of real double)
%                   Indexes of the FIR filter (h1) impulse response.
%
%               - h2_idx (1-D row/col array of real double)
%                   Indexes of the FIR filter (h2) impulse response.
%
%               - D_offset (1-D row/col array of real double)
%                   Delay offsets.
%
%               - D_coarse (real double)
%                   Coarse delay.
%
%       OUTPUT: TBD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [best_D, best_h1, best_h2, best_dc, best_e, best_y_hat, ...
        best_cond_A, best_mse, best_mse_dB, best_esr, best_esr_dB] = ...
        lieiq_1(x, y, h1_idx, h2_idx, D_offsets, D_coarse)


%% Check x, y and hidx.
if isempty(x.s)
    error('x.s is empty.');
end
if isempty(y.s)
    error('y.s is empty.');
end
if isempty(h1_idx)
    error('h1_idx is empty.');
end
if isempty(h2_idx)
    error('h2_idx is empty.');
end
if x.fs ~= y.fs
    error('Sampling rate mismatch.');
end
    

%%
% Perform coarse integer delay estimate (D_coarse). Since I worry that a hugh
% DC offset may cause error in coarse integer delay estimate and so a coarse 
% DC offset is removed from y1 to help getting a more reliable delay estimation.
%
if isnan(D_coarse)
    y1 = y;
    y1.s = y1.s - (mean(y1.s) - mean(x.s));
    correlation   = ckhsigcorr(y1, x);
    [~, D_coarse] = ckhsigmax(ckhsigabs(correlation));
    if isempty(correlation.s)
        correlation   = ckhsigcorr(x, y1);
        [~, D_coarse] = ckhsigmax(ckhsigabs(correlation));
        D_coarse      = -D_coarse;
    end
    if strcmp(x.type, 'circular') && (abs(D_coarse) > (length(x.s) / 2))
        if D_coarse > 0
            D_coarse = D_coarse - length(x.s);
        else
            D_coarse = D_coarse + length(x.s);
        end
    end
end


%%
% Repeat the estimation of the two FIR filters and DC offset for a range of
% integer delays. The main reason for the repeat is that I don't know how to
% get a perfect estimate of the integer delay under the influence of IQ
% imbalance and DC offset (but no noise). Also the estimation of the two FIR
% filters and DC offset is very sensitive to the integer delay. This is why
% need to repeat the estimation of the two FIR filters and DC offset for a 
% of integer delays.
%
% The number "5" is a magic number. The larger the number is, the more reliable
% is the estimate but it would take a longer time.
%
%best_esr = Inf;
N = length(D_offsets);
result        = [];
result.D      = NaN(1, N);
result.h1     = repmat(ckhfir, 1, N);
result.h2     = repmat(ckhfir, 1, N);
result.dc     = NaN(1, N);
result.e      = repmat(x, 1, N);
result.y_hat  = repmat(x, 1, N);
result.cond_A = NaN(1, N);
result.mse    = NaN(1, N);
result.mse_dB = NaN(1, N);
result.esr    = NaN(1, N);
result.esr_dB = NaN(1, N);
for iter = 1:length(D_offsets)

    % Set D.
    D = D_coarse + D_offsets(iter);

    % Apply integer delay to x.
    tmpfir = ckhfir(1, x.fs, D, 1);
    y_hat  = ckhfirapply(tmpfir, x);
    clear tmpfir

    % Time intersect y_hat and y.
    [y_hat_intersect, y_intersect] = ckhsigintersect([y_hat, y], 'list');
    if isempty(y_hat_intersect.s)
        continue;
    end
    
    % Form A1 matrix.
    [A1, ~, tidx1] = ckhsigconvmtx(y_hat_intersect, h1_idx);
    A1 = A1{1};
    if isempty(A1)
        continue;       % Not enough samples for the filter span.
    end
    tidx1 = tidx1{1};

    % Form A2 matrix.
    [A2, ~, tidx2] = ckhsigconvmtx(y_hat_intersect, h2_idx);
    A2 = conj(A2{1});
    if isempty(A2)
        continue;       % Not enough samples for the filter span.
    end
    tidx2 = tidx2{1};
    
    % Find common time indexes between A1 and A2 matrices.
    tidx_common = [];
    tidx_common(1) = max([tidx1(1), tidx2(1)]);
    tidx_common(2) = min([tidx1(2), tidx2(2)]);
    
    % Time intersect A1 matrix.
    n = tidx_common(1) - tidx1(1);
    A1(1:n,:) = [];
    n = tidx1(2) - tidx_common(2);
    A1(end-n+1:end,:) = [];
    
    % Time intersect A2 matrix.
    n = tidx_common(1) - tidx2(1);
    A2(1:n,:) = [];
    n = tidx2(2) - tidx_common(2);
    A2(end-n+1:end,:) = [];
    
    % Form matrix A.
    A = [A1, A2, ones(size(A1, 1), 1)];
    if size(A,1) <= size(A,2)
        continue;   % Make sure that the linear system is over-determined.
                    % Note that we do not allow exact linear system.    
    end
    if rank(A) < size(A,2)
        % This is a special case where A is rank-deficient. So far I have
        % encountered two cases when A is rank-deficient. 
        %       Case 1: h2 is actually zero and there is no IQ imbalance.
        %       Case 2: There is IQ imbalance but h1 and h2 are over-modelled.
        % Since I don't know how to detect which case is true and so I choose
        % to set h2 = 0 and print out a warning message. The reason of my
        % choice is that the code would be able to estimate correctly when 
        % the signal is actually free of IQ imbalance.
        A = [A1, ones(size(A1, 1), 1)];
        str = 'A is rank-deficient. Set h2 = 0.';
        warning('ckhsiglieiq:rank_deficient', str);
    end
    clear A1 A2    
    
    % Jointly estimate FIR filters (h1 and h2) and DC offset (dc).
    tmp = ckhsiggrep(y_intersect, tidx_common);
    b = tmp.s;
    if (size(A,2) == length(h1_idx)+1)
        est = A \ b(:);
        h1 = ckhfir(est(1:length(h1_idx)),    x.fs, h1_idx, 1);
        h2 = ckhfir(zeros(1, length(h2_idx)), x.fs, h2_idx, 1);
    elseif (size(A,2) == length(h1_idx)+length(h2_idx)+1)
        est = A \ b(:);
        h1 = ckhfir(est(1:length(h1_idx)), x.fs, h1_idx, 1);
        h2 = ckhfir(est(length(h1_idx)+1:length(h1_idx)+length(h2_idx)), ...
            x.fs, h2_idx, 1);
    else
        error('Wrong dimension for matrix A.');
    end
    dc = est(end);
    cond_A = cond(A);
    clear A b

    % Apply FIR filters and DC offset.
    [y1_hat, h1]     = ckhfirapply(h1, y_hat);
    [y2_hat, h2]     = ckhfirapply(h2, ckhsigconj(y_hat));
    [y1_hat, y2_hat] = ckhsigintersect([y1_hat, y2_hat], 'list');
    y_hat            = y1_hat;
    y_hat.s          = y1_hat.s + y2_hat.s + dc;
    clear y1_hat y2_hat

    % Time intersect y_hat and y.
    [y_hat_intersect, y_intersect] = ckhsigintersect([y_hat, y], 'list');

    % Calculate error signal, mse, mse_dB, esr and esr_dB.
    e   = y_hat_intersect;
    e.s = y_intersect.s - y_hat_intersect.s;    
    mse = mean(abs(e.s) .^ 2);
    if mse == 0
        mse_dB = -Inf;
    else
        mse_dB = 10*log10(mse);
    end
    esr = mse / mean(abs(y_intersect.s) .^ 2);
    if esr == 0
        esr_dB = -Inf;
    else
        esr_dB = 10*log10(esr);
    end
    
    % Save all results.
    result.D(iter)      = D;
    result.h1(iter)     = h1;
    result.h2(iter)     = h2;
    result.dc(iter)     = dc;
    result.e(iter)      = e;
    result.y_hat(iter)  = y_hat;
    result.cond_A(iter) = cond_A;
    result.mse(iter)    = mse;
    result.mse_dB(iter) = mse_dB;
    result.esr(iter)    = esr;
    result.esr_dB(iter) = esr_dB;
    
end


%% Crash if there is no solution.
if all(isnan(result.esr))
    error('Solution not found due to input signals being too short.');
end


%% Find the best solution. Note that it is possible to have NaN in result.esr
%% (and all other fields inside result) due to the CONTINUE inside the for loop.
[~, m]      = min(result.esr);
best_D      = result.D(m);
best_h1     = result.h1(m);
best_h2     = result.h2(m);
best_dc     = result.dc(m);
best_e      = result.e(m);
best_y_hat  = result.y_hat(m);
best_cond_A = result.cond_A(m);
best_mse    = result.mse(m);
best_mse_dB = result.mse_dB(m);
best_esr    = result.esr(m);
best_esr_dB = result.esr_dB(m);


%%
% It is possible to have two solutions having almost identical esr. 
%
% Print warning message if esr is within 1% (magic number) of best_esr or
% both esr and best_esr are small.
%
tmp_esr = result.esr;   % Find the next minimum esr.
[~, m] = min(tmp_esr);
tmp_esr(m) = Inf;
next_best_esr = min(tmp_esr);
if (abs(next_best_esr - best_esr) < (0.01 * best_esr)) || ...
        ((abs(next_best_esr) < 1e-10) && (abs(best_esr) < 1e-10))
    warning('ckhsiglieiq:multiple_solutions', ...
        'best_esr = %e. next_best_esr = %e.', ...
        best_esr, next_best_esr);
end


end

