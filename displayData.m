function displayData(app)

ax = app.Image;
axc = app.Colorbar;

axp = app.ImageParameters;
dataStructure = app.ExportdataButton.UserData;


%Check for processed images
if isfield(dataStructure,'ImagesRC')
    ImagesRC = dataStructure.ImagesRC;
end
%Check for unprocessed images
if isfield(dataStructure,'rawImages')
    rawImages = dataStructure.rawImages;
    rawImagesAdjusted = dataStructure.rawImages;
end

id = app.AnalysisprogressGauge.UserData;
if isempty(id)
    id = 1;
    app.AnalysisprogressGauge.UserData = 1;
end
if id~=0
    if ~exist('ImagesRC','var')
        hold(ax,'off')
        if isempty(rawImagesAdjusted{id})
            I = rawImages{id};
        else
            I = rawImagesAdjusted{id};
        end
        imagesc(ax,I);axis(ax,'image');colormap(ax,gray)
        title(ax,dataStructure.fileName{id},'interpreter','none')
        hold(axp,'off')
        imagesc(axp,I);axis(axp(1),'image');colormap(axp,gray)
        title(axp,dataStructure.fileName{id},'interpreter','none')
    else
        if ~isempty(ImagesRC{id})
            if isempty(rawImagesAdjusted{id})
                I = rawImages{id};
            else
                I = rawImagesAdjusted{id};
            end
            hold(ax,'off')
            imagesc(ax,ImagesRC{id});axis(ax,'image');
            colormap(ax,gray)
            title(ax,dataStructure.fileName{id},'interpreter','none')
            hold(axp,'off')
            imagesc(axp,I);axis(axp,'image');colormap(axp,gray)
            title(axp,dataStructure.fileName{id},'interpreter','none')
            
            position = ax.Position;
            ax.PositionConstraint = 'innerposition';
            cb = colorbar(ax);
            positionCb = ax.Position;
            positionCbproper = cb.Position;
            colorbar(ax,'delete')
            %disp(position)
            %disp(positionCb)
            if strcmp(dataStructure.Type{id} , 'Contacts')
                %Contacts
                
                %Change visualization
                app.Metric.Visible = 'off';
                for chn = 1:length(app.Metric.Children)
                    delete(app.Metric.Children(1))
                end
                app.DataDisplayButtonGroup.Visible = 'off';
                app.MetricButtonGroup.Visible = 'off';
                app.ShowellipticalfitCheckBox.Visible = 'on';
                app.ContourMetricButtonGroup.Visible = 'on';
                
                ContoursX = dataStructure.ContactsContoursX{id};
                ContoursY = dataStructure.ContactsContoursY{id};
                ContoursXs = dataStructure.ContactsContoursXs{id};
                ContoursYs = dataStructure.ContactsContoursYs{id};
                ContoursFx = dataStructure.CntMetrics{id}.processedContoursX;
                ContoursFy = dataStructure.CntMetrics{id}.processedContoursY;
                Radii = dataStructure.Contacts_AverageRadius{id};
                Ellipticity = dataStructure.CntMetrics{id}.ellipticity;
                Angle = dataStructure.CntMetrics{id}.EllipseAngle;
                FitStdError = dataStructure.CntMetrics{id}.StdError;
                
                hold(ax,'on')
                mR = min(Radii);
                MR = max(Radii);
                mE = min(Ellipticity);
                ME = max(Ellipticity);
                mA = min(Angle);
                MA = max(Angle);
                mfse = min(FitStdError);
                Mfse = max(FitStdError);
                colorbar(ax,'delete')
                colorbar(axc,'delete')
                
                for m = 1:numel(ContoursFx)
                    
                    C = jet(256);
                    
                    switch app.ContourMetricButtonGroup.SelectedObject.Text
                        case 'Radius'
                            Cid = round(1+255*(Radii(m)-mR)/(MR-mR));
                            if length(Radii)==1
                                Cid = 1;
                            end
                            fill(ax,ContoursX{m},ContoursY{m},C(Cid,:),'edgecolor','none')
                        case 'Ellipticity'
                            Cid = round(1+255*(Ellipticity(m)-mE)/(ME-mE));
                            if length(Radii)==1
                                Cid = 1;
                            end
                            fill(ax,ContoursX{m},ContoursY{m},C(Cid,:),'edgecolor','none')
                        case 'Angle'
                            Cid = round(1+255*(Angle(m)-mA)/(MA-mA));
                            if length(Radii)==1
                                Cid = 1;
                            end
                            fill(ax,ContoursX{m},ContoursY{m},C(Cid,:),'edgecolor','none')
                        case 'Fit std error'
                            Cid = round(1+255*(FitStdError(m)-mfse)/(Mfse-mfse));
                            if length(Radii)==1
                                Cid = 1;
                            end
                            fill(ax,ContoursX{m},ContoursY{m},C(Cid,:),'edgecolor','none')
                        case 'None'
                            
                            plot(ax,ContoursXs{m},ContoursYs{m},'.-b','linewidth',2)
                            plot(ax,ContoursX{m},ContoursY{m},'.-g','linewidth',2)
                    end
                    
                    if app.ShowellipticalfitCheckBox.Value
                        plot(ax,ContoursFx{m},ContoursFy{m},'-r','linewidth',1)
                    end
                end
                hold(ax,'off')
                
                
                Tlabels = cell(1,11);
                switch app.ContourMetricButtonGroup.SelectedObject.Text
                    case 'Radius'
                        for nlab = 1:11
                            Tlabels{nlab} = num2str((nlab-1)*(MR-mR)/10+mR,'%0.2f');
                        end
                        title(ax,[dataStructure.fileName{id} ' - Radius [nm]'],'interpreter','none')
                    case 'Ellipticity'
                        for nlab = 1:11
                            Tlabels{nlab} = num2str((nlab-1)*(ME-mE)/10+mE,'%0.2f');
                        end
                        title(ax,[dataStructure.fileName{id} ' - Ellipticity'],'interpreter','none')
                    case 'Angle'
                        for nlab = 1:11
                            Tlabels{nlab} = num2str((nlab-1)*(MA-mA)/10+mA,'%0.2f');
                        end
                        title(ax,[dataStructure.fileName{id} ' - Angle [deg]'],'interpreter','none')
                    case 'Fit std error'
                        for nlab = 1:11
                            Tlabels{nlab} = num2str((nlab-1)*(Mfse-mfse)/10+mfse,'%0.2f');
                        end
                        title(ax,[dataStructure.fileName{id} ' - Fit std error [nm]'],'interpreter','none')
                end
                
                
                if ~strcmp(app.ContourMetricButtonGroup.SelectedObject.Text,'None')
                    clc = colorbar(app.Image);
                    colormap(clc,jet(256));
                    %app.Image.PositionConstraint = 'innerposition';
                    
                    clc.TickLabels = Tlabels;
                    %clc.Position = positionCbproper;
                    %ax.Position = positionCb;
                    
                else
                    
                    colorbar(axc,'off')
                end
                
            else
                %Lines
                
                %Change visualization
                colorbar(axc,'delete')
                app.Metric.Visible = 'on';
                app.DataDisplayButtonGroup.Visible = 'on';
                app.MetricButtonGroup.Visible = 'on';
                app.ShowellipticalfitCheckBox.Visible = 'off';
                app.ContourMetricButtonGroup.Visible = 'off';
                
                Le = dataStructure.ProfilesLFilled{id};
                Te = dataStructure.ProfilesRFilled{id};
                LeB = dataStructure.LeProfilesBridged{id};
                TeB = dataStructure.TeProfilesBridged{id};
                LeP = dataStructure.LeProfilesPinched{id};
                TeP = dataStructure.TeProfilesPinched{id};
                LeU = dataStructure.LeProfilesUndetected{id};
                TeU = dataStructure.TeProfilesUndetected{id};
                LeS = dataStructure.LeProfilesSpikes{id};
                TeS = dataStructure.TeProfilesSpikes{id};
                
                %CentersB = dataStructure.CentersB{id};
                %CentersP = dataStructure.CentersP{id};
                hold(ax,'on')
                for m = 1:size(Le,2)
                    plot(ax,squeeze(Le(:,m)),1:size(ImagesRC{id},1),'-g','linewidth',1)
                    plot(ax,squeeze(Te(:,m)),1:size(ImagesRC{id},1),'-g','linewidth',1)
                    if app.ShowerrorsButton.Value
                        plot(ax,squeeze(LeB(:,m)),1:size(ImagesRC{id},1),'.r','markersize',15)
                        plot(ax,squeeze(TeB(:,m)),1:size(ImagesRC{id},1),'.r','markersize',15)
                        plot(ax,squeeze(LeP(:,m)),1:size(ImagesRC{id},1),'.b','markersize',15)
                        plot(ax,squeeze(TeP(:,m)),1:size(ImagesRC{id},1),'.b','markersize',15)
                        plot(ax,squeeze(LeS(:,m)),1:size(ImagesRC{id},1),'.k','markersize',15)
                        plot(ax,squeeze(TeS(:,m)),1:size(ImagesRC{id},1),'.k','markersize',15)
                        plot(ax,squeeze(LeU(:,m)),1:size(ImagesRC{id},1),'.y','markersize',15)
                        plot(ax,squeeze(TeU(:,m)),1:size(ImagesRC{id},1),'.y','markersize',15)
                    end
                end
                hold(ax,'off')
                %         if ~isempty(CentersB)
                %             plot(ax(1),CentersB(:,2),CentersB(:,1),'o','linewidth',2,'color','r')
                %             hold(ax(1),'off')
                %         end
                
                if strcmp(app.DataDisplayButtonGroup.SelectedObject.Text,'HDCF')
                    %if strcmp(app.DisplaySwitch.Value,'Average')
                    %    HHCF = dataStructure.AverageHHCF_LWR;
                    %else
                    if strcmp(app.MetricButtonGroup.SelectedObject.Text,'LWR')
                        HHCF = dataStructure.HHCorrF{id};
                        HHCFFit = dataStructure.HHCorrFFit{id};
                        CorrLength = dataStructure.LWRCorrLength{id};
                        Tstring = ['Line width Correlation Length: ' num2str(CorrLength) ' nm'];
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER')
                        HHCF = dataStructure.HHCorrFLER{id};
                        HHCFFit = dataStructure.HHCorrFLERfit{id};
                        CorrLength = dataStructure.LcLER{id};
                        Tstring = ['Line Edge Correlation Length: ' num2str(CorrLength) ' nm'];
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER lead')
                        HHCF = dataStructure.HHCorrFLERl{id};
                        HHCFFit = dataStructure.HHCorrFLERlfit{id};
                        CorrLength = dataStructure.LcLERl{id};
                        Tstring = ['Leading Edge Correlation Length: ' num2str(CorrLength) ' nm'];
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER trail')
                        HHCF = dataStructure.HHCorrFLERt{id};
                        HHCFFit = dataStructure.HHCorrFLERtfit{id};
                        CorrLength = dataStructure.LcLERt{id};
                        Tstring = ['Trailing Edge Correlation Length: ' num2str(CorrLength) ' nm'];
                    end
                    %end
                    r = dataStructure.r{id};
                    
                    loglog(app.Metric,r,HHCF,'o',r,HHCFFit,'lineWidth',2);axis(app.Metric,'tight')
                    %loglog(app.Metric,r,HHCF,'o');axis(app.Metric,'tight')
                    hold(app.Metric,'on')
                    loglog(app.Metric,[CorrLength CorrLength],get(app.Metric,'ylim'),'linewidth',2)
                    hold(app.Metric,'off')
                    title(app.Metric,Tstring)
                    
                    xlabel(app.Metric,'x [nm]')
                    ylabel(app.Metric,'HDCF(x)')
                elseif strcmp(app.DataDisplayButtonGroup.SelectedObject.Text,'PSD')
                    
                    freq = dataStructure.freq{id};
                    if strcmp(app.MetricButtonGroup.SelectedObject.Text,'LWR')
                        PSD = dataStructure.PSD_LWR{id};
                        PSD_fit = dataStructure.PSD_LWR_fit{id};
                        PSD_fit_unbiased = dataStructure.PSD_LWR_fit_unbiased{id};
                        Tstring = 'LWR Power Spectral Density';
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER')
                        PSD = dataStructure.PSD_LER{id};
                        PSD_fit = dataStructure.PSD_LER_fit{id};
                        PSD_fit_unbiased = dataStructure.PSD_LER_fit_unbiased{id};
                        Tstring = 'LER Power Spectral Density';
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER lead')
                        PSD = dataStructure.PSD_LERl{id};
                        PSD_fit = dataStructure.PSD_LERl_fit{id};
                        PSD_fit_unbiased = dataStructure.PSD_LERl_fit_unbiased{id};
                        Tstring = 'Leading edge LER Power Spectral Density';
                    elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER trail')
                        PSD = dataStructure.PSD_LERt{id};
                        PSD_fit = dataStructure.PSD_LERt_fit{id};
                        PSD_fit_unbiased = dataStructure.PSD_LERt_fit_unbiased{id};
                        Tstring = 'Trailing edge LER Power Spectral Density';
                    end
                    
                    normLength = length(PSD);
                    loglog(app.Metric,freq,PSD(1:length(freq)),freq,PSD_fit,'lineWidth',2)
                    xlabel(app.Metric,'nm^{-1}')
                    ylabel(app.Metric,'nm^{3}')
                    axis(app.Metric,'tight')
                    ylim = get(app.Metric,'ylim');
                    xlim = get(app.Metric,'xlim');
                    hold(app.Metric,'on')
                    loglog(app.Metric,freq,PSD_fit_unbiased,'lineWidth',2)
                    set(app.Metric,'ylim',ylim,'xlim',xlim)
                    hold(app.Metric,'off')
                    title(app.Metric,Tstring)
                    grid(app.Metric,"on")
                    legend(app.Metric,{"Raw data","PSD fit"})
                else
                    LCDU = dataStructure.LinesCD{id};
                    LCenters = dataStructure.LinesCenters{id};
                    app.Metric.XScale = 'linear';
                    app.Metric.YScale = 'linear';
                    plot(app.Metric,LCenters,LCDU,'o-','lineWidth',2)
                    axis(app.Metric,'tight')
                    xlabel(app.Metric,'nm')
                    ylabel(app.Metric,'CD [nm]')
                    title(app.Metric,'Average CD value across the image')
                end
            end
            %imagesc(ax(1),rawImages{id});axis(ax(1),'image');colormap(gray)
            app.AnalysisprogressGauge.UserData = id;
        else
            if isempty(rawImagesAdjusted{id})
                I = rawImages{id};
            else
                I = rawImagesAdjusted{id};
            end
            %         %Contacts
            %         Contours = dataStructure.ContactsContours;
            %         hold(ax,'on')
            %         for m = 1:numel(Contours)
            %             try
            %             plot(ax,Contours(m).x,Contours(m).y,'-g','linewidth',2)
            %             catch
            %                 disp('Uffa')
            %             end
            %         end
            imagesc(ax,I);axis(ax,'image');colormap(ax,gray)
            title(ax,dataStructure.fileName{id},'interpreter','none')
            imagesc(axp,I);axis(axp(1),'image');colormap(axp,gray)
            title(axp,dataStructure.fileName{id},'interpreter','none')
            
        end
        
    end
