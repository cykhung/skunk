function status = ckhfirselftest

%%
%       SYNTAX: status = ckhfirselftest;
%
%  DESCRIPTION: Run all FIR filter selftests.
%
%        INPUT: none.
%
%       OUTPUT: - status (1-D row array of real double)
%                   Status vector. Number of elements = number of selftest
%                   functions. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Specify all selftest functions.
filename = {'ckhfirselftestfir', 'ckhfirselftestsetidx',                ...
    'ckhfirselftestfull', 'ckhfirselftestconv', 'ckhfirselftestfreq',   ...
    'ckhfirselftestapply'};


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
