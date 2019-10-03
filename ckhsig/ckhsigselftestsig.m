function status = ckhsigselftestsig

%%
%       SYNTAX: status = ckhsigselftestsig;
%
%  DESCRIPTION: Test constructor.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Run selftests.
tmp = ckhsigselftestsig_zadoff;
if tmp == 0
    status = 0;
end
tmp = ckhsigselftestsig_handleSimulinkSimulationDataSignal;
if tmp == 0
    status = 0;
end


end



% ------------------------------------------------------------------------------
%                           Zadoff-Chu Sequence
% ------------------------------------------------------------------------------

function status = ckhsigselftestsig_zadoff


% Reference: pp. 155 of LTE - The UMTS Long Term Evolution From Theory To
%            Practice [Second Edition]


%% Initialize status.
status = 1;


%% Property 1: Constant Amplitude
%
% * A Zadoff-Chu sequence has constant amplitude of 1.
%
% * A N_ZC-point FFT of a Zadoff-Chu sequence has constant amplitude of
%   sqrt(N_ZC).
%
% * A N_ZC-point IFFT of a Zadoff-Chu sequence has constant amplitude of 
%   1 / sqrt(N_ZC).
%
for N_ZC = [3 5 13 53 97 839]       % All prime numbers.
    
    for u = 1 : (N_ZC - 1)          % Try out all u's
        
        % Zadoff-Chu sequence.
        z = ckhsig('zadoff-chu', u, N_ZC, 1);
        if length(z.s) ~= N_ZC
            status = 0;
        end
        if ~strcmp(z.type, 'circular')
            status = 0;
        end
        if max(abs(abs(z.s) - 1)) > 1e-15
            status = 0;
        end
        
        % N_ZC-point FFT.
        s = fft(z.s);
        ideal = sqrt(N_ZC);
        if max(abs(abs(s) - ideal)) > 1e-8
            status = 0;
        end
        
        % N_ZC-point IFFT.
        s = ifft(z.s);
        ideal = 1 / sqrt(N_ZC);
        if max(abs(abs(s) - ideal)) > 1e-8
            status = 0;
        end
        
    end
    
end


%% Property 2: Zero Cyclic Autocorrelation
%
% * Zadoff-Chu sequences of any length have "ideal" cyclic autocorrelation (i.e.
%   the correlation with its circularly shifted version is a delta function).
%   Actually this is true for any cyclic shift of the original Zadoff-Chu
%   sequence.
%
% * The main benefit of the Constant Amplitude Zero Autocorrelation (CAZAC) 
%   property is that it allows multiple orthogonal sequences to be generated
%   from the same ZC sequence. Indeed, if the periodic autocorrelation of a ZC
%   sequence provides a single peak at the zero lag, the periodic correlation of
%   the same sequence against its cyclic shifted replica provides a peak at lag
%   NCS, where NCS is the number of samples of the cyclic shift. This creates a
%   Zero-Correlation Zone (ZCZ) between the two sequences. As a result, as long
%   as the ZCZ is dimensioned to cope with the largest possible expected time
%   misalignment between them, the two sequences are orthogonal for all
%   transmissions within this time misalignment.
%
% * Cyclic autocorrelation at zero lag = N_ZC.
%
% * This property lets us create a bank of perfectly orthogonal complex-valued
%   sequences.
%
for N_ZC = [3 5 13 53 97]           % All prime numbers.
    
    for u = 1 : (N_ZC - 1)          % Try out all u's
        
        % Generate one Zadoff-Chu sequence.
        z = ckhsig('zadoff-chu', u, N_ZC, 1);

        % Generate a bank of sequences via cyclic shifts.
        A   = zeros(N_ZC,N_ZC);
        row = 1;
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
        
        % Check cyclic autocorrelation property.
        C = A * A';
        if max(abs(diag(C) - N_ZC)) > 1e-10 % Check all diagonal elements.
            status = 0;
        end
        I = logical(eye(N_ZC,N_ZC));
        C(I) = 0;                           % Zero out all diagonal elements.
        if max(abs(C(:))) > 1e-9
            status = 0;
        end

    end

end


