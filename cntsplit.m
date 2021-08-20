function M = cntsplit(C)

f = 0;
k = 1;
cnt = 1;
while f==0
    np = C(2,k);
    M(cnt).('x')=C(1,k+1:k+np);
    M(cnt).('y')=C(2,k+1:k+np);
    k=k+np+1;
    cnt = cnt+1;
    if k>=size(C,2)
        f=1;
    end
end