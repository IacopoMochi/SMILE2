function output = measureContacts(app)

dataStructure = app.ExportdataButton.UserData;

Contours = dataStructure.ContactsContours;
Centers = dataStructure.ContactsCenters;
Radii = dataStructure.Contacts_AverageRadius;

ContoursFit  = struct;
output = struct;
for n = 2:numel(Contours)
    X = Contours(n).x;
    Y = Contours(n).y;
    X0 = Centers(n).x;
    Y0 = Centers(n).y;
    dt = 2*pi/(numel(X)-1);
    Th = 0:dt:2*pi;
    beta0 = [X0;Radii(n);Y0;Radii(n);0;0];
    
    %beta = fminsearch(@(beta) EllFit(beta,X,Y,Th),...
    %    beta0);
    %beta = beta0;
    beta = nlinfit([Th Th],[X Y],EllModel,beta0);
    
    cx = beta(2)*cos(Th+beta(6))+beta(1);
    cy = beta(4)*sin(Th+beta(6))+beta(3);
    cxr = cx*cos(beta(5))+cy*sin(beta(5));
    cyr = -cx*sin(beta(5))+cy*cos(beta(5));
    ContoursFit.X = cxr;
    ContoursFit.Y = cyr;
    
    output.processedContoursX{n} = ContoursFit.X;
    output.processedContoursY{n} = ContoursFit.Y;
    output.MajorSemiaxis{n} = max([beta(2) beta(4)]); 
    output.MinorSemiaxis{n} = min([beta(2) beta(4)]); 
    output.ellipticity{n} = (output.MajorSemiaxis{n}-...
        output.MinorSemiaxis{n})/output.MajorSemiaxis{n};
    output.EllipseAngle{n} = mod(abs(beta(5)),2*pi)*180/pi;
    
    %Fit center
    %Contour Fit Error
end