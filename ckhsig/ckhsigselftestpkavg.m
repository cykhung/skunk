function status = ckhsigselftestpkavg

%%
%       SYNTAX: status = ckhsigselftestpkavg;
%
%  DESCRIPTION: Test ckhsigpkavg.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = 2x3 array of empty signal structures. 
x = repmat(ckhsig, 2, 3);
[pk_pwr_dB, avg_pwr_dB, par_dB] = ckhsigpkavg(x);
if any(size(pk_pwr_dB) ~= [2 3])
    status = 0;
end
for n = 1:2
    for k = 1:3
        if ~isnan(pk_pwr_dB(n,k)) || ~isnan(avg_pwr_dB(n,k)) || ...
                ~isnan(par_dB(n,k))
            status = 0;
        end
    end
end


%% Test: x = signal object of 0. 
x = ckhsig;
x.s = 0;
[pk_pwr_dB, avg_pwr_dB, par_dB] = ckhsigpkavg(x);
if (pk_pwr_dB ~= -Inf) || (avg_pwr_dB ~= -Inf) || ~isnan(par_dB)
    status = 0;
end


%% Test: x = 2x3 array of signal objects. Scaling should not change 
%%       peak-to-average ratio.
x = repmat(ckhsig, 2, 3);
x(1,1).s = (1:5) + 1i*(11:15);
x(1,2).s = 2 * x(1,1).s;
x(1,3).s = 3 * x(1,1).s;
x(2,1).s = 4 * x(1,1).s;
x(2,2).s = 5 * x(1,1).s;
x(2,3).s = 6 * x(1,1).s;
[pk_pwr_dB, avg_pwr_dB, par_dB] = ckhsigpkavg(x);
ideal_par_dB = 20*log10(max(abs(x(1).s))) - 10*log10(mean(abs(x(1).s).^2));
for n = 1:numel(pk_pwr_dB)
    ideal_pk_pwr_dB = 20*log10(max(abs(x(n).s)));
    ideal_avg_pwr_dB = 10*log10(mean(abs(x(n).s).^2));
    if max(abs(pk_pwr_dB(n) - ideal_pk_pwr_dB)) > 0
        status = 0;
    end
    if max(abs(avg_pwr_dB(n) - ideal_avg_pwr_dB)) > 0
        status = 0;
    end
    if max(abs(par_dB(n) - ideal_par_dB)) > 1e-12
        status = 0;
    end        
end


%% Exit function.
end

