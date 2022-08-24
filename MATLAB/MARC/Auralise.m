%build IR Banks
Fs = 44100;
irPath = uigetdir("IRs/", "Pick an IR Set"); %Path to IR's
addpath(irPath);

IRSet = dir(fullfile(irPath, '*.wav')); %Get all IR's in Path
[sampLength, ~] = size(audioread(IRSet(1).name)); 

%Channel IR Matrix
leftIRs =  zeros(length(IRSet), sampLength);
rightIRs = zeros(length(IRSet), sampLength);

for k = 1:length(IRSet)
    IRname = IRSet(k).name; 
    [n_IR, fs] = audioread(IRname);
    if fs ~= Fs
        error("Sample rates do not match! Please select different IR's");
    end
    leftIRs(k, :) = n_IR(:, 1);


end

%Input Audio 
[audioFilename, audioPathname] = uigetfile('*.wav', 'Pick an input audio file');
addpath(audioPathname);
if isequal(audioFilename,0) || isequal(audioPathname,0)
   disp('User canceled file selection')
else
   disp(['User selected ', fullfile(audioPathname, audioFilename)])
end
Audio = audioread(audioFilename);


%Output = GyroHRTFConvolution(Audio, )