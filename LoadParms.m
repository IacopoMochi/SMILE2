function LoadParms(~,~)

h = guihandles();
if ispc
    sl = '\';
else
    sl = '/';
end

if ~exist('parameters','dir')
    mkdir('parameters')
end
[filename, pathname] = uigetfile(['parameters' sl ' *.mat']);
%%%%Windows deployment
% if ~exist([ctfroot sl 'parameters'],'dir')
%     mkdir([ctfroot sl 'parameters'])
% end
% [filename, pathname] = uigetfile([ctfroot sl 'parameters' sl ' *.mat']);
load([pathname filename],'parameters')

dataStructure = h.pb_export.UserData;

h.Y2.String = num2str(parameters.ROI_Y2);
h.Y1.String = num2str(parameters.ROI_Y1);
h.X2.String = num2str(parameters.ROI_X2);
h.X1.String = num2str(parameters.ROI_X1);
h.auto_rotation.Value = parameters.rotation;
h.auto_distortion.Value = parameters.RemoveDistortion;

h.parmPS.String = num2str(parameters.ps);
h.ed_Threshold.String = num2str(parameters.threshold);
h.ed_spikePeak.String = num2str(parameters.spikePeak);
h.CD_fraction.String = num2str(parameters.CD_fraction); 
h.parmFN.String = num2str(parameters.FN);
h.parmLN.String = num2str(parameters.LN);
h.ed_CF.String = num2str(parameters.CF);
h.parmExN.String = num2str(parameters.ExN);
h.parmExNe.String = num2str(parameters.ExNe);
h.ed_alpha.String = num2str(parameters.Alpha);
h.ed_MIT.String = num2str(parameters.MI);
h.ed_MFE.String = num2str(parameters.MFE);
h.ed_peakProm.String = num2str(parameters.MinPeakProminence);
h.ed_peakDist.String = num2str(parameters.MinPeakDistance);
h.PSDmodel.Value = parameters.PSDModel;
h.edgefitF.Value = parameters.EdgeDetectionMethod;
h.parmRemGrad.Value = parameters.RemoveGradient;
h.parmRemGrad.Value = parameters.RemoveGradient;
h.SEMmodel.Value = parameters.SEM_model;

h.parmBridgingTh.String = num2str(parameters.BridgingThreshold);
h.parmPinchingTh.String = num2str(parameters.PinchingThreshold);

h.Pol2.Value = parameters.LinesTone;
h.Pol1.Value = ~parameters.LinesTone;

dataStructure.parameters = parameters;