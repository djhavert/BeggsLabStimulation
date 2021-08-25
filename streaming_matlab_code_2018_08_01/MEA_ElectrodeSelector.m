% MEA Electrode Selector
% Katy Hagen
% 10/2/2020

% Inputs:
    %Corners: array of 4 512-MEA indices
    %fig: figure number to plot selected indices in, or 0 for no figure
% Outputs:
    %Indices: array of all 512-MEA indices within a quadrilateral formed by
    %         Corners
    %Figure: the figure produced has blue circles for the electrode array
    %         corners, red dots for all selected electrodes, and black for
    %         all other electrodes (no plot if fig=0 input)
    
% Warnings:
    % Indices in Corners must be between 1 and 512.
    % Do not input repeated indices in Corners.
    % This program is designed to select indices forming a convex
    % quadrilateral. Concave shapes or narrow shapes with many points in a
    % line may cause it to fail.
    % In case of repeated indices or failure, the bounds are ignored and it
    % makes the smallest possible rectangle around them.
    
% Testing Output:
    % Run the following in the Command Window to test 
    % MEA_ElectrodeSelector([randi(512,1), randi(512,1), randi(512,1), randi(512,1)], 1);

function [Indices] = MEA_ElectrodeSelector(Corners, fig)
%% MEA Shape
% MEA Indices are manually coded. ME1 through ME8 represent the eight
% sections of the 512-MEA. Every other row of the MEA is offset, but here
% they are treated as being perfectly aligned and creating a square
% lattice.

