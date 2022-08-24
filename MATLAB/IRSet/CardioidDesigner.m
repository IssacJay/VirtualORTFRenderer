%% Create a custom microphone element
CardMic = phased.CustomMicrophoneElement; %Create Cardioid Microphone Element 
CardMic.FrequencyVector = [0 1e+20]; %Set Frequency Response to Audible spectrum
CardMic.FrequencyResponse = [0 0]; %Assign a Flat Frequency Responce
CardMic.PolarPatternFrequencies = [125 1000]; %Polar Response Set Frequencies
CardMic.PolarPatternAngles = [-180:1:180]; %Polar Response Angles
CardMic.PolarPattern = mag2db([...
    0.6+0.4*cosd(CardMic.PolarPatternAngles);... %Polar Response at 125hz
    0.5+0.5*cosd(CardMic.PolarPatternAngles)]); %Polar Response at 1kHz

figure
pattern(CardMic,[125,1000],[-180:180],0,'Type','powerdb');