%% Property 3: Low Cyclic Cross Correlation
%
% * The absolute value of the cyclic cross-correlation between any two
%   Zadoff-Chu sequences (of different root indices u1 and u2) is constant and
%   equal to sqrt(N_ZC) if abs(u1 - u2) is relatively prime with respect to
%   N_ZC. This condition can be easily guaranteed if N_ZC is a prime number.
%
% * This property let us create a bank of mildly orthogonal complex-valued
%   sequences.
%
for N_ZC = [3 5 13 53 97]       % All prime numbers.

    % Generate a bank of sequences via all different cyclic shifts and all 
    % different root indices.
    A   = zeros((N_ZC - 1) * N_ZC, N_ZC);
    row = 1;
    for u = 1 : (N_ZC - 1)
        z = ckhsig('zadoff-chu', u, N_ZC, 1);
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
    end
    
    % Check both zero cyclic autocorrelation and low cross correlation
    C    = A * A';
    T    = [N_ZC * eye(N_ZC), sqrt(N_ZC)*ones(N_ZC, size(A,1)-N_ZC)];
    B    = zeros(size(C));
    row1 = 1;
    row2 = size(T,1);
    for n = 0 : ((size(B,1) / size(T,1)) - 1)
        B(row1:row2, :) = circshift(T, [0, n*N_ZC]);
        row1 = row1 + size(T,1);
        row2 = row2 + size(T,1);
    end
    E = abs(B - abs(C));
    if max(abs(E(:))) > 1e-9
        status = 0;
    end
    
end


%% Property 4: N_ZC-point FFT of Zadoff–Chu Sequence
%
% * If N_ZC is prime, Discrete Fourier Transform of Zadoff–Chu sequence is
%   another Zadoff–Chu sequence conjugated, scaled and time scaled. 
%   [wikipedia] 


%% Property 5: Zero Cyclic Autocorrelation for N_ZC-point FFT of Zadoff–Chu
%%             Sequence
%
% * This property follows from property 4.
%
% * Cyclic autocorrelation at zero lag = N_ZC ^ 2.
%
for N_ZC = [3 5 13 53 97]           % All prime numbers.
    
    for u = 1 : (N_ZC - 1)          % Try out all u's
        
        % Generate one Zadoff-Chu sequence.
        z   = ckhsig('zadoff-chu', u, N_ZC, 1);
        z.s = fft(z.s);

        % Generate a bank of sequences via cyclic shifts.
        A   = zeros(N_ZC,N_ZC);
        row = 1;
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
        
        % Check cyclic autocorrelation property.
        C = A * A';
        if max(abs(diag(C) - (N_ZC ^ 2))) > 1e-9 % Check all diagonal elements.
            status = 0;
        end
        I = logical(eye(N_ZC,N_ZC));
        C(I) = 0;                           % Zero out all diagonal elements.
        if max(abs(C(:))) > 1e-10
            status = 0;
        end

    end

end


%% Property 6: Low Cyclic Cross Correlation for N_ZC-point FFT of Zadoff–Chu
%%             Sequence
%
% * This property follows from property 4.
%
%
for N_ZC = [3 5 13 53 97]       % All prime numbers.

    % Generate a bank of sequences via all different cyclic shifts and all 
    % different root indices.
    A   = zeros((N_ZC - 1) * N_ZC, N_ZC);
    row = 1;
    for u = 1 : (N_ZC - 1)
        z   = ckhsig('zadoff-chu', u, N_ZC, 1);
        z.s = fft(z.s);
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
    end
    
    % Check both zero cyclic autocorrelation and low cross correlation
    C    = A * A';
    T    = [N_ZC * N_ZC       * eye(N_ZC), ...
            N_ZC * sqrt(N_ZC) * ones(N_ZC, size(A,1)-N_ZC)];
    B    = zeros(size(C));
    row1 = 1;
    row2 = size(T,1);
    for n = 0 : ((size(B,1) / size(T,1)) - 1)
        B(row1:row2, :) = circshift(T, [0, n*N_ZC]);
        row1 = row1 + size(T,1);
        row2 = row2 + size(T,1);
    end
    E = abs(B - abs(C));
    if max(abs(E(:))) > 1e-8
        status = 0;
    end
    
end


%% Property 7: Zero Cyclic Autocorrelation for N_ZC-point IFFT of Zadoff–Chu
%%             Sequence
%
% * This property follows from property 4.
%
% * Cyclic autocorrelation at zero lag = N_ZC ^ 2.
%
for N_ZC = [3 5 13 53 97]           % All prime numbers.
    
    for u = 1 : (N_ZC - 1)          % Try out all u's
        
        % Generate one Zadoff-Chu sequence.
        z   = ckhsig('zadoff-chu', u, N_ZC, 1);
        z.s = ifft(z.s);

        % Generate a bank of sequences via cyclic shifts.
        A   = zeros(N_ZC,N_ZC);
        row = 1;
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
        
        % Check cyclic autocorrelation property.
        C = A * A';
        if max(abs(diag(C) - 1)) > 1e-9     % Check all diagonal elements.
            status = 0;
        end
        I = logical(eye(N_ZC,N_ZC));
        C(I) = 0;                           % Zero out all diagonal elements.
        if max(abs(C(:))) > 1e-10
            status = 0;
        end

    end

end


%% Property 8: Low Cyclic Cross Correlation for N_ZC-point FFT of Zadoff–Chu
%%             Sequence
%
% * This property follows from property 4.
%
for N_ZC = [3 5 13 53 97]       % All prime numbers.

    % Generate a bank of sequences via all different cyclic shifts and all 
    % different root indices.
    A   = zeros((N_ZC - 1) * N_ZC, N_ZC);
    row = 1;
    for u = 1 : (N_ZC - 1)
        z   = ckhsig('zadoff-chu', u, N_ZC, 1);
        z.s = fft(z.s);
        for delay = 0 : (N_ZC - 1)
            A(row,:) = circshift(z.s, [0 delay]);
            row      = row + 1;
        end
    end
    
    % Check both zero cyclic autocorrelation and low cross correlation
    C    = A * A';
    T    = [N_ZC * N_ZC       * eye(N_ZC), ...
            N_ZC * sqrt(N_ZC) * ones(N_ZC, size(A,1)-N_ZC)];
    B    = zeros(size(C));
    row1 = 1;
    row2 = size(T,1);
    for n = 0 : ((size(B,1) / size(T,1)) - 1)
        B(row1:row2, :) = circshift(T, [0, n*N_ZC]);
        row1 = row1 + size(T,1);
        row2 = row2 + size(T,1);
    end
    E = abs(B - abs(C));
    if max(abs(E(:))) > 1e-8
        status = 0;
    end
    
end


%% Exit function.
end



function status = ckhsigselftestsig_handleSimulinkSimulationDataSignal


%% Initialize status.
status = 1;


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 1 channel. 1 sample per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '100')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '1')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '0.5');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 1])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '0.5');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1.s) ~= 1
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 1 channel. 1 sample per frame. 2 simulation time steps.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '100')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '1')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [2 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 1 2])
    status = 0;
end
if any(size(x2.Time) ~= [2 1])
    status = 0;
end
if any(size(x2.Data) ~= [2 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
simout.logsout.x1.private.simulink = ...
    rmfield(simout.logsout.x1.private.simulink, 'type');
simout.logsout.x2.private.simulink = ...
    rmfield(simout.logsout.x2.private.simulink, 'type');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1.s) ~= 2
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 1 channel. 4 samples per frame. 1 simulation time step.
%
% * For some reason, Simulink assigns signal x2 to be a sample-based signal
%   (this is because signal x2 has dimension "4" but not "[4x1]"). So it does
%   not make sense to check signal x2. In practice, if we need to fix this
%   problem, we can use the "Frame Conversion" block.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '100')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '4')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
if length(simout.logsout.x1.s) ~= 4
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 1 channel. 4 samples per frame. 2 simulation time steps.
%
% * For some reason, Simulink assigns signal x2 to be a sample-based signal
%   (this is because signal x2 has dimension "4" but not "[4x1]"). So it does
%   not make sense to check signal x2. In practice, if we need to fix this
%   problem, we can use the "Frame Conversion" block.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '100')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '4')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '4');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
if any(size(x1.Time) ~= [2 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 1 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '4');
if length(simout.logsout.x1.s) ~= 8
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 2 channels. 4 samples per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '[100 200]')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '4')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 2])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [4 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
for n = 1:length(simout.logsout.x1)
    if length(simout.logsout.x1(n).s) ~= 4
        status = 0;
    end
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 3 channels. 4 samples per frame. 2 simulation time steps.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '[100 200 300]')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '4')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '4');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [2 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 3 2])
    status = 0;
end
if any(size(x2.Time) ~= [2 1])
    status = 0;
end
if any(size(x2.Data) ~= [4 3 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '4');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 3
    status = 0;
end
for n = 1:length(simout.logsout.x1)
    if length(simout.logsout.x1(n).s) ~= 8
        status = 0;
    end
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 2 channels. 1 sample per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency',      '[100 200]')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '1')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '0.5');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 2])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '0.5');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
for n = 1:length(simout.logsout.x1)
    if length(simout.logsout.x1(n).s) ~= 1
        status = 0;
    end
end
bdclose all


%% ckhsigselftestsigtest01.slx.
%
% * Sine Wave Block: 3 channels. 1 sample per frame. 2 simulation time steps.
%
open_system('ckhsigselftestsigtest01.slx');
set_param('ckhsigselftestsigtest01/Sine Wave', 'Frequency', '[100 200 300]')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SamplesPerFrame', '1')
set_param('ckhsigselftestsigtest01/Sine Wave', 'SampleTime',      '1')
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [2 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 3 2])
    status = 0;
