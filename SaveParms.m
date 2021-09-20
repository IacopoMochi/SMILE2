function SaveParms(~,~)

h = guihandles();
gatherParameters;

dataStructure = h.pb_export.UserData;
parameters = dataStructure.parameters;

if ispc
    sl = '\';
else
    sl = '/';
end
if ~exist('parameters','dir')
    mkdir('parameters')
end

%[filename, pathname] = uiputfile(['parameters' sl '*.mat']);
%%%Windows deployment
if ~exist([ctfroot sl 'parameters'],'dir')
    mkdir([ctfroot sl 'parameters'])
end

[filename, pathname] = uiputfile([ctfroot sl 'parameters' sl '*.mat']);

if isequal(filename,0) || isequal(pathname,0)
    %Operation cancelled
else
    save([pathname filename],'parameters')
end


