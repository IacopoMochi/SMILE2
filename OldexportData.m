function exportData(app)

About = table(app.Version,app.Release,app.Author,...
    'VariableNames',{'Version','Release date','Author'});
Text = 'Export data';
Color = [0.96,0.96,0.96];
[filename, pathname] = uiputfile({'*.txt;*.xlsx;*.mat'});
app.ExportdataButton.Text = 'Saving...';
app.ExportdataButton.BackgroundColor = [0.7,0.7,1];
drawnow;
filename = [pathname filename];
D = app.dataTable.Data;
Dc = app.dataTable_Contacts.Data;
DS = app.ExportdataButton.UserData;
Ddata =  struct();
Ddata.PSD_LWR = DS.PSD_LWR;
Ddata.PSD_LWR_fit = DS.PSD_LWR_fit;
Ddata.PSD_LWR_fit_unbiased = DS.PSD_LWR_fit_unbiased;
Ddata.PSD_LER = DS.PSD_LER;
Ddata.PSD_LER_fit = DS.PSD_LER_fit;
Ddata.PSD_LER_fit_unbiased = DS.PSD_LER_fit_unbiased;
Ddata.PSD_LERl = DS.PSD_LERl;
Ddata.PSD_LERl_fit = DS.PSD_LERl_fit;
Ddata.PSD_LERl_fit_unbiased = DS.PSD_LERl_fit_unbiased;
Ddata.PSD_LERt = DS.PSD_LERt;
Ddata.PSD_LERt_fit = DS.PSD_LERt_fit;
Ddata.PSD_LERt_fit_unbiased = DS.PSD_LERt_fit_unbiased;
Ddata.PS = DS.PS;
Ddata.LeadingEdges = DS.ProfilesLFilled;
Ddata.TrailingEdges = DS.ProfilesRFilled;
Ddata.LineCenters = DS.LinesCenters;
Ddata.Frequency = DS.freq;

D = cell2table(D);
Dc = cell2table(Dc);

AllParms = app.ParametersTab.UserData;
parameters = gatherParameters(app);

%%Lines
VD = app.dataTable.ColumnName;
VN = VD;
for n = 1:numel(VD)
    a = VN{n};
    a(isspace(a))='_';
    VN{n} = a;
end
if ~isempty(D)
    L = length(VN);

    FN = fieldnames(parameters);
    cntp = 0;
    cntc = size(D,2);
    for kk = 1:length(FN)

        cntp = cntp+1;
        VD{L+cntp} = FN{kk};
        VN{L+cntp} = FN{kk};
        parm = cell(size(D,1),1);
        for n = 1:(size(D,1)-1)
            p = AllParms{n};
            if ~isempty(p)
                parm{n} = p.(FN{kk});
            else
                parm{n} = [];
            end
        end
        D.(['D' num2str(cntc+kk)]) = parm;
    end
end
D.Properties.VariableDescriptions = VD;
D.Properties.VariableNames = VN;

%%contacts
VD = app.dataTable_Contacts.ColumnName;
VN = VD;
for n = 1:numel(VD)
    a = VN{n};
    a(isspace(a))='_';
    VN{n} = a;
end

L = length(VN);
if ~isempty(Dc)
    FN = fieldnames(parameters);
    cntp = 0;
    cntc = size(D,2);
    for kk = 1:length(FN)

        cntp = cntp+1;
        VD{L+cntp} = FN{kk};
        VN{L+cntp} = FN{kk};
        parm = cell(size(D,1),1);
        for n = 1:size(Dc,1)
            p = AllParms{n};
            if ~isempty(p)
                parm{n} = p.(FN{kk});
            else
                parm{n} = [];
            end
        end
        Dc.(['Dc' num2str(cntc+kk)]) = parm;
    end
end
Dc.Properties.VariableDescriptions = VD;
Dc.Properties.VariableNames = VN;

if strcmpi(filename(end-2:end),'mat')
    save([pathname filename],'D','Dc','Ddata')
