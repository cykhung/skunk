function mvobj(src, dst)

%%
%       SYNTAX: mvobj(src, dst);
%               mvobj src dst
%
%  DESCRIPTION: Move figure. 
%
%        INPUT: - src (real double or char)
%                   Source figure number.
%
%               - dst (real double or char)
%                   Destination figure number.
%
%       OUTPUT: none.


%% Parse input arguments.
if ischar(src)
    src = str2double(src);
end
if ischar(dst)
    dst = str2double(dst);
end


% %% Check src and dst.
% if numel(src) ~= numel(dst)
%     error('numel(src) ~= numel(dst)')
% end


%% Do the move.
for n = 1:numel(src)
        
    % Clear dstination figure.
    figure(dst(n))
    clf reset
    
    % Move children(s) (except legend) from source figure to destination figure.
    f    = figure(src(n));
    mask = true(1, numel(f.Children));
    for k = 1:numel(f.Children)
        switch class(f.Children(k))
        case 'matlab.graphics.illustration.Legend'
            mask(k) = 0;
        end
    end
    set(f.Children(mask), 'Parent', figure(dst(n)));
   
    % Copy dcmobj.
    srcdcm           = datacursormode(figure(src(n)));
    dstdcm           = datacursormode(figure(dst(n)));
    dstdcm.UpdateFcn = srcdcm.UpdateFcn;
    dstdcm.Enable    = srcdcm.Enable;
    
end


%% Bring focus back to command window.
commandwindow


end

