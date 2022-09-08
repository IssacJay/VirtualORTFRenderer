%ORTFConv
function [Output] = ORTFConv(input, IRName, Distance, Rotate)

%SET INPUT VARIABLES
NInput = length(input); %Sample length of Input
Overlap = 2; %Frame overlap 
FrameSize = 1024; %STFT Frame size
StepSize = FrameSize/Overlap; %Step length (2 Windows)
NFrames = floor((NInput - FrameSize)/StepSize); %Number of Frames

IRs = importdata(IRName); %Import IR's
load("CoordinateTable.mat"); %Import Coordinate Table

%GET IR DATA
CoordinateIndex = Coordinates; %Look up index for IR's in Cartesian Coordinates
ORTF_L = IRs.L; %Get Ambisonic IR's for channel
ORTF_R = IRs.R; %Get Ambisonic IR's for channel


%CONVOLUTION VARIABLES
NIR = length(ORTF_L(:,1)); %Length of IR's
NOutput = NInput + NIR - 1; %Sample Length of output = Length of input + length of Impulse responce - 1 sample
FrameConvLength = FrameSize + NIR - 1; %Length of convolved frame = frame size + length of impulse responce - 1 sample
Hann = hann(FrameSize, 'periodic');  % Generate the Hann function to window a frame
%Create Convolution Zero Pad and Output matrix
Output = zeros(NOutput,2); %Zero padded Audio Output matrix initialised 
padIR = zeros(FrameConvLength, 4); %Zero padded Frame Convolution matrix initialised

%STFT CONVOLUTION LOOP
for i = 1 : NFrames %Frame window loop 
   
    padX = zeros(FrameConvLength, 1);  %Create Input Zero Pad
    Frame = i; %Current Frame 
    
    %Get Current Coordinates 
     i_X = Distance(i,1); %Current Reciever X Coordinate
     i_Y = Distance(i,2); %Current Reciever Y Coordinate
    GridStep = 1;

    % Apply the window to the current frame of the input vector
    y_Start = 1 + (Frame * StepSize) - StepSize; %Starting sample of current frame
    xFrame = (input(y_Start : y_Start + FrameSize - 1)).*Hann; %Source input values within current frame
    
    % Weighted Binlinear Interpolation Look Up Table
    i_XMin = (floor((i_X./(GridStep)))*GridStep)+1; %Find the nearest X index value lower than current position
    i_YMin = (floor((i_Y./(GridStep)))*GridStep)+1; %Find the nearest Y index value lower than current value
    
    i_XMax = (ceil((i_X./(GridStep))).*GridStep)+1; %Find the nearest X index value larger than current value
    i_YMax = (ceil((i_Y./(GridStep)))*GridStep)+1; %Find the nearest Y index value larger than current value
    
    %Cartesian Bilinear Weights
    Theta = 2; %Resolution of X IR's - (in Meters)
    Phi = 2; %Resolution of Y IR's -  (in Meters)
    c_theta = (mod(i_X, Theta))/Theta; %Current Azimuth 
    c_phi = (mod(i_Y, Phi))/Phi; %Current Elev
    
    Cart_aW = (1-c_theta)*(1-c_phi); % A Weight
    Cart_bW = c_theta * (1-c_phi); % B Weight
    Cart_cW = c_theta * c_phi; % C Weight
    Cart_dW = (1-c_theta)*c_phi; % D Weight

    %Safety
    if i_YMin < 1 %Ensure Y and X does not go below 1 and above 7 meters 
        i_YMin = 1;
    elseif i_XMin < 1
        i_XMin = 1;
    elseif i_YMax > 6
        i_YMax = 6;
    elseif i_XMax > 6
        i_XMax = 6;
    end
  
 
    %Get IR's from Look Up Table
    %Cartesian A - Bottom Left
    Cart_A = [i_XMin, i_YMin]; %Bottom Left Index
    [q1, i_IndexA] = ismember(Cart_A, CoordinateIndex, 'rows'); %Check that index exists in Dataset 
    if q1 == 0
        i_IndexA = 1; %If index does not exist, index 1 is assigned
    end
    %Cartesian B - Bottom Right
    Cart_B = [i_XMax, i_YMin]; %Bottom Right Index
    [q1, i_IndexB] = ismember(Cart_B, CoordinateIndex, 'rows'); %Check that index exists in Dataset 
    if q1 == 0
        i_IndexB = 1; %If index does not exist, index 1 is assigned
    end
    %Cartesian C - Top Left
    Cart_C = [i_XMax, i_YMax]; %Bottom Left Index
    [q1, i_IndexC] = ismember(Cart_C, CoordinateIndex, 'rows'); %Check that index exists in Dataset 
    if q1 == 0
        i_IndexC = 1; %If index does not exist, index 1 is assigned
    end
    %Cart D - Top Right
    Cart_D = [i_XMin, i_YMax]; %Top Right Index
    [q1, i_IndexD] = ismember(Cart_D, CoordinateIndex, 'rows'); %Check that index exists in  Dtaset 
    if q1 == 0
        i_IndexD = 1; %If index does not exist, index 1 is assigned
    end
   
    %Create IR by Interpolating IR's and zero pad
    padIR(1:NIR,1) = (ORTF_L(:,i_IndexA) .* Cart_aW) + (ORTF_L(:,i_IndexB) .* Cart_bW) + (ORTF_L(:,i_IndexC) .* Cart_cW) + (ORTF_L(:,i_IndexD) .* Cart_dW); %The weighted IR's are summed to the W channel zero padded Impulse Responce
    padIR(1:NIR,2) = (ORTF_R(:,i_IndexA) .* Cart_aW) + (ORTF_R(:,i_IndexB) .* Cart_bW) + (ORTF_R(:,i_IndexC) .* Cart_cW) + (ORTF_R(:,i_IndexD) .* Cart_dW); %The weighted IR's are summed to the X channel zero padded Impulse Responce
   
    
    %Zero pad source signal 
    padX(1:FrameSize) = padX(1:FrameSize) + xFrame;

    %Calculate the DL2
    hyp_Dist = sqrt((Distance(i,1)^2 + (abs(Distance(i,2)-3.5))^2));
    dB_Diff = -6.49 * log(hyp_Dist); %Gives -4.5dB reduction per distance doubling
    DL = db2mag(dB_Diff);

    % Convolve the impulse response with this frame   
    %Y = ifft(fft(padX).*fft(padIR)); %Use for single IR
    L = ifft(fft(padX).*fft(padIR(:,1))).* DL; %Convole W signal 
    R = ifft(fft(padX).*fft(padIR(:,2))).* DL; %Convole X signal 


    % Add frame to the output vector
    Output(y_Start: y_Start + FrameConvLength - 1, 1) = (Output(y_Start: y_Start + FrameConvLength - 1, 1) + L); %W Channel from frame added to output matrix 
    Output(y_Start: y_Start + FrameConvLength - 1, 2) = (Output(y_Start: y_Start + FrameConvLength - 1, 2) + R); %X Channel from frame added to output matrix 


end
end