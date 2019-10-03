function tf = ckhsigisempty(x)

%%
%       SYNTAX: tf = ckhsigisempty(x);
% 
%  DESCRIPTION: Test if x.s = [].
%
%        INPUT: - x (N-D array of struct)
%                   Signal structure(s).
%
%       OUTPUT: - tf (N-D array of real double)
%                   True/false flag(s). Valid values are:
%                       1 - x.s = [].
%                       0 - x.s ~= [].


%% Check if x.s = [].
% ckhsigisvalid(x);
tf = zeros(size(x));
for n = 1:numel(x)
    if isempty(x(n).s)
        tf(n) = 1;
    end
end


end
