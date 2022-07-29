function exportData(app)

D = app.dataTable.Data;
Dc = app.dataTable_Contacts.Data;
DS = app.ExportdataButton.UserData;
DSc =  struct();
DSc.PSD_LWR = DS.PSD_LWR;
DSc.PSD_LWR_fit = DS.PSD_LWR_fit;
DSc.PSD_LWR_fit_unbiased = DS.PSD_LWR_fit_unbiased;

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
if strcmpi(FN_Lines(end-2:end),'mat')
    save([pathname FN_Lines],'D','DSc')
else
    writetable(D,[pathname FN_Lines])
    writetable(Dc,[pathname FN_Contacts])
end