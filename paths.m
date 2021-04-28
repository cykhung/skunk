function p = paths

%% Get MATLAB path.
p = path;
p = strsplit(p, ';')';

%% Filter out matlabroot.
mask    = contains(p, matlabroot);
p(mask) = [];

%% Filter out hardware support package root.
h = matlabshared.supportpkg.getSupportPackageRoot;
if ~isempty(h)
    mask    = contains(p, h, 'IgnoreCase', true);
    p(mask) = [];
end

%% Turn p into categorical.
p = categorical(p);

end

