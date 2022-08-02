function exportData(app)

D = app.dataTable.Data;
Dc = app.dataTable_Contacts.Data;
DS = app.ExportdataButton.UserData;
Ddata =  struct();
Ddata.PSD_LWR = DS.PSD_LWR;
Ddata.PSD_LWR_fit = DS.PSD_LWR_fit;
Ddata.PSD_LWR_fit_unbiased = DS.PSD_LWR_fit_unbiased;
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


[filename, pathname] = uiputfile({'*.txt;*.xlsx;*.mat'});

pd = strfind(filename,'.');

FN_Lines = [filename(1:pd-1) '_Lines' filename(pd:end)];
FN_Contacts = [filename(1:pd-1) '_Contacts' filename(pd:end)];
if strcmpi(filename(end-2:end),'mat')
    save([pathname filename],'D','Dc','Ddata')
else
    if ~isempty(D)
        writetable(D,[pathname FN_Lines])
    end
    if ~isempty(Dc)
        writetable(Dc,[pathname FN_Contacts])
    end
end