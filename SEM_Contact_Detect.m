function Output = SEM_Contact_Detect(parameters,app)

%filename = parameters.filename;
Output = struct();
% if strcmp(parameters.SEM_model,'Zeiss')
%     %Zeiss SEM: reading image pixel size from header
%     A = imfinfo(filename);
%     v = A.UnknownTags.Value;
%     r = strfind(v,char(13));
%     for n = 1:(length(r)-1)
%         s = v(r(n)+1:r(n+1)-1);
%         if contains(s,'Image Pixel Size = ')
%             ids1 = strfind(s,'Image Pixel Size = ');
%             s = s(ids1(1)+19:end);
%             ids = strfind(s,' ');
%             sc = s(1:ids(1)-1);
%             unit = s(ids(1)+1:end);
%             switch unit
%                 case 'um'
%                     ps = str2double(sc)*1000;
%                 case 'nm'
%                     ps = str2double(sc);
%                 case 'pm'
%                     ps = str2double(sc)/1000;
%             end
%             parameters.ps = ps;
%             app.PixelsizenmEditField.Value = ps;
%         end
%     end
% elseif strcmp(parameters.SEM_model,'Hitachi')
%     %Hitachi SEM: reading image pixel size from header
%     A = imfinfo(filename);
%     v = A.UnknownTags.Value;
%     vv = v(v~=0); %remove spaces
%     r = find(vv==13); %detect line breaks
%     ps = [];
%     for n = 1:(length(r)-1)
%         s = char(vv(r(n)+1:r(n+1)-1));
%         if contains(s,'PixelSize=')
%             ps = str2double(s(12:end));
%             parameters.ps = ps;
%             app.PixelsizenmEditField.Value = ps;
%         end
%     end
% else
%     ps = parameters.ps;
% end
ps = parameters.ps{1};

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

%Cropped image
%Ac = normal(A(h1:h2,w1:w2));
Ac = A(h1:h2,w1:w2);
%Cropped and filtered image
%Acf = normal(AF(h1:h2,w1:w2));
Acf = AF(h1:h2,w1:w2);


comap = normal(Acf)<0.5;
m = mean(Acf(comap));
M = mean(Acf(~comap));
if sum(comap(:))<sum(1-comap(:))
    backgroundmap = ~comap;
else
    backgroundmap = comap;
end
Ac = (Ac-m)/(M-m);
Acf = (Acf-m)/(M-m);

%% flattening image
flattening = parameters.RemoveGradient;

[xfit,yfit] = meshgrid(1:size(Acf,2),1:size(Acf,1));
xfit = xfit-size(xfit,2)/2;
yfit = yfit-size(yfit,1)/2;
for n = 1:2
    id = ~isnan(Acf);
    if strcmp(flattening,'Linear')
        F = fit([xfit(backgroundmap),yfit(backgroundmap)],Acf(backgroundmap),'poly11');
        F = F(xfit,yfit);
        AcF = normal(Acf-F);
    elseif strcmp(flattening,'Quadratic')
        F = fit([xfit(backgroundmap),yfit(backgroundmap)],Acf(backgroundmap),'poly22');
        F = F(xfit,yfit);
        AcF = normal(Acf-F);
    elseif strcmp(flattening,'Cubic')
        F = fit([xfit(backgroundmap),yfit(backgroundmap)],Acf(backgroundmap),'poly22');
        F = F(xfit,yfit);
        AcF = normal(Acf-F);
    else
        AcF = Acf;
    end
end
Acf = AcF;
%
%
% ArcF = (ArcF-(median(min(ArcF,[],2))))./((median(max(ArcF,[],2)))-(median(min(ArcF,[],2))));
% ArcF(ArcF<0)=0;
% Sb = mean(ArcF);

C = contourc(Acf,[threshold,threshold]);
M = cntsplit(C);

MM = struct();


ContoursRadius = zeros(numel(M),1);
ContoursCentersX = zeros(numel(M),1);
ContoursCentersY = zeros(numel(M),1);
for n = 1:numel(M)
    ContoursCentersX(n) = mean(M(n).x);
    ContoursCentersY(n) = mean(M(n).y);
    ContoursRadius(n) = mean(sqrt((M(n).x-ContoursCentersX(n)).^2+...
        (M(n).y-ContoursCentersY(n)).^2));
end
mr = median(ContoursRadius);
% Detect nested contacts
cnt = 0;
for n = 1:numel(M)
    for m = 1:numel(M)
        if m~=n
            x2 = (M(n).x-ContoursCentersX(m)).^2;
            y2 = (M(n).y-ContoursCentersY(m)).^2;
            if sum((x2+y2)<ContoursRadius(m)^2)>size(x2)/2
                cnt = cnt+1;
                MM(cnt).xi = M(n).x;
                MM(cnt).yi = M(n).y;
                MM(cnt).xo = M(m).x;
                MM(cnt).yo = M(m).y;
                MM(cnt).isnested = true;
                MM(cnt).Id = n;
            end
        end
    end
end
% Remove inner nested contacts (if any)
idn = true([numel(M),1]);
if cnt>0
    for n = 1:cnt
        idn(MM(n).Id) = false;
    end
end
M = M(idn);
ContoursRadius2 = [];
if app.ExcludeedgesCheckBox.Value
    %Cut edge contacts
    cnt = 0;
    th = app.ContactsubimagesizeEditField.Value;
    for n= 1:numel(M)
        maxradius = max(max(sqrt(mean(M(n).x)-M(n).x).^2+...
            (mean(M(n).y-M(n).y).^2)), mr);
        if ContoursCentersX(n)>maxradius*(th+1) && ContoursCentersY(n)>maxradius*(th+1) && ...
                ContoursCentersY(n)<(h2-h1-maxradius*(th)) && ...
                ContoursCentersX(n)<(w2-w1-maxradius*(th))
            cnt = cnt+1;
            %MC(cnt).x = M(n).x;
            %MC(cnt).y = M(n).y;
            MCx{cnt} = M(n).x;
            MCy{cnt} = M(n).y;
            ContoursRadius2 = [ContoursRadius2 ContoursRadius(n)];
        end
    end
