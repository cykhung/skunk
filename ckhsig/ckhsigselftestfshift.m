function status = ckhsigselftestfshift

%%
%       SYNTAX: status = ckhsigselftestfshift;
%
%  DESCRIPTION: Test ckhsigfshift.
%
%        INPUT: none.
%
%       OUTPUT: - status (real int)
%                   Status. Valid values are:
%                       0 - Fail.
%                       1 - Pass.


%% Initialize status.
status = 1;


%% Test: x = empty signal structure. 
x = ckhsig;
fc = 0.2;
[y, actual_fc] = ckhsigfshift(x, fc);
if ~isempty(y.s) || ~strcmp(y.type, 'segment') || (y.fs ~= 1) || ...
        ~isempty(y.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = segment signal structure. fc = 0.2.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
fc = 0.2;
[y, actual_fc] = ckhsigfshift(x, fc);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = segment signal structure. fc = 0.2. circ_lo = 0.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
fc = 0.2;
[y, actual_fc] = ckhsigfshift(x, fc, 0);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = segment signal structure. fc = 0.2. circ_lo = 1.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
fc = 0.2;
[y, actual_fc] = ckhsigfshift(x, fc, 1);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = streaming signal structure. fc = 0.2.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'streaming';
fc = -0.13;
% [y, actual_fc] = ckhsigfshift(x, fc);
% y = get(y);
% ideal_s = v .* exp(1i*2*pi*fc*[idx(1):idx(2)]);
% if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'streaming') || ...
%         (y.fs ~= 1) || any(y.idx ~= idx) || (actual_fc ~= fc)
%     status = 0;
% end
try                                     %#ok<TRYNC>
    ckhsigfshift(x, fc);
    status = 0;
end


%% Test: x = streaming signal structure. fc = 0.2. circ_lo = 0.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'streaming';
fc = -0.13;
% [y, actual_fc] = ckhsigfshift(x, fc, 0);
% y = get(y);
% ideal_s = v .* exp(1i*2*pi*fc*[idx(1):idx(2)]);
% if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'streaming') || ...
%         (y.fs ~= 1) || any(y.idx ~= idx) || (actual_fc ~= fc)
%     status = 0;
% end
try                                     %#ok<TRYNC>
    ckhsigfshift(x, fc);
    status = 0;
end


%% Test: x = streaming signal structure. fc = 0.2. circ_lo = 1.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'streaming';
fc = -0.13;
% [y, actual_fc] = ckhsigfshift(x, fc, 0);
% y = get(y);
% ideal_s = v .* exp(1i*2*pi*fc*[idx(1):idx(2)]);
% if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'streaming') || ...
%         (y.fs ~= 1) || any(y.idx ~= idx) || (actual_fc ~= fc)
%     status = 0;
% end
try                                     %#ok<TRYNC>
    ckhsigfshift(x, fc);
    status = 0;
end


%% Test: x = circularly continuous signal structure. LO is circularly continuous.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'circular';
fc = 0.5;
[y, actual_fc] = ckhsigfshift(x, fc);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = circularly continuous signal. LO is not circularly continuous.
lastwarn('');
orig_warn_state = warning('query', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:LO');
x = ckhsig;
x.s = 1:3;
x.idx = [0 2];
x.type = 'circular';
fc = 0.25;
[y, actual_fc] = ckhsigfshift(x, fc);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
str = ['LO is not circularly continuous. ', ...
        'Output signal type is set to ''segment''.'];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: x = circularly continuous signal structure. LO is circularly continuous.
%%       circ_lo = 0.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'circular';
fc = 0.5;
[y, actual_fc] = ckhsigfshift(x, fc, 0);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = circularly continuous signal structure. LO is circularly continuous.
%%       circ_lo = 1.
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [-2 3];
x.type = 'circular';
fc = 0.5;
[y, actual_fc] = ckhsigfshift(x, fc, 1);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc)
    status = 0;
end


%% Test: x = circularly continuous signal structure. LO is not circularly 
%%       continuous. circ_lo = 0.
lastwarn('');
orig_warn_state = warning('query', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:LO');
x = ckhsig;
x.s = 1:3;
x.idx = [0 2];
x.type = 'circular';
fc = 0.25;
[y, actual_fc] = ckhsigfshift(x, fc, 0);
ideal_s = x.s .* exp(1i*2*pi*fc*(x.idx(1):x.idx(2)));
str = ['LO is not circularly continuous. ', ...
        'Output signal type is set to ''segment''.'];
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'segment') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= fc) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: x = circularly continuous signal structure. LO is circularly continuous.
%%       circ_lo = 1.
lastwarn('');
orig_warn_state = warning('query', 'ckhsigfshift:new_fc');
warning('off', 'ckhsigfshift:new_fc');
x = ckhsig;
x.s = 1:3;
x.idx = [0 2];
x.type = 'circular';
fc = 0.25;
[y, actual_fc] = ckhsigfshift(x, fc, 1);
ideal_s = (1:3) .* exp(1i*2*pi*(1/3)*(0:2));
str = sprintf(['fc is changed from %f to %f to force LO to be ', ...
            'circularly continuous.'], fc, 1/3);
