function project()
    figure('Name', 'Voice Record and Modulation', 'Position', [100, 100, 600, 400]);
    
    isRecording1 = false;
    isRecording2 = false;
    audio1 = [];
    audio2 = [];
    recorder1 = [];
    recorder2 = [];

    statusText = uicontrol('Style', 'text', 'String', 'Status: Ready', ...
        'Position', [200, 350, 250, 30], 'FontSize', 10, 'HorizontalAlignment', 'left');

    uicontrol('Style', 'pushbutton', 'String', 'Record Signal 1', ...
        'Position', [20, 280, 120, 30], 'Callback', @startRecording1);
    uicontrol('Style', 'pushbutton', 'String', 'Stop Signal 1', ...
        'Position', [20, 240, 120, 30], 'Callback', @stopRecording1);

    uicontrol('Style', 'pushbutton', 'String', 'Record Signal 2', ...
        'Position', [20, 180, 120, 30], 'Callback', @startRecording2);
    uicontrol('Style', 'pushbutton', 'String', 'Stop Signal 2', ...
        'Position', [20, 140, 120, 30], 'Callback', @stopRecording2);

    uicontrol('Style', 'pushbutton', 'String', 'SSB Modulation', ...
        'Position', [20, 80, 120, 30], 'Callback', @ssb);
    uicontrol('Style', 'pushbutton', 'String', 'QAM Modulation', ...
        'Position', [20, 40, 120, 30], 'Callback', @qam);

    function startRecording1(~, ~)
        if ~isRecording1
            Fs = 48000;
            recorder1 = audiorecorder(Fs, 16, 1);
            record(recorder1);
            isRecording1 = true;
            set(statusText, 'String', 'Status: Recording Signal 1');
        end
    end

    function stopRecording1(~, ~)
        if isRecording1
            stop(recorder1);
            audio1 = getaudiodata(recorder1);
            isRecording1 = false;
            set(statusText, 'String', 'Status: Signal 1 recorded');
        end
    end

    function startRecording2(~, ~)
        if ~isRecording2
            Fs = 48000;
            recorder2 = audiorecorder(Fs, 16, 1);
            record(recorder2);
            isRecording2 = true;
            set(statusText, 'String', 'Status: Recording Signal 2');
        end
    end

    function stopRecording2(~, ~)
        if isRecording2
            stop(recorder2);
            audio2 = getaudiodata(recorder2);
            isRecording2 = false;
            set(statusText, 'String', 'Status: Signal 2 recorded');
        end
    end

    function ssb(~, ~)
    original_fs = 48000;
    target_fs = 220000;
    fc = 100000;

        if ~isempty(audio1) && ~isempty(audio2)
            set(statusText, 'String', 'Status: Applying SSB modulation...');
       
        audio1_resampled = resample(audio1, target_fs, original_fs);
        audio2_resampled = resample(audio2, target_fs, original_fs);

        t1 = (0:length(audio1_resampled)-1)/target_fs;
        t2 = (0:length(audio2_resampled)-1)/target_fs;
        f1 = linspace(-target_fs/2, target_fs/2, length(audio1_resampled));
        f2 = linspace(-target_fs/2, target_fs/2, length(audio2_resampled));

            audio1f = fftshift(fft( audio1_resampled)/length( audio1_resampled));
            audio2f = fftshift(fft( audio2_resampled)/length( audio2_resampled));

           SLSB = ssbmod(audio1_resampled, fc, target_fs, 0);
        SUSB = ssbmod(audio2_resampled, fc, target_fs, 0, 'upper');

        SLSBf = fftshift(fft(SLSB)/length(SLSB));
        SUSBf = fftshift(fft(SUSB)/length(SUSB));

        dLSB = ssbdemod(SLSB, fc, target_fs);
        dUSB = ssbdemod(SUSB, fc, target_fs);

        dLSBf = fftshift(fft(dLSB)/length(dLSB));
        dUSBf = fftshift(fft(dUSB)/length(dUSB));

        figure('Name', 'Original Signals');
        subplot(2,2,1); plot(t1, audio1_resampled); title('Signal 1 - Time'); xlabel('Time'); ylabel('Amplitude');
        subplot(2,2,2); plot(f1, audio1f); title('Signal 1 - Frequency'); xlabel('Freq'); ylabel('Magnitude');
        subplot(2,2,3); plot(t2, audio2_resampled); title('Signal 2 - Time'); xlabel('Time'); ylabel('Amplitude');
        subplot(2,2,4); plot(f2, audio2f); title('Signal 2 - Frequency'); xlabel('Freq'); ylabel('Magnitude');

        figure('Name', 'SSB Modulated');
        subplot(2,2,1); plot(t1, SLSB); title('LSB Modulated Signal 1 - Time');
        subplot(2,2,2); plot(f1, SLSBf); title('LSB Modulated Signal 1 - Freq');
        subplot(2,2,3); plot(t2, SUSB); title('USB Modulated Signal 2 - Time');
        subplot(2,2,4); plot(f2, SUSBf); title('USB Modulated Signal 2 - Freq');

        figure('Name', 'Demodulated Signals');
        subplot(2,2,1); plot(t1, dLSB); title('Demodulated LSB - Time');
        subplot(2,2,2); plot(f1, dLSBf); title('Demodulated LSB - Freq');
        subplot(2,2,3); plot(t2, dUSB); title('Demodulated USB - Time');
        subplot(2,2,4); plot(f2, dUSBf); title('Demodulated USB - Freq');
    else
        set(statusText, 'String', 'Error: Record both signals first!');
    end
