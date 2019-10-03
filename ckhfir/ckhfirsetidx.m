function h = ckhfirsetidx(h)

%%
%       SYNTAX: h = ckhfirsetidx(h);
%
%  DESCRIPTION: Set h.idx.
%
%        INPUT: - h (N-D array of struct)
%                   FIR filter structure(s).
%
%       OUTPUT: - h (N-D array of struct)
%                   FIR filter structure(s).


%% Set h.idx.
for n = 1:numel(h)
    if isempty(h(n).idx)
        h(n).idx = (1:length(h(n).h)) - ceil(length(h(n).h)/2);
    end
end


end