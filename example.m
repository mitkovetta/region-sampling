function example(visualize, saveRegions)
% Example of sampling random regions from and image.
%

if ~exist('visualize', 'var') || isempty(visualize)
    visualize = true;
end

if ~exist('saveRegions', 'var') || isempty(saveRegions)
    saveRegions = false;
end

GRID = [3 4];
REGION_SIZE = 32;
I = imread('peppers.png');

%--------------------------------------------------------------------------

N = prod(GRID);
rows = randi(size(I,1), N, 1);
cols = randi(size(I,2), N, 1);

disp('* Generating random transformations...');
tic;
T = transform(N, size(I,3), ...
    'translation',  0, ...
    'rotation',     pi/2, ...
    'scaling',      0.2, ...
    'hReflection',  true, ...
    'vReflection',  true, ...
    'channelShift', 10, ...
    'contrast',     0.05, ...
    'blur',         5, ...
    'whiteNoise',   20);
toc;

disp('* Sampling image regions...');
tic;
[R, G] = sample(I, rows, cols, T, REGION_SIZE);
toc;

if visualize
    
    figure;
    subplot(1, 2, 1);
    imshow(I, []);
    hold on;
    plotT(rows, cols, G);
    
    subplot(1, 2, 2);
    montage(R, 'Size', GRID);
    
end

if saveRegions
   
    mkdir('regions');
    
    disp('* Writing image regions to disk...');
    tic;
    saveas(R, 'regions', 'list.txt', ...
        'filetype', 'jpg', ...
        'quality',  75, ...
        'suffix',   'example', ...
        'labels',   [rows cols])
    toc;
end

disp('* Done.');

end

% Helpers

function plotT(rows, cols, G)


plot(cols, rows, 'o', ...
    'MarkerFaceColor', [1 0.2 0.2], ...
    'MarkerEdgeColor', [0 0 0], ...
    'LineWidth', 2);

for i_G = 1:length(G)
    
    U = G(i_G).U;
    V = G(i_G).V;
    
    x = [U(1,1) U(1, end) U(end, end) U(end, 1) U(1,1)];
    y = [V(1,1) V(1, end) V(end, end) V(end, 1) V(1,1)];
    
    plot(x, y, ...
        'Color', [1 0.8 0.2], ...
        'LineWidth', 1.5);
    plot(x(1), y(1), '^', ...
        'MarkerFaceColor', [0.2 1 0.2], ...
        'MarkerEdgeColor', [0 0 0], ...
        'LineWidth', 2);
    plot(x(3), y(3), 'v', ...
        'MarkerFaceColor', [0.2 0.2 1], ...
        'MarkerEdgeColor', [0 0 0], ...
        'LineWidth', 2);
    plot((x(1)+x(3))/2, (y(1)+y(3))/2, 'o', ...
        'MarkerFaceColor', [1 0.8 0.2], ...
        'MarkerEdgeColor', [0 0 0], ...
        'LineWidth', 2);
    text((x(1)+x(3))/2, (y(1)+y(3))/2, num2str(i_G), ...
        'Color', [1 0.8 0.2], ...
        'FontSize', 14);
    
end

end
