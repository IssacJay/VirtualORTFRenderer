clear all
close all

%Polar Pattern Generator
%Polar pattern = a + b(cos(theta))
% 1 0 omni-directional
% 0.75 0.25 sub-cardioid 
% 0.5 0.5 cardioid (uni-directional) 
% 0.25 0.75 hyper-cardioid 
% 0 1 figure-8 (bi-directional)

%Input Variables
a = 0.75; %Constant
b = 0.25; %Coefficient
aa = 0;
bb = 1;
%Output Variables 
polpat = zeros(360,3); %dB output array

%Calculate Magnitude Responce for each Angle
for i = 1:360 %For all Azimuthal Angles
    g = (a + (b*(cos(deg2rad(i))))) + (aa + (bb*(cos(deg2rad(i))))); %Calculate Magnitude Responce
    polpat(i,1) = 10 * log10(abs(g)); %Convert from Mag to dB
    polpat(i, 2) = i; %Azimuthal Angle
end

%Convert to Cartesian
polpat(polpat < -30) = -30; %Limit responce to -30dB 
%[X,Y] = pol2cart(polpat(:,2),polpat(:,2)); %Cartesian


axes = polaraxes;
h = polarplot(axes, polpat);
axes.ThetaZeroLocation = 'top';
rlim([-30 0])
rticks([-24,-18,-12,-6])
rticklabels(["-24dB","-18dB","-12dB","-6dB","0dB"])
title("Cardioid Polar Pattern")
subtitleString = strcat('a =  ', num2str(a), ', b =  ', num2str(b));
subtitle(subtitleString)
set(h,'LineWidth',2); %sets the 'LineWidth' property of the plotted line only

%3D Plot
% theta = [1;1;360];
% phi = polpat;
% rho = 1;
% [theta,phi] = meshgrid(theta,phi);
% [x,y,z] = sph2cart(theta,phi,rho);
% surf(x,y,z)
% 
% r=sqrt(x^2+y^2)
% theta=arctan(y/x)
% 
% sqrt(x^2+y^2) = A + Bcos(arctan(y/x))