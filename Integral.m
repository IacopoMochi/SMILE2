function y = Integral(beta,Rv,edf)

sig2 =beta(1);
Cl = 1/beta(2);
Nl = beta(3);
alpha = beta(4);
if alpha > 1
    alpha = 1;
elseif alpha < 0
    alpha = 0;
end

P = 2-2*exp(-abs(Rv/Cl).^(2*alpha));
S = sum(P);
y = sig2*(real(fft(P))/S)+Nl;
%y = sig2*(abs(fft(P))/S)+Nl;
y = y(edf(1):edf(2))';