else
    for n= 1:numel(M)
        MCx{n} = M(n).x;
        MCy{n} = M(n).y;
        ContoursRadius2 = [ContoursRadius2 ContoursRadius(n)];
    end
end

ContoursRadius = ContoursRadius2;

AllRadii = cell(numel(MCx),1);
for n = 1:numel(MCx)
    ContoursCentersX(n) = mean(MCx{n},'omitnan');
    ContoursCentersY(n) = mean(MCy{n},'omitnan');
    AllRadii{n} = sqrt((MCx{n}-ContoursCentersX(n)).^2+...
        (MCy{n}-ContoursCentersY(n)).^2);
    ContoursRadius(n) = mean(AllRadii{n});
end
Output.contacts_radius = ContoursRadius;
Output.ContoursCentersX = ContoursCentersX;
Output.ContoursCentersY = ContoursCentersY;



Output.PixelSize = ps;
Output.AC = A(h1:h2,w1:w2);

a = app.ContactsubimagesizeEditField.Value;
b = app.RadiusfractionEditField.Value;
contactCount = 0;
for n = 1:size(ContoursRadius,2)
    R = AllRadii{n};
    r = max(max(R)*a,2);
    %r = ContoursRadius(n);
    %th = 0:1/(2*r):2*pi-1/(2*r);
    x1 = round(ContoursCentersX(n)-r);
    x2 = round(ContoursCentersX(n)+r);
    y1 = round(ContoursCentersY(n)-r);
    y2 = round(ContoursCentersY(n)+r);
    S = size(Ac);

    if x1>0 && x1<=S(2) && x2>0 && x2<=S(2) && y1>0 && y1<=S(1) && y2>0 && y2<=S(1)

        contactCount = contactCount+1;
        B = Ac(y1:y2,x1:x2);
        [x,y] = meshgrid(1:(x2-x1+1),1:(y2-y1+1));

        g = griddedInterpolant(x',y',B');
        X = MCx{contactCount};
        Y = MCy{contactCount};


        if strcmp(app.ContourdetectionButtonGroup.SelectedObject.Text,'Edge fit function')
            for k = 1:numel(X)
                ra = sqrt((Y(k)-ContoursCentersY(n)).^2+(X(k)-ContoursCentersX(n)).^2);
                rr = ra*(1-b):1/(4*b*r):ra*(1+b);
                %rr = R(k)*(1-b):1/(4*b*r):R(k)*(1+b);
                th = atan2(Y(k)-ContoursCentersY(n), X(k)-ContoursCentersX(n));
                xi = rr*cos(th)+(x2-x1)/2;
                yi = rr*sin(th)+(y2-y1)/2;
                edge = g(xi,yi);


                switch app.EdgefitfunctionButtonGroup.SelectedObject.Text
                    case 'Polynomial'
                        if length(edge)>4
                            [p,~,~] = edgeDetectPoly_C(app,rr,edge);
                        else
                            p = nan;
                        end
                    case 'Linear'
                        if length(edge)>3
                            [p,~] = edgeDetectLin_C(app,rr,edge);
                        else
                            p = nan;
                        end
                    case 'Threshold'
                        if length(edge)>3
                            p = edgeDetectLin_C(app,rr,edge);
                        else
                            p = nan;
                        end
                end
                if isnan(p)
                    p = ra;
                end
                %Robustness check (profile fit error)
                if p<=rr(1) || p>=rr(end)
                    p = ra;
                end

                if k>1
                    if abs(p-p0)>app.MaxspikeEditField.Value
                        p = ra;

                    end
                    p0 = p;
                else
                    p0 = p;
                end
                switch app.EdgefitfunctionButtonGroup.SelectedObject.Text
                    case 'Polynomial'
                        %xp = (p-rr(1))*cos(th);
                        %yp = (p-rr(1))*sin(th);
                        xp = (p)*cos(th);
                        yp = (p)*sin(th);
                    case 'Linear'
                        xp = p*cos(th);
                        yp = p*sin(th);
                    case 'Threshold'
                        xp = p*cos(th);
                        yp = p*sin(th);
                end

                X(k) = xp;
                Y(k) = yp;

                %             if p>(2*ra)
                %                 plot(rr,edge,'-k',rr,bb2(1)*rr+bb2(2),'-r',(0.5-bb2(2))/bb2(1),0.5,'o');
                %
                %             %hold(app.Image,'on')
                %             %line(app.Image,[xi(1) xi(end)]+ContoursCentersX(n)-(x2-x1)/2,[yi(1) yi(end)]+ContoursCentersY(n)-(y2-y1)/2,'color','red')
                %
                %
                %             %plot(app.Image,xp+ContoursCentersX(n),yp+ContoursCentersY(n),'o')
                %             %plot(rr,edge,rr,polyval(P,rr,[],mu))
                %                 waitforbuttonpress
                %             end

            end
            MCxA{n} = X+ContoursCentersX(n)-1;
            MCyA{n} = Y+ContoursCentersY(n)-1;
        else

            MCxA{n} = X;
            MCyA{n} = Y;
        end
    else
        MCxA{n} = MCx{n};
        MCyA{n} = MCy{n};
    end

    Output.contacts_contoursX = MCxA;
    Output.contacts_contoursY = MCyA;
    Output.contacts_contoursXs = MCx;
    Output.contacts_contoursYs = MCy;


end