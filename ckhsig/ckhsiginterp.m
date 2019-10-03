function x = ckhsiginterp(x, L)

%%
%       SYNTAX: y = ckhsiginterp(x, L);
% 
%  DESCRIPTION: Interpolate input signal structure. If one of the input 
%               variables is a N-D array while another input variable has only
%               one element, then the single-element input variable will be
%               automatically expanded to a N-D array filled with the same
%               element.
%
%               In the special case where x = empty signal structure, y.idx and
%               y.fs_Hz will still be modified by this function accordingly.
%
%               In the special case where L = 1, y = x.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structures. Either circularly continuous or segment
%                   signal. Streaming signal is not supported. Can be empty.
%
%               - L (N-D array of real double)
%                   Interpolation factors. Valid values are: 1 to 10. Must be
%                   integer.
%
%       OUTPUT: - y (N-D array of struct)
%                   Interpolated signal structures.


%% Check x.
ckhsigisvalid(x);


%% Check signal type.
type = ckhsiggettype(x);
if any(strcmp(type(:), 'streaming'))
    error('Input streaming signal is not supported');
end


%% Check L.
if any(L ~= fix(L))
    error('L is not an integer.');
end
if any(L < 1) || any(L > 10)
    error('L is out of range.');
end


%% Make sure that x and L have the same size.
desired_size = size(x);
if length(L) > 1
    desired_size = size(L);
end
if length(x) == 1
    x = repmat(x, desired_size);
end
if length(L) == 1
    L = repmat(L, desired_size);
end
if any(size(x) ~= size(L))
    error('size(x) ~= size(L)');
end


%% Interpolate one signal at a time.
for n = 1:numel(x)
    x(n) = interp_1(x(n), L(n));
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: y = interp_1(x, L);
% 
%  DESCRIPTION: Interpolate one signal structure.
%
%        INPUT: - x (struct)
%                   Signal structure. Can be empty.
%
%               - L (real double)
%                   Interpolation factor.
%
%       OUTPUT: - y (struct)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = interp_1(x, L)


%% Interpolate.
switch L
case 1
    % Do nothing.
case 2
    x = interp_1_special(x, 2);
case 3
    x = interp_1_special(x, 3);
case 4
    for n = 1:2
        x = interp_1_special(x, 2);
    end
case 5
    x = interp_1_special(x, 5);
case 6
    x = interp_1_special(x, 2);
    x = interp_1_special(x, 3);
case 7
    x = interp_1_special(x, 7);
case 8
    for n = 1:3
        x = interp_1_special(x, 2);
    end
case 9
    for n = 1:2
        x = interp_1_special(x, 3);
    end
case 10
    x = interp_1_special(x, 2);
    x = interp_1_special(x, 5);
otherwise
    error('Invalid L.');
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: y = interp_1_special(x, L);
% 
%  DESCRIPTION: Interpolate one signal structure with special interpolation
%               factor.
%
%        INPUT: - x (sig)
%                   Signal structure. Can be empty.
%
%               - L (real double)
%                   Interpolation factor. Valid values are: 2, 3, 5 and 7.
%
%       OUTPUT: - y (sig)
%                   Signal structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = interp_1_special(x, L)


%% Set x.idx.
x = ckhsigsetidx(x);


%% Insert zeros. This block of code can handle empty signal structure.
s          = zeros(1, length(x.s) * L);
s(1:L:end) = x.s;
idx(1)     = x.idx(1) * L;
idx(2)     = idx(1) + length(s) - 1;
x.idx      = [];
x.s        = s;
x.idx      = idx;
x.fs       = x.fs * L;


%% Apply lowpass filter. Force streaming signal to be segment signal.
switch L
case 2
    h = load('interp_fir_2.mat');
    h = h.h;
case 3
    h = load('interp_fir_3.mat');
    h = h.h;
case 5
    h = load('interp_fir_5.mat');
    h = h.h;
case 7
    h = load('interp_fir_7.mat');
    h = h.h;
otherwise
    error('Invalid L.');
end
dc_gain_dB = 20*log10(abs(sum(h)));
if abs(dc_gain_dB) > 0.1
    error('abs(dc_gain_dB) > 0.1.');
end
h1    = ckhfir;
h1.h  = h;
h1.fs = x.fs;
x     = ckhfirapply(h1, x);


%% Apply gain L.
x.s = x.s * L;


end



% %
% % Generate lowpass filter impulse responses and save them to files.
% % 
% if 0
%     
%     % L = 2.
%     h = remez(1000, [0 0.5/2 (0.5/2)+0.005 0.5]/0.5, [1 1 0 0], [1 80]);    
%     save('c:\khung\skunk\trunk\+ckh\@sig\private\interp_fir_2.mat', 'h');
%     
%     % L = 3.
%     h = remez(1000, [0 0.5/3 (0.5/3)+0.005 0.5]/0.5, [1 1 0 0], [1 80]);
%     save('c:\khung\skunk\trunk\+ckh\@sig\private\interp_fir_3.mat', 'h');
%     
%     % L = 5.
%     h = remez(2500, [0 0.5/5 (0.5/5)+0.002 0.5]/0.5, [1 1 0 0], [1 80]);
%     save('c:\khung\skunk\trunk\+ckh\@sig\private\interp_fir_5.mat', 'h');
%     
%     % L = 7.
%     h = remez(2500, [0 0.5/7 (0.5/7)+0.002 0.5]/0.5, [1 1 0 0], [1 80]);
%     save('c:\khung\skunk\trunk\+ckh\@sig\private\interp_fir_7.mat', 'h');
% 
% end



