function fs = ckhsiggetfs(x)

%%
%       SYNTAX: fs = ckhsiggetfshz(x);
%
%  DESCRIPTION: Get x.fs.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - fs (N-D array of real double)
%                   N-D array of sampling rate in Hz.


%% Get x.fs.
fs = zeros(size(x));
for n = 1:numel(x)
    fs(n) = x(n).fs;
end


end
