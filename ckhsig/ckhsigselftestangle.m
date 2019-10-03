function status = ckhsigselftestangle

%%
%       SYNTAX: status = ckhsigselftestangle;
%
%  DESCRIPTION: Test ckhsigangle.
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
y = repmat(ckhsig, 1, 4);
y(1) = ckhsigangle(x, 'deg');
y(2) = ckhsigangle(x, 'rad');
y(3) = ckhsigangle(x, 'deg', 'wrap');
y(4) = ckhsigangle(x, 'rad', 'wrap');
ideal_y = x;
ideal_y.s = [];
ideal_y = repmat(ideal_y, 1, 4);
if ~isequal(ideal_y, y)
    status = 0;
end


%% Test: x = one signal structure. degree. wrap.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
y = ckhsigangle(x, 'deg', 'wrap');
ideal_s = angle(x.s) / pi * 180;
if max(abs(y.s - ideal_s)) > 0
    status = 0;
end


%% Test: x = one signal structure. degree. unwrap.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
y = ckhsigangle(x, 'deg', 'unwrap');
ideal_s = unwrap(angle(x.s)) / pi * 180;
if max(abs(y.s - ideal_s)) > 0
    status = 0;
end


%% Test: x = one signal structure. radian. wrap.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
y = ckhsigangle(x, 'rad', 'wrap');
ideal_s = angle(x.s);
if max(abs(y.s - ideal_s)) > 0
    status = 0;
end


%% Test: x = one signal structure. radian. unwrap.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
y = ckhsigangle(x, 'rad', 'unwrap');
ideal_s = unwrap(angle(x.s));
if max(abs(y.s - ideal_s)) > 0
    status = 0;
end


%% Test: x = 2x2 array of signal structures. One of the signal structure is 
%%       empty.
x = repmat(ckhsig, 2, 2);
x(1).s = (10:15) + 1i*(-4:1);
x(1).s = (-10:15);
x(1).s = 1i*(-4:1);
y = ckhsigangle(x, 'deg', 'unwrap');
if any(size(y) ~= [2 2])
    status = 0;
end
for n = 1:3
    ideal_s = unwrap(angle(x(n).s)) / pi * 180;
    if max(abs(y(n).s - ideal_s)) > 0
        status = 0;
    end
end


%% Exit function.
end

