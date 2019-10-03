function ckhsigcwt(x)

%%
%       SYNTAX: ckhsigcwt(x)
% 
%  DESCRIPTION: Plot Continuous Wavelet Transform (CWT).
%
%        INPUT: - x (struct)
%                   Single signal structure. x.s must not be [].
%
%       OUTPUT: none.


%% Only support single signal.
if numel(x) ~= 1
    error('Only support single signal.');
end


%% Only support segment signal.
if ~strcmp(x.type, 'segment')
    error('Only support segment signal.');
end


%% Only support non-empty signal.
if isempty(x.s)
    error('Only support non-empty signal.');
end


%% Plot CWT.
x = ckhsigsetidx(x);
if x.idx(1) ~= 0
    warning('ckhsigcwt:notStartAt0', 'CWT plot not honoring x.idx(1)');
end
cwt(x.s, x.fs);
% t = (x.idx(1) : x.idx(2)).' / x.fs;
% t = seconds(t);
% T = timetable(t, x.s(:));
% cwt(T);
colormap('jet')
colorbar


end




% function ckhsigcwt(x, wave, norm, magscale, minPwrDb, freqscale)
% 
% %%
% %       SYNTAX: ckhsigcwt(x, wave, norm, magscale, minPwrDb, freqscale)
% % 
% %  DESCRIPTION: Plot Continuous Wavelet Transform (CWT).
% %
% %        INPUT: - x (struct)
% %                   Signal structure. x.s must not be [].
% %
% %               - wave (char)
% %                   Wavelet. Valid strings are: 'morse', 'amor', or 'bump'.
% %
% %               - norm (string)
% %                   Normalization type. Valid types are:
% %                       'none' - No normalization.
% %                       'max'  - Normalize CWT magnitude by its maximum
% %                                value. 
% %
% %               - magscale (char)
% %                   Magnitude scale. Valid strings are:
% %                       'linear' - Plot CWT magnitude in linear scale.
% %                       'dB' - Plot CWT magnitude in dB scale.
% %
% %               - minPwrDb (real double)
% %                   Minimum power in dB. Only applicable if magscale = 'dB'.
% %
% %               - freqscale (char)
% %                   Frequency axis scale. Valid strings are:
% %                       'linear' - Plot frequency axis in linear scale.
% %                       'log' - Plot frequency axis in log scale.
% 
% 
% %% Only support segment signal.
% if ~strcmp(x.type, 'segment')
%     error('Only support segment signal.');
% end
% 
% 
% %% Set x.idx.
% x = ckhsigsetidx(x);
% 
% 
% %% Calculate CWT.
% [W, f, COI] = cwt(x.s, wave, x.fs, 'VoicesPerOctave', 48);
% W           = abs(W);
% 
% 
% %% Process COI.
% %
% % * Wayne's email on July 27, 2017:
% %
% %       Hi Kevin, yes that is correct. The COI is just meant to give the user a
% %       sense of where edge effects become a concern so essentially we could
% %       have set the first value and last values to Infinity, or simply the
% %       maximum value of the frequency axis. Likely in 18a, I will just change
% %       that value to the maximum frequency value, but in any event it doesn’t
% %       really matter. It’s just a visual affordance.
% %
% if any(COI < 0)
%     error('Does not handle negative frequency in COI.');
% end
% mask      = COI > (x.fs / 2);
% COI(mask) = x.fs / 2;
% 
% 
% %% Normalize W.
% switch norm
% case 'max'
%    W = W / max(W(:));
% case 'none'
%    % Do nothing.
% otherwise
%    error('Invalid norm.');
% end
% 
% 
% %% Plot W in linear scale or dB scale.
% switch magscale
% case 'linear'
%     % Do nothing.
% case 'dB'
%     W = 20*log10(W);
% otherwise
%     error('Invalid magscale.');
% end
% 
% 
% %% Saturate bottom values of W.
% switch magscale
% case 'linear'
%     % Do nothing.
% case 'dB'
%     W(W <= minPwrDb) = minPwrDb;
% otherwise
%     error('Invalid magscale.');
% end
% 
% 
% % %% Plot CWT. Does not work.
% % t  = (x.idx(1) : x.idx(2)) / x.fs;
% % AX = axes('parent', gcf);
% % surface('Parent',       AX,                 ...
% %         'XData',        [min(t) max(t)],    ...
% %         'YData',        [max(f) min(f)],    ...
% %         'CData',        W,                  ...
% %         'ZData',        zeros(2,2),         ...
% %         'CDataMapping', 'scaled',           ...
% %         'FaceColor',    'texturemap',       ...
% %         'EdgeColor',    'none');
% % AX.YLim   = [min(f),max(f)];
% % AX.XLim   = [min(t) max(t)];
% % AX.Layer  = 'top';
% % AX.YDir   = 'normal';
% % AX.YScale = freqscale;
% % colormap(jet);
% % colorbar
% % axis tight
% % hold on
% % plot(t, COI, 'w--', 'linewidth', 2)
% % hold off
% % xlabel('Time (s)');
% % ylabel('Frequency (Hz)');
% % title(sprintf('Magnitude Scalogram [%s]', wave));
% 
% 
% %% Plot CWT.
% t = (x.idx(1) : x.idx(2)) / x.fs;
% surface(t, f, W)
% set(gca, 'yscale', freqscale)
% % view(0,90)
% shading interp
% colormap(jet);
% colorbar
% axis tight
% hold on
% plot3(t, COI, ones(size(t))*max(W(:)), 'w--', 'linewidth', 2)
% hold off
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
% title(sprintf('Magnitude Scalogram [%s]', wave));
% 
% 
% end
% 
