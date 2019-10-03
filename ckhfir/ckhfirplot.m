function ckhfirplot(varargin)

%%
%       SYNTAX: ckhfirplot(h);
%               ckhfirplot(h, linetype);
%               ckhfirplot(h, linetype, xunit);
% 
%  DESCRIPTION: Time domain plot.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%               - linetype (char or 1-D row/col cell array of char)
%                   Line types. Optional. Set to '' or {} for default values.
%                   Default = {'r', 'b', 'k', 'c', 'm', 'y', 'g'}. If number of
%                   line types < numel(h), then line types will be reused.
%
%               - xunit (char)
%                   Unit of the x-axis (i.e. time). Optional. Valid units are:
%                   'idx', 's', 'ms', 'us', 'ns'. Default = 'idx'. Select 'idx'
%                   for plotting against sample index. Note that a warning
%                   message will be generated if 'idx' is selected and input
%                   input FIR filter structures have different sampling rates.
%
%       OUTPUT: none.


%% Assign input arguments.
options          = [];
options.linetype = '';
options.xunit    = 'idx';
switch nargin
case 1
    h                = varargin{1};
case 2
    h                = varargin{1};
    options.linetype = varargin{2};
case 3
    h                = varargin{1};
    options.linetype = varargin{2};
    options.xunit    = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end


%% Check h.
ckhfirisvalid(h);


%% Convert all FIR filters to have full impulse responses.
h = ckhfirfull(h);


%% Convert all full FIR filter structures to signal structures.
x = repmat(ckhsig, size(h));
for n = 1:numel(x)
    x(n).s   = h(n).h;
    x(n).idx = [h(n).idx(1) h(n).idx(end)];
    x(n).fs  = h(n).fs;
end


%% Do plotting.
ckhsigplot(x, options.linetype, options.xunit);


end

