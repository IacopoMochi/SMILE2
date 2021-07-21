function y = Gaussian(beta,freq)

A = beta(1);
B = beta(2);
C = beta(3);
D = 2;

y = (A*exp(-(freq.^D)*B^D)+C).';