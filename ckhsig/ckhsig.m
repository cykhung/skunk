function x = ckhsig(in1, in2, in3, in4)

%%
%       SYNTAX: x = ckhsig(s);
%               x = ckhsig(s, fs);
%               x = ckhsig(s, fs, type);
%               x = ckhsig(s, fs, type, idx);
%               x = ckhsig('zadoff-chu', u, N_ZC, fs);
%               x = ckhsig;
%               x = ckhsig(simulinkLogSignal);
%               x = ckhsig(audioFilename);
%
%  DESCRIPTION: Construct signal structure.
%
%               x = ckhsig('zadoff-chu', u, N, fs); constructs one Zadoff-Chu
%               sequence. x.type = 'circular'. Reference:
%
%                   "Polyphase Codes With Good Periodic Correlation Properties",
%                   David C. Chu, IEEE Transmissions On Information Theory,
%                   1972.
%
%                   >> jarvis find zadoff
%
%               x = ckhsig constructs a "default" signal structure with the
%               following fields:
%                   x.type  = 'segment';
%                   x.s     = [];
%                   x.fs    = 1;
%                   x.idx   = [];
%
%        INPUT: - s (1-D row/col array of complex double)
%                   Vector of signal samples.
%
%               - type (string)
%                   Signal type. Refer to x.type in the output argument.
%                   Optional. Default = 'segment'.
%
%               - fs (real double)
%                   Sampling rate of the samples in Hz. Refer to x.fs in the
%                   output argument. Default = 1.
%
%               - idx (1-D row/col array of real double)
%                   Index vector. Refer to x.idx in the output argument.
%
%               - u (real double)
%                   Zadoff-Chu sequence root index. u and N_ZC must be
%                   relatively prime, i.e. u and N_ZC cannot have a common
%                   factor. Therefore if N_ZC is a prime number, then the valid 
%                   values of u are: 1, 2, ..., (N_ZC - 1).
%
%               - N_ZC (real double)
%                   Length of the Zadoff-Chu sequence. N_ZC must be odd.
%
%               - simulinkLogSignal (Simulink.SimulationData.Signal)
%                   Simulink logging signal object.
%
%               - audioFilename (string)
%                   Audio filename.
%
%       OUTPUT: - x (struct)
%                   Signal structure. Valid fields are:
%
%                   - type (string)
%                       Signal type. Valid strings are:
%                           'streaming' - Streaming signal.
%                           'circular' - Circularly continuous signal.
%                           'segment' - Signal segment.
%
%                   - s (1-D row array of complex double)
%                       Vector of signal samples. Can be []. Signal samples are
%                       assumed to be contiguous in time.
%
%                   - fs (real double)
%                       Sampling rate of the samples in Hz. x.fs > 0.
%
%                   - idx (1-D row array of real double)
%                       Index vector. Length = 2. idx(1) and idx(2) are the time
%                       indices of the first and last samples in x.s. Set to []
%                       for default value. Default = [0, length(x.s)-1].
%
%                   - private (struct)
%                       Private parameter structure. Valid fields are:
%
%                       - simulink (struct)
%                           Simulink information structure. Optional. This field
%                           may not exist.


%% Create signal structure.
x.type  = 'segment';
x.s     = [];
x.fs    = 1;
x.idx   = [];
switch nargin
case 0
case 1
    if isa(in1, 'Simulink.SimulationData.Signal')
        x = handleSimulinkSimulationDataSignal(in1);
    elseif ischar(in1)
        x = handleAudioFile(in1);
    elseif isa(in1, 'double')
        x.s = in1;
        if ~isempty(x.s)
            x.s = x.s(:).';
        end        
    elseif isa(in1, 'timetable')
        % Undocumented feature.
        % Single timetable (but possibly multiple signals).
        n0 = seconds(in1.Properties.StartTime) * in1.Properties.SampleRate;
        if abs(n0 - fix(n0)) > 0
            error('Start index is not an integer.');
        end
        x = repmat(struct, [1, size(in1,2)]);
        for n = 1:numel(x)
            x(n).type = 'segment';
            x(n).s    = in1{:,n};
            x(n).s    = x(n).s(:).';
            x(n).fs   = in1.Properties.SampleRate;
            x(n).idx  = [0, length(x(n).s)-1] + n0;
        end
    elseif iscell(in1) && isa(in1{1}, 'timetable')
        % Undocumented feature.
        % Cell array of timetables.
        x = repmat(struct, size(in1));
        for n = 1:numel(in1)
            if ~isa(in1{n}, 'timetable')
               error('Only support timetable.'); 
            end
            if size(in1{n},2) ~= 1
                error('Only support single signal.');
            end
            n0 = seconds(in1{n}.Properties.StartTime) * ...
                                                in1{n}.Properties.SampleRate;
            if abs(n0 - fix(n0)) > 0
                error('Start index is not an integer.');
            end
            x(n).type = 'segment';
            x(n).s    = in1{n}{:,1};
            x(n).s    = x(n).s(:).';
            x(n).fs   = in1{n}.Properties.SampleRate;
            x(n).idx  = [0, length(x(n).s)-1] + n0;
        end
    end
