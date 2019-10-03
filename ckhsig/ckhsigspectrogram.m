function ckhsigspectrogram(x, Nfft, win, norm, magscale, minPwrDb)

%%
%       SYNTAX: ckhsigspectrogram(x, Nfft, win, norm, magscale, minPwrDb)
% 
%  DESCRIPTION: Plot spectrogram.
%
%        INPUT: - x (struct)
%                   Signal structure. x.s must not be [].
%
%               - Nfft (real double)
%                   FFT length. 
%
%               - win (1-D row/col array of real double)
%                   Window.
%
%               - norm (string)
%                   Normalization type. Valid types are:
%                       'none' - No normalization.
%                       'max'  - Normalize spectrogram magnitude by its maximum
%                                value. 
%
%               - magscale (char)
%                   Magnitude scale. Valid strings are:
%                       'linear' - Plot spectrogram magnitude in linear scale.
%                       'dB' - Plot spectrogram magnitude in dB scale.
%
%               - minPwrDb (real double)
%                   Minimum power in dB. Only applicable if magscale = 'dB'.


%% Only support segment signal.
if ~strcmp(x.type, 'segment')
    error('Only support segment signal.');
end


%% Set x.idx.
x = ckhsigsetidx(x);


%% Calculate spectrogram.
% X1 = oldcode(x, win, Nfft);
N = length(x.s) - length(win) + 1;
X = (1:length(win))' + (0 : (N-1)); % Implicit expansion. X = matrix of indexes.
X = x.s(X);        % Now X = matrix of sample values. Each column is one signal.
X = X .* win(:);   % Implicit expansion. Windowing.
X = fft(X, Nfft);
% if max(abs(X(:) - X1(:))) > 0
%     error('Error')
% end
X = abs(X);
X = fftshift(X,1);
X = flipud(X);
n = x.idx(1) + (0 : (N-1));
% n = n + (Nfft/2);                    % Fudge factor ???????
n = n + (length(win)/2);            % Fudge factor ???????
t = n  / x.fs;  
f = fftf(Nfft, x.fs)';
f = flipud(f);


%% Normalize X.
switch norm
case 'max'
   X = X / max(X(:));
case 'none'
   % Do nothing.
otherwise
   error('Invalid norm.');
end


%% Plot X in linear scale or dB scale.
switch magscale
case 'linear'
    % Do nothing.
case 'dB'
    X = 20*log10(X);
otherwise
    error('Invalid magscale.');
end


%% Saturate bottom values of X.
switch magscale
case 'linear'
    % Do nothing.
case 'dB'
    X(X <= minPwrDb) = minPwrDb;
otherwise
    error('Invalid magscale.');
end


% %% Plot spectrogram.
% surface(t, f, X)
% % set(gca, 'yscale', 'log')
% shading interp
% colormap(jet);
% colorbar
% axis tight
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
% title(sprintf('Spectrogram [%d WIN. Fs = %g Hz.]', length(win), x.fs_Hz));


%% Plot spectrogram.
imagesc(t, f, X);
axis xy
colormap(jet);
colorbar
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram');
grid off


end


function X = oldcode(x, win, Nfft)

N = length(x.s) - length(win) + 1;
m = 1:length(win);
X = zeros(Nfft, N);
if Nfft < length(win)
    error('Nfft < length(win)');
end
for n = 1:N
    X(:,n) = fft(x.s(m).' .* win(:), Nfft);
    m = m + 1;
end

end



