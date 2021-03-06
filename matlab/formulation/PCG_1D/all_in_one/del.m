function Dx = del(x,c)
if ~(x.DL.is_CC) && ~(x.DL.is_N)
    x
    error('Bad input to del')
end
Dx = x;
if (x.DL.is_CC)
    Dx.vals = zeros(c.sn,1);
    Dx.vals(2:end-1) = diff(x.vals)./c.dhc';
elseif (x.DL.is_N)
    Dx.vals = zeros(c.sc,1);
    Dx.vals(:) = diff(x.vals)./c.dhn';
else
    error('Bad input to del in del.m')
end
end