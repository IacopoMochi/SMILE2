function setROI(app)

dataStructure = app.ExportdataButton.UserData;


rawImages = dataStructure.rawImages;
rawImagesAdjusted = dataStructure.rawImagesAdjusted;
id = app.AnalysisprogressGauge.UserData;
if isempty(id)
    id = 1;
end

if isempty(rawImagesAdjusted{id})
    I = rawImages{id};
else
    I = rawImagesAdjusted{id};
end
imagesc(app.ImageParameters ,I);axis(app.ImageParameters,'image');
colormap(app.ImageParameters,gray)
title(app.ImageParameters,dataStructure.fileName{id},'interpreter','none')
R = getrect(app.ImageParameters);
R = round(R);
x = zeros(5,1);
y = zeros(5,1);
x(1) = R(1); y(1) = R(2);
x(2) = R(1)+R(3); y(2) = R(2);
x(3) = R(1)+R(3); y(3) = R(2)+R(4);
x(4) = R(1); y(4) = R(2)+R(4);
x(5) = x(1); y(5) = y(1);
line(app.ImageParameters,x,y,'linewidth',2,'color','r')
app.SetROIButton.UserData = [x y];
app.minXpixEditField.Value = x(1);
app.maxXpixEditField.Value = x(2);
app.minYpixEditField.Value = y(2);
app.maxYpixEditField.Value = y(3);
end