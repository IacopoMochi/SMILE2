function output = measureContacts(app)

dataStructure = app.ExportdataButton.UserData;

ContoursX = dataStructure.ContactsContoursX;
ContoursY = dataStructure.ContactsContoursY;
CentersX = dataStructure.ContactsCentersX;
CentersY = dataStructure.ContactsCentersY;
Radii = dataStructure.Contacts_AverageRadius;

ContoursFit  = struct;
output = struct;
for n = 2:numel(ContoursX)
    X = ContoursX{n};
    Y = ContoursY{n};
    X0 = CentersX{n};
    Y0 = CentersY{n};
    dt = 2*pi/(numel(X)-1);
    Th = 0:dt:2*pi;
    beta0 = [X0;Radii(n);Y0;Radii(n);0;0];
    
    %beta = fminsearch(@(beta) EllFit(beta,X,Y,Th),...
    %    beta0);
    %beta = beta0;
    Options = statset('nlinfit');
    Options.MaxIter = 1000;
    beta = nlinfit([Th Th],[X Y],@EllModel,beta0,Options);
    
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