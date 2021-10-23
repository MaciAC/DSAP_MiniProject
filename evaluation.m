clear all;
addpath(genpath("obj_evaluation_quality")); % We will use the Matlab code from Loizou

% Use |audioDatastore| to create a datastore for the files in the "..." folder.
experiment = "data/babble/10db";
specific = 0;
plots = true;

% Read and process the contents of each file from the datastore
samplingFreq=8000;
names = ["wiener" "soft" "." "cohen"];

for option=[ 2, 4]
noisy=audioDatastore(experiment); % Change it to the proper folder
clean=audioDatastore("data/clean");

for n=1:30
    if specific == 0 || specific == n 
    fileID = fopen('results/' + names(option) + "_" + experiment.replace('/', '_') + '.txt','w'); % Results will be saved for comparison

    [NoisySignal] = read(noisy);
    [CleanSignal] = read(clean);

    filename = string(noisy.Files(n));
    C = strsplit(filename, '/');

    output =  "/Users/maciaac/Documents/UPC/DSAP/miniproject/DSAP_MiniProject/results/";

    aux_output = output + names(option)+ "/" + C(end);
    if option ~=1
        pSAP = logmmse_SPU(filename, aux_output, option);
    else
        wiener_as(filename, aux_output); % Wiener filter
    end
    if plots
    figure();
    subplot(2,1,1);
    hold on
    plot(NoisySignal);
    [CleanedSignal, Srate]= audioread(aux_output);
    plot(CleanedSignal);
    xlim([0 size(CleanedSignal,1)]);

    %plot(CleanSignal);

    subplot(2,1,2);
    imagesc(pSAP(1:70,:)*150);
    saveas(gcf,'results/plots/Signals_' + extractBefore(C(end), '.') + '_' + names(option) + "_" + experiment.replace('/', '_') +'.png');
    end
    % Process the file, put the cleaned signal in CleanedSignal
    %audiowrite("NoisySignal.wav",NoisySignal,samplingFreq);
    %wiener_as("NoisySignal.wav","CleanedSignal.wav"); % Wiener filter
    
    % Compute evaluation measures
    %audiowrite("CleanSignal.wav",CleanSignal,samplingFreq);
    [snr_mean(n), segsnr_mean(n)]= comp_snr(clean.Files{n},aux_output);
    Pesq(n)=pesq(clean.Files{n},aux_output);
    [sig(n),bak(n),ovl(n)]=composite(clean.Files{n},aux_output);
    end
end

% Average measures
snr_m=mean(snr_mean);
segsnr_m=mean(segsnr_mean);
pesq_m=mean(Pesq);

sig_m=mean(sig); % predicted rating [1-5] of speech distortion
bak_m=mean(bak); % predicted rating [1-5] of noise distortion
ovl_m=mean(ovl); % predicted rating [1-5] of overall quality

% Print results in file results.txt
fprintf(fileID,'\n segsnr_m=%1.1f pesq_m=%1.1f sig_m=%1.1f bak_m=%1.1f ovl_m=%1.1f\n',segsnr_m, pesq_m, sig_m, bak_m, ovl_m);
end