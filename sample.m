function [R, G] = sample(I, rows, cols, T, regionWidth, varargin)
% Sample regions from the image at specified locations applying random
% transformations.
%

V = @validateattributes;

isImage     = @(x)V(x, {'numeric'}, {'3d', 'nonempty'}); % 3D or less
isStruct    = @(x)V(x, {'struct'},  {'vector'});
isPint      = @(x)V(x, {'numeric'}, {'scalar', 'positive', 'integer'});
checkRows   = @(x)V(x, {'numeric'}, {'vector', 'positive', '<=', size(I,1)});
checkCols   = @(x)V(x, {'numeric'}, {'vector', 'positive', '<=', size(I,2), 'size', size(rows)});

parser = inputParser();

parser.addRequired('I',             isImage);
parser.addRequired('rows',          checkRows);
parser.addRequired('cols',          checkCols);
parser.addRequired('T',             isStruct);
parser.addRequired('regionWidth',   isPint);

parser.addParameter('regionHeigth', regionWidth, isPint);
parser.addParameter('padValue',     'symmetric');

parser.parse(I, rows, cols, T, regionWidth, varargin{:});

P = parser.Results;

%--------------------------------------------------------------------------

N = length(rows);
channels = size(I,3);

imageClass = class(I);

I = double(I);

diagonal = sqrt(regionWidth^2 + P.regionHeigth^2);
translation = max(max(abs(cat(1, T.translation))));
scaling = max(cat(1, T.scaling));
padding = ceil(scaling * (diagonal/2 + translation)); % worst case

I = padarray(I, [padding padding], P.padValue);

for i_channel = channels:-1:1
    F{i_channel} = griddedInterpolant(I(:,:,i_channel), 'linear', 'none');
end

x = linspace(-regionWidth/2 + 1/2, regionWidth/2-1/2, regionWidth);
y = linspace(-P.regionHeigth/2 + 1/2, P.regionHeigth/2-1/2, P.regionHeigth);

[X, Y] = meshgrid(x, y);

R = zeros(regionWidth, P.regionHeigth, channels, N, imageClass);

for i_R = N:-1:1
    
    % translate (taking into account the padding), scale, reflect and rotate
    U = padding + cols(i_R) + T(i_R).translation(1) + ...
        T(i_R).scaling * ( ...
        T(i_R).vReflection * cos(T(i_R).rotation) * X + ...
        T(i_R).hReflection * sin(T(i_R).rotation) * Y);    
    V = padding + rows(i_R) + T(i_R).translation(2) + ...
        T(i_R).scaling * ( ...
        T(i_R).vReflection * -sin(T(i_R).rotation) * X + ...
        T(i_R).hReflection * cos(T(i_R).rotation) * Y);
    
    if nargout(mfilename) == 2
        G(i_R).U = U - padding;
        G(i_R).V = V - padding;
    end
    
    current = zeros(regionWidth, P.regionHeigth, channels);
    
    for i_channel = 1:channels
        current(:,:,i_channel) = ...
            T(i_R).channelShift(i_channel) + F{i_channel}(V, U);
    end
        
    if T(i_R).contrast ~= 1
        current = sign(current) .* abs(current) .^ T(i_R).contrast;
    end
    
    s = T(i_R).blur;     
    if s > 1/2 % skip small filter widths         
        w =  2.*round((4*s+1)/2)-1;
        current = imfilter(current, ...
            fspecial('gaussian', [w w], s), 'symmetric');       
    end
    
    if T(i_R).whiteNoise ~= 0
        current = current + T(i_R).whiteNoise * rand(size(current));
    end
    
    R(:,:,:,i_R) = cast(current, imageClass);
    
end

end