end

    function qam(~, ~)
        set(statusText, 'String', 'Status: QAM modulation placeholder');
        original_fs=48000;
        target_fs=220000;
        fc = 100000;
        
        if isempty(audio1) || isempty(audio2)
        errordlg('One or both audio signals are empty. Please record audio first.', 'Audio Error');
        return;
    end

%resample the audio 
        audio1_resampled = resample(audio1, target_fs, original_fs);
        audio2_resampled = resample(audio2, target_fs, original_fs);

        %parameters 
        t1 = (0:length(audio1_resampled)-1)' /target_fs;
        t2 = (0:length(audio2_resampled)-1)/target_fs;
        f1 = linspace(-target_fs/2, target_fs/2, length(audio1_resampled));
        f2 = linspace(-target_fs/2, target_fs/2, length(audio2_resampled));
        
         %carriers 
        mc=cos(2*pi*fc*t1);
        ms=sin(2*pi*fc*t1);

      %DSB-SC audio 1 using cosine 
      audio1DSB=  audio1_resampled.*mc;   %time domain
       audio1DSBf= fftshift(fft(audio1DSB)/length(audio1DSB));%freguency domain 
      
 %DSB-SC audio 1 using sine
 a1hilbert = imag(hilbert(audio1_resampled));  % imaginary part for LSB
a1hilbertf=fftshift(fft( a1hilbert)/length( a1hilbert));%Hilbert transform frequency domain
audio1hat=a1hilbert.*ms   %hilbert*sine in time domain
 audio1hatf=fftshift(fft(audio1hat)/length(audio1hat));%hilbert*sine in frequency domain
figure  ('Name', 'DSB-SC of audio1 for LSB')
     subplot(4,1,1);
     plot(t1,a1hilbert);
     title('hilbert transform in time')
     xlabel('Time');
      ylabel('Amplitude')
     subplot(4,1,2)
     plot(f1,a1hilbertf);
         title('hilbert transform in freq')
     xlabel('Frequency');
      ylabel('Amplitude');
     subplot(4,1,3)
      plot(t1,audio1hat);
       title('audio1 hat in time domain')
      xlabel('Time');
      ylabel('Amplitude');
     subplot(4,1,4)
     title('audio1 hat in freq doamin  ')
      plot(f1,audio1hatf);
      xlabel('Frequency');
      ylabel('Amplitude');






       figure  ('Name', 'DSB-SC of audio1 for USB')
      subplot(2,1,1)
      plot(t1,audio1DSB);
      xlabel('Time');
      ylabel('Amplitude');
      subplot(2,1,2)
      plot(f1,abs(audio1DSBf));
      xlabel('frequency');
      ylabel('Amplitude');
 audio1usbf=audio1hatf - audio1DSBf;
 figure;
 plot(f1,audio1usbf)
      
      
      

    
    
    
    
    end

end