function x = ckhsigfir(x, h, idx)

%%
%       SYNTAX: y = ckhsigfir(x, h);
%               y = ckhsigfir(x, h, idx);
% 
%  DESCRIPTION: Apply FIR filter to input signal(s).
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). All input signals must have the same
%                   sampling rate.
%
%               - h (1-D row/col array of complex double)
%                   Vector of FIR filter impulse response. Refer to h.h in the
%                   output argument.
%
%               - idx (1-D row array of real double)
%                   Tap indices. length(h) = length(idx). Indices can be
%                   positive, negative and zero. Optional. Set to [] for default
%                   value. Default = [1:length(h.h)] - ceil(length(h.h)/2).
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Set idx.
if nargin == 2
    idx = [];
end


%% Apply FIR filtering.
if length(unique([x(:).fs])) ~= 1
    error('All input signals must have the same sampling rate.');
end
h = ckhfir(h, x(1).fs, idx, 1);
x = ckhfirapply(h, x);


end