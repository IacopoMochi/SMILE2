function y = NoWhiteNoise(beta,freq)

sig2 = beta(1);
Lc = 1./beta(2);
alpha = beta(3);

%y = (sig2./(1+abs(2*pi*Lc*freq).^(0.5+alpha)+Nl).';
y = (Lc*sig2./(1+freq.^2*Lc^2).^(0.5+alpha)).';