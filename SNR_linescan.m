%Linescan error
d = dir('/Users/iacopomochi/Downloads/SOG/**/*');
sp = '/';
if ispc
    sp = '\';
end


x = -128:127;
dataTable = cell(length(d),6);
for n = 1:length(d)
    I = double(imread([d(n).folder sp d(n).name]));
h = histcounts(I(:),256);
Gt = @(beta) sum((beta(1)*exp((-(x-beta(2)).^2)./(2*beta(3)^2))+...
    beta(1)*beta(4)*exp((-(x-beta(5)).^2)./(2*beta(6)^2))-h).^2);

G2 = @(beta,x) beta(1)*exp((-(x-beta(2)).^2)./(2*beta(3)^2))+...
    beta(1)*beta(4)*exp((-(x-beta(5)).^2)./(2*beta(6)^2));
G1 = @(beta,x) beta(1)*exp((-(x-beta(2)).^2)./(2*beta(3)^2));
beta0 = [max(h) -50 30 1 50 30];
lb = [max(h)/3 -100 10 0.5 -50 10];
ub = [max(h) 50 50 1.5 100 50];
options = optimoptions('fmincon');
options.StepTolerance = 1e-11;
beta = fmincon(Gt,beta0,[],[],[],[],lb,ub);

bar(0:255,h,1)
hold on
plot(0:255,h,0:255,G1(beta(1:3),x),0:255,G1([beta(4)*beta(1) beta(5:6)],x),0:255,G2(beta,x))
hold off
dataTable{n,1} =  

