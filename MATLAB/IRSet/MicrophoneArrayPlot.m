%% Stereo Microphone Array
%% Input Arguments
MicSpacing = 0.17; %Distance between mics
MicAngle = 110; %Angle between mics
ArrayName = ' ORTF';

%% Assign Frequencies and Propagation Speed
Frequency = 1000; %Test Frequency   
PropagationSpeed = 344; %Speed of Sound

%% Create a geometry array from microphone positions
Array = phased.ConformalArray();%Create Microphone Array Element
Array.ElementPosition = [0 0;-(MicSpacing/2) (MicSpacing/2);0 0]; %Create position matrix for each microphone
Array.ElementNormal = [-(MicAngle/2) (MicAngle/2);0 0]; %Create angle matrix for each microphone

%% Create a custom microphone element
CardMic = phased.CustomMicrophoneElement; %Create Cardioid Microphone Element 
CardMic.FrequencyVector = [0 1e+20]; %Set Frequency Response to Audible spectrum
CardMic.FrequencyResponse = [0 0]; %Assign a Flat Frequency Responce
CardMic.PolarPatternFrequencies = [125 1000]; %Polar Response Set Frequencies
CardMic.PolarPatternAngles = [-180:1:180]; %Polar Response Angles
CardMic.PolarPattern = mag2db([...
    0.6+0.4*cosd(CardMic.PolarPatternAngles);... %Polar Response at 125hz
    0.5+0.5*cosd(CardMic.PolarPatternAngles)]); %Polar Response at 1kHz


Array.Element = CardMic;

%% Find the weights
w = ones(getNumElements(Array), length(Frequency));


%% Array ICTD and ICLD
% ICTD 
ICTDTable = zeros(73,37); % ITD Values Table
[aziLength,eleLength] = size(ICTDTable); % Size of Table
ICTD = phased.ElementDelay('SensorArray',Array, 'PropagationSpeed', PropagationSpeed); % Time delay of each microphone element

% ICLD
ICLDTable = zeros(73,37); % Store ITD Values

for a = 1:aziLength % Each Azimuth Angle
    for e = 1:eleLength %Each Elevation Angle
        ang = [a*5 - 185;e*5 - 95]; % Current source angle

        ICTD_ae = ICTD(ang); % Get tau
        ICTDTable(a,e) = (ICTD_ae(1) - ICTD_ae(2)); % Calculate time difference

        resp = Array([31.5,63,125, 250, 500, 1000, 2000, 4000, 8000, 16000], ang);
        resp = sum(resp, [2 3]); % Get summed level of left and right channel
        ICLDTable(a,e) = mag2db(resp(2)/resp(1)); %Get ICLD
    end
end

%% Create Figure
figure(1)

%% Plot 2D Polar Plot
format = 'polar';
plotType = 'powerdb';
plotStyle = 'Overlay';
subplot(2,2,1)
pattern(Array, [125, 1000, 2000], -180:180, 0, 'PropagationSpeed', PropagationSpeed,...
    'CoordinateSystem', format ,'weights', w, ...
    'Type', plotType, 'PlotStyle', plotStyle);

%% Plot 2D Polar Plot
format = 'polar';
cutAngle = 45;
plotType = 'powerdb';
plotStyle = 'Overlay';
subplot(2,2,2)
pattern(Array, [125, 1000, 2000], -180:180, cutAngle, 'PropagationSpeed', PropagationSpeed,...
    'CoordinateSystem', format ,'weights', w, ...
    'Type', plotType, 'PlotStyle', plotStyle);

% % Plot 3D Polar Plot
% format = 'polar';
% plotType = 'powerdb';
% subplot(2,2,2)
% pattern(Array, 1000, 'PropagationSpeed', PropagationSpeed,...
%     'CoordinateSystem', format,'weights', w(:,1),...
%     'ShowArray',false,'ShowLocalCoordinates',true,...
%     'ShowColorbar',true,'Orientation',[0;0;0],...
%     'Type', plotType);

%% Plot ICTD 3D
subplot(2,2,3);
[X1,Y1] = meshgrid(-180:5:180,-90:5:90);
Z1 = ICTDTable';
itd = surf(X1,Y1,Z1);
itd.EdgeColor = 'none';
ylim([-90 90]);
xlim([-180 180]);
zlim([-0.001 0.001])
yticks([-90 -60, -30, 0, 30, 60, 90]); 
shading interp
title('Interchannel Time Difference (Seconds)')
xlabel('Azimuth Angle (Deg)')
ylabel('Elevation Angle (Deg)')
zlabel('Time Difference (ms)')
colorbar


%% Plot ICLD 3D
subplot(2,2,4);
[X2,Y2] = meshgrid(-180:5:180,-90:5:90);
Z2 = ICLDTable';
icld = surf(X2,Y2,Z2);
icld.EdgeColor = 'none';
ylim([-90 90]);
xlim([-180 180]);
zlim([-20 20]);
yticks([-90 -60, -30, 0. 30, 60, 90]); 
shading interp
title('Interchannel Level Difference (dB)')
xlabel('Azimuth Angle (Deg)')
ylabel('Elevation Angle (Deg)')
zlabel('Level Difference (dB)')
colorbar

%% Plot ICTD 2D


sgtitle(strcat('Simulated Spatial Characteristics of', ' ', ArrayName, ' Microphone Array:', ' ', string(MicSpacing), 'm/', string(MicAngle), '°'));

