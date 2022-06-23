clear all
close all
polarpatern = zeros(360,1);
%Polar pattern = a + b(cos(theta))
% 1 0 omni-directional
% 0.75 0.25 sub-cardioid 
% 0.5 0.5 cardioid (uni-directional) 
% 0.25 0.75 hyper-cardioid 
% 0 1 figure-8 (bi-directional)

a = 0;
b = 1;

for i = 1:360
    g = a + (b*(cos(deg2rad(i))));
    polarpatern(i,1) = 10 * log10(abs(g));
end
polarpatern(polarpatern < -30) = -30; 

axes = polaraxes;
h = polarplot(axes, polarpatern);
axes.ThetaZeroLocation = 'top';
rlim([-30 0])
rticks([-24,-18,-12,-6])
rticklabels(["-24dB","-18dB","-12dB","-6dB","0dB"])
title("Cardioid Polar Pattern")
subtitleString = strcat('a =  ', num2str(a), ', b =  ', num2str(b));
subtitle(subtitleString)
set(h,'LineWidth',3); %sets the 'LineWidth' property of the plotted line only

%3D Plot
% theta = [1;1;360];
% phi = polarpatern;
% rho = 1;
% [theta,phi] = meshgrid(theta,phi);
% [x,y,z] = sph2cart(theta,phi,rho);
% surf(x,y,z)