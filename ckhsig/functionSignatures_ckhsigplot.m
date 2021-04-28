function y = functionSignatures_ckhsigplot(inputs)

% inputs = 1-D cell array
%
% inputs{1} = first input argument
% inputs{2} = second input argument
%           ...


% %% Debug
% global X N Y
% X = [X, {inputs}];
% N = N + 1;


%% Convert strings to chars.
inputs = convertContainedStringsToChars(inputs);


%% Handle the case of zero input argument.
if (numel(inputs) == 1) && isempty(inputs{1})
    y        = string;
    y(end+1) = "x, {'r', 'b'}, 's')";
    % Y{N} = y;   % Debug
    return;
end


% %% Handle the case of specifying xunit.
% if (numel(inputs) == 3)
%     y = {'idx', 's', 'ms', 'us', 'ns'};
%     % Y{N} = y;   % Debug
%     return;
% end


% %% Handle the case of specifying norm.
% if (numel(inputs) == 4) && ismember(inputs{4}, {'Hz', 'kHz', 'MHz', 'GHz'})
%     y = {'none', 'sum_psd', 'max'};
%     % Y{N} = y;   % Debug
%     return;
% end


% %% Debug.
% Y{N} = y;


end