case 2
    x.s  = in1;
    x.fs = in2;
    if ~isempty(x.s)
        x.s = x.s(:).';
    end
case 3
    x.s    = in1;
    x.type = in3;
    x.fs   = in2;
    if ~isempty(x.s)
        x.s = x.s(:).';
    end
case 4
    if ischar(in1)
        % Generate Zadoff-Chu sequence.
        u     = in2;
        N_ZC  = in3;
        fs = in4;
        if mod(N_ZC, 2) ~= 1
            error('N_ZC must be an odd integer.');
        end
        if (u < 1) || (u > (N_ZC - 1))
            error('u out of range.');
        end
        f = N_ZC / u;
        if (u ~= 1) && (fix(f) == f)
            warning('ckhsig:ZadoffChu:notRelativelyPrime', ...
                'u and N_ZC are not relatively prime');
        end        
        n = 0 : (N_ZC - 1);
        z = exp(-1i * pi * u * n .* (n + 1) / N_ZC);
        x.type  = 'circular';
        x.s     = z;
        x.fs    = fs;
    else
        x.s    = in1;
        x.fs   = in2;
        x.type = in3;
        x.idx  = in4;
        if ~isempty(x.s)
            x.s = x.s(:).';
        end
        if ~isempty(x.idx)
            x.idx = x.idx(:)';
        end
    end
end


%% Is x valid?
ckhsigisvalid(x);


end


function x = handleSimulinkSimulationDataSignal(s)


%% Check s.
if length(s) ~= 1
    error('length(s) ~= 1.');
end
if length(s.Values.Time) == 1
    % Corner case. Sample time = Inf (eg. Constant Block).
elseif isempty(s.Values.Time)
    % Corner case. Signal at the output of Input Port but Input is not
    % defined in Model Configuration Parameters.
else
    dt = unique(diff(s.Values.Time));
    if any(abs(dt - dt(1)) > 1e-10)
        error(['Input argument is not a discrete-time signal since it ', ...
            'does not have periodic sampling times.']);
    end
end


%% Frame-based Signal or Sample-based Signal?
%
% * Frame-based Signal:
%
%       s.Values.Data = M-by-N-by-P array of double.
%
%           where M = Number of samples per frame per channel.
%                 N = Number of channels.
%                 P = Number of frames (i.e. number of simulation time steps).
%
% * Sample-based Signal:
%
%       s.Values.Data = matrix of double where each column represents one
%                       channel.
%
if length(size(s.Values.Data)) == 3
    % 3-D array.
    is_frame_based_signal = 1;
else
    % Matrix or vector.
    if length(s.Values.Time) == 1
        % Corner case. Only one simulation time step.
        is_frame_based_signal = 1;
    else
        is_frame_based_signal = 0;
    end
end


%% Get signal attributes.
if is_frame_based_signal == 1
    NsamplesPerFrame = size(s.Values.Data, 1);
    Nchannels        = size(s.Values.Data, 2);
    Nframes          = size(s.Values.Data, 3);
else
    Nframes          = size(s.Values.Data, 1);
    Nchannels        = size(s.Values.Data, 2);
    NsamplesPerFrame = 1;
end


%% Form signal structure.
if length(s.Values.Time) ~= Nframes
    error('Invalid signal format.');
end
x = repmat(struct, 1, Nchannels);
for n = 1:length(x)
    
    % Set x.type.
    x(n).type  = 'segment';
    
    % Set x.s.
    if isempty(s.Values.Time)
        x(n).s = [];
    else
        if is_frame_based_signal == 1
            x(n).s = double(s.Values.Data(:,n,:));
        else
            x(n).s = double(s.Values.Data(:,n));
        end
        x(n).s = x(n).s(:).';
    end    
    
    % Set x.fs.
    if (length(s.Values.Time) == 1) || isempty(s.Values.Time)
        x(n).fs = 1;     % Arbitrarily set to 1 Hz.
    else
        x(n).fs = NsamplesPerFrame / dt(1);
    end
    
    % Set x.idx.
    if isempty(s.Values.Time)
        x(n).idx = [];
    else
        x(n).idx(1) = round(s.Values.Time(1)   * x(n).fs);
        x(n).idx(2) = x(n).idx(1) + ((NsamplesPerFrame * Nframes) - 1);
    end
   
    % Set x.simulink.
    if is_frame_based_signal == 1
        x(n).private.simulink.type = 'frame-based';
    else
        x(n).private.simulink.type = 'sample-based';
    end
    x(n).private.simulink.Nframes          = Nframes;
    x(n).private.simulink.NsamplesPerFrame = NsamplesPerFrame;
    
end


end



function x = handleAudioFile(filename)

[y, fs] = audioread(filename);
x       = repmat(ckhsig, 1, size(y,2));
idx     = [0, size(y,1)-1];
for n = 1:length(x)
    x(n) = ckhsig(y(:,n), fs, 'segment', idx);
end

end



