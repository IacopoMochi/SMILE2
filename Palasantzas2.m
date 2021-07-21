function y = Palasantzas2(beta,freq)

sig = beta(1);
Lc = 1./beta(2);
Nl = beta(3);
alpha = beta(4);

y = (Lc*sig^2./(1+(freq.^2*Lc^2).^(0.5+alpha))+Nl).';