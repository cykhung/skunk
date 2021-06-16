function hidefig(varargin)

%%
%       SYNTAX: hidefig
%               hidefig 1 2 3
%               hidefig 1:3 5 10
%               hidefig(1, 2, 3)
%               hidefig([1:3 5], 10)
%               hidefig all
%
%  DESCRIPTION: Hide figures.
%
%        INPUT: TBD.
%
%       OUTPUT: none.


%% Get figure numbers.
if nargin == 0
    figs = get(gcf, 'Number');
else
    figs = [];
    for n = 1:nargin
        if ischar(varargin{n})
            if strcmp(varargin{n}, 'all')
                h = findall(groot, 'Type', 'figure');
                y = [h.Number];
            else
                y = eval(varargin{n});
            end
        else
            y = varargin{n};
        end
        figs = [figs, y(:).']; %#ok<AGROW>
    end
end


%% Hide figures.
for n = 1:numel(figs)
    set(figure(figs(n)), 'HandleVisibility', 'off')
end


%% Set focus back to command window.
commandwindow


end

