function T = transform3(N, varargin)
% Generate random image transformation in 3D.
%

V = @validateattributes;

isNni   = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative' 'integer'});
isNnn   = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative'});
isAngle = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative', '<=', pi});
isBool  = @(x, name)V(x, {'logical'}, {'scalar'});

parser = inputParser();

parser.addRequired('N', isNni);

parser.addParameter('translation',      0,     isNnn);
parser.addParameter('xRotation',        0,     isAngle);
parser.addParameter('yRotation',        0,     isAngle);
parser.addParameter('zRotation',        0,     isAngle);
parser.addParameter('scaling',          0,     isNnn);
parser.addParameter('xReflection',      false, isBool);
parser.addParameter('yReflection',      false, isBool);
parser.addParameter('zReflection',      false, isBool);
parser.addParameter('intensShift',      0,     isNnn);
parser.addParameter('contrast',         0,     isNnn);
parser.addParameter('blur',             0,     isNnn);
parser.addParameter('whiteNoise',       0,     isNnn);
parser.addParameter('elasticAlpha',     0,     isNnn);
parser.addParameter('elasticSigma',     0,     isNnn);

parser.parse(N, varargin{:});

P = parser.Results;

%--------------------------------------------------------------------------

for i_T = N:-1:1    
    T(i_T).translation  = randRange(P.translation * [-1 1], [1 3]);        
    T(i_T).xRotation     = randRange(P.xRotation * [-1 1]); 
    T(i_T).yRotation     = randRange(P.yRotation * [-1 1]); 
    T(i_T).zRotation     = randRange(P.zRotation * [-1 1]); 
    T(i_T).scaling      = randRange(P.scaling * [-1 1] + 1);    
    T(i_T).xReflection  = 1 - 2 * randBin() * P.xReflection;
    T(i_T).yReflection  = 1 - 2 * randBin() * P.yReflection;    
    T(i_T).zReflection  = 1 - 2 * randBin() * P.zReflection;    
    T(i_T).intensShift  = randRange(P.intensShift * [-1 1]);    
    T(i_T).contrast     = randRange(P.contrast * [-1 1] + 1);   
    T(i_T).blur         = randRange([0 P.blur]);
    T(i_T).whiteNoise   = randRange([0 P.whiteNoise]);
    T(i_T).elasticAlpha = P.elasticAlpha;
    T(i_T).elasticSigma = P.elasticSigma;    
end

end

% Helpers

function rnd = randRange(rng, siz)
% Random numbers uniformly distributed in a specified range.
%

if ~exist('siz', 'var') || isempty(siz)
    siz = 1;
end

%--------------------------------------------------------------------------

rnd = rand(siz)*diff(rng) + rng(1);

end

function rnd = randBin(siz)
% Random binary number.
%

if ~exist('siz', 'var') || isempty(siz)
    siz = 1;
end

%--------------------------------------------------------------------------

rnd = rand(siz) > 1/2;

end
