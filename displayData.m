function displayData(app)

ax = app.Image;

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
        
        if strcmp(dataStructure.Type{id} , 'Contacts')
        %Contacts
        Contours = dataStructure.ContactsContours;
        ContoursFx = dataStructure.CntMetrics.processedContoursX;
        ContoursFy = dataStructure.CntMetrics.processedContoursY;
        hold(ax,'on')
        for m = 1:numel(ContoursFx)
            plot(ax,Contours(m).x,Contours(m).y,'-g','linewidth',2)
            plot(ax,ContoursFx{m},ContoursFy{m},'-r','linewidth',1)
        end
        
        else
        %Lines
        
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
        
        if strcmp(app.DataDisplayButtonGroup.SelectedObject.Text,'HHCF')
            %if strcmp(app.DisplaySwitch.Value,'Average')
            %    HHCF = dataStructure.AverageHHCF_LWR;
            %else
            if strcmp(app.MetricButtonGroup.SelectedObject.Text,'LWR')
                HHCF = dataStructure.HHCorrF{id};
                HHCFFit = dataStructure.HHCorrFFit{id};
                CorrLength = dataStructure.LWRCorrLength{id};
                Tstring = ['Line width Height-Height Correlation Length: ' num2str(CorrLength) ' nm'];
            elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER')
                HHCF = dataStructure.HHCorrFLER{id};                
                HHCFFit = dataStructure.HHCorrFLERfit{id};
                CorrLength = dataStructure.LcLER{id};
                Tstring = ['Line Edge Height-Height Correlation Length: ' num2str(CorrLength) ' nm'];
            elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER lead')
                HHCF = dataStructure.HHCorrFLERl{id};
                HHCFFit = dataStructure.HHCorrFLERlfit{id};
                CorrLength = dataStructure.LcLERl{id};
                Tstring = ['Leading Edge Height-Height Correlation Length: ' num2str(CorrLength) ' nm'];
            elseif strcmp(app.MetricButtonGroup.SelectedObject.Text,'LER trail')
                HHCF = dataStructure.HHCorrFLERt{id};
                HHCFFit = dataStructure.HHCorrFLERtfit{id};
                CorrLength = dataStructure.LcLERt{id};
                Tstring = ['Trailing Edge Height-Height Correlation Length: ' num2str(CorrLength) ' nm'];
            end
            %end
            r = dataStructure.r{id};
            
            loglog(app.Metric,r,HHCF,'o',r,HHCFFit,'lineWidth',2);axis(app.Metric,'tight')
            %loglog(app.Metric,r,HHCF,'o');axis(app.Metric,'tight')
            hold(app.Metric,'on')
            loglog(app.Metric,[CorrLength CorrLength],get(app.Metric,'ylim'),'linewidth',2)
            hold(app.Metric,'off')
            title(app.Metric,Tstring)
            
            xlabel(app.Metric,'nm')
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
