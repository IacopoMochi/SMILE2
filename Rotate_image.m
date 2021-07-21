function Rotate_image(~,~)

h = guihandles;
alpha = h.slider_manual_rotation.Value* 180 - 90;
h.slider_manual_rotation.UserData = alpha;

axp = get(h.ParametersTab,'userdata');
id = h.lb_status.UserData;
dataStructure = h.pb_export.UserData;
rawImages = dataStructure.('rawImages');
I = imrotate(rawImages{id},alpha,'nearest','crop');
imagesc(axp,I);axis(axp,'image');colormap(gray)
rawImagesAdjusted = dataStructure.('rawImagesAdjusted');
rawImagesAdjusted{id} = I;
dataStructure.('rawImagesAdjusted') = rawImagesAdjusted;
h.pb_export.UserData = dataStructure;