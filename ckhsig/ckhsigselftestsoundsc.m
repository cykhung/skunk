function status = ckhsigselftestsoundsc

%%
%       SYNTAX: status = ckhsigselftestsoundsc;
%
%  DESCRIPTION: Test ckhsigsoundsc.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test.
tmp      = load('handel.mat');
filename = 'handel.wav';
audiowrite(filename, tmp.y, tmp.Fs);
x        = ckhsig(filename);
ckhsigsoundsc(x);
pause(1);
clear sound
delete(filename);


%% Exit function.
end

