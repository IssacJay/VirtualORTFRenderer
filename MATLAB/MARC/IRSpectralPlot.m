%% Spectrogram
Fs = 48000; %dff Sample Rate
numDFF = 1;
N = 128;
for n = 1:numDFF
    IRFile = uigetdir(); %Get IR 
    for i = 1:length(IRFile)
        IR = audioread(IRFile);
        Y = abs(fft(IR(:,1)));
        Y = mag2db(Y(1:N,:));
        Y = Y(1:N/2); 
        XREF = abs(max(max(Y))); 
        Y = Y./XREF * 0.99; % 0-1 scale 
        x_axis = (1:Fs/N:Fs/2); 
        %subplot(2, 2, n); plot(x_axis, Y);grid;
    end
end
%ylim([-80, 0])
%title(['Frequency Domain Plot from ' num2str(y_start) ' Samples: ' FileName]);
xlabel('Frequency (Hz)') 
ylabel('Amplitude (dB)') 
xlim([0 Fs/2])