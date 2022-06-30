function y = Integral(beta,Rv,edf)

sig2 =abs(beta(1));
Cf = beta(2);
Nl = beta(3);
alpha = beta(4);
if alpha > 1
    alpha = 1;
elseif alpha < 0
    alpha = 0;
end

P = exp(-abs(Rv*Cf).^(2*alpha));
%S = sum(P);
y = sig2*(abs(fft(P/sum(P)))).^2+abs(Nl);
%y = sig2*(abs(fft(P))/S)+Nl;

y = y(edf(1):edf(2))';
