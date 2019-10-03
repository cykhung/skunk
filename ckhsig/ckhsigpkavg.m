function varargout = ckhsigpkavg(x)

%%
%       SYNTAX: ckhsigpkavg(x);
%               [pk_pwr_dB, avg_pwr_dB, par_dB] = ckhsigpkavg(x);
%
%  DESCRIPTION: Calculate peak-to-average statistics. If there is no output
%               argument, then the function will print the results on the
%               screen (stdout).
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - pk_pwr_dB (N-D array of real double)
%                   Peak power(s) in dB = 10*log10(max(abs(s)).^2). Return
%                   NaN for s = []. Return -Inf for s = all zeros.
%
%               - avg_pwr_dB (N-D array of real double)
%                   Average power(s) in dB =  10*log10(mean(abs(s).^2)).
%                   Return NaN for s = []. Return -Inf for s = all zeros.
%
%               - par_dB (N-D array of real double)
%                   Peak-to-average ratio(s) in dB = pk_pwr_dB - avg_pwr_dB.
%                   Return NaN for either s = [] or s = all zeros.


%% Check x.
ckhsigisvalid(x);


%% Calculate peak-to-average statistics.
pk_pwr_dB  = NaN(size(x));
avg_pwr_dB = NaN(size(x));
par_dB     = NaN(size(x));
for n = 1:numel(x)
    if isempty(x(n).s)
        pk_pwr_dB(n)  = NaN;
        avg_pwr_dB(n) = NaN;
        par_dB(n)     = NaN;
    else
        pk_pwr = max(abs(x(n).s))^2;
        if pk_pwr == 0
            pk_pwr_dB(n) = -Inf;
        else
            pk_pwr_dB(n) = 10*log10(pk_pwr);
        end
        avg_pwr = mean(abs(x(n).s).^2);
        if avg_pwr == 0
            avg_pwr_dB(n) = -Inf;
        else
            avg_pwr_dB(n) = 10*log10(avg_pwr);
        end
        par_dB(n) = pk_pwr_dB(n) - avg_pwr_dB(n);
    end        
end


%% Print result and exit function.
if nargout == 0
    str = ['Signal %d: Peak power = %.2f dB. Average power = %.2f dB. ', ...
        'Peak-to-average ratio = %.2f dB.\n'];    
    fprintf('\n');
    fprintf(str, [1:numel(x); pk_pwr_dB(:).'; avg_pwr_dB(:).'; par_dB(:).']);
    fprintf('\n');
    return;
end


%% Assign output argument and exit function.
if nargout ~= 0
   varargout = {pk_pwr_dB, avg_pwr_dB, par_dB};
end


end


