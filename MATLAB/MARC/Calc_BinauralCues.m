%% Calculate Time and Level Difference of IR Set

%% Init
clear all
close all
clc
%% Input Variables
numIR = 4; %Number of IR Sets
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

        %% Get Azi/Ele Angles from Filename
        [per,IRName,~]=fileparts(IRname); %Get Filename from full file
        azi_ele = strsplit(IRName, '_'); %Split filename by '_'
        azi = strrep(azi_ele(2), ',', '.'); %Replace ',' with '.' to create float
        ele = strrep(azi_ele(4), ',', '.'); %Replace ',' with '.' to create float
        Index(k, 1, l) = str2num(cell2mat(azi(1))); %Add file azimuth to index matrix
        Index(k, 2, l) = str2num(cell2mat(ele(1))); %Add file elevation to index matrix
    
        %% Calculate ICLD
        ICLD(k, 1, l) = (rms(IR(:,1))); %RMS Value of Left channel
        ICLD(k, 2, l) = (rms(IR(:,2))); %RMS Value of Right channel
        ICLD(k, 3, l) = mag2db(ICLD(k,1, l)/ICLD(k,2, l)); %ICLD 
        Index(k,3, l) = ICLD(k, 3, l); %Add to Index Array
        
        %% Calculate ICTD
        % Filter to 3 kHz
        fc = 3000/(Fs/2); 
        [b,a] = butter(4,fc,'low');
        IR = filtfilt(b,a,IR);
        % Interaural X-Corr
        c = xcorr(IR(:,1),IR(:,2));
        [~,i] = max(c);
        ICTD = (length(IR)/2 - (i - length(IR)/2))/fs;
        Index(k,4, l) = ICTD;

        %% Calculate Phantom Source Shift
        shiftTD = 0.13 * (ICTD * 10000); %Phantom Shift of ICTD
        shiftLD = 0.075 * ICLD(k, 3, l); %Phantom Shift of ICLD
        phantomShift = (shiftTD + shiftLD) * 100; %Phantom Source Shift
        Index(k,5,l) = phantomShift;
        %% Azimuth == 0 Set
        if Index(k, 2, l) == 0
            if Index(k,1, l) <= 180
                polarCoord(n,1, l) = Index(k,1, l);
            elseif Index(k,1, l) > 180
                polarCoord(n,1, l) = -180 + mod(Index(k,1, l), 180) ; %Azimuth
            end
            polarCoord(n,2, l) = Index(k,2, l); %Elevation (should always be zero)
            polarCoord(n,3, l) = Index(k,3, l); %ICLD
            polarCoord(n,4, l) = Index(k,4, l); %ICTD
            polarCoord(n,5, l) = Index(k,5, l); %Phantom Source Shift
            n = n + 1; %Increase n Index
        end
        if k == length(IRSet)
                n = 1; %Reset n index for new IR Set
        end
    
    end

    %% Normalise Phantom Source Shift
    shiftMax = max(abs(polarCoord(1,5,:))); %Maximum Shift value from KU 100 (for normalisation of all shift)
    shiftFactor = shiftMax/100;
    polarCoord(:,5,:) = polarCoord(:,5,:) ./ shiftFactor; % Normalise all shift values

    %% 3D Plot
    % figure(1)
    % Index_2 = sortrows(Index);
    % Index_2 = sortrows(Index_2, 2);
    % [theta, phi] = meshgrid(Index_2(:,1),(90-Index_2(:,2)));
    % rho = 30-(abs(Index_2(:,3))); 
    % [x,y,z] = sph2cart(theta, phi, rho);
    % surf(x,y,z);
    
    %% ICLD ICTD Phantom Shift Figure
    figure(2)

    %% Sorting for ICLD Figure
    polarCoord(9,1,l) = -180; 
    polarCoord(9,3,l) = polarCoord(1,3, l); % 
    i_polarCoord = polarCoord(:,:,l); 
    i_polarCoord = sortrows(i_polarCoord);
    
    %% Plot ICLD
    sub1 = subplot(3,1,1);
    hold on
    theta = i_polarCoord(:,1);
    icld = i_polarCoord(:,3);
    ix = linspace(-180,180);
    iq = interp1(theta,icld,ix,'makima');
    ld = plot(ix,iq);
    title('Inter Channel/Aural Level Difference')

    xlim([-180 180]);
    xlabel('Source Angle (°)')
    ylabel('ICLD (dB)')
    ylim([-25 25])
    xticks(-180:30:180);
    %legend('KU100', 'ORTF', 'NOS', 'IRT-Cross', 'Location', 'SouthEast');
    switchLines(ld, l)

    %% Plot ICTD
    sub2 = subplot(3,1,2);
    hold on
    ictd = i_polarCoord(:,4);
    it = interp1(theta,ictd,ix,'spline');
    td = plot(ix, it); 
    title('Inter Channel/Aural Time Difference')
    xlabel('Source Angle (°)')
    ylabel('ICTD (Sec)')
    xlim([-180 180])
    xticks(-180:30:180);
    %ylim([-85 85])
    %legend('KU100', 'ORTF', 'NOS', 'IRT-Cross', 'Location', 'SouthEast');
    switchLines(td, l)
    
        
    %% Plot Phantom Shift
    sub3 = subplot(3,1,3);
    hold on
    phShift = i_polarCoord(:,5);
    ips = interp1(theta,phShift,ix,'spline');
    shift = plot(ix, ips); 
    title('Phantom Source Shift')
    xlabel('Source Angle (°)')
    ylabel('Phantom Source Shift (%)')
    xlim([-180 180])
    xticks(-180:30:180);
    switchLines(shift, l)
    

    end
%% Plot Design

set(sub1,'XGrid','on','XTick',...
    [-180:30:180],'YGrid','on');
set(sub2,'XGrid','on','XTick',...
    [-180:30:180],'YGrid','on');
set(sub3,'XGrid','on','XTick',...
    [-180:30:180],'YGrid','on');
l1 = legend(sub1,'show');l2 = legend(sub2,'show');l3 = legend(sub3,'show');
set(l1,'Location','southeast');set(l2,'Location','southeast');set(l3,'Location','southeast');


function [] = switchLines(plt, l)
    switch l
        case 1
            set(plt(1),'DisplayName','KU100 (Binaural Head)','LineWidth',1);
        case 2
            set(plt(1),'DisplayName','ORTF (17cm/110°)','LineWidth',1);
        case 3
            set(plt(1),'DisplayName','NOS (30cm/90°)','LineWidth',1,'LineStyle','--');
        case 4
            set(plt(1),'DisplayName','ORTF Surround (20cm/100° - 8cm/80°)','LineWidth',1,'LineStyle','--');
        case 5
            set(plt(1),'DisplayName','XY (6cm/90°)','LineWidth',1,'LineStyle','--');
    end
end