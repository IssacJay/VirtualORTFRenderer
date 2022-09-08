clear all 
close all
%% Diffuse Field Analysis
fffFile = uigetfile(); %Get DFF 
A = importdata(fffFile);
Fs = 48000; %dff Sample Rate

%% Calculate Spectral Response of DFF
Left = abs(fft(A.data(:,1))); %Get real FFT values of left channel
Right = abs(fft(A.data(:,2))); %Get real FFT values of right channel

N = length(Left)/2; %Get length of FFT up to nyquist
Left = mag2db(Left(1:N,:)); %Convert left to dB
Right = mag2db(Right(1:N,:)); %Convert right to dB

%% Calculate DF Response
invLeft = 0 - Left; %Left Input
invRight = 0 - Right; %Right Input
x_axis = (1:Fs/N/2:Fs/2); 

%% Calculate Output 
flat = invLeft + Left;
YMatrix = [Left, invLeft, Right, invRight, flat];
% 
% figure(1);
% hold on
% dff = plot(x_axis, Left, 'r', x_axis, invLeft,'y');
% xlim([20 20000])
% ylim([-18 18])

%% Create Plot using semilog
semilogx1 = semilogx(x_axis,YMatrix);
set(semilogx1(1),'Color',[1 0 0]);
set(semilogx1(2),'Color',[1 1 0]);
set(semilogx1(1),'LineWidth',2,'Color',[1 0 0]);
set(semilogx1(2),'LineWidth',2,'Color',[0 0 1]);
set(semilogx1(3),'LineWidth',1,'Color',[1 0 0]);
set(semilogx1(4),'LineWidth',1,'Color',[0 0 1]);
set(semilogx1(5),'LineWidth',1,'Color',[0 0 0]);

%% Plot presentation 
legend(["Left DFF" "Left Input" "Right DFF" "Right Input" "Output"]);
xlim([20 20000])
ylim([-18 18])
xticks([32.5 63 125 250 500 1000 2000 4000 8000 16000]);
yticks([-18 -12 -6 0 6 12 18]);
xlabel("Frequency (Hz)")
ylabel("Amplitude (dB)")
title("Diffuse Field Filter of ORTF Surround Microphone Array")
