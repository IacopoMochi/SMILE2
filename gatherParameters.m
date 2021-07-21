function gatherParameters(app)


dataStructure = app.ExportdataButton.UserData;
%Gather the parameters from the GUI
parameters = struct;
parameters.SEM_model = app.SEMmodelDropDown.Value;
parameters.ROI_X1 = ceil(app.minXpixEditField.Value);
parameters.ROI_X2 = floor(app.maxXpixEditField.Value);
parameters.ROI_Y1 = ceil(app.minYpixEditField.Value);
parameters.ROI_Y2 = floor(app.maxYpixEditField.Value);

parameters.sx = 0;
parameters.sy = 0;

parameters.rotation = app.AutorotationalignmentCheckBox.Value;
parameters.ps = app.PixelsizenmEditField.Value;
parameters.threshold = app.ThresholdEditField.Value;
parameters.spikePeak = app.MaxspikeEditField.Value;
parameters.CD_fraction = app.CDfractionEditField.Value;
parameters.FN = app.LowfrequencyaverageEditField.Value;
parameters.LN = app.HighfrequencyaverageEditField.Value;
parameters.CF = app.CorrelationfrequencyEditField.Value;
parameters.ExN = app.LowfrequencyexclusionEditField.Value;
parameters.ExNe = app.HighfrequencyexclusionEditField.Value;
parameters.Alpha = app.AlphaEditField.Value;
parameters.MI = app.MaximumnumberofiterationsEditField.Value;
parameters.MFE = app.MaximumnumberofiterationsEditField.Value;
parameters.MinPeakProminence = app.MinpeakprominenceEditField.Value;
parameters.MinPeakDistance = app.MinpeakdistanceEditField.Value;
%parameters.PSDmodel = h.PSDmodel.String{h.PSDmodel.Value};
parameters.RemoveDistortion = app.RemovedistortionCheckBox.Value;
parameters.RemoveGradient = app.GradientcorrectionButtonGroup.Buttons.Value;
parameters.BridgingThreshold = app.BridgingthresholdEditField.Value;
parameters.PinchingThreshold = app.PinchingthresholdEditField.Value;
parameters.PSDModel = app.PSDmodelDropDown.Value;
parameters.EdgeDetectionMethod = app.EdgefitfunctionButtonGroup.Buttons.Value;

parameters.LinesTone = app.ImagetoneButtonGroup.Buttons.Value; %Positive tone if true

dataStructure.parameters = parameters;
app.ExportdataButton.UserData = dataStructure;