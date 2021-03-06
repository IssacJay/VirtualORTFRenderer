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
a = 0.5; %Constant
b = 0.5; %Coefficient

%Output Variables 
polpat = zeros(36,3); %dB output array
cart = zeros(36,3);
%Calculate Magnitude Responce for each Angle
for i = 1:36 %For all Azimuthal Angles
    theta = i * 10 - 10;
    if theta == 0
        theta = 360;
    end
    g = (a + (b*(cos(deg2rad(theta))))); %Calculate Magnitude Responce
    polpat(i,1) = 10 * log10(abs(g)); %Convert from Mag to dB
    polpat(i, 2) = theta; %Azimuthal Angle
    

    %Cartesian
    phi = 90; 
    cart(i,1) = g * sind(phi) * cosd(theta); 
    cart(i,2) = g * sind(phi) * sind(theta);
    cart(i,3) = g * cosd(phi); 
end


%Convert to Cartesian
polpat(polpat < -30) = -30; %Limit responce to -30dB 

%Plot 2D Polar Pattern
figure(1)
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

%Plot 3D Polar Pattern
figure(2)
plot(cart(:,1),cart(:,2))