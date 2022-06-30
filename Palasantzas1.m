function y = Palasantzas1(beta,freq)

sig = beta(1);
Lc = 1./beta(2);
Nl = beta(3);
alpha = beta(4);
a = beta(5);

y = (Lc*sig^2./(1+a*freq.^2*Lc^2).^(1+alpha)+abs(Nl)).';