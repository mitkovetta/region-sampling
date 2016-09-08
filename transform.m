function T = transform(N, channels, varargin)
% Generate random image transformation.
%

V = @validateattributes;

isNni   = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative' 'integer'});
isNnn   = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative'});
isAngle = @(x, name)V(x, {'numeric'}, {'scalar', 'nonnegative', '<=', pi});
isBool  = @(x, name)V(x, {'logical'}, {'scalar'});

parser = inputParser();

parser.addRequired('N',         isNni);
parser.addRequired('channels',  isNni);

parser.addParameter('translation',      0,     isNnn);
parser.addParameter('rotation',         0,     isAngle);
parser.addParameter('scaling',          0,     isNnn);
parser.addParameter('hReflection',      false, isBool);
parser.addParameter('vReflection',      false, isBool);
parser.addParameter('channelShift',     0,     isNnn);
parser.addParameter('intensShift',      0,     isNnn);
parser.addParameter('contrast',         0,     isNnn);
parser.addParameter('blur',             0,     isNnn);
parser.addParameter('whiteNoise',       0,     isNnn);
parser.addParameter('elasticAlpha',     0,     isNnn);
parser.addParameter('elasticSigma',     0,     isNnn);

parser.parse(N, channels, varargin{:});

P = parser.Results;

%--------------------------------------------------------------------------

for i_T = N:-1:1    
    T(i_T).translation  = randRange(P.translation * [-1 1], [1 2]);        
    T(i_T).rotation     = randRange(P.rotation * [-1 1]); 
    T(i_T).scaling      = randRange(P.scaling * [-1 1] + 1);    
    T(i_T).hReflection  = 1 - 2 * randBin() * P.hReflection;
    T(i_T).vReflection  = 1 - 2 * randBin() * P.vReflection;
    T(i_T).channelShift = randRange(P.channelShift * [-1 1], [1 channels]);    
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