if (max(abs(y.s - ideal_s)) > 0) || ~strcmp(y.type, 'circular') || ...
        (y.fs ~= 1) || any(y.idx ~= x.idx) || (actual_fc ~= 1/3) || ...
        ~strcmp(lastwarn, str)
    status = 0;
end
warning(orig_warn_state);


%% Test: x = 2x3 array of nonempty signal structure. fc = 0.2.
x = repmat(ckhsig, 2, 3);
for n = 1:6
    x(n).s   = ((10:15) + 1i*(-4:1)) * n;
    x(n).idx = [-2 3] + n;
end
for n = 1:3
    x(2,n).type = 'segment';
end
[y, actual_fc] = ckhsigfshift(x, 0.2);
if any(size(y) ~= [2 3])
    status = 0;
end
for n = 1:3
    if ~strcmp(y(1,n).type, 'segment')
        status = 0;
    end
end
for n = 1:3
    if ~strcmp(y(2,n).type, 'segment')
        status = 0;
    end
end
for n = 1:6
    ideal_s = x(n).s .* exp(1i*2*pi*0.2*(x(n).idx(1):x(n).idx(2)));
    if (max(abs(y(n).s - ideal_s)) > 0) || (actual_fc(n) ~= 0.2)
        status = 0;
    end
end


%% Test: x = circularly continuous signal structure. 
%%       fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78].
lastwarn('');
orig_warn_state = warning('query', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:LO');
x = ckhsig;
x.s = (10:15) + 1i*(-4:1);
x.idx = [1 6];
x.type = 'circular';
fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78];
[y, actual_fc] = ckhsigfshift(x, fc);
if any(size(y) ~= [2 3])
    status = 0;
end
if any(size(actual_fc) ~= [2 3])
    status = 0;
end
str = ['LO is not circularly continuous. ', ...
        'Output signal type is set to ''segment''.'];
if ~strcmp(lastwarn, str)
    status = 0;
end
for m = 1:2
    for n = 1:3
        ideal_s = x.s .* exp(1i*2*pi*fc(m,n)*(x.idx(1):x.idx(2)));
        if (max(abs(y(m,n).s - ideal_s)) > 0) || (y(m,n).fs ~= 1) || ...
                any(y(m,n).idx ~= x.idx) || (actual_fc(m,n) ~= fc(m,n))
            status = 0;
        end
        if (m == 1) && (n == 2)
            if ~strcmp(y(m,n).type, 'circular')
                status = 0;
            end
        else
            if ~strcmp(y(m,n).type, 'segment')
                status = 0;
            end
        end        
    end
end
warning(orig_warn_state);


%% Test: x = 2x3 array of nonempty signal structure. 
%%       fc = [0.5 0.4 -0.3; 0.13 0.56 -0.78].
x = repmat(ckhsig, 2, 3);
for n = 1:6
    x(n).s = ((10:15) + 1i*(-4:1)) * n;
    x(n).idx = [-2 3] + n;
end
x(1).type = 'circular';
for n = 4:6
    x(n).type = 'segment';
end
fc = [0.5 0.4 -0.3; 0.13 0.56 -0.78];
[y, actual_fc] = ckhsigfshift(x, fc);
if any(size(y) ~= [2 3])
    status = 0;
end
if any(size(actual_fc) ~= [2 3])
    status = 0;
end
y = y(:);
if ~strcmp(y(1).type, 'circular')
    status = 0;
end
for n = 2:3
    if ~strcmp(y(n).type, 'segment')
        status = 0;
    end
end
for n = 4:6
    if ~strcmp(y(n).type, 'segment')
        status = 0;
    end
end
fc = fc(:);
actual_fc = actual_fc(:);
x = x(:);
for n = 1:6
    ideal_s = x(n).s .* exp(1i*2*pi*fc(n)*(x(n).idx(1):x(n).idx(2)));
    if (max(abs(y(n).s - ideal_s)) > 0) || ...
            (y(n).fs ~= 1) || ...
            any(y(n).idx ~= x(n).idx) || ...
            (actual_fc(n) ~= fc(n))
        status = 0;
    end
end