elseif strcmpi(filename(end-3:end),'xlsx')
    fnames = D.File_Name;
    fnamesc = Dc.File_Name;
    if ~isempty(fnames)
        writecell(fnames(1:end-1,1),filename,'FileType','Spreadsheet',...
            'Sheet','Image List');
    end
    if ~isempty(fnamesc)
        writecell(fnamesc,filename,'FileType','Spreadsheet',...
            'Sheet','Image List','WriteMode','append');
    end
    if ~isempty(D)
        writetable(D,filename,'FileType','Spreadsheet',...
            'Sheet','Lines Data')
        if app.ExportedgesCheckBox
            A = Ddata.LeadingEdges;
            for n = 1:size(A,2)
                writematrix(A{1,n}*Ddata.PS(n),filename,'FileType','Spreadsheet',...
                    'Sheet',['Image ' num2str(n) ' Leading edges' ]);
            end
            B = Ddata.TrailingEdges;
            for n = 1:size(B,2)
                writematrix(B{1,n}*Ddata.PS(n),filename,'FileType','Spreadsheet',...
                    'Sheet',['Image ' num2str(n) ' Trailing edges' ]);
            end
        end
        if app.ExportPSDCheckBox
            labels = {'Frequency','PSD LWR','PSD LWR fit','PSD LWR fit unbiased',...
                'PSD LER','PSD LER fit','PSD LER fit unbiased',...
                'PSD LERl','PSD LERl fit','PSD LERl fit unbiased',...
                'PSD LERt','PSD LERt fit','PSD LERt fit unbiased'};
            for n = 1:size(Ddata.Frequency,2)
                sheetName = ['Image ' num2str(n) ' PSD'];
                writecell(labels,filename,'FileType','spreadsheet',...
                    'Sheet',sheetName)

                datamatrix = zeros(max(size(Ddata.Frequency{n})),13);
                datamatrix(:,1) = Ddata.Frequency{n}';
                datamatrix(:,2) = Ddata.PSD_LWR{n};
                datamatrix(:,3) = Ddata.PSD_LWR_fit{n};
                datamatrix(:,4) = Ddata.PSD_LWR_fit_unbiased{n};
                datamatrix(:,5) = Ddata.PSD_LER{n};
                datamatrix(:,6) = Ddata.PSD_LER_fit{n};
                datamatrix(:,7) = Ddata.PSD_LER_fit_unbiased{n};
                datamatrix(:,8) = Ddata.PSD_LERl{n};
                datamatrix(:,9) = Ddata.PSD_LERl_fit{n};
                datamatrix(:,10) = Ddata.PSD_LERl_fit_unbiased{n};
                datamatrix(:,11) = Ddata.PSD_LERt{n};
                datamatrix(:,12) = Ddata.PSD_LERt_fit{n};
                datamatrix(:,14) = Ddata.PSD_LERt_fit_unbiased{n};
                writematrix(datamatrix,filename,'FileType','spreadsheet',...
                    'Sheet',sheetName,'Range','A2')

            end
        end
    end
    if ~isempty(Dc)
        writetable(Dc,filename,'FileType','Spreadsheet',...
            'Sheet','Contacts Data')
    end
    writetable(About,filename,'Spreadsheet',...
        'Sheet','About')
else %Comma separated values
    fnames = D.File_Name;
    fnamesc = Dc.File_Name;
    writetable(About,filename,"FileType","Text",'WriteVariableNames',true);
    if ~isempty(D)
        writecell(fnames(1:end-1,1),filename,'FileType','Text',...
            'Delimiter',',');
    end
    if ~isempty(Dc)
        writecell(fnamesc,filename,'FileType','Text',...
            'Delimiter',',','WriteMode','append');
    end
    if ~isempty(D)
        writetable(D,filename,'FileType','Text','WriteMode','append','WriteVariableNames',true)

    end
    if ~isempty(Dc)
        writetable(Dc,filename,"FileType","Text",'WriteMode','append','WriteVariableNames',true);
    end
end

app.ExportdataButton.Text = Text;
app.ExportdataButton.BackgroundColor = Color;
