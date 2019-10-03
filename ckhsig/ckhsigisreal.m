function tf = ckhsigisreal(x)

%%
%       SYNTAX: tf = ckhsigisreal(x);
% 
%  DESCRIPTION: Test if the imaginary part of each signal sample is equal to 0.
%
%               In the special case where x.s = [], this function will return 1.
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - tf (N-D array of real double)
%                   True/false flag(s). Valid values are:
%                       1 - All samples are purely real, i.e. imaginary part is
%                           0.
%                       0 - Samples are complex-valued.


%% Check if imaginary part is 0?
% ckhsigisvalid(x);
tf = zeros(size(x));
for n = 1:numel(x)
    if all(imag(x(n).s) == 0)
        tf(n) = 1;
    end
end


end
