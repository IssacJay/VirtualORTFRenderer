clear all 
close all

Fs = 48000; %dff Sample Rate
numDFF = 3;
YMatrix = [];
for n = 1:numDFF

    %% Diffuse Field Analysis
    dffFile = uigetfile(); %Get DFF 
    A = importdata(dffFile);
  
    
    %% Calculate Spectral Response of DFF
    Left = abs(fft(A.data(:,1))); %Get real FFT values of left channel
    %Right = abs(fft(A.data(:,2))); %Get real FFT values of right channel
    
    if n == 1 
        N = length(Left)/2; %Get length of FFT up to nyquist
        DFFs = zeros(2,N,numDFF);
    end
    Left = mag2db(Left(1:N,:)) - 6; %Convert left to dB
    
    %% Calculate DF Response
    invLeft = 0 - Left; %Left Input
    
    DFFs(1,:,n) = Left;
    DFFs(2,:,n) = invLeft;
    YMatrix = [YMatrix, Left];
    
end


    %% Calculate Output 
    %flat = invLeft + Left;
    %YMatrix = [DFFs(1,:,, invLeft, Right, invRight, flat];
    % 
    % figure(1);
    % hold on
    % dff = plot(x_axis, Left, 'r', x_axis, invLeft,'y');
    % xlim([20 20000])
    % ylim([-18 18])
    
    %% Create Plot using semilog
    x_axis = (1:Fs/N/2:Fs/2); 
    semilogx1 = semilogx(x_axis,YMatrix);
    set(semilogx1(1),'Color',[1 0 0]);
    set(semilogx1(2),'Color',[1 1 0]);
    set(semilogx1(1),'LineWidth',1,'Color',[1 0 0]);
    set(semilogx1(2),'LineWidth',1,'Color',[1 0 0]);
    set(semilogx1(3),'LineWidth',1,'Color',[0 1 1]);
    set(semilogx1(4),'LineWidth',1,'Color',[0 1 1]);
    set(semilogx1(5),'LineWidth',1,'Color',[0 1 0]);
    set(semilogx1(6),'LineWidth',1,'Color',[0 1 0]);
    
    %% Plot presentation 
    legend(["ORTF DFF" "ORTF Input" "ORTF Surround DFF" "ORTF Surround Input" "NOS DFF" "NOS Input"]);
    xlim([400 20000])
    ylim([-6 6])
    xticks([32.5 63 125 250 500 1000 2000 4000 8000 16000]);
    yticks([-18 -12 -6 0 6 12 18]);
    xlabel("Frequency (Hz)")
    ylabel("Amplitude (dB)")
    title("Diffuse Field Filter of ORTF Surround Microphone Array")
