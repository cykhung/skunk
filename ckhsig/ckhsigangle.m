function x = ckhsigangle(x, unit, unwrap_flag)

%%
%       SYNTAX: y = ckhsigangle(x, unit);
%               y = ckhsigangle(x, unit, unwrap_flag);
% 
%  DESCRIPTION: Find angle in rad or degree with optional unwrap.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%               - unit (string)
%                   Unit. Valid values are:
%                       'deg' - Degree.
%                       'rad' - Radian.
%
%               - unwrap_flag (string)
%                   Unwrap flag. Optional. Default = 'wrap'. Valid values are:
%                       'wrap' - Do not unwrap.
%                       'unwrap' - Perform unwrap.
%
%       OUTPUT: - y (N-D array of struct)
%                   Signal structure(s).


%% Set unwrap_flag.
if exist('unwrap_flag', 'var') == 0
    unwrap_flag = 'wrap';
end


%% Find angle.
for n = 1:numel(x)
    
    % Find angle in radian.
    x(n).s = angle(x(n).s);
    
    % Unwrap angle in radian.
    switch unwrap_flag
    case 'wrap'
        % Do nothing.
    case 'unwrap'
        x(n).s = unwrap(x(n).s);
    otherwise
        error('Invalid unwrap_flag.');
    end
    
    % Convert from radian to degree.
    switch unit
    case 'deg'
        x(n).s = (x(n).s / pi) * 180;
    case 'rad'
        % Do nothing.
    otherwise
        error('Invalid unit.');
    end
    
end


end

