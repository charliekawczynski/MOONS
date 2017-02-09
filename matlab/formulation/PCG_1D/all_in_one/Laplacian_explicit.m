function Ax = Laplacian_explicit(x,c)
Ax = x;
temp = x;
temp = del(temp,c);
temp = switchToDual(temp);
Ax = del(temp,c);
Ax = switchToDual(Ax);
Ax.vals = zeroghostpoints(Ax.vals);
end