function Output = SEM_line_Edge_detect(parameters,app)

filename = parameters.filename;
MinPeakProminence = parameters.MinPeakProminence; %0.36
MinPeakDistance = parameters.MinPeakDistance; %40

if strcmp(parameters.SEM_model,'Zeiss')
    %Zeiss SEM: reading image pixel size from header
    A = imfinfo(filename);
    v = A.UnknownTags.Value;
    r = strfind(v,char(13));
    for n = 1:(length(r)-1)
        s = v(r(n)+1:r(n+1)-1);
        if contains(s,'Image Pixel Size = ')
            ids1 = strfind(s,'Image Pixel Size = ');
            s = s(ids1(1)+19:end);
            ids = strfind(s,' ');
            sc = s(1:ids(1)-1);
            unit = s(ids(1)+1:end);
            switch unit
                case 'um'
                    ps = str2double(sc)*1000;
                case 'nm'
                    ps = str2double(sc);
                case 'pm'
                    ps = str2double(sc)/1000;
            end
            parameters.ps = ps;
        end
    end
elseif strcmp(parameters.SEM_model,'Hitachi')
    %Hitachi SEM: reading image pixel size from header
    A = imfinfo(filename);
    v = A.UnknownTags.Value;
    vv = v(v~=0); %remove spaces
    r = find(vv==13); %detect line breaks
    ps = [];
    for n = 1:(length(r)-1)
        s = char(vv(r(n)+1:r(n+1)-1));
        if contains(s,'PixelSize=')
            ps = str2double(s(12:end));
            parameters.ps = ps;
        end
    end
else
    ps = parameters.ps;
end


A = double(parameters.rawImages);

h1 = parameters.ROI_Y1;
h2 = parameters.ROI_Y2;
w1 = parameters.ROI_X1;
w2 = parameters.ROI_X2;


%Cropped image used to calculate the rotation angle
Ac = A(h1:h2,w1:w2);

if parameters.rotation == true
    
    %2-step radon transform for image alignment
    
    alpha0 = -5:0.05:5;
    sp = size(Ac);
    [x,y] = meshgrid(-sp(2)/2:sp(2)/(sp(2)-1):sp(2)/2,-sp(1)/2:sp(1)/(sp(1)-1):sp(1)/2);
    ra = min(sp/2);
    P = (x.^2+y.^2)<ra^2;
    R = radon(Ac.*P,alpha0);
    [~,id] = max(sum(R.^2));
    alpha1 = alpha0(id)-0.25:0.01:alpha0(id)+0.25;
    R = radon(Ac.*P,alpha1);
    [~,id] = max(sum(R.^2));
    
    %Rotation correction
    alpha = -alpha1(id);
    %A = imresize(A,2,'lanczos3');
    Ar = imrotate(A,alpha,'nearest','crop');
    %Ar = imrotate(A,alpha,'bicubic','crop');
    %Ar = imresize(Ar,0.5,'lanczos3');
    
else
    Ar = A;
end
%Image filtering
s1 = size(A,1);
s2 = size(A,2);
sx = parameters.sx;
sy = parameters.sy;