else %Display average metrics
    AD = app.averageCheckBox.UserData;
    
    if strcmp(app.DataDisplayButtonGroup.SelectedObject.Text,'HDCF')
        %if strcmp(app.DisplaySwitch.Value,'Average')
        %    HHCF = dataStructure.AverageHHCF_LWR;
        %else
        if strcmp(app.MetricButtonGroup.SelectedObject.Text,'LWR')
            HHCF = AD.HHCorrFunc;
            HHCFFit = AD.HHCorrFuncFit;
            CorrLength = AD.LWRCorrLength;
            Tstring = ['Average line width correlation length: ' num2str(CorrLength) ' nm'];
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER')
            HHCF = AD.HHCorrFunc_LER;
            HHCFFit = AD.HHCorrFuncFit_LER;
            CorrLength = AD.LERCorrLength;
            Tstring = ['Average line edge correlation length: ' num2str(CorrLength) ' nm'];
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER lead')
            HHCF = AD.HHCorrFunc_LERl;
            HHCFFit = AD.HHCorrFuncFit_LERl;
            CorrLength = AD.LERlCorrLength;
            Tstring = ['Average leading edge correlation length: ' num2str(CorrLength) ' nm'];
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER trail')
            HHCF = AD.HHCorrFunc_LERt;
            HHCFFit = AD.HHCorrFuncFit_LERt;
            CorrLength = AD.LERtCorrLength;
            Tstring = ['Average trailing edge correlation length: ' num2str(CorrLength) ' nm'];
        end
        %end
        r = AD.r;
        
        loglog(app.Metric,r,HHCF,'o',r,HHCFFit,'lineWidth',2);axis(app.Metric,'tight')
        %loglog(app.Metric,r,HHCF,'o');axis(app.Metric,'tight')
        hold(app.Metric,'on')
        loglog(app.Metric,[CorrLength CorrLength],get(app.Metric,'ylim'),'linewidth',2)
        hold(app.Metric,'off')
        title(app.Metric,Tstring)
        
        xlabel(app.Metric,'x [nm]')
        ylabel(app.Metric,'HDCF(x)')
    elseif strcmp(app.DataDisplayButtonGroup.SelectedObject.Text,'PSD')
        
        freq = AD.freq;
        if strcmp(app.MetricButtonGroup.SelectedObject.Text,'LWR')
            PSD = AD.PSD;
            PSD_fit = AD.PSD_LWR_fit;
            PSD_fit_unbiased = AD.PSD_LWR_fit_unbiased;
            Tstring = 'Average LWR Power Spectral Density';
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER')
            PSD = AD.PSD_LER;
            PSD_fit = AD.PSD_LER_fit;
            PSD_fit_unbiased = AD.PSD_LER_fit_unbiased;
            Tstring = 'Average LER Power Spectral Density';
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER lead')
            PSD = AD.PSD_LERl;
            PSD_fit = AD.PSD_LERl_fit;
            PSD_fit_unbiased = AD.PSD_LERl_fit_unbiased;
            Tstring = 'Average Leading edge LER Power Spectral Density';
        elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER trail')
            PSD = AD.PSD_LERt;
            PSD_fit = AD.PSD_LERt_fit;
            PSD_fit_unbiased = AD.PSD_LERt_fit_unbiased;
            Tstring = 'Average Trailing edge LER Power Spectral Density';
        end
        
        
        loglog(app.Metric,freq,PSD(1:length(freq)),freq,PSD_fit,'lineWidth',2)
        xlabel(app.Metric,'nm^{-1}')
        ylabel(app.Metric,'nm^{3}')
        axis(app.Metric,'tight')
        ylim = get(app.Metric,'ylim');
        xlim = get(app.Metric,'xlim');
        hold(app.Metric,'on')
        loglog(app.Metric,freq,PSD_fit_unbiased,'lineWidth',2)
        set(app.Metric,'ylim',ylim,'xlim',xlim)
        hold(app.Metric,'off')
        title(app.Metric,Tstring)
        grid(app.Metric,"on",'LineWidth',2)
    else
        if id>0
            LCDU = dataStructure.LinesCD{id};
            LCenters = dataStructure.LinesCenters{id};
            app.Metric.XScale = 'linear';
            app.Metric.YScale = 'linear';
            plot(app.Metric,LCenters,0,0)
            axis(app.Metric,'tight')
            xlabel(app.Metric,'nm')
            ylabel(app.Metric,'CD [nm]')
            title(app.Metric,'Average CD value across the image')
        end
    end
end
set(app.Metric,'FontSize',24)
end %eof