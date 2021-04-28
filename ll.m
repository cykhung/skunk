function T = ll(varargin)

%%
%       SYNTAX: T = ll;
%               T = ll(files);
%               T = ll(rootdir, includedir, excludedir, includefile, excludefile);
%
%  DESCRIPTION: Search files recursively.
%
%        INPUT: - files (char)
%                   File pattern. Examples: *
%                                           *.m
%                                           files\*
%                                           lib\files\*
%
%       OUTPUT: - T (table)
%                   Table. See output T in searchfile.m for more details.


%% Assign input arguments.
switch nargin
case 0
    rootdir     = pwd;
    includedir  = '*';
    excludedir  = '';
    includefile = '*';
    excludefile = '';
case 1
    [rootdir, includedir, excludedir, includefile, excludefile] = ...
        parseinput(varargin{1});
case 5
    [rootdir, includedir, excludedir, includefile, excludefile] = ...
        deal(varargin{:});
end


%% Make sure that drive letter is lowercase.
if (length(rootdir) >= 2) && strcmp(rootdir(2), ':')
    rootdir(1) = lower(rootdir(1));
end


%% Search.
% fprintf('rootdir     = ''%s''\n', rootdir)
% fprintf('includedir  = ''%s''\n', includedir)
% fprintf('excludedir  = ''%s''\n', excludedir)
% fprintf('includefile = ''%s''\n', includefile)
% fprintf('excludefile = ''%s''\n', excludefile)
% fprintf('\n')
T = searchfile(rootdir, includedir, excludedir, includefile, excludefile);


end


function [rootdir, includedir, excludedir, includefile, excludefile] = ...
    parseinput(x)


%% Case 1:
%
% * Examples: >> ll foo.m
%             >> ll foo*
%
[filepath, name, ext] = fileparts(x);
if isempty(filepath) && (exist([name, ext], 'dir') ~= 7)
    rootdir     = pwd;
    includedir  = '*';
    excludedir  = '';
    includefile = [name, ext];
    excludefile = '';
    return
end


%% Case 2:
%
% * Examples: >> ll files     where files is a folder.
%             >> ll abc.def   where abc.def is a folder.
%
[filepath, name, ext] = fileparts(x);
if isempty(filepath) && (exist([name, ext], 'dir') == 7)
    error('Not supported.');
    % rootdir     = pwd;
    % includedir  = [name, ext];
    % excludedir  = '';
    % includefile = '*';
    % excludefile = '';
    % return
end


%% Case 3:
%
% * Examples: >> ll lib\files   where lib\files is a folder.
%
[filepath, name, ext] = fileparts(x);   %#ok<ASGLU>
if ~isempty(filepath) && (exist(x, 'dir') == 7)
    error('Not supported.');
    % rootdir     = x;
    % includedir  = '*';
    % excludedir  = '';
    % includefile = '*';
    % excludefile = '';
    % return
end


%% Case 4:
%
% * Examples: >> ll files\*         where files is a folder.
%             >> ll lib\files\*     where lib\files is a folder.
%
% * Not Allowed: >> ll lib*\*
%                 >> ll tmp\lib*\*
%                 >> ll tmp*\lib\*
%
[filepath, name, ext] = fileparts(x);
if ~isempty(filepath) && strcmp(name, '*') && isempty(ext)
    if ~isempty(strfind(filepath, '*'))    %#ok<STREMP>
        error('Not supported.');
    else
        rootdir     = filepath;
        includedir  = '*';
        excludedir  = '';
        includefile = '*';
        excludefile = '';
        return
    end
end


%% Case 5:
%
% * Examples: >> ll lib\foo.m
%             >> ll lib\foo*.m
%             >> ll tmp\lib\foo.m
%             >> ll tmp\lib\foo*.m
%
% * Not Allowed: >> ll lib*\foo.m
%                 >> ll tmp\lib*\foo.m
%                 >> ll tmp*\lib\foo.m
%
[filepath, name, ext] = fileparts(x);
if ~isempty(filepath)
    if ~isempty(strfind(filepath, '*'))    %#ok<STREMP>
        error('Not supported.');
    else
        rootdir     = filepath;
        includedir  = '*';
        excludedir  = '';
        includefile = [name, ext];
        excludefile = '';
    end
    return
end


%% Should not reach here.
error('Invalid input argument');


end


