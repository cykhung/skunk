function x = ckhsigcorr(x, p)

%%
%       SYNTAX: y = ckhsigcorr(x, p);
% 
%  DESCRIPTION: Calculate correlation between x and p. For example, in a
%               Direct Sequence Spread Sprectrum reciever, x will be the  
%               received samples and p will be the local PN sequence.
%               
%               Both x.s and p.s must not be empty.
%
%               If one of the input variables is a N-D array while another
%               input variable has only one element, then the
%               single-element input variable will be automatically
%               expanded to a N-D array filled with the same element.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). x.s cannot be empty. Streaming signal
%                   is not supported.
%
%               - p (N-D array of struct)
%                   Signal structure(s). p.s cannot be empty. Streaming signal
%                   is not supported. Circular and segment signal are treated
%                   the same.
%
%       OUTPUT: - y (N-D array of struct)
%                   Output signal structure(s) containing the correlation.


%% Check x.
ckhsigisvalid(x);


%% Check p.
ckhsigisvalid(p);


%% Make sure that x and p have the same size.
desired_size = size(x);
if length(p) > 1
    desired_size = size(p);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(p) == 1
    p = repmat(p, desired_size);
end
if any(size(x) ~= size(p))
    error('size(x) ~= size(p)');
end


%% Perform correlation between one pair of signals at a time.
for n = 1:numel(x)
    x(n) = corr_1(x(n), p(n));
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: corr_1 - Perform Correlation Between One Pair Of Signals.
%
%       SYNTAX: y = corr_1(x, p);
% 
%  DESCRIPTION: Perform correlation between one pair of signals.
%
%        INPUT: - x (struct)
%                   Signal structure.
%
%               - p (struct)
%                   Signal structure.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = corr_1(x, p)


%% Make sure that x.s is not [].
if isempty(x.s)
    error('x.s = [].');
end


%% Make sure that x is not a streaming signal.
if strcmp(x.type, 'streaming')
    error('Streaming signal is not supported.');
end


%% Make sure that p.s is not [].
if isempty(p.s)
    error('p.s = [].');
end


%% Make sure that p is not a streaming signal.
if strcmp(p.type, 'streaming')
    error('Streaming signal is not supported.');
end


%% Make sure that x.fs == p.fs.
if x.fs ~= p.fs
    error('x.fs ~= p.fs.');
end


%% Set x.idx and p.idx.
x = ckhsigsetidx(x);
p = ckhsigsetidx(p);


%% Insert zeros at the beginning and end of x.s.
if strcmp(x.type, 'segment')
    N = length(p.s) - 1;
    idx = x.idx;
    x.idx = [];
    x.s = [zeros(1,N), x.s, zeros(1,N)];
    x.idx = [idx(1)-N, idx(2)+N];
end


%% Use p to construct a FIR filter object. Note that the impulse response = 
%% flip(conj(p.s)).
mode = 1;
h = ckhfir(conj(p.s), p.fs, -(p.idx(1):p.idx(2)), mode);


%% Use FIR filtering to get correlation.
y = ckhfirapply(h, x);


end




