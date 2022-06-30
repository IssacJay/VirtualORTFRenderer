% 3-D Pattern of Cardioid Microphone over Restricted Range of Angles
% Plot the 3-D magnitude pattern of a custom cardioid microphone with both the azimuth and elevation angles restricted to the range -40 to 40 degrees in 0.1 degree increments.
% Create a custom microphone element with a cardioid pattern.

sCustMike = phased.CustomMicrophoneElement;
sCustMike.PolarPatternFrequencies = [500 1000];
sCustMike.PolarPattern = mag2db([...
    0.5+0.5*cosd(sCustMike.PolarPatternAngles);...
    0.6+0.4*cosd(sCustMike.PolarPatternAngles)]);

%Plot the 3-D magnitude pattern.
fc = 1000;
pattern(sCustMike,fc,[-180:180],[-90:90],...
    'CoordinateSystem','polar',...
    'Type','powerdb');
