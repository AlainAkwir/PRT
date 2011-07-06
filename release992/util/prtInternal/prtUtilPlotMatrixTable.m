function varargout = prtUtilPlotMatrixTable(X,cLim,cMap,num2strFormat,textCMap)
% prtUtilPlotMatrixTable displays a matrix as a table. The table is actually an
%   image with lines between each pixel.
%
% Syntax: [axesHandle, textHandles, verticleLineHandles, horizontalLineHandles]
%           = prtUtilPlotMatrixTable(X,cLim,cMap,num2strFormat,textCMap)
%
% Inputs:
%   X - 2-D Matrix to plot
%   cLim - The limits for image scaling default = [min(X(:)), max(X(:))]
%   cMap - The colormap for image default = gray;
%   num2strFormat - The string format for each matrix element 
%       default = '%.2f'
%   textCMap - The colorMap to use for the text Color.
%       default - [cMap(end,:); cMap(1,:)];
%           If cMap has only 1 color the default = 1-cMap.
%
% Outputs: These names are all fairly descriptive
%   axesHandle
%   textHandles
%   verticleLineHandles
%   horizontalLineHandles
%
% Example:
%   prtUtilPlotMatrixTable(rand(5),[0 1],summer(128),'%.2f',[0 0 0])
%   prtUtilPlotMatrixTable(rand(5),[0 1],summer(128),'%.2f')
%   prtUtilPlotMatrixTable(rand(5),[0 1],[1 1 1],[],[0 0 0])
%
% Other m-files required: none
% Subfunctions: getBestFontSize
% MAT-files required: none
%
% See also: plotConfusionMatrix.m

% Copyright 2011, New Folder Consulting, L.L.C.


if nargin < 2 || isempty(cLim)
    cLim = [min(X(:)) max(X(:))];
end

if nargin < 3 || isempty(cMap)
    cMap = gray;
end

if nargin < 4 || isempty(num2strFormat)
    num2strFormat = [];
end

if nargin < 5 || isempty(textCMap)
    if size(cMap,1) == 1;
        textCMap = 1-cMap;
    else
        textCMap = [cMap(end,:); cMap(1,:)];
    end
end

[nRows, nCols] = size(X);

%imageAxes = axes;
imagesc(X,cLim);
colormap(cMap);
fontSize = getBestFontSize(gca);
textHandles = zeros(size(X));
verticleLineHandles = zeros(nRows,1);
horizontalLineHandles = zeros(nCols,1);
hold on;

%textCMapInds = gray2ind(mat2gray(X,cLim),size(textCMap,1))+1;
[dontNeed, textCMapInds] = histc( (X-cLim(1))./(cLim(2)-cLim(1)) , linspace(0,1+eps,size(textCMap,1)+1));
textCMapInds(textCMapInds==0 | ~isfinite(textCMapInds)) = size(textCMap,1);
textCMapInds(textCMapInds==0 | ~isfinite(textCMapInds)) = 1;

for iRow = 1:nRows
    for jCol = 1:nCols
        cNum = X(iRow,jCol);

        cTextColor = textCMap(textCMapInds(iRow,jCol),:);
        
        if fontSize > 0
            
            cTextString = num2str(cNum,num2strFormat);
            
            % Some smart decimal place pruning
            done = false;
            while ~done
                if length(cTextString) > 1 && strcmpi(cTextString(end),'0')
                    cTextString(end) = [];
                else
                    done = true;
                end
            end
            % Remove last decimal if necessary
            if strcmpi(cTextString(end),'.')
                cTextString(end) = [];
            end
            
%             % Some smart decimal place pruning
%             cDecimalPlace = find(cTextString=='.',1,'first');
%             if ~isempty(cDecimalPlace)
%                 lastZero = find(cTextString((cDecimalPlace+1):end)=='0',1,'first');
%                 if ~isempty(lastZero)
%                     cTextString = cTextString(1:(lastZero+cDecimalPlace-1));
%                 end
%                 
%                 if isequal(cTextString(end),'.')
%                     cTextString = cTextString(1:end-1);
%                 end
%             end
            
            %if ~isequal(cTextString,'0')
                textHandles(jCol,iRow) = text(jCol,iRow,cTextString,...
                    'color',cTextColor,'horizontalAlignment','center',...
                    'fontsize',fontSize,'clipping','on','visible','on');
            %end
            
        end
        
        if iRow == 1
            horizontalLineHandles(jCol) = plot([jCol jCol]+0.5,[0.5 0.5+nRows],'k','linewidth',1);
        end
    end
    verticleLineHandles(iRow) = plot([0.5 0.5+nCols],[iRow, iRow]+0.5,'k','linewidth',1);
end
hold off;

set(gca,'YTick',1:nRows,'XTick',1:nCols,...
    'XTickLabel',num2str((1:nCols)'),'YTickLabel',num2str((1:nRows)'),...
    'Xlim',[0.5 nCols+0.5],'Ylim',[0.5 nRows+0.5],...
    'TickLength',[0 0]);

varargout = {};
if nargout > 0 
    varargout = {gca, textHandles, verticleLineHandles, horizontalLineHandles};
end


function fs = getBestFontSize(imAxes)
% I found this little gem in a MATLAB central file heatmaptext.m
% This should solve alot of our problems with this function
% It adjusts the font size relative to the number of col and rows.
%
% 31-Jan-2008 - I have modified this so it checks the extent of the axes
% instead of the figure. This allows the fontsize to change relative to a
% subplot.
% 
% Apparently this is copyright the MathWorks as is stated in the funciton.
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=15877&objectType=file#
%

% Try to keep font size reasonable for text

maxFontSize = 9;
magicNumber = 80;

nrows = diff(get(imAxes,'YLim'));
ncols = diff(get(imAxes,'XLim'));

set(imAxes,'units','pixels');
extent = get(imAxes,'Position');
set(imAxes,'units','normalized');
ratioNum = extent(end);
if ncols < magicNumber && nrows < magicNumber
    ratio = ratioNum/max(nrows,ncols);
elseif ncols < magicNumber
    ratio = ratioNum/ncols;
elseif nrows < magicNumber
    ratio = ratioNum/nrows;
else
    ratio = 1;
end
%fs = min(maxFontSize,ceil(ratio/4));    % the gold formula
fs = ceil(ratio/4);
if fs < 4 % Font sizes less than 4 still look like crap
    fs = 0;
end