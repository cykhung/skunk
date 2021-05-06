function du(folder)

if nargin == 0
    folder = '.';
end
% exe = fullfile(pwdcygwin64, 'bin', 'du.exe');
% cmd = sprintf('%s "%s" -h --max-depth=1', exe, folder);
% dos(cmd);
s = dir([folder, '\**']);
x = sum([s.bytes]);
if x >= (1024^3)
    fprintf('%.2f GB\n', x / (1024^3));
elseif x >= (1024^2)
    fprintf('%.2f MB\n', x / (1024^2));
else
    fprintf('%.2f kB\n', x / 1024);
end
x = [s.isdir];
fprintf('%d Files\n', sum(x == 0));
x = {s.name};
fprintf('%d Folders\n', sum(strcmp(x, '.')) - 1);

end
