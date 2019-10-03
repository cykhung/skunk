function T = ckhsigstats(x)

%%
%       SYNTAX: T = ckhsigstats(x);
% 
%  DESCRIPTION: Calculate basic signal statistics.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - T (table)
%                   Signal statistics table.


%% Check if signal is valid.
ckhsigisvalid(x);


%% Set x.idx.
x = ckhsigsetidx(x);


%% Create blank table.
N                      = numel(x);
T                      = table;
T.type                 = categorical(repmat({''}, N, 1), ...
                                     {'segment', 'circular', 'streaming'});
T.complex              = NaN(N,1);
T.fs                   = NaN(N,1);
T.Nsamples             = NaN(N,1);
T.duration_sec         = NaN(N,1);
T.start_idx            = NaN(N,1);
T.end_idx              = NaN(N,1);
T.peak_pwr_dB          = NaN(N,1);
T.avg_pwr_dB           = NaN(N,1);
T.peak_to_avg_ratio_dB = NaN(N,1);
T.max_abs              = NaN(N,1);
T.abs_dc               = NaN(N,1);


%% Fill in statistics.
[pk_pwr_dB, avg_pwr_dB, par_dB] = ckhsigpkavg(x);
isreal                          = double(ckhsigisreal(x));
for n = 1:numel(x)
    T.type(n)                 = x(n).type;
    T.complex(n)              = ~isreal(n);
    T.fs(n)                   = x(n).fs;
    T.Nsamples(n)             = length(x(n).s);
    T.duration_sec(n)         = length(x(n).s) / x(n).fs;
    T.start_idx(n)            = x(n).idx(1);
    T.end_idx(n)              = x(n).idx(2);
    T.peak_pwr_dB(n)          = pk_pwr_dB(n);
    T.avg_pwr_dB(n)           = avg_pwr_dB(n);
    T.peak_to_avg_ratio_dB(n) = par_dB(n);
    T.max_abs(n)              = max(abs(x(n).s));
    T.abs_dc(n)               = abs(mean(x(n).s));
end


end

