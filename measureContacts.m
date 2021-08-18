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
    dt = 2*pi/numel(X);
    Th = 0:dt:2*pi-dt;
    EllFit = @(beta,X,Y,Th) sum((X-beta(1)-beta(2).*cos(Th+beta(5))).^2+...
        (Y-beta(3)-beta(4).*sin(Th+beta(5))).^2);
    beta = fminsearch(@(beta) EllFit(beta,X,Y,Th),...
        [X0;Radii(n);Y0;Radii(n);0]);
    ContoursFit.X = beta(2)*cos(Th+beta(5))+beta(1);
    ContoursFit.Y = beta(4)*sin(Th+beta(5))+beta(3);
    
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