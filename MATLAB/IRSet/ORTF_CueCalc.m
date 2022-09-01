%% ORTF ITD and ILD Calculator
clear all
close all
%Source Variables
Theta = 0; %Source Direction (angle of incidence) in degrees

%Microphone Variables
MicrophoneSpacing = 0.2; %Microphone Spacing in Meters 
MicrophoneAngle = 100; %Microphone Angle in degrees

aa = 0.5;
b = 0.5;

%Binaural Variables
HeadWidth = 0.18; %Width of Head in meters

%Constant Variables
c = 344; %Speed of Sound
m = MicrophoneSpacing; %Assing to new variable
a = MicrophoneAngle; %Assing to new variable


MicValues = zeros(360, 6);
BinauralValues = zeros(360, 5); 
PhantomSourceShift = zeros(360,2);
for n = -180:179
    Theta = n; 
    index = n + 181;
    
    %Calculate ICTD and ICLD of the Microphone
    MicValues(index, 1) = n; 
    MicValues(index, 2) = sind(Theta) * (m/c); %Calculate Interchannel Time Difference
      
    if Theta == 180 - a/2
        Theta = 179 - a/2;
    elseif Theta == -180 + a/2
        Theta = -179 + a/2;
    end
    
    MicValues(index, 3) = mag2db((0.5 + 0.5*cosd(Theta - a/2))/(0.5 + 0.5*cosd(Theta + a/2))); %Calculate Interchannel Level Difference 
    MicValues(index, 3) = mag2db(aa + b*tand(Theta - a/2));
    MicValues(index, 4 ) = mag2db((1 + cosd(Theta + a/2))); %Left Microphone
    MicValues(index, 5) = mag2db((1 + cosd(Theta - a/2))); %Right Microphone
   

    if  MicValues(index, 3) < -100
         MicValues(index, 3) = -100;
         MicValues(index, 4) = -100;
         MicValues(index, 5) = -100; 
    end
    if  MicValues(index, 3) > 100
         MicValues(index, 3) = 100;
         MicValues(index, 4) = 100;
         MicValues(index, 5) = 100; 
    end

    %Calculate ITD and ILD for Binaural
    Rho = Theta;
    if Rho < -90
        Rho = -180 - Rho;
    elseif Rho > 90
        Rho = 180 - Rho;
    end
    Theta = deg2rad(Theta);
    Rho = deg2rad(Rho);
    HeadRadius = HeadWidth/2; 
    ITD = ((HeadRadius*(Rho)) + (HeadRadius * sin(Rho)))/c; %Calculate Interchannel Time Difference
    ILD = HeadWidth * sqrt(1) * sin(Theta); %Calculate Interchannel Level Difference 
    ILD_dB = log10(ILD) * 20; %Calculate Interchannel Level Difference in dB
    ILD_dB = 20 *sin(Theta);
    
   

    BinauralValues(index, 1) = n;
    BinauralValues(index, 2) = ITD; 
    BinauralValues(index, 3) = ILD_dB;
    BinauralValues(index, 4) = ILD_dB;

    %Phantom Source Shift
    ITDShift = MicValues(index,2) * 13;
    ILDShift = MicValues(index, 3) * 0.075; 
    PhantomSourceShift(index, 1) = ITDShift + ILDShift; 
    
end
subplot(2,1,1)
plot(MicValues(:,1),MicValues(:,2), 'b')
title('Binaural ITD against Stereo Microphone ICTD')
hold on
plot(MicValues(:,1),BinauralValues(:,2), 'r')
xlabel('Source Angle (°)')
ylabel('ICTD (Sec)')
xlim([-90 90])
xticks(-180:30:180);
legend('ORTF', 'Binaural', 'Location', 'SouthEast')

subplot(2,1,2)
hold off
plot(MicValues(:,1),MicValues(:,3), 'b')
title('Binaural ILD against Stereo Microphone ICLD')
hold on
plot(MicValues(:,1),BinauralValues(:,4), 'r');
xlabel('Source Angle (°)')
ylabel('ICLD (dB)')
xlim([-90 90])
xticks(-180:30:180);
%ylim([-85 85])
legend('ORTF', 'Binaural', 'Location', 'SouthEast')