ME1 = fliplr([1:8:64; 5:8:64; 2:8:64; 6:8:64; 3:8:64; 7:8:64; 4:8:64; 8:8:64]);
ME2 = ME1+64;
ME3 = flipud(reshape(129:192,[8,8])');
ME4 = flipud(reshape(193:256,[8,8])');
ME5 = fliplr(ME1+256);
ME6 = ME5+64;
ME7 = reshape(385:448,[8,8])';
ME8 = reshape(449:512,[8,8])';
MEA = [ME4 ME5 ME6 ME7;ME3 ME2 ME1 ME8];

%% Find Corners
% The indices of Corners are located in Euclidean space. This space will be
% used to delete any unwanted indices in later parts of the program.

%Find coordinates for Corners
Corn = Corners; %copy Corners
y = zeros(1,length(Corners)); %Initialize
x = zeros(1,length(Corners)); %Initialize
for i=1:length(Corners) %find coordinates of corners
    [yi,xi] = find(MEA==Corners(i));
    y(i) = yi;
    x(i) = xi;
end %end for i

%% Check for Repeated Indices
% The program will fail if any indices are repeated. By default, it creates
% the smallest possible rectangles around the points, plots them, and
% terminates without running the rest of the program.

if length(unique(Corners))<4
    disp('Error in MEA_ElectrodeSelector: Repeated corner indices.')
    disp('Creating rectangle around boundaries.')
    X = min(y):max(y); %all possible x indices
    Y = min(x):max(x); %all possible y indices
    Indices = reshape(MEA(X,Y),[numel(MEA(X,Y)),1]); %all MEA indices
    yI = zeros(1,length(Indices)); %initialize
    xI = zeros(1,length(Indices)); %initialize
    for i=1:length(Indices) %find coordinates of Indices
        [yi,xi] = find(MEA==Indices(i));
        yI(i) = yi;
        xI(i) = xi;
    end
    % Plot
    if fig~=0 %if plotting
        figure(fig)
        [y0, x0] = find(MEA);
        figure(1)
        hold off
        scatter(x0,-y0,'k.')
        hold on
        scatter(x,-y,'bo')
        scatter(xI,-yI, 'r.')
        xlim([0 33])
        ylim([-17 0])
    end
    return %terminate program
end

%% Sort Corners
% To determine on which sides of each element of Corners must be defined as
% an upper or lower corner and a left or right corner. These are called UL,
% UR, LL, and LR. Without this discrimination, indices are not kept on the
% correct side of the bounds. A series of simple rules is applied to select
% which corner is which. An incorrect assignment of corners may cause
% problems later on, resulting in program failure.
% Note that the y-axis gets flipped during plotting, so Upper and Lower
% seem backwards of what they intuitively are in this section.

coord = [x;y];
xs = sort(coord(1,:));
ys = sort(coord(2,:));

% Define Upper Left
xx = find(coord(1,:)==xs(1)); %smallest x indices
if length(xx)>1 %if multiple equally small x
    index = xx(coord(2,xx)==max(coord(2,xx))); %determine index of highest y
    LL = Corn(index); %highest y is Lower Left
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
else %one smallest x
    xx = [xx find(coord(1,:)==xs(2))]; %add next smallest x
    index = xx(coord(2,xx)==max(coord(2,xx))); %determine index of highest y 
    if length(index)>1 %if too many values selected
        index = index(1);
    end
    LL = Corn(index); %highest y is Lower Left
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
end

xs = sort(coord(1,:));
ys = sort(coord(2,:));

% Define Lower Right
xx = find(coord(1,:)==xs(3)); %largest x indices
if length(xx)>1 %if multiple equally large x
    index = xx(coord(2,xx)==max(coord(2,xx))); %determine index of highest y
    LR = Corn(index); %highest y is Lower Right
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
else %one largest x
    xx = [xx find(coord(1,:)==xs(2))]; %add next largest x
    index = xx(coord(2,xx)==max(coord(2,xx))); %determine index of highest y 
    if length(index)>1 %if too many values selected
        index = index(1);
    end
    LR = Corn(index); %highest y is Lower Right
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
end

xs = sort(coord(1,:));
ys = sort(coord(2,:));

% Determine Upper Left
xx = min(xs); %find lowest x
if length(xx)>1 %if multiple equally small x
    index = xx(coord(2,xx)==min(coord(2,xx))); %determine index of lowest y
    UL = Corn(index); %lowest y is Upper Left
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
else %different x
    index = find(coord(1,:)==xx); %determine index of smallest x
    if length(index)>1 %if too many values selected
        index = index(1);
    end
    UL = Corn(index); %smallest x is Upper Left
    Corn(index) = []; %remove that index
    coord(:,index) = []; %remove that index
end

% Determine Upper Right
UR = Corn; %last remaining value

%% Find Possible Coordinates
% Using the maximum and minimum x and y coordinates specified by Corners,
% the smallest possible rectange is drawn around the points. This rectangle
% is the default setting used in the event of program failure.

% Find indices for possible points within Corners
X = min(y):max(y); %all possible x indices
Y = min(x):max(x); %all possible y indices
Indices = reshape(MEA(X,Y),[numel(MEA(X,Y)),1]); %all MEA indices

% Find coordinates for possible points within Corners
yI = zeros(1,length(Indices)); %initialize
xI = zeros(1,length(Indices)); %initialize
for i=1:length(Indices) %find coordinates of Indices
    [yi,xi] = find(MEA==Indices(i));
    yI(i) = yi;
    xI(i) = xi;
end

%% Check Bounds, Trim Excess, Plot
% The equation in Euclidean space of a line is determined between the
% corners. All points outside of the desired boundaries specified by the
% lines are eliminated.
% One effect of this simple linear elimination is that an excess of points
% is removed for concave shapes. This is why concave shapes are not
% recommended.
% Another is that having too many points along a tight line (for example,
% attempting to make a triangle) may cause a boundary to be drawn that
% eliminates most or all indices.

%lower bound (y)
if LL~=LR %non-constant
    Gr = max(LL,LR); %greater of bounds
    Le = min(LL,LR); %least of bounds
    [yg,xg] = find(MEA==Gr); %Gr coordinates
    [yl,xl] = find(MEA==Le); %Le coordinates
    s = (yg-yl)/(xg-xl); %slope between 2 points
    b = yg - s*xg; %y intercept for 2 points
    remove = yI>s*xI+b; %if point is beyond bound
    yI(remove) = [];
    xI(remove) = [];
    Indices(remove) = [];
end

%upper bound (y)
if UL~=UR %non-constant
    Gr = max(UL,UR); %greater of bounds
    Le = min(UL,UR); %least of bounds
    [yg,xg] = find(MEA==Gr); %Lg coordinates
    [yl,xl] = find(MEA==Le); %Ll coordinates
    s = (yg-yl)/(xg-xl); %slope between 2 points
    b = yg - s*xg; %y intercept for 2 points
    remove = yI<s*xI+b; %if point is beyond bound
    yI(remove) = [];
    xI(remove) = [];
    Indices(remove) = [];
end

%left bound(x)
if UL~=LL %non-constant
    Gr = max(UL,LL); %greater of bounds
    Le = min(UL,LL); %least of bounds
    [yg,xg] = find(MEA==Gr); %Lg coordinates
    [yl,xl] = find(MEA==Le); %Ll coordinates
    s = (yg-yl)/(xg-xl); %slope between 2 points
    b = yg - s*xg; %y intercept for 2 points
    if s<=0 %positive slope or 0 slope
        remove = yI<s*xI+b; %if point is beyond bound
    else %negative slope
        remove = yI>s*xI+b; %if point is beyond bound
    end
    yI(remove) = [];
    xI(remove) = [];
    Indices(remove) = [];
end

%right bound (x)
if UR~=LR %non-constant
    Gr = max(LR,UR); %greater of bounds
    Le = min(LR,UR); %least of bounds
    [yg,xg] = find(MEA==Gr); %Lg coordinates
    [yl,xl] = find(MEA==Le); %Ll coordinates
    s = (yg-yl)/(xg-xl); %slope between 2 points
    b = yg - s*xg; %y intercept for 2 points
    if s<=0 %positive slope
        remove = yI>s*xI+b; %if point is beyond bound
    else %negative slope
        remove = yI<s*xI+b; %if point is beyond bound
    end
    yI(remove) = [];
    xI(remove) = [];
    Indices(remove) = [];
end

% Back up in case there are no points.
if isempty(xI)
    disp('Error in MEA_ElectrodeSelector: No indices found within bounds.')
    disp('Creating rectangle around boundaries.')
    Indices = reshape(MEA(X,Y),[numel(MEA(X,Y)),1]); %all MEA indices
    yI = zeros(1,length(Indices)); %initialize
    xI = zeros(1,length(Indices)); %initialize
    for i=1:length(Indices) %find coordinates of Indices
        [yi,xi] = find(MEA==Indices(i));
        yI(i) = yi;
        xI(i) = xi;
    end
end

% Plot
if fig~=0 %if plotting
    figure(fig)
    [y0, x0] = find(MEA);
    figure(1)
    hold off
    scatter(x0,-y0,'k.')
    hold on
    scatter(x,-y,'bo')
    scatter(xI,-yI, 'r.')
    xlim([0 33])
    ylim([-17 0])
end