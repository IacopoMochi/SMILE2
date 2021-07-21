function exportData(app)

D = app.dataTable.Data;
DS = app.ExportdataButton.UserData;
DSc =  struct();
DSc.PSD_LWR = DS.PSD_LWR;
DSc.PSD_LWR_fit = DS.PSD_LWR_fit;
DSc.PSD_LWR_fit_unbiased = DS.PSD_LWR_fit_unbiased;

D = cell2table(D);

parameters = app.ExportdataButton.UserData.parameters;

VD = {'Selected'  'File Name'  'Type' 'Number of detected features' ...
    'Average CD [nm]' 'stdCD [nm]'   'Mean LWR [nm]' ...
    'Mean LWR unbiased [nm]' 'Mean LER [nm]' 'Mean LER unbiased [nm]'};
VN = {'Selected'  'FileName'  'Type' 'NumberFeatures' ...
    'Average_CD' 'stdCD'   'MeanLWR' ...
    'MeanLWR_unbiased' 'MeanLER' 'MeanLER_unbiased'};


L = length(VN);
FN = fieldnames(parameters);
        cntp = 0;
        for kk = 1:length(FN)
            if (isnumeric(parameters.(FN{kk})) || islogical(parameters.(FN{kk}))) &&...
                    size(parameters.(FN{kk}),1)==1 && size(parameters.(FN{kk}),2)==1
                cntp = cntp+1;
                VD{L+cntp} = FN{kk};
                VN{L+cntp} = FN{kk};
            end
        end
D.Properties.VariableDescriptions = VD;
D.Properties.VariableNames = VN;

[filename, pathname] = uiputfile({'*.txt;*.xlsx;*.mat'});
if strcmpi(filename(end-2:end),'mat')
    save([pathname filename],'D','DSc')
else
    writetable(D,[pathname filename])
end