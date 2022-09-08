function [Output, fileName, OutputOrientation, volume, NFrames] = GyroHRTFConvolution(input, sourceOrientation, volume, FrameSize, trackNumber, Fs, GyroDataset, HRTFs)
%Exam Number : Y3908606 
%Input Variables: Audio, Orientation Matrix, Volume Vector, Frame Size,
%Track Number, Fs, GyroscopeData String, HRTF String

%Imports
load(GyroDataset);
load(HRTFs);

NInput = length(input); %Sample length of Input
%NSecs = length(input)/Fs; %Time duration of output
%FrameSize = FrameSize; %Window size
Overlap = 2; 
StepSize = FrameSize/Overlap; %Step length (2 Windows)
NFrames = floor((NInput - FrameSize)/StepSize); %Number of Frames
%FrameHz = 1/((FrameSize/Fs)*Overlap); %Frequency Rate of each Frame  

%Format Input Pan Varaibles
SourceOrientation = sourceOrientation; 
SourceOrientation(SourceOrientation == 0, 1) = 360; %Convert any azimuth value at 0 (centre) to 360 (essential for calculating source/gyroscope offset in frame) 

%Create Output Orientation Variables
[OrientationLength, DoF] = size(SourceOrientation);
OutputOrientation = zeros(OrientationLength, DoF); 

%HRIR Variables
HRIR_L = l_eq_hrir_S.content_m; %Left HRIR matrix 
HRIR_R = r_eq_hrir_S.content_m; %Right HRIR matrix
[~, NIR] = size(HRIR_R); %Calculate length of HRIR
HRIRIndex = [l_eq_hrir_S.azim_v, l_eq_hrir_S.elev_v]; %Look up index for Azimuth and Elevation
HRIRStep = 15; %Resolution (degrees) of HRIR dataset


%Mobile Orientation(Gyroscope) Variables
%Sampling rate = Fs/WindowSize = 1/(FrameSize/Fs) = 1/1024/44100 = 43.066 ≈ 43.1Hz
%Recorded with a resolution of 100th of a degree
Azimuth = Orientation.X; %Azimuth output from Mobile Sensor
Pitch = Orientation.Y; %Elevation output from Mobile Sensor
%Yaw = Orientation.Z;%Pitch output from Mobile Sensor (Currently unsupported)  

%Converting Mobile gyroscope values from Interaural Polar Coordinates to
%Verical Polar Coordinates (HRIR format)
%Scale Azimuth from -179.9:179.9 to 0:359.9
Azimuth = Azimuth + 360; %Sets scale to 179.9:539.9
Azimuth = mod(Azimuth, 360); %Sets scale to 0:359.9
Azimuth = 360 - Azimuth; %Sets azimuth anticlockwise to match HRIRDataset
Azimuth(Azimuth == 360) = 0; %If value of 360 exists in vector, change value to 0 because 360=0 in HRIR set
AzimuthOrig = Azimuth; %

%Scale Elevation from 90:-90 to -45:90
Pitch = -Pitch; %Invert postive/negative values
Pitch = Pitch + 90; %Scale from 0:180
Pitch(Pitch<45) = 45; %For values less than 45, limit to 45
Pitch = Pitch - 90; %Scale from -45:90

%Convolution variables
NOutput = NInput + NIR - 1; %Sample Length of output = Length of input + length of Impulse responce - 1 sample
FrameConvLength = FrameSize + NIR - 1; %Length of convolved frame = frame size + length of impulse responce - 1 sample
Hann = hann(FrameSize, 'periodic');  % Generate the Hann function to window a frame


