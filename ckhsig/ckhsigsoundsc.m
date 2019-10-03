function ckhsigsoundsc(x)

%%
%       SYNTAX: ckhsigsoundsc(x);
% 
%  DESCRIPTION: Play mono or stereo audio signal.
%
%               To stop the playback, use either one of the following commands
%               at the MATLAB command window:
%                   >> clear sound
%                   >> clear all
%               Found this in http://stackoverflow.com/questions/1742268/
%               how-to-stop-sound-in-matlab
%
%        INPUT: - x (1-D row/col array of struct)
%                   Signal structure(s).
%
%       OUTPUT: none.


%% Play audio signal.
ckhsigisvalid(x);
switch length(x)
case 1
    % Mono.
    soundsc(x(1).s(:), x(1).fs);
case 2
    % Stereo.
    if x(1).fs ~= x(2).fs
        error('Sampling rate mismatch.');
    end
    x = ckhsigsetidx(x);
    if any(x(1).idx ~= x(2).idx)
        error('Sample indexes mismatch.');
    end
    soundsc([x(1).s(:), x(2).s(:)], x(1).fs);    
otherwise
    error('Invalid number of input signals.');
end


end
