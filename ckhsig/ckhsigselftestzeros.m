function status = ckhsigselftestzeros

%%
%       SYNTAX: status = ckhsigselftestzeros;
%
%  DESCRIPTION: Test ckhsigzeros.
%
%        INPUT: none.
%
%       OUTPUT: - status (real double)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal structure. 
x = ckhsig;
y = ckhsigzeros(x);
ideal_y = x;
ideal_y.s = [];
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x = 2x2 cell array of signal structures. One of the signal objects is 
%%       empty.
x = repmat(ckhsig, 2, 2);
x(1).s = (10:15) + 1i*(-4:1);
x(2).s = (-10:15);
x(3).s = 1i*(-4:1);
y = ckhsigzeros(x);
if any(size(y) ~= [2 2])
    status = 0;
end
for n = 1:3
    ideal_s = zeros(size(x(n).s));
    if max(abs(y(n).s - ideal_s)) > 0
        status = 0;
    end
end


%% Exit function.
end

