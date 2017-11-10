function hPirate = pirateplot(xData,vLabel,ici,Paleta)
% --------------------------------------------------------------------------
% It is not a help text
% xData:    cell where each row is a data set
% vLabel:   cell of strings with same length of "xData"
% ici:      Confidence interval of mean, computed whit frequentist approach
% Paleta:   Color palate, e.g. jet or gray  
%
% This function is a copy of work of Nathaniel Phillips (he create pirate plot, I just adapted):
%
% Phillips, N.D., 2017. YaRrr! The Pirate’s Guide to R. APS Observer, 30(3).
%
% URL: https://scholar.google.ch/citations?view_op=view_citation&hl=en&user=ThWbpDQAAAAJ&citation_for_view=ThWbpDQAAAAJ:dTyEYWd-f8wC
%
%
% Brasil, julho de 2017
% Adelino P. Silva
% adelinocpp@gmail.com
% Telegram +55 31 9 8801-3605
% -------------------------------------------------------------------------

hPirate = gcf;

if (~iscell(xData))
    fprintf('Data must be a cell.\n');
    return,
elseif (length(xData) < 1)
    fprintf('Data must length greater than 0.\n');
    return,
else
    nData = length(xData);
end,

if (~iscell(vLabel))
    fprintf('Label must be a cell.\n');
    return,
elseif (length(vLabel) ~= nData)
    fprintf('Data and Label must be the same length.\n');
    return,
elseif (~ischar(vLabel{1}))
    fprintf('Labels must be characters.\n');
    return,
end,

if ((nargin < 3) || isempty(ici))
    ici = 0.95;
end;
if (nargin < 4)
    Paleta = jet;
end;
if ( (size(Paleta,1) < 64) || (size(Paleta,2) ~= 3))
    fprintf('Invalid color palete.\n');
end,
vec_X = zeros(1,nData);

yLimMax = -inf;
yLimMin = inf;
for i = 1:nData
    vec_X(i) = 2*(i-1) + 1;
    x = xData{i};
    if (isrow(x))
        x = x';
    end,
    yLimMax = max([x;yLimMax]);
    yLimMin = min([x;yLimMin]);
end,
xLimMax = vec_X(end) + 1;
xLimMin = vec_X(1) - 1;

strLabel = cell(1,xLimMax-xLimMin+1);
k = 0;
j = 0;
for i = xLimMin:xLimMax
    k = k+1;
    if (~isempty(find(i == vec_X(:))))
        j = j + 1;
        strLabel{k} = vLabel{j};
    else
        strLabel{k} = '';
    end,
end;

numDens = 200;
yDens = linspace(yLimMin,yLimMax,numDens);

cDens = cell(1,nData);
cYDens = cell(1,nData);
cMean = cell(1,nData);
cEP   = cell(1,nData);
cCI   = cell(1,nData);
xScat = cell(1,nData);
xDenFill = cell(1,nData);
yDenFill = cell(1,nData);
for i = 1:nData
    x = xData{i};
    
    ix = min(x);
    mx = max(x);
    sx = std(x);
    yDens = linspace(ix - sx, mx + sx,numDens);
    
    xDens = ksdensity(x,yDens,'Kernel','triangle'); %,'Bandwidth',0.2
    xDens = 0.9*xDens./max(xDens);
    
    xDenFill{i} = [vec_X(i) - xDens, fliplr(vec_X(i) + xDens)];
    yDenFill{i} = [yDens, fliplr(yDens)];
    
    xScat{i} = vec_X(i)*ones(1,length(x)) + 0.1*(rand(1,length(x))-0.5);
    cDens{i} = xDens;
    cMean{i} = mean(x);
    cYDens{i} = yDens;
    cEP{i}   = std(x)/sqrt(length(x));
    cCI{i}   = tinv(1 - 0.5*(1-ici),length(x));
end,



idx = fix(linspace(1,size(Paleta,1),nData));
vColor = Paleta(idx,:);
figure(hPirate); 
grid on;
yLimMin = floor(yLimMax*10)/10;
yLimMax = ceil(yLimMax*10)/10;
axis([xLimMin, xLimMax, -inf, +inf]);
for i = 1:nData
    
    vColorT = min(1.5*vColor(i,:),1);
    hold on, fillhandle = fill(xDenFill{i},yDenFill{i},vColorT);
    set(fillhandle,'FaceAlpha',0.25,'EdgeAlpha',0.25);
    %set(fillhandle,'FaceAlpha',0.25,'EdgeAlpha',0.15);
    
%     vColorT = [0,0,0];
    vColorT = max(0.75*vColor(i,:),0);
    hold on, plot(vec_X(i) + cDens{i},cYDens{i},'-','LineWidth',0.5,'Color',vColorT);
    hold on, plot(vec_X(i) - cDens{i},cYDens{i},'-','LineWidth',0.5,'Color',vColorT);
        
    vColorT = vColor(i,:);%min(0.75*vColor,1);
    %hold on, plothandle = plot(xScat{i},xData{i},'o','MarkerSize',6,'MarkerFaceColor',vColorT, 'MarkerEdgeColor',[0,0,0], 'MarkerFaceAlpha',0.15,'MakerEdgeAlpha',0.15);
    %set(plothandle,'MarkerFaceAlpha',0.15,'MakerEdgeAlpha',0.15);
    hold on, scatter(xScat{i},xData{i},floor(40/nData),'filled',...
        'MarkerFaceColor',vColorT, 'MarkerEdgeColor',[0,0,0],...
        'MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0.15);
    
    %vColorT = [0,0,0];
    vColorT = vColor(i,:);
    xMed = [vec_X(i) - 0.8; vec_X(i) + 0.8];
    yMed = [cMean{i}; cMean{i}];
    hold on, plot(xMed,yMed,'-','LineWidth',2,'Color',vColorT);
    
    xICMed = [vec_X(i) - 0.7; vec_X(i) - 0.7;...
              vec_X(i) + 0.7; vec_X(i) + 0.7];
    yICMed = [cMean{i} - cEP{i}*cCI{i}; cMean{i} + cEP{i}*cCI{i};...
              cMean{i} + cEP{i}*cCI{i}; cMean{i} - cEP{i}*cCI{i}];
          
    vColorT = min(0.75*vColor(i,:),1);
    hold on, fillhandle = fill(xICMed,yICMed,vColorT);
    set(fillhandle,'EdgeColor','none','FaceAlpha',0.45,'EdgeAlpha',0.45);
end;
set(gca,'XTick',xLimMin:xLimMax);
set(gca,'XTickLabel',strLabel);
