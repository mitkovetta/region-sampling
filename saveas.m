function saveas(R, saveDir, listFile, varargin)
% Save extracted regions on disk as image files.
%

V = @validateattributes;

isString        = @(x)V(x, {'char'},	{'vector'});
checkType       = @(x)(any(validatestring(x, {'jpg', 'jpeg', 'tif', 'png', 'mat'})));
checkQuality    = @(x)V(x, {'numeric'}, {'scalar', 'integer', 'positive', '<=', 100});
checkLabels 	= @(x)V(x, {'numeric'}, {'2d', 'nonempty'});

parser = inputParser();

parser.addParameter('filetype',         'jpg',  checkType);
parser.addParameter('quality',          [],     checkQuality);
parser.addParameter('suffix',           '',     isString);
parser.addParameter('labels',           [],     checkLabels);
parser.addParameter('filenameFormat',   [],     isString);
parser.addParameter('labelsFormat',     [],     isString);

parser.parse(varargin{:});

P = parser.Results;

%--------------------------------------------------------------------------

N = size(R, 4);


fid = fopen(listFile, 'a');

if fid == -1
    error('Could not open list file for writing.');
end

if ~isempty(P.suffix)
    P.suffix = ['_' P.suffix];
end

if isempty(P.filenameFormat)
    filenameWidth = length(num2str(N));
    P.filenameFormat = ['%0' num2str(filenameWidth) 'd'];
end
    
if ~isempty(P.labels)
    if isempty(P.labelsFormat)
        labelsWidth = length(num2str(max(P.labels(:))));
        P.labelsFormat = ['%' num2str(labelsWidth) 'd'];
    end
end

for i_R = 1:N
    
    currentPath = fullfile(saveDir, ...
        [num2str(i_R, P.filenameFormat) P.suffix '.' P.filetype]);
    
    if ismember(P.filetype, {'jpg', 'jpeg'})
        imwrite(R(:,:,:,i_R), currentPath, 'Quality', P.quality);
    elseif ismember(P.filetype, {'mat'})
        data__ = R(:,:,:,i_R); %#ok<NASGU>
        save(currentPath, 'data__');
    else
        imwrite(R(:,:,:,i_R), currentPath);
    end
    
    fprintf(fid, currentPath);
    
    if ~isempty(P.labels)
        if size(P.labels, 1) > 1
            for k = 1:size(P.labels,2)
                fprintf(fid, [' ' P.labelsFormat], P.labels(i_R, k));
            end
        else % one set of labels for all files
            for k = 1:length(P.labels)
                fprintf(fid, [' ' P.labelsFormat], P.labels(k));
            end
        end
        
    end
    
    fprintf(fid, '\n');
    
end

fclose(fid);

end
