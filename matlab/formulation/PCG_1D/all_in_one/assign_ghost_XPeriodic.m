function u = assign_ghost_XPeriodic(u,val)
if ~u.BCs.bc1.type.Periodic
	u.vals(1) = val;
end
if ~u.BCs.bc2.type.Periodic
	u.vals(end) = val;
end
end