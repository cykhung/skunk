function T = ckhslstats(logsout)

%%
%       SYNTAX: T = ckhslstats(logsout);
%
%  DESCRIPTION: Calculate statistics of the logged signals.
%
%               Example: >> T = ckhslstats(simout.logsout);
%
%        INPUT: - logsout (struct)
%                   Structure containing logged signals. This structure is
%                   created by ckhSlxSim().
%
%       OUTPUT: - T (table)
%                   Table containing signal statistics.


%% Initialize table T. Create dummy row.
T                  = table;
T.name             = categorical({''});
T.type             = categorical({''}, {'frame-based', 'sample-based'}, ...
    'Protected', 1);
T.Nframes          = NaN;
T.NsamplesPerFrame = NaN;
T.fs               = NaN;
T.NsamplesTotal    = NaN;
T.minabs           = NaN;
T.maxabs           = NaN;
T.dcabs            = NaN;
T.avgPwrDb         = NaN;


%% Loop through all signals.
simulinkSignalNames = fieldnames(logsout);
k = 2;  % Table row index.
for m = 1:length(simulinkSignalNames)
    x = logsout.(simulinkSignalNames{m});
    for n = 1:numel(x)
        T(end+1,:)    = T(1,:);     %#ok<AGROW>
        if numel(x) == 1
            T.name(k) = simulinkSignalNames(m);
        else
            T.name(k) = {[simulinkSignalNames{m}, '(', num2str(n), ')']};
        end
        if isfield(x(n), 's')
            T.type(k)             = x(n).private.simulink.type;
            T.Nframes(k)          = x(n).private.simulink.Nframes;
            T.NsamplesPerFrame(k) = x(n).private.simulink.NsamplesPerFrame;
            T.fs(k)               = x(n).fs;
            T.NsamplesTotal(k)    = length(x(n).s);
            T.minabs(k)           = min(abs(x(n).s));
            T.maxabs(k)           = max(abs(x(n).s));
            T.dcabs(k)            = abs(mean(x(n).s));
            T.avgPwrDb(k)         = 10*log10(mean(abs(x(n).s) .^ 2));
        end
        k                     = k + 1;
    end
end


%% Delete dummy row.
T(1,:) = [];


end

