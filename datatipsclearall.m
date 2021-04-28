function datatipsclearall(figs)

%%
%       SYNTAX: datatipsclearall;
%               datatipsclearall(figs);
%
%  DESCRIPTION: Clear all datatips in all subplots in a figure.
%
%               datatipsclearall() clears all datatips in all subplots in
%               current figure.
%
%        INPUT: - figs (N-D array of figure or N-D array of real double)
%                   Figure object(s) or figure number(s).
%
%       OUTPUT: none.


%% Find all figure windows.
if nargin == 0
    figs = gcf;
end


%% Clear all datatips.
for n = 1:numel(figs)
    dcmobj = datacursormode(figs(n));
    dcmobj.removeAllDataCursors;
end


% Interactively create data tips by clicking on data points in a chart. To
% assign interactively created data tips to a variable, use the findobj
% function.
% 
% dt = findobj(chart,'Type','datatip'); 
%
% To delete data tips, use the delete function.
% 
% delete(dt);


end