end
if any(size(x2.Time) ~= [2 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 3 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 3
    status = 0;
end
for n = 1:length(simout.logsout.x1)
    if length(simout.logsout.x1(n).s) ~= 2
        status = 0;
    end
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 1 channel. 1 sample per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X',      '1:100');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '1');
simout = sim(bdroot, 'StopTime', '0.5');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 1])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '0.5');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if any(simout.logsout.x1.s ~= 1)
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 1 channel. 1 sample per frame. 2 simulation time steps.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X',      '1:100');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '1');
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [2 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 1 2])
    status = 0;
end
if any(size(x2.Time) ~= [2 1])
    status = 0;
end
if any(size(x2.Data) ~= [2 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
simout.logsout.x1.private.simulink = ...
    rmfield(simout.logsout.x1.private.simulink, 'type');
simout.logsout.x2.private.simulink = ...
    rmfield(simout.logsout.x2.private.simulink, 'type');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if any(simout.logsout.x1.s ~= [1 2])
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 1 channel. 4 samples per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X',      '1:100');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '4');
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 1])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
if any(simout.logsout.x1.s ~= [1 2 3 4])
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 2 channels. 1 samples per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X', ...
    '[(1:100)'', (11:110)'']');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '1');
simout = sim(bdroot, 'StopTime', '0.5');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 2])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '0.5');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
if any(simout.logsout.x1(1).s ~= 1)
    status = 0;
end
if any(simout.logsout.x1(2).s ~= 11)
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 2 channels. 1 samples per frame. 3 simulation time steps.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X', ...
    '[(1:100)'', (11:110)'']');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '1');
simout = sim(bdroot, 'StopTime', '2');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [3 1])
    status = 0;
end
if any(size(x1.Data) ~= [1 2 3])
    status = 0;
end
if any(size(x2.Time) ~= [3 1])
    status = 0;
end
if any(size(x2.Data) ~= [1 2 3])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '2');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
if any(simout.logsout.x1(1).s ~= 1:3)
    status = 0;
end
if any(simout.logsout.x1(2).s ~= 11:13)
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 2 channels. 4 samples per frame. 1 simulation time step.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X', ...
    '[(1:100)'', (11:110)'']');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '4');
simout = sim(bdroot, 'StopTime', '1');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [1 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 2])
    status = 0;
end
if any(size(x2.Time) ~= [1 1])
    status = 0;
end
if any(size(x2.Data) ~= [4 2])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '1');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
if any(simout.logsout.x1(1).s ~= 1:4)
    status = 0;
end
if any(simout.logsout.x1(2).s ~= 11:14)
    status = 0;
end
bdclose all


%% ckhsigselftestsigtest02.slx.
%
% * From Block: 2 channels. 4 samples per frame. 3 simulation time steps.
%
open_system('ckhsigselftestsigtest02.slx');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'X', ...
    '[(1:100)'', (11:110)'']');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'Ts',     '1');
set_param('ckhsigselftestsigtest02/Signal From Workspace', 'nsamps', '4');
simout = sim(bdroot, 'StopTime', '11');
x1     = get(get(simout, 'logsout'), 'x1');
x1     = x1.Values;
x2     = get(get(simout, 'logsout'), 'x2');
x2     = x2.Values;
if any(size(x1.Time) ~= [3 1])
    status = 0;
end
if any(size(x1.Data) ~= [4 2 3])
    status = 0;
end
if any(size(x2.Time) ~= [3 1])
    status = 0;
end
if any(size(x2.Data) ~= [4 2 3])
    status = 0;
end
simout = ckhslsim(bdroot, 'StopTime', '11');
if ~isequal(simout.logsout.x1, simout.logsout.x2)
    status = 0;
end
if length(simout.logsout.x1) ~= 2
    status = 0;
end
if any(simout.logsout.x1(1).s ~= 1:12)
    status = 0;
end
if any(simout.logsout.x1(2).s ~= 11:22)
    status = 0;
end
bdclose all


%% Delete "slprj".
rmdir('slprj', 's');


end