%% Test: x = circularly continuous signal structure. 
%%       fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78].
%%       circ_lo = [1 0 0; 0 1 1];
lastwarn('');
orig_warn_state_1 = warning('query', 'ckhsigfshift:LO');
orig_warn_state_2 = warning('query', 'ckhsigfshift:new_fc');
warning('off', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:new_fc');
x = ckhsig((10:15) + 1i*(-4:1), 1, 'circular', [1 6]);
fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78];
circ_lo = [1 0 0; 0 1 1];
[y, actual_fc] = ckhsigfshift(x, fc, circ_lo);
if any(size(y) ~= [2 3])
    status = 0;
end
if any(size(actual_fc) ~= [2 3])
    status = 0;
end
y = reshape(y, [2 3]);
fc1 = [1/6 0.5 -0.3; 0.13 0.5 -5/6];
for m = 1:2
    for n = 1:3
        ideal_s = x.s .* exp(1i*2*pi*actual_fc(m,n)*(x.idx(1):x.idx(2)));
        if (max(abs(y(m,n).s - ideal_s)) > 0) || (y(m,n).fs ~= 1) || ...
                any(y(m,n).idx ~= x.idx) || (actual_fc(m,n) ~= fc1(m,n))
            status = 0;
        end
    end
end
type = cell(2,3);
for n = 1:6
    type{n} = y(n).type;
end
actual_type = {'circular', 'circular', 'segment'; 'segment', 'circular', ...
        'circular'};
if any(strcmp(type, actual_type) == 0)
    status = 0;
end
warning(orig_warn_state_1);
warning(orig_warn_state_2);


%% Test: x = circularly continuous signal structure. 
%%       fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78].
%%       circ_lo = [1 0 NaN; 0 1 1];
lastwarn('');
orig_warn_state_1 = warning('query', 'ckhsigfshift:LO');
orig_warn_state_2 = warning('query', 'ckhsigfshift:new_fc');
warning('off', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:new_fc');
x = ckhsig((10:15) + 1i*(-4:1), 1, 'circular', [1 6]);
fc = [0.1 0.5 -0.3; 0.13 0.56 -0.78];
circ_lo = [1 0 NaN; 0 1 1];
[y, actual_fc] = ckhsigfshift(x, fc, circ_lo);
if any(size(y) ~= [2 3])
    status = 0;
end
if any(size(actual_fc) ~= [2 3])
    status = 0;
end
fc1 = [1/6 0.5 -0.3; 0.13 0.5 -5/6];
for m = 1:2
    for n = 1:3
        ideal_s = x.s .* exp(1i*2*pi*actual_fc(m,n)*(x.idx(1):x.idx(2)));
        if (max(abs(y(m,n).s - ideal_s)) > 0) || (y(m,n).fs ~= 1) || ...
                any(y(m,n).idx ~= x.idx) || (actual_fc(m,n) ~= fc1(m,n))
            status = 0;
        end
    end
end
type = cell(2,3);
for n = 1:6
    type{n} = y(n).type;
end
actual_type = {'circular', 'circular', 'segment'; 'segment', 'circular', ...
        'circular'};
if any(strcmp(type, actual_type) == 0)
    status = 0;
end
warning(orig_warn_state_1);
warning(orig_warn_state_2);


%% Test: x = nonempty signal structure. fc = 1.001.
x = ckhsig;
x.s = [2 3];
try                                         %#ok<TRYNC>
    ckhsigfshift(x, 1.001);
    status = 0;
end


%% Test: x = nonempty signal structure. fc = 0.4. circ_lo = 3.
x = ckhsig;
x.s = [2 3];
try                                         %#ok<TRYNC>
    ckhsigfshift(x, 0.4, 3);
    status = 0;
end


%% Test: x = 2x3 cell array of segment signal structures. fc = [0.2 0.3].
x = ckhsig;
x.s = [2 3];
x = repmat(x, 2, 3);
try                                         %#ok<TRYNC>
    ckhsigfshift(x, [0.2 0.3]);
    status = 0;
end


%% Test: x = 2x3 cell array of segment signal structures. fc = 0.2. 
%%       circ_lo = [1 0].
x = ckhsig;
x.s = [2 3];
x = repmat(x, 2, 3);
try                                         %#ok<TRYNC>
    ckhsigfshift(x, 0.2, [1 0]);
    status = 0;
end


%% Test: x = 1 segment signal structure. fc = 2x3 array. circ_lo = [1 0].
x = ckhsig;
x.s = [2 3];
try                                         %#ok<TRYNC>
    ckhsigfshift(x, repmat(0.2,2,3), [1 0]);
    status = 0;
end


%% Test: x = circularly continuous signal. LO is not circularly continuous.
lastwarn('');
orig_warn_state = warning('query', 'ckhsigfshift:LO');
warning('off', 'ckhsigfshift:new_fc');
x = ckhsig(ones(1,1e5), 100, 'circular');
x = ckhsigfshift(x, 0.1251, 1);
if ~isempty(lastwarn)
    status = 0;
end
warning(orig_warn_state);


%% Exit function.
end

