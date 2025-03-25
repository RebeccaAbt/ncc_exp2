function [data_rs, time_rs, time] = resample_interp(data, p_before, q_after, dx, dy)

p = p_before; % eigentlich 0.025, muss aber ganzzalig sein
q = q_after;

xStart = 0;
% dx = 0.025;
N = length(data);
time  = xStart + (0:N-1)*dx;

% dy = dx*(q/p);
N = length(data)*(p/q);
time_rs  = xStart + (0:N-1)*dy;

x = data'; 

tx = time';
ty = time_rs';

ax = interp1(tx([1,end]),x([1,end],:),tx);
ay = interp1(ty([1,end]),x([1,end],:),ty);
data_rs = resample(x-ax,p,q)+ay;

end