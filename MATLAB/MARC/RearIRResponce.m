%% Create ORTF Surround
clear all; close all; clc;
irPath = uigetdir("IRs/", "Pick an IR Set"); %Path to IR's
%irPath = "/Users/issacthomas/Documents/GitHub/VirtualORTFRenderer/MATLAB/MARC/IRs/MARC_Recordings/IRT_Cross_19/IRs_02-08(17-47-20)/filters/48K_24bit";
addpath(irPath);
IRSet = dir(fullfile(irPath, '*.wav')); %Get all IR's in Path
Fs = 48000;

%% IR Setting
fc = 7000;
gain = 1;


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

        %% Create output samples vector
        if k == 1
            IRs = zeros(length(IRSet), length(IR), 2);
            Index = zeros(length(IRSet), 2);
            fileNames = cell(length(IRSet), 1);
        end
        fileNames(k) = {IRname};
        IRs(k, :, 1) = IR(:,1)'; IRs(k,:,2) = IR(:,2)';
        
        %% Get Azi/Ele Angles from Filename
        [~,IRName,~]=fileparts(IRname); %Get Filename from full file
        azi_ele = strsplit(IRName, '_'); %Split filename by '_'
        azi = strrep(azi_ele(2), ',', '.'); %Replace ',' with '.' to create float
        ele = strrep(azi_ele(4), ',', '.'); %Replace ',' with '.' to create float
        Index(k, 1) = str2num(cell2mat(azi(1))); %Add file azimuth to index matrix
        Index(k, 2) = str2num(cell2mat(ele(1))); %Add file elevation to index matrix
    

        

 end
 
 %% Output Matrix
 rearIRs = IRs; 
 outputIRs = zeros(length(IRSet),length(IR), 2); 

 %% Create Output IR's
 for n = 1:length(IRSet)
     azi = Index(n, 1);
     ele = Index(n,2); 
     aziRev = [mod(azi + 180, 360), ele];
     
    [f_member, f_Index] = ismember([azi,ele], Index, 'rows'); 
    [r_member, r_Index] = ismember(aziRev, Index, 'rows'); %Check that index exists in HRIR Dataset 
    if r_member == 1 %Combine front and rear microphones

        outputIRs(n,:,1) = (IRs(f_Index, :, 1) + rearIRs(r_Index, :, 2)) .* 0.5;
        outputIRs(n,:,2) = (IRs(f_Index, :, 2) + rearIRs(r_Index, :, 1)) .* 0.5;

    elseif r_member == 0
        outputIRs(n,:,1) = IRs(f_Index, :, 1);
        outputIRs(n,:,2) = IRs(f_Index, :, 2);
    end
 end

%% Create Audio files
outPath = uigetdir("IRs/", "Create an IR Directory"); %Path to IR's
addpath(outPath)

 for i = 1:length(IRSet)
        outIR = squeeze(outputIRs(i, :, :));
        filename = append(outPath, '/', string(fileNames(i)));
        audiowrite(filename, outIR, Fs);
 end