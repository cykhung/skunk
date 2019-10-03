function ckhsigpolar(varargin)

%%
%       SYNTAX: ckhsigpolar(x);
%               ckhsigpolar(x, linetype);
% 
%  DESCRIPTION: Polar plot of signal samples.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s). x.s must not be empty.
%
%               - linetype (char or 1-D row/col cell array of char)
%                   Line types. Optional. Set to '' or {} for default values.
%                   Default = {'ro', 'bx', 'k+', 'g^', 'c*', 'mv', 'yd', ...}.
%                   If number of line types < numel(x), then line types will be
%                   reused.
%
%       OUTPUT: none.


%% Assign input arguments.
options = [];
switch nargin
case 1
    x                = varargin{1};
case 2
    x                = varargin{1};
    options.linetype = varargin{2};
otherwise
    error('Invalid number of input arguments.');
end


%% Check x.
ckhsigisvalid(x);


%% Check for empty signal.
if any(ckhsigisempty(x(:)))
    error('x.s = [].');
end


%% Assign default values to options.
if ~isfield(options, 'linetype') || isempty(options.linetype)
    options.linetype = {'ro', 'bx', 'k+', 'g^', 'c*', 'mv', 'yd'};
end


%% Convert linetype from string to cell array of strings.
if ~iscell(options.linetype)
    options.linetype = {options.linetype};
end


%% Do actual plotting.
linetype_idx = 1;
for n = 1:numel(x)
    
    % Plot.
    polarplot(angle(x(n).s), abs(x(n).s), options.linetype{linetype_idx});
    hold on
    
    % Increment linetype index.
    linetype_idx = linetype_idx + 1;
    if linetype_idx > length(options.linetype)
        linetype_idx = 1;
    end
    
end
hold off
title('Polar Plot');


%% Turn on grid, zoom and pan. Must do these after legend.
zoom on
grid on
pan xon
% zoom xon


end


