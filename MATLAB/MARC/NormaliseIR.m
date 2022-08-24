%% Normalise
%% Input Variables
numIR = 5; %Number of IR Sets
Fs = 48000; %Sample Rate
n = 1; %For indexing Azi = 0
%% Output variables
irPath = "/Users/issacthomas/Documents/GitHub/VirtualORTFRenderer/MATLAB/MARC/IRs/MARC_Recordings/KU100/IRs_22-07(15-49-13)/filters/48K_24bit";
addpath(irPath); % For initial setup 
IRSet = dir(fullfile(irPath, '*.wav')); %Get all IR's in Path
Index = zeros(length(IRSet), 5, numIR); %Azimuth, Elevation, ICLD, ICTD, Phantom Shift
ICLD = zeros(length(IRSet), 3, numIR); %Chan L, Chan R, ICLD 
polarCoord = zeros(9, 5, numIR);  %Azimuth, Elevation, ICLD, ICTD, Phantom Shift

%% Iterate through IR Sets
for l = 1:numIR
    %%  Select IR Set
    irPath = uigetdir("IRs/", "Pick an IR Set"); %Path to IR's
    %irPath = "/Users/issacthomas/Documents/GitHub/VirtualORTFRenderer/MATLAB/MARC/IRs/MARC_Recordings/KU100/IRs_22-07(15-49-13)/filters/48K_24bit";
    addpath(irPath);
    IRSet = dir(fullfile(irPath, '*.wav')); %Get all IR's in Path

    for k = 1:length(IRSet)
        %% Get IR Data
        IRname = IRSet(k).name; %Get name of current IR
        [IR, fs] = audioread(IRname); %Read IR
        if fs ~= Fs
            error("Sample rates do not match! Please select different IR's");
        end
        % Check channel dimentions
        if (size(IR,2)~=2)
            disp('Error. Signal input must be an N x 2 matrix.');
            return;
        end
    end