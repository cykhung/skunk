function status = ckhsigselftest

%%
%       SYNTAX: status = ckhsigselftest;
%
%  DESCRIPTION: Run all signal selftests.
%
%        INPUT: none.
%
%       OUTPUT: - status (1-D row array of real double)
%                   Status vector. Number of elements = number of selftest
%                   functions. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Specify all selftest functions.
filename = {'ckhsigselftestsig', 'ckhsigselftestgrep', 'ckhsigselftestpsd'  ...
    'ckhsigselftestabs', 'ckhsigselftestpkavg', 'ckhsigselftestconj',       ...
    'ckhsigselftestreal', 'ckhsigselftestimag', 'ckhsigselftestfshift',     ...
    'ckhsigselftestdelay', 'ckhsigselftestcorr', 'ckhsigselftestconvmtx',   ...
    'ckhsigselftestintersect', 'ckhsigselftestdecimate',                    ...
    'ckhsigselftestinterp', 'ckhsigselftestmax', 'ckhsigselftestmin',       ...
    'ckhsigselftestlie', 'ckhsigselftestangle', 'ckhsigselftestisreal',     ...
    'ckhsigselftestflip', 'ckhsigselftestisempty', 'ckhsigselftestcorrmtx', ...
    'ckhsigselftestlieiq', 'ckhsigselftestsoundsc', 'ckhsigselftestadd',    ...
    'ckhsigselftestmultiply', 'ckhsigselftestzeros'};


%% Run all selftest functions.
status = zeros(1, length(filename));
for n = 1:length(filename)
    fprintf('[%s] Running %s ... ', datestr(now), which(filename{n}));
    status(n) = eval(filename{n});
    if status(n)
        fprintf('PASSED.\n');
    else
        fprintf('FAILED.\n');
    end
end


%% Exit function.
end
