function h = ckhfirfull(h)

%%
%       SYNTAX: h = ckhfirfull(h);
% 
%  DESCRIPTION: Return full impulse response of FIR filter structure. "Full" 
%               implies that there is no gap in the filter impulse response.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%       OUTPUT: - h (N-D array of struct)
%                   FIR filter structure(s). h.idx is always in ascending order.


%% Check h.
ckhfirisvalid(h);


%% Set h.idx.
h = ckhfirsetidx(h);


%% Obtain the full impulse response of each input FIR filter object.
for n = 1:numel(h)
    
    % Calculate filter tap of the full impulse response.
    idx_shifted           = h(n).idx - min(h(n).idx);
    h_full                = zeros(1, max(idx_shifted));
    h_full(idx_shifted+1) = h(n).h;

    % Calculate index of the full impulse response.
    idx_full = (min(h(n).idx) : max(h(n).idx));

    % Set obj.h and obj.idx.
    h(n).idx = [];
    h(n).h   = h_full;
    h(n).idx = idx_full;
    
end


end


