function status = ckhfirselftestapply

%%
%       SYNTAX: status = ckhfirselftestapply;
%
%  DESCRIPTION: Test ckhfirapply.m.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test apply_segment.
status = status & ckhfirselftestapplysegment;


%% Test apply_circular.
status = status & ckhfirselftestapplycircular;


%% Test apply_streaming.
status = status & ckhfirselftestapplystreaming;


%% Exit function.
end

