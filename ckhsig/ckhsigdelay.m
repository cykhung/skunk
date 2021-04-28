function x = ckhsigdelay(x, D, Ntaps)

%%
%       SYNTAX: y = ckhsigdelay(x, D);
%               y = ckhsigdelay(x, D, Ntaps);
% 
%  DESCRIPTION: Delay input signal(s).
%
%               If one of the input variables is a N-D array while another input
%               variable has only one element, then the single-element input
%               variable will be automatically expanded to a N-D array filled
%               with the same element.
%
%        INPUT: - x (N-D array of struct)
%                   Input signal structure(s).
%
%               - D (N-D array of real double)
%                   Delay. Can be integer or fractional. Can be positve, zero or
%                   negative. For example, D = 2, 3.45, -4.5 and 0.
%
%               - Ntaps (N-D array of real double)
%                   Number of taps of the Lagrange fractional delay filter.
%                   Optional. Default value = 101. Use NaN for default value.
%
%       OUTPUT: - y (N-D array of struct)
%                   Delayed signal structure(s).


%% Check x.
ckhsigisvalid(x);


%% Assign defualt value for Ntaps.
if nargin == 2
    Ntaps = 101;
end


%% Substitute default value for Ntaps.
Ntaps(isnan(Ntaps)) = 101;


%% Make sure that x, D and Ntaps have the same size.
desired_size = size(x);
if numel(D) > 1
    desired_size = size(D);
elseif numel(Ntaps) > 1
    desired_size = size(Ntaps);
end
if numel(x) == 1
    x = repmat(x, desired_size);
end
if numel(D) == 1
    D = repmat(D, desired_size);
end
if numel(Ntaps) == 1
    Ntaps = repmat(Ntaps, desired_size);
end
if any(size(x) ~= size(D))
    error('size(x) ~= size(D)');
end
if any(size(x) ~= size(Ntaps))
    error('size(x) ~= size(Ntaps)');
end
if any(size(D) ~= size(Ntaps))
    error('size(D) ~= size(Ntaps)');
end


%% Delay one signal at a time.
for n = 1:numel(x)
    x(n) = delay_1(x(n), D(n), Ntaps(n));
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: delay_1 - Delay One Signal Structure.
%
%       SYNTAX: y = delay_1(x, D, Ntaps);
% 
%  DESCRIPTION: Delay one signal structure.
%
%        INPUT: - x (struct)
%                   Signal structure.
%
%               - D (real double)
%                   Delay.
%
%               - Ntaps (real double)
%                   Number of taps.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = delay_1(x, D, Ntaps)


%% Construct delay FIR filter.
D_fractional = D - fix(D);
if D_fractional == 0
    if strcmp(x.type, 'circular')
        % Special case: Integer delay and circular signal.
        x.s = circshift(x.s, [0, D]);
        return;     % Early exit.
    end
    h = ckhfir(1, x.fs, D, 1);
else
    % % Lagrange.
    % h         = ckhfir('lagrangefd', Ntaps, D_fractional, 1, x.fs, []);
    % h         = ckhfirsetidx(h);
    % D_integer = D - D_fractional;
    % h.idx     = h.idx + D_integer;
    
    % designFracDelayFIR
    if D_fractional < 0
        D_fractional = D_fractional + 1;
    end
    [h, i0]   = designFracDelayFIR(D_fractional, Ntaps);
    h         = ckhfir(h, x.fs, 0:(length(h)-1), 1);
    D_integer = D - D_fractional;
    h.idx     = h.idx - i0 + D_integer;
end


%% Filter input signal.
x = ckhfirapply(h, x);


end


