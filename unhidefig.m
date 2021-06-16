function unhidefig(varargin)

%%
%       SYNTAX: unhidefig
%               unhidefig 1 2 3
%               unhidefig 1:3 5 10
%               unhidefig(1, 2, 3)
%               unhidefig([1:3 5], 10)
%               unhidefig all
%
%  DESCRIPTION: Un-hide figures.
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


%% Un-hide figures.
for n = 1:numel(figs)
    set(figure(figs(n)), 'HandleVisibility', 'on')
end


%% Set focus back to command window.
commandwindow


end

