function rmobj

%%
%       SYNTAX: rmobj;
% 
%  DESCRIPTION: Delete the last plot object in current axes.
%
%        INPUT: none.
%
%       OUTPUT: none.


%% Delete last plot object.
h = get(gca, 'Children');
delete(h(1));


end