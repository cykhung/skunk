function w = getkaiser(beta, N)

%%
%       SYNTAX: w = getkaiser(beta, N);
% 
%  DESCRIPTION: Return Kaiser window for different length and different beta.
%
%        INPUT: - beta (real double)
%                   Kaiser window parameter.
%
%               - N (real double)
%                   Window length.
%
%       OUTPUT: - w (1-D row array of real double)
%                   Kaiser window.
%
%    $Revision: 7250 $
%
%        $Date: 2014-10-31 17:18:04 -0400 (Fri, 31 Oct 2014) $
%
%      $Author: khung $

%% Calculate kaiser window.
M     = N - 1;
alpha = M/2;
n     = 0 : M;
nu    = 0;
num   = besseli(nu, beta*sqrt(1 - (((n - alpha)/alpha) .^ 2)));
den   = besseli(nu, beta);
w     = num / den;

end
