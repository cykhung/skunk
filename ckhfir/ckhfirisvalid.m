function ckhfirisvalid(h)

%%
%       SYNTAX: ckhfirisvalid(h);
%
%  DESCRIPTION: Check if FIR filter structure is valid. If it is not valid, then 
%               this function will crash and generate an error message.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%       OUTPUT: none.


%% Check h.mode.
for n = 1:numel(h)
    if ~ismember(h(n).mode, [1, 0, -1])
        error('Invalid mode.');
    end
end


%% Check h.h and h.idx.
for n = 1:numel(h)
    if isempty(h(n).h)
        error('h.h = [].');
    end
    if ~isempty(h(n).idx) && (length(h(n).h) ~= length(h(n).idx))
        error('length(h.h) ~= length(h.idx).');
    end
end


%% Check h.fs.
for n = 1:numel(h)
    if isempty(h(n).fs)
        error('Sampling rate is not defined.');
    end
end


end

