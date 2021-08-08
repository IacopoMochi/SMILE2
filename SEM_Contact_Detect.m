function Output = SEM_Contact_Detect(parameters,app)

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


%Cropped image
Ac = A(h1:h2,w1:w2);

end