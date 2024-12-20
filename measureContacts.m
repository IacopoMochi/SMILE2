function output = measureContacts(app,id)

dataStructure = app.ExportdataButton.UserData;

ContoursX = dataStructure.ContactsContoursX{id};
ContoursY = dataStructure.ContactsContoursY{id};
CentersX = dataStructure.ContactsCentersX{id};
CentersY = dataStructure.ContactsCentersY{id};
Radii = dataStructure.Contacts_AverageRadius{id};

output = struct;
warning off
for n = 1:length(ContoursX)
    X = ContoursX{n};
    Y = ContoursY{n};
    X0 = CentersX(n);
    Y0 = CentersY(n);
    dt = 2*pi/(numel(X)-1);
    Th = 0:dt:2*pi;
    beta0 = [0;(Radii(n));0;(Radii(n));0;0];
    
    %beta = fminsearch(@(beta) EllFit(beta,X,Y,Th),...
    %    beta0);
    %beta = beta0;
    Options = statset('nlinfit');
    Options.MaxIter = app.MaximumnumberofiterationsEditField.Value;
%     try
    beta = nlinfit([Th Th],[X-X0 Y-Y0],@EllModel,beta0,Options);
%     catch
%         disp('darn')
%     end
    cx = beta(2)*cos(Th+beta(6))+beta(1);
    cy = beta(4)*sin(Th+beta(6))+beta(3);
    cxr = cx*cos(beta(5))+cy*sin(beta(5))+X0;
    cyr = -cx*sin(beta(5))+cy*cos(beta(5))+Y0;
    beta(2)=abs(beta(2));beta(4)=abs(beta(4));
    
    

    output.processedContoursX{n} = cxr;
    output.processedContoursY{n} = cyr;
    output.MajorSemiaxis(n) = max([beta(2) beta(4)]); 
    output.MinorSemiaxis(n) = min([beta(2) beta(4)]); 
    output.ellipticity(n) = (output.MajorSemiaxis(n)-...
        output.MinorSemiaxis(n))/output.MajorSemiaxis(n);
    output.EllipseAngle(n) = mod(abs(beta(5)),pi)*180/pi;
    output.StdError(n) = std(sqrt(cxr.^2+cyr.^2)-sqrt(X.^2+Y.^2));
    output.Radii = Radii;
    
end