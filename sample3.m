function [R, G] = sample3(I, rows, cols, slices, T, regionWidth, varargin)
% Sample regions from the image at specified locations applying random
% transformations in 3D.
%

V = @validateattributes;

isImage     = @(x)V(x, {'numeric'}, {'3d', 'nonempty'}); % 3D or less
isStruct    = @(x)V(x, {'struct'},  {'vector'});
isPint      = @(x)V(x, {'numeric'}, {'scalar', 'positive', 'integer'});
checkRows   = @(x)V(x, {'numeric'}, {'vector', 'positive', '<=', size(I,1)});
checkCols   = @(x)V(x, {'numeric'}, {'vector', 'positive', '<=', size(I,2), 'size', size(rows)});
checkSlices = @(x)V(x, {'numeric'}, {'vector', 'positive', '<=', size(I,3), 'size', size(rows)});

parser = inputParser();

parser.addRequired('I',             isImage);
parser.addRequired('rows',          checkRows);
parser.addRequired('cols',          checkCols);
parser.addRequired('slices',        checkSlices);
parser.addRequired('T',             isStruct);
parser.addRequired('regionWidth',   isPint);

parser.addParameter('regionHeigth', regionWidth, isPint);
parser.addParameter('regionDepth',  regionWidth, isPint);
parser.addParameter('padValue',     'symmetric');

parser.parse(I, rows, cols, slices, T, regionWidth, varargin{:});

P = parser.Results;

%--------------------------------------------------------------------------

N = length(rows);

imageClass = class(I);

I = double(I);

diagonal = sqrt(regionWidth^2 + P.regionHeigth^2);
translation = max(max(abs(cat(1, T.translation))));
scaling = max(cat(1, T.scaling));
padding = ceil(scaling * (diagonal/2 + translation)); % worst case

I = padarray(I, [1 1 1] * padding, P.padValue);

x = linspace(-regionWidth/2 + 1/2, regionWidth/2-1/2, regionWidth);
y = linspace(-P.regionHeigth/2 + 1/2, P.regionHeigth/2-1/2, P.regionHeigth);
z = linspace(-P.regionDepth/2 + 1/2, P.regionDepth/2-1/2, P.regionDepth);

[X, Y, Z] = meshgrid(x, y, z);

F = griddedInterpolant(I, 'linear', 'none');

R = zeros(regionWidth, P.regionHeigth, P.regionDepth, N, imageClass);

for i_R = N:-1:1
    
    a = T(i_R).xRotation;
    b = T(i_R).yRotation;
    g = T(i_R).zRotation;
    
    % translate (taking into account the padding), scale, reflect and rotate
    U = padding + cols(i_R) + T(i_R).translation(1) + ...
        T(i_R).scaling * ( ...
        T(i_R).xReflection * cos(a) * cos(b) * X + ...
        T(i_R).yReflection * (cos(a) * sin(b) * sin(g) - sin(a) * cos(g)) * Y + ...
        T(i_R).zReflection * (cos(a) * sin(b) * cos(g) + sin(a) * sin(g)) * Z);    
    V = padding + rows(i_R) + T(i_R).translation(2) + ...
        T(i_R).scaling * ( ...
        T(i_R).xReflection * sin(a) * cos(b) * X + ...
        T(i_R).yReflection * (sin(a) * sin(b) * sin(g) + cos(a) * cos(g))* Y + ...
        T(i_R).zReflection * (sin(a) * sin(b) * cos(g) - cos(a) * sin(g))* Z);
    W = padding + slices(i_R) + T(i_R).translation(3) + ...
        T(i_R).scaling * ( ...
        T(i_R).xReflection * -sin(b) * X + ...
        T(i_R).yReflection * cos(b) * sin(g) * Y + ...
        T(i_R).zReflection * cos(b) * cos(g) * Z);
    
    if T(i_R).elasticAlpha ~= 0 && T(i_R).elasticSigma ~= 0     
        warning('Random elastinc deformation not tested');
        
        a = T(i_R).elasticAlpha;
        s = T(i_R).elasticSigma;
        
        du = 2*rand(size(U))-1;
        du = imgaussfilt3(du, s, 'padding', 'symmetric');
        du = du / (max(abs(du(:)))) * a;
        
        dv = 2*rand(size(V))-1;
        dv = imgaussfilt3(dv, s, 'padding', 'symmetric');
        dv = dv / (max(abs(dv(:)))) * a;
        
        dw = 2*rand(size(W))-1;
        dw = imgaussfilt3(dw, s, 'padding', 'symmetric');
        dw = dw / (max(abs(dw(:)))) * a;
        
        U = U + du;
        V = V + dv;        
        W = W + dw;
    end
    
    if nargout(mfilename) == 2
        G(i_R).U = U - padding;
        G(i_R).V = V - padding;
        G(i_R).W = W - padding;
    end
    
    current = T(i_R).intensShift + F(V, U, W);
       
    if T(i_R).contrast ~= 1
        current = sign(current) .* abs(current) .^ T(i_R).contrast;
    end
    
    s = T(i_R).blur;     
    if s > 1/2 % skip small filter widths         
        current = imgaussfilt3(current, s, 'padding', 'symmetric');
    end
    
    if T(i_R).whiteNoise ~= 0
        current = current + T(i_R).whiteNoise * (2*rand(size(current))-1);
    end
    
    R(:,:,:,i_R) = cast(current, imageClass);
    
end

end