%Create Convolution Zero Pad and Output matrix
Output = zeros(NOutput,2); %Zero padded Audio Output matrix initialised 
padIR = zeros(FrameConvLength, 2); %Zero padded Frame Convolution matrix initialised
%Convolution Stage
for i = 1 : NFrames %Frame window loop 
   
    padX = zeros(FrameConvLength, 1);  %Create Input Zero Pad

    Frame = i; %Current Frame 
    
    % Apply the window to the current frame of the input vector x
    y_Start = 1 + (Frame * StepSize) - StepSize; %Starting sample of current frame
    xFrame = (input(y_Start : y_Start + FrameSize - 1)).*Hann; %Source input values within current frame
    
    %Calculate current HRIR needed in Frame
    i_Azimuth = (AzimuthOrig(round((Frame + 1)/(1024/StepSize)), 1)); %Select the current Gyroscopic azimuth value at index i(frame)
    i_SourceAzi = SourceOrientation(Frame, 1);%Select the current Source Azimuth value at index i(frame)
    i_Azimuth = i_Azimuth - i_SourceAzi; %Offset gyroscope and source azimuth
    i_Azimuth = mod(i_Azimuth, 360); %Modulo to restrict values above 360 and below 0 
    i_Azimuth = 360 - i_Azimuth; %Ensure orientation remains anti-clockwise 
                                                                               
    i_Elevation = (Pitch(round((Frame + 1)/(1024/StepSize)), 1)); %Select the current Gyroscopic elevation value at index i(frame)
    i_SourceEle = SourceOrientation(Frame, 2); %Select the current Source Elevation value at index i(frame)
    i_Elevation = i_SourceEle - i_Elevation; %Offset gyroscope and source elevation
    if i_Elevation > 90
        i_Elevation = 90; %Limit elevation to 90 degrees
    end
    if i_Elevation <-45 
        i_Elevation = -45; %Limit elevation to -45 degrees
    end
    OutputOrientation(Frame, :) = [i_Azimuth, i_Elevation]; %Add summed gyroscope and source Orientation to Output Orientation Matrix


    %HRTF Weighted Binlinear Interpolation
    i_AzimuthMin = (floor((i_Azimuth./(HRIRStep)))*HRIRStep); %Find the nearest azimuth index value lower than Gyroscope value
    %i_AzimuthMinWeight = (i_Azimuth-(i_AzimuthMin))/HRIRStep; %Calculate weight of this index value by calculating the difference the two values
    i_ElevMin = (floor((i_Elevation./(HRIRStep)))*HRIRStep); %Find the nearest elevation index value lower than Gyroscope value
    %i_ElevMinWeight = (i_Pitch-(i_ElevMin))/HRIRStep; %Calculate weight of this index value by calculating the difference the two values
    
    i_AzimuthMax = (ceil((i_Azimuth./(HRIRStep))).*HRIRStep); %Find the nearest azimuth index value larger than Gyroscope value
    %i_AzimuthMaxWeight = (i_AzimuthMax - i_Azimuth)/HRIRStep; %Calculate weight of this index value by calculating the difference the two values
    i_ElevMax = (ceil((i_Elevation./(HRIRStep)))*HRIRStep); %Find the nearest elevation index value larger than Gyroscope value
    %i_ElevMaxWeight = (i_Pitch-(i_ElevMin))/HRIRStep; %Calculate weight of this index value by calculating the difference the two values

    %HRIR Bilinear Weights
    Theta = 15; %Resolution of azimuth - HRIR's (in Degrees)
    Phi = 15; %Resolution of elevation - HRIR's (in Degrees)
    c_theta = (mod(i_Azimuth, Theta))/Theta; %Current Azimuth 
    c_phi = (mod(i_Elevation, Phi))/Phi; %Current Elev
    
    HRIR_aW = (1-c_theta)*(1-c_phi); %HRIR A Weight
    HRIR_bW = c_theta * (1-c_phi); %HRIR B Weight
    HRIR_cW = c_theta * c_phi; %HRIR C Weight
    HRIR_dW = (1-c_theta)*c_phi; %HRIR D Weight

    %Safety
    if i_ElevMin < -45 %Ensure elevation does not go below -45 degrees 
        i_ElevMin = -45;
    end
      if i_AzimuthMax == 360 %Change Azimuth to 0 if 360 degrees
        i_AzimuthMax = 0;
    end
    %Look Up Table
    %HRIR A - Bottom Left
    HRIR_A = [i_AzimuthMin, i_ElevMin]; %Bottom Left HRIR Index
    [q1, i_IndexA] = ismember(HRIR_A, HRIRIndex, 'rows'); %Check that index exists in HRIR Dataset 
    if q1 == 0
        i_IndexA = 1; %If index does not exist, index 1 is assigned
    end
    %HRIR B - Bottom Left
    HRIR_B = [i_AzimuthMax, i_ElevMin]; %Bottom Right HRIR Index
    [q1, i_IndexB] = ismember(HRIR_B, HRIRIndex, 'rows'); %Check that index exists in HRIR Dataset 
    if q1 == 0
        i_IndexB = 1; %If index does not exist, index 1 is assigned
    end
    %HRIR C - Bottom Left
    HRIR_C = [i_AzimuthMax, i_ElevMax]; %Bottom Right HRIR Index
    [q1, i_IndexC] = ismember(HRIR_C, HRIRIndex, 'rows'); %Check that index exists in HRIR Dataset 
    if q1 == 0
        i_IndexC = 1; %If index does not exist, index 1 is assigned
    end
    %HRIR D - Bottom Left
    HRIR_D = [i_AzimuthMin, i_ElevMax]; %Bottom Right HRIR Index
    [q1, i_IndexD] = ismember(HRIR_D, HRIRIndex, 'rows'); %Check that index exists in HRIR Dataset 
    if q1 == 0
        i_IndexD = 1; %If index does not exist, index 1 is assigned
    end
   

    %Create HRIR by Interpolating HRIR's and zero pad
    padIR(1:NIR,1) = (HRIR_L(i_IndexA,:) .* HRIR_aW) + (HRIR_L(i_IndexB,:) .* HRIR_bW) + (HRIR_L(i_IndexC,:) .* HRIR_cW) + (HRIR_L(i_IndexD,:) .* HRIR_dW); %The weighted HRIRs are summed to the left zero padded Impulse Responce
    padIR(1:NIR,2) = (HRIR_R(i_IndexA,:) .* HRIR_aW) + (HRIR_R(i_IndexB,:) .* HRIR_bW) + (HRIR_R(i_IndexC,:) .* HRIR_cW) + (HRIR_R(i_IndexD,:) .* HRIR_dW); %The weighted HRIRs are summed to the right zero padded Impulse Responce
    
    %Zero pad source signal 
    padX(1:FrameSize) = padX(1:FrameSize) + xFrame;
    
    % Convolve the impulse response with this frame   
    %Y = ifft(fft(padX).*fft(padIR)); %Use for single IR
    YL = ifft(fft(padX).*fft(padIR(:,1))); %Convole L signal 
    YR = ifft(fft(padX).*fft(padIR(:,2))); %Convole R signal 

    % Add the convolution result for this frame into the output vector y
    Output(y_Start: y_Start + FrameConvLength - 1, 1) = Output(y_Start: y_Start + FrameConvLength - 1, 1) + YL; %Left Channel
    Output(y_Start: y_Start + FrameConvLength - 1, 2) = Output(y_Start: y_Start + FrameConvLength - 1, 2) + YR; %Right Channel
end

maxVolume = max(volume);
Output = (0.99.* Output./max(abs(Output))).*maxVolume; %Normalise output 
fileName = "ExportedAudio/GyroscopeAudio/" + "Track" + num2str(trackNumber) + "_Gyro.wav"; %Create filename string
%audiowrite(fileName, Output, Fs); %Create output file 
end