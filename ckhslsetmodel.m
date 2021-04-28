function ckhslsetmodel(varargin)

%%
%       SYNTAX: ckhslsetmodel(model);
%               ckhslsetmodel(model, addSignalName);
%               ckhslsetmodel(model, addSignalName, logAllTopSignals);
%
%  DESCRIPTION: Set several model parameters of an open model.
%
%        INPUT: - model (string)
%                   Model name.
%
%               - addSignalName (real double or logical)
%                   Add signal name to all signals in the model top-level.
%                   Default = 1. Valid values are:
%                       0 - Don't add signal names (top-level only).
%                       1 - Add signal names (top-level only).
%
%               - logAllTopSignals (real double or logical)
%                   Turn on data logging for all signals in the model top-level.
%                   Default = 1. Valid values are:
%                       0 - Turn off logging (top-level only).
%                       1 - Turn on logging (top-level only).
%
%       OUTPUT: none.


%% Assign input arguments.
addSignalName    = 1;           % Use default value.
logAllTopSignals = 1;           % Use default value.
switch nargin
case 1
    model = varargin{1};
case 2
    model         = varargin{1};
    addSignalName = varargin{2};
case 3
    model            = varargin{1};
    addSignalName    = varargin{2};
    logAllTopSignals = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end


%% Turn on "Save to workspace Time:".
set_param(model, 'SaveTime', 'on');


%% Set "Save to workspace Format:".
set_param(model, 'SaveFormat', 'Dataset'); 


%% Turn off "Save to workspace Limit data points to last:".
set_param(model, 'LimitDataPoints', 'off');


%% Set "Save to workspace Decimation:"
set_param(model, 'Decimation', '1');


%% Set "Save to workspace Output:"
set_param(model, 'SaveOutput', 'on');


%% Turn on "Signals Signal logging:".
set_param(model, 'SignalLogging', 'on');


%% Set "Signal logging:" variable name.
set_param(model, 'SignalLoggingName', 'logsout');


%% Set "Signals Signal logging format:".
set_param(model, 'SignalLoggingSaveFormat', 'Dataset');


%% Turn on "Display --> Sample --> Colors".
set_param(model, 'SampleTimeColors', 'on');


%% Turn on "Display --> Signals & Port --> Signal Dimensions".
set_param(model, 'ShowLineDimensions', 'on');


%% Turn on "Display --> Signals & Port --> Port Data Types".
set_param(model, 'ShowPortDataTypes', 'on');


%% Add signal name to all signals in the model top-level.
if addSignalName == 1
    lines = find_system(model, 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'Line');
    % lines = find_system(model, 'LookUnderMasks', 'all', 'FindAll', 'on', 'Type', 'Line');
    sourcePorts = cell(size(lines));
    for n = 1:length(lines)
        sourcePorts{n} = get(lines(n), 'SourcePort');
    end
    T = table;
    T.SourcePort = unique(sourcePorts);
    T.SignalName = cell(size(T.SourcePort));
    for n = 1:length(T.SignalName)
        T.SignalName{n} = sprintf('x%d', n);
    end
    for n = 1:length(lines)
        if strcmp(get(lines(n), 'SegmentType'), 'trunk')
            if isempty(get(lines(n), 'Name'))
                sourcePort = get(lines(n), 'SourcePort');
                signalName = T{strcmp(T.SourcePort, sourcePort), 'SignalName'};
                set(lines(n), 'Name', signalName{1})
            end
        end
    end
end


%% Turn on data logging for all signals in the model top-level.
if logAllTopSignals == 1
    lines = find_system(model, 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'Line');
    for n = 1:length(lines)
        if strcmp(get(lines(n), 'SegmentType'), 'trunk')
            set(lines(n), 'DataLogging', 1);
        end
    end
end


end


