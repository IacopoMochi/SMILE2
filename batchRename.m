folder = 'C:\Users\mochi_i\Documents\IMEC\';

d = dir([folder '**\1.RUN*.xlsx']);


for n = 1:length(d)
    L = d(n).folder;
    id = strfind(L,'IMEC\');
    N = L(id+5:end-6);
    N(N=='\')='';
    N(N=='.')='-';
    N=[N 'Pala1.xlsx'];

    movefile([d(n).folder '\' d(n).name],[folder N])
end