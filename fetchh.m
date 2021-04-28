function fetchh(varargin)

%%
%       SYNTAX: fetchh lte
%               fetchh v:\khung\backup\History.xml lte 

if nargin == 1
    filename    = fullfile(prefdir, 'History.xml');
    includetext = varargin{1};
else
    filename    = varargin{1};
    includetext = varargin{2};
end
searchcore(filename, includetext);

end
