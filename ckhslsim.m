function simout = ckhslsim(varargin)

%%
%       SYNTAX: simout = ckhslsim(model);
%               simout = ckhslsim(model, ...);
%
%  DESCRIPTION: Run simulation of an open model. Convert logged Simulink signal
%               into signal object.
%
%        INPUT: - model (string)
%                   Model name.
%
%       OUTPUT: - simout (struct)
%                   MATLAB structure containing model information, simulation
%                   outputs and simulation logged signals. Valid fields are:
%                   TBD.


%% Get model name.
model = varargin{1};


%% Run simulation.
if nargin == 1
    % Must set some parameters in the SIM call otherwise the output agrument
    % won't be of class Simulink.SimulationOutput.
    StopTime = get_param(bdroot', 'StopTime');
    simulationOutput = sim(model, 'StopTime', StopTime);
else
    simulationOutput = sim(varargin{:});
    % simulationOutput = sim(model, varargin{2:end});
end


%% Initialize simout.
simout = struct;


%% Add fields in simulationOutput into simout.
for name = get(simulationOutput)'
    simout.(name{1}) = get(simulationOutput, name{1});
end


%% Add ModelInfo into simout.
if any(strcmp(fieldnames(simout), 'ModelInfo'))
    error('Fieldname "ModelInfo" already exists.');
end
x = getSimulationMetadata(simulationOutput);
simout.ModelInfo = x.ModelInfo;


%% Check "Save to workspace Time:".
if ~strcmp(get_param(model, 'SaveTime'), 'on')
    str = ['Model''s "Save to workspace Time" is off. Cannot determine ', ...
        'model simulation time step.'];
    warning('ckhslsim:SaveTimeOff', str);
end


%% Check "Save to workspace Format:".
if ~strcmp(get_param(model, 'SaveFormat'), 'Dataset')
    str = 'Model''s "Save to workspace Format" is not Dataset.';
    warning('ckhslsim:SaveFormatNotDataset', str);
end


%% Check "Save to workspace Limit data points to last:".
if strcmp(get_param(model, 'LimitDataPoints'), 'on')
    str = ['Model''s "Save to workspace Limit data points to last" is on. ', ...
        'Not all time steps are saved.'];
    warning('ckhslsim:LimitDataPointsToLastOn', str);
end


%% Check "Save to workspace Output:".
if ~strcmp(get_param(model, 'SaveOutput'), 'on')
    str = 'Model''s "Save to workspace Output" is off.';
    warning('ckhslsim:SaveOutputOff', str);
end


%% Check "Save to workspace Decimation:".
if ~strcmp(get_param(model, 'Decimation'), '1')
    str = 'Model''s "Save to workspace Decimation" is not 1.';
    warning('ckhslsim:DecimationNotOne', str);
end


%% Check "Signals Signal logging:".
if ~strcmp(get_param(model, 'SignalLogging'), 'on')
    str = 'Model''s "Signals Signal logging" is off.';
    warning('ckhslsim:SignalLoggingOff', str);
end


%% Check "Signals Signal logging format:".
if ~strcmp(get_param(model, 'SignalLoggingSaveFormat'), 'Dataset')
    str = 'Model''s "Signals Signal logging format" is not Dataset.';
    warning('ckhslsim:SignalLoggingFormatNotDataset', str);
end


%% Print model unique time step.
if strcmp(get_param(model, 'SaveTime'), 'on')
    variableName = get_param(bdroot, 'TimeSaveName');
    tout         = simout.(variableName);
    fprintf('\n');
    fprintf('unique(round(diff(simout.%s), 10)) = \n', variableName)
    t = unique(round(diff(tout), 10));
    if length(t) > 100
        % Truncate printing.
        t = t(1:100);
        fprintf('%.15f\n', t);
        fprintf('... Too many to show. Only print the first 100 values.\n');
    else
        fprintf('%.15f\n', t);
    end
    fprintf('\n');
end 


%% Handle "Output:".
if strcmp(get_param(model, 'SaveOutput'), 'on') && ...
        strcmp(get_param(model, 'SaveFormat'), 'Dataset')
    variableName = get_param(model, 'OutputSaveName');
    if isfield(simout, variableName)
        y = simout.(variableName);
        if isa(y, 'Simulink.SimulationData.Dataset')
            s = [];
            for n = 1:numElements(y)
                x = get(y, n);
                s(n).Name = x.Values.Name;              %#ok<AGROW>
                s(n).Time = x.Values.Time;              %#ok<AGROW>
                s(n).Data = x.Values.Data;              %#ok<AGROW>
            end
            simout.(variableName) = s;
        end
    end
end


%% Handle "Signal logging:".
if strcmp(get_param(model, 'SignalLogging'), 'on') && ...
        strcmp(get_param(model, 'SignalLoggingSaveFormat'), 'Dataset')
    variableName = get_param(model, 'SignalLoggingName');
    if isfield(simout, variableName)
        logsout = simout.(variableName);
        s = struct;
        unnamedCnt = 1;
        for n = 1:numElements(logsout)
            x    = get(logsout, n);
            name = x.Values.Name;
            if any(strcmp(name, fieldnames(s)))
                str = sprintf(['Signal name "%s" is duplicated. ', ...
                    'Only one signal is logged.'], name);
                warning('ckhslsim:SignalNameDuplicate', str);         %#ok<SPWRN>
            end
            if isempty(name)
                name       = sprintf('Unnamed%d', unnamedCnt);
                unnamedCnt = unnamedCnt + 1;
            end
            try
                s.(name) = ckhsig(x);
                % tmp = ckhsig(x);
                % if ~iscell(tmp)
                %     s.(name) = tmp;
                % else
                %     for m = 1:length(tmp)
                %         new_name = sprintf('%s_%d', name, m);
                %         if any(strcmp(fieldnames(s), new_name))
                %             error('Fieldname collision.');
                %         end
                %         s.(new_name) = tmp{m};
                %     end
                % end
            catch ME
                if strcmp(ME.message, ...
                        ['Input argument is not a discrete-time signal ', ...
                        'since it does not have periodic sampling times.'])
                    str = sprintf(['Signal "%s" is not a discrete-time ', ...
                        'signal since it does not have periodic sampling ', ...
                        'times.'], name);
                    warning('ckhslsim:SignalNotPeriodicSampling', str); %#ok<SPWRN>
                    s.(name).Time = x.Values.Time;
                    s.(name).Data = x.Values.Data;
                else
                    rethrow(ME);
                end
            end
        end
        s = orderfields(s, sort(fieldnames(s)));
        simout.(variableName) = s;
    end
end
    

end

