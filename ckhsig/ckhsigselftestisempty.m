function status = ckhsigselftestisempty

%%
%       SYNTAX: status = ckhsigselftestisempty;
%
%  DESCRIPTION: Test ckhsigisempty.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = 2x3 array. 
x = repmat(ckhsig, 2, 3);
x(1).s = [1 2];
x(1,3).s = [1 2];
tf = ckhsigisempty(x);
if max(max(abs(tf - [0 1 0; 1 1 1]))) > 0
    status = 0;
end


%% Exit function.
end






