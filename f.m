function f(fig)

if nargin == 0
    figure
else
    if ischar(fig)
        fig = str2double(fig);
    end
    figure(fig)
end
% clf(figure(9001), 'reset');
clf(gcf, 'reset');
drawnow
% pause(0.1)
commandwindow

end
