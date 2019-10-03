function w = ckhfirconv(h)

%%
%       SYNTAX: w = ckhfirconv(h);
% 
%  DESCRIPTION: Perform convolution of several FIR filter structures.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%       OUTPUT: - w (struct)
%                   FIR filter structure.


%% Check h.
ckhfirisvalid(h);


%% Special case: numel(h) = 1.
if numel(h) == 1
    w = h;
    return;
end


%% Make sure that all input FIR filter structures have the same sampling rate.
fs = NaN(1, numel(h));
for n = 1:numel(h)
    fs(n) = h(n).fs;
end
fs(isnan(fs)) = [];
% Use fs(1) as reference.
if ~isempty(fs) && (max(abs(fs - fs(1))) > 0)
    error('Sampling rate mismatch between different FIR filter structures.');
end


%% Get full impulse response of each input FIR filter structure.
h = ckhfirfull(h);


%% Initialize output structure, w.
w = h(1);


%% Convolve filters to get the full impulse response of the final filter.
w.idx = [];
for n = 2:numel(h)
    w.h = conv(w.h, h(n).h);
end


%% Get idx of the full impulse response of the final filter.
offset_to_zero = NaN(1, numel(h));
for n = 1:numel(h)
    offset_to_zero(n) = -min(h(n).idx);
end
N = length(w.h);
w.idx = (0:N-1) - sum(offset_to_zero);


end

