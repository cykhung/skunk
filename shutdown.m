function shutdown(varargin)

%%
%       SYNTAX: shutdown;
%               shutdown(delay);
%               shutdown delay
%
%  DESCRIPTION: Shutdown PC.
%
%        INPUT: - delay (real double)
%                   Delay in minutes. This is useful for delay shutdown. Default
%                   = 0.


%% Assign input arguments.
delay = 0;
switch nargin
case 0
    % Do nothing.
case 1
    delay = varargin{1};
    if ischar(delay)
        delay = eval(delay);
    end
otherwise
    error('Invalid number of input arguments.');
end


%% Shut down.
c = 'dos(''C:\Windows\System32\shutdown.exe /s /t 5''); quit';
if delay == 0
    eval(c)
else
    t = timer('Name', 'Shutdown', 'TimerFcn', c);
    startat(t, datetime('now') + minutes(delay));
end


end


% function shutdown(varargin)
% 
% %%
% %       SYNTAX: shutdown;
% %               shutdown(action);
% %               shutdown(action, t_sec);
% %
% %  DESCRIPTION: Shutdown PC.
% %
% %               Calling this function without any input argument is equivalent
% %               to the following MATLAB commands:
% %                   >> shutdown('off', 5); quit
% %
% %        INPUT: - action (string)
% %                   Action. Valid strings are:
% %                       'abort'   - Abort a system shutdown.
% %                       'restart' - Restart a PC.
% %                       'off'     - Turn off a PC. Default.
% %                       'sleep'   - Put PC into sleep mode.
% %
% %               - t_sec (real double)
% %                   Time to shutdown in seconds. Default = 0. Valid values are: 
% %                   0, 1, ..., 600.
% 
% 
% %% Assign input arguments.
% switch nargin
% case 0
%     shutdown('off', 5);
%     quit
% case 1
%     action = varargin{1};
%     t_sec  = 0;
% case 2
%     [action, t_sec] = deal(varargin{:});
%     if ischar(t_sec)
%         t_sec = str2num(t_sec); %#ok<ST2NM>
%     end
%     if (t_sec < 0) || (t_sec > 600)
%         error('t_sec out of range.');
%     end
% otherwise
%     error('Invalid number of input arguments.');
% end
% 
% %% Perform action.
% switch action
% case 'abort'
%     dos('C:\Windows\System32\shutdown.exe /a');
% case 'restart'
%     dos(sprintf('C:\\Windows\\System32\\shutdown.exe /r /t %d', t_sec));
% case 'off'
%     dos(sprintf('C:\\Windows\\System32\\shutdown.exe /s /t %d', t_sec));
% case 'sleep'
%     dos(sprintf('C:\\Windows\\System32\\shutdown.exe /s /t %d', t_sec));
% otherwise
%     error('Invalid action.');
% end
% 
% end



% %
% % Perform action.
% %
% s = 'shutdown ';
% switch action
% case 'abort'
%     dos('shutdown -a');
%     return;
% case 'restart'
%     s = [s, '-r '];
% case 'off'
%     s = [s, '-s '];
% otherwise
%     error('Invalid action.');
% end
% % s = [s, sprintf('-t %d -f -c "%s" &', t_sec, msg)];
% s = [s, '-f '];
% [status, result] = dos('shutdown --version');
% if status ~= 0
%     error('status ~= 0');
% end
% if ~isempty(regexp(result, 'shutdown V1.2', 'once'))
%     s = [s, sprintf('%d &', t_sec)];
% else
%     s = [s, sprintf('-t %d &', t_sec)];
% end
% dos(s);




% dos('shutdown -r -t 10 -f -c "MATLAB (sometimes) rules" &'), quit

% dos('shutdown --help')
% Usage: shutdown [-i | -l | -s | -r | -a] [-f] [-m \\computername] [-t xx] [-c "comment"] [-d up:xx:yy]
% 	No args			Display this message (same as -?)
% 	-i			Display GUI interface, must be the first option
% 	-l			Log off (cannot be used with -m option)
% 	-s			Shutdown the computer
% 	-r			Shutdown and restart the computer
% 	-a			Abort a system shutdown
% 	-m \\computername	Remote computer to shutdown/restart/abort
% 	-t xx			Set timeout for shutdown to xx seconds
% 	-c "comment"		Shutdown comment (maximum of 127 characters)
% 	-f			Forces running applications to close without warning
% 	-d [u][p]:xx:yy		The reason code for the shutdown
% 				u is the user code
% 				p is a planned shutdown code
% 				xx is the major reason code (positive integer less than 256)
% 				yy is the minor reason code (positive integer less than 65536)



% dos('shutdown --help')
% Usage: shutdown [OPTION]... secs|"now"
% Bring the system down.
%   -f, --force      Forces the execution.
%   -s, --shutdown   The system will shutdown and power off (if supported)
%   -r, --reboot     The system will reboot.
%   -h, --hibernate  The system will suspend to disk (if supported)
%   -p, --suspend    The system will suspend to RAM (if supported)
%       --help       Display this help and exit.
%       --version    Output version information and exit.
% To reboot is the default if started as `reboot', to hibernate if started
% as `hibernate', to suspend if started as `suspend', to shutdown otherwise.


% dos('shutdown --version')
% shutdown V1.2, Corinna Vinschen, Nov 28 2001
% Copyright (C) 2001 Corinna Vinschen <corinna@vinschen.de>
% This is free software; see the source for copying conditions.
% There is NO warranty; not even for MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.