[x,y] = meshgrid(-s1/2:s1/(s1-1):s1/2,-s2/2:s2/(s2-1):s2/2);
if sx>0 && sy>0
    G = exp(-x.^2/(2*sx^2)-y.^2/(2*sy^2));
    G1 = G(round(s2/2-5*sy):round(s2/2+5*sy),round(s1/2-5*sx):round(s1/2+5*sx));
    Arf = conv2(Ar,G1','same');
elseif sx>0 && sy<=0
    G = exp(-x.^2/(2*sx^2));
    Arf = conv2(Ar,G','same');
elseif sy>0 && sx<=0
    G = exp(-y.^2/(2*sy^2));
    Arf = conv2(Ar,G','same');
else
    Arf = Ar;
end

%Cropping
Arc = Arf(h1:h2,w1:w2);
%Arc_nf = Ar(h1:h2,w1:w2);


Arcc = Arc;
id = Arc<mean(Arc(:));
Arcc(id) = nan;
% M = nanmean(Arcc,2);


%% flattening image
flattening = parameters.RemoveGradient;

[xfit,yfit] = meshgrid(1:size(Arcc,2),1:size(Arcc,1));
xfit = xfit-size(xfit,2)/2;
yfit = yfit-size(yfit,1)/2;
for n = 1:2
    id = ~isnan(Arcc);
    if strcmp(flattening,'Linear')
        F = fit([xfit(id),yfit(id)],Arcc(id),'poly11');
        F = F(xfit,yfit);
        ArcF = normal(Arc-F);
    elseif strcmp(flattening,'Quadratic')
        F = fit([xfit(id),yfit(id)],Arcc(id),'poly22');
        F = F(xfit,yfit);
        ArcF = normal(Arc-F);
    elseif strcmp(flattening,'Cubic')
        F = fit([xfit(id),yfit(id)],Arcc(id),'poly33');
        F = F(xfit,yfit);
        ArcF = normal(Arc-F);
    else
        ArcFm = medfilt2(Arc,[5,5]);
        ArcF = (Arc-min(ArcFm(:)))./(max(ArcFm(:))-min(ArcFm(:)));
        F = ones(size(Arc));
    end
    Arc = ArcF;
    Arcc = ArcF;
end


ArcF = (ArcF-(median(min(ArcF,[],2))))./((median(max(ArcF,[],2)))-(median(min(ArcF,[],2))));
ArcF(ArcF<0)=0;
Sb = mean(ArcF);
%%%%Experimental binarize image for edge location detection
% ArcB=ArcF;
% 
% ArcB(ArcF<mean(ArcF(:)))=0;
% ArcB(ArcF>=mean(ArcF(:)))=1;
% Sb = mean(ArcB);


%Create a filtered version of the image
%Arcf = wiener2(ArcF,[1,5]);

%Arcf = Arc;
%Arc = NLMean(Arc,3,0.001,5);

%S_nf = sum(Arc_nf);
%Arc_nf = (Arc_nf-min(S_nf)/size(Arc_nf,1))./(max(S_nf)/size(Arc_nf,1)-min(S_nf)/size(Arc_nf,1));


dS = smooth(diff(Sb));
[~,edgelocations]= findpeaks(normal(abs(dS)),...
    'MinPeakProminence',MinPeakProminence,...
    'MinPeakDistance',MinPeakDistance);
leadingEdges = [];
trailingEdges = [];
for n = 1:length(edgelocations)
    if app.ImagetoneButtonGroup.Buttons(2).Value
        if dS(edgelocations(n))>0
            trailingEdges = [trailingEdges edgelocations(n)];
        else
            leadingEdges = [leadingEdges edgelocations(n)];
        end
    else
        if dS(edgelocations(n))<0
            trailingEdges = [trailingEdges edgelocations(n)];
        else
            leadingEdges = [leadingEdges edgelocations(n)];
        end
    end
    
    
end

%consider only complete lines
newLeadingEdges = [];
newTrailingEdges = [];
for n = 1:length(leadingEdges)
    ve = trailingEdges>leadingEdges(n);
    id = find(ve,1);
    if ~isempty(id)
        newLeadingEdges = [newLeadingEdges leadingEdges(n)];
        newTrailingEdges = [newTrailingEdges trailingEdges(id)];
    end
end
leadingEdges = newLeadingEdges;
trailingEdges = newTrailingEdges;


averageCD = mean(trailingEdges-leadingEdges);
averagePitch = mean([diff(trailingEdges) diff(leadingEdges)]);
linesCenters = (trailingEdges+leadingEdges)/2;

CD = averageCD;

%Edge detection threshold
threshold = parameters.threshold;

%Spike filtering
ff = parameters.spikePeak;

if strcmp(app.EdgerangeButton.Text,'CD fraction')
    %Search the edge in a range of b*CD around the guessed position
    b = round(CD*parameters.CD_fraction);
else
    b = app.EdgedetectionrangeEditField.Value;
end
%fwhmf = 3;

if app.EdgefitfunctionButtonGroup.Buttons(1).Value
    [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectLin(leadingEdges,trailingEdges,ArcF,CD,b,threshold);
elseif app.EdgefitfunctionButtonGroup.Buttons(2).Value
    [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectfPoly(leadingEdges,trailingEdges,ArcF,b,threshold);
else
    %[leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectThreshold(leadingEdges,trailingEdges,ArcF,CD,b,threshold,fwhmf);
    [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectThreshold(leadingEdges,trailingEdges,ArcF,CD,b,threshold);
end

%Find undetected regions, bridge and pinch defects
leadingEdgeProfilesUndetectedId = isnan(leadingEdgeProfiles);
trailingEdgeProfilesUndetectedId = isnan(trailingEdgeProfiles);

%Find spikes
leadingEdgeProfilesSpikesId = ...
    (abs(diff(leadingEdgeProfiles(1:end-1,:))) > ff) &...
    (abs(diff(leadingEdgeProfiles(2:end,:))) > ff);
leadingEdgeProfilesSpikesId = [false(1,size(leadingEdgeProfilesSpikesId,2));leadingEdgeProfilesSpikesId;false(1,size(leadingEdgeProfilesSpikesId,2))];
trailingEdgeProfilesSpikesId = ...
    (abs(diff(trailingEdgeProfiles(1:end-1,:))) > ff) &...
    (abs(diff(trailingEdgeProfiles(2:end,:))) > ff);
trailingEdgeProfilesSpikesId = [false(1,size(trailingEdgeProfilesSpikesId,2));trailingEdgeProfilesSpikesId;false(1,size(trailingEdgeProfilesSpikesId,2))];

% if size(leadingEdgeProfiles,2)>1
%     [~,leadingEdgeProfilesSpikesId] = gradient(leadingEdgeProfiles);
% else
%     leadingEdgeProfilesSpikesId = gradient(leadingEdgeProfiles);
% end
% if size(trailingEdgeProfiles,2)>1
%     [~,trailingEdgeProfilesSpikesId] = gradient(trailingEdgeProfiles);
% else
%     trailingEdgeProfilesSpikesId = gradient(trailingEdgeProfiles);
% end
% leadingEdgeProfilesSpikesId = abs(leadingEdgeProfilesSpikesId)>ff; 
% trailingEdgeProfilesSpikesId = abs(trailingEdgeProfilesSpikesId)>ff; 

% %Substitute spikes with median profiles value
 %leadingEdgeProfiles(leadingEdgeProfilesSpikesId)=nan*median(leadingEdgeProfiles(~leadingEdgeProfilesSpikesId));
 %trailingEdgeProfiles(trailingEdgeProfilesSpikesId)=nan*median(trailingEdgeProfiles(~trailingEdgeProfilesSpikesId));

 for lep = 1:size(leadingEdgeProfiles,2)
    leadingEdgeProfiles(leadingEdgeProfilesSpikesId(:,lep),lep)=median(leadingEdgeProfiles(~leadingEdgeProfilesSpikesId(:,lep),lep));
 end
 for tep = 1:size(trailingEdgeProfiles,2)
    trailingEdgeProfiles(trailingEdgeProfilesSpikesId(:,tep),tep)=median(trailingEdgeProfiles(~trailingEdgeProfilesSpikesId(:,tep),tep));
 end
pinchingThreshold = parameters.PinchingThreshold;
pinchingId = (trailingEdgeProfiles-leadingEdgeProfiles)<=pinchingThreshold;

bridgingThreshold = parameters.BridgingThreshold;
bridgingId1 = false(size(leadingEdgeProfiles));
bridgingId2 = false(size(leadingEdgeProfiles));
bridgingIds = (leadingEdgeProfiles(:,2:end)-trailingEdgeProfiles(:,1:end-1))<=bridgingThreshold;
bridgingId1(:,2:end) = bridgingIds;
bridgingId2(:,1:end-1) = bridgingIds;

%Substitute defective regions with average values
leadingEdgeProfilesFilled = leadingEdgeProfiles;
trailingEdgeProfilesFilled = trailingEdgeProfiles;

%leadingEdgeProfilesFilled(leadingEdgeProfilesUndetectedId)=nan;
leadingEdgeProfilesFilled(bridgingId2)=nan;
leadingEdgeProfilesFilled(pinchingId)=nan;
%trailingEdgeProfilesFilled(trailingEdgeProfilesUndetectedId)=nan;
trailingEdgeProfilesFilled(bridgingId1)=nan;
trailingEdgeProfilesFilled(pinchingId)=nan;

% %Find spikes again
% leadingEdgeProfilesSpikesId = abs(diff(leadingEdgeProfilesFilled,1)) > ff;
% trailingEdgeProfilesSpikesId = abs(diff(trailingEdgeProfilesFilled,1)) > ff;
% A = [false(1,size(leadingEdgeProfilesSpikesId,2));leadingEdgeProfilesSpikesId];
% B = [leadingEdgeProfilesSpikesId;false(1,size(leadingEdgeProfilesSpikesId,2))];
% leadingEdgeProfilesSpikesId = A | B;
% A = [false(1,size(trailingEdgeProfilesSpikesId,2));trailingEdgeProfilesSpikesId];
% B = [trailingEdgeProfilesSpikesId;false(1,size(trailingEdgeProfilesSpikesId,2))];
% trailingEdgeProfilesSpikesId = A | B;
% 
% leadingEdgeProfilesFilled(leadingEdgeProfilesSpikesId) = nan;
% trailingEdgeProfilesFilled(trailingEdgeProfilesSpikesId) = nan;



for n = 1:size(leadingEdgeProfiles,2)
    leadingEdgeProfilesFilled(isnan(leadingEdgeProfilesFilled(:,n)),n) = ...
        nanmedian(leadingEdgeProfilesFilled(:,n));
    trailingEdgeProfilesFilled(isnan(trailingEdgeProfilesFilled(:,n)),n) = ...
        nanmedian(trailingEdgeProfilesFilled(:,n));
end

%Create defective profiles

leadingEdgeProfilesSpikes = leadingEdgeProfilesFilled*nan;
leadingEdgeProfilesBridged = leadingEdgeProfilesFilled*nan;
leadingEdgeProfilesPinched = leadingEdgeProfilesFilled*nan;
leadingEdgeProfilesUndetected = leadingEdgeProfilesFilled*nan;
trailingEdgeProfilesSpikes = trailingEdgeProfilesFilled*nan;
trailingEdgeProfilesBridged = trailingEdgeProfilesFilled*nan;
trailingEdgeProfilesPinched = trailingEdgeProfilesFilled*nan;
trailingEdgeProfilesUndetected = trailingEdgeProfilesFilled*nan;

leadingEdgeProfilesSpikes(leadingEdgeProfilesSpikesId) = leadingEdgeProfilesFilled(leadingEdgeProfilesSpikesId);
trailingEdgeProfilesSpikes(trailingEdgeProfilesSpikesId) = trailingEdgeProfilesFilled(trailingEdgeProfilesSpikesId);
leadingEdgeProfilesBridged(bridgingId1) = leadingEdgeProfilesFilled(bridgingId1);
trailingEdgeProfilesBridged(bridgingId2) = trailingEdgeProfilesFilled(bridgingId2);
leadingEdgeProfilesPinched(pinchingId) = leadingEdgeProfilesFilled(pinchingId);
trailingEdgeProfilesPinched(pinchingId) = trailingEdgeProfilesFilled(pinchingId);
leadingEdgeProfilesUndetected(leadingEdgeProfilesUndetectedId) = leadingEdgeProfilesFilled(leadingEdgeProfilesUndetectedId);
trailingEdgeProfilesUndetected(trailingEdgeProfilesUndetectedId) = trailingEdgeProfilesFilled(trailingEdgeProfilesUndetectedId);


CentersP = [];
CentersB = [];
% clustR = 0.5;
% L = 1:size(trailingEdgeProfilesFilled,1);
% for nn = 2:size(leadingEdgeProfiles,2)
%     D = [L(pinchingId(:,nn))' (trailingEdgeProfilesFilled(pinchingId(:,nn),nn)+...
%         leadingEdgeProfilesFilled(pinchingId(:,nn),nn))*0.5];
%     if ~isempty(D)
%         if size(D,1)>1 && sum(isnan(D(:)))==0
%             centers = subclust(D,clustR);
%             CentersP = [CentersP;centers];
%         elseif sum(isnan(D(:)))==0
%             CentersP = [CentersP;D];
%         end
%     end
%
%     D = [L(bridgingId1(:,nn))' (trailingEdgeProfilesFilled(bridgingId1(:,nn),nn)+...
%         leadingEdgeProfilesFilled(bridgingId2(:,nn-1),nn-1))*0.5];
%     if ~isempty(D)
%         if size(D,1)>1 && sum(isnan(D(:)))==0
%             centers = subclust(D,clustR);
%             CentersB = [CentersB;centers];
%         elseif sum(isnan(D(:)))==0
%             CentersB = [CentersB;D];
%         end
%     end
% end

OLP = leadingEdgeProfilesFilled;
OLT = trailingEdgeProfilesFilled;
LW = OLT-OLP;

Output = struct;
Output.trailingEdgeProfiles = trailingEdgeProfiles;
Output.leadingEdgeProfiles = leadingEdgeProfiles;
Output.trailingEdgeProfilesFilled = trailingEdgeProfilesFilled;
Output.leadingEdgeProfilesFilled = leadingEdgeProfilesFilled;
Output.trailingEdgeProfilesBridged = trailingEdgeProfilesBridged;
Output.leadingEdgeProfilesBridged = leadingEdgeProfilesBridged;
Output.trailingEdgeProfilesPinched = trailingEdgeProfilesPinched;
Output.leadingEdgeProfilesPinched = leadingEdgeProfilesPinched;
Output.trailingEdgeProfilesSpikes = trailingEdgeProfilesSpikes;
Output.leadingEdgeProfilesSpikes = leadingEdgeProfilesSpikes;
Output.trailingEdgeProfilesUndetected = trailingEdgeProfilesUndetected;
Output.leadingEdgeProfilesUndetected = leadingEdgeProfilesUndetected;
Output.CentersP = CentersP;
Output.CentersB = CentersB;
Output.Pitch = averagePitch;

Output.Arc = Arc;
Output.F = F;
Output.PS = ps;
Output.LWvar = LW;
end


