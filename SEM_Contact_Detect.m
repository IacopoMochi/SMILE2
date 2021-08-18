function Output = SEM_Contact_Detect(parameters,app)

filename = parameters.filename;
Output = struct();
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


threshold = app.ThresholdEditField.Value;
sx = app.DenoiseXEditField.Value;
sy = app.DenoiseYEditField.Value;

w = 10*round(max(sx,sy));
[x,y] = meshgrid(-w/2:2*w/(w-1):w/2);
g = exp(-(x.^2/(2*sx^2)+y.^2/(2*sy^2)));
g = g./sum(g(:));
AF = conv2(A,g,'same');

%Cropped and filtered image
Acf = normal(AF(h1:h2,w1:w2));

C = contourc(Acf,[threshold,threshold]);
M = cntsplit(C);

ContoursRadius = zeros(numel(M),1);
ContoursCenters = struct;
for n = 1:numel(M)
    ContoursCenters(n).x = mean(M(n).x);
    ContoursCenters(n).y = mean(M(n).y);
    ContoursRadius(n) = mean(sqrt((M(n).x-ContoursCenters(n).x).^2+...
        (M(n).y-ContoursCenters(n).y).^2));
end

%Cut edge contacts
cnt = 1;
MC  = struct;
mr = mean(ContoursRadius);
for n= 1:numel(M)
    if ContoursCenters(n).x>2*mr && ContoursCenters(n).y>2*mr && ...
            ContoursCenters(n).y<(h2-h1-2*mr) && ...
            ContoursCenters(n).x<(w2-w1-2*mr)
        cnt = cnt+1;
        MC(cnt).x = M(n).x;
        MC(cnt).y = M(n).y;
    end
end

Output.contacts_contours = MC;

ContoursCenters = struct;
for n = 1:numel(MC)
    ContoursCenters(n).x = mean(MC(n).x);
    ContoursCenters(n).y = mean(MC(n).y);
    ContoursRadius(n) = mean(sqrt((MC(n).x-ContoursCenters(n).x).^2+...
        (MC(n).y-ContoursCenters(n).y).^2));
end
Output.contacts_centers = ContoursCenters;
Output.contacts_radius = ContoursRadius;

Output.PixelSize = ps;
Output.AC = A(h1:h2,w1:w2);



end