clear all;
addpath(genpath("obj_evaluation_quality")); % We will use the Matlab code from Loizou

% Use |audioDatastore| to create a datastore for the files in the "..." folder.
experiment = "data/car/10db";
specific = 0; % 0 to compute all examples 1 to 30 for an specific audio signal
plots = true;

% Read and process the contents of each file from the datastore
samplingFreq=8000;
names = ["wiener" "soft" "hard" "cohen"];

for option=[4]
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
        if option ~= 3
        pSAP = logmmse_SPU(filename, aux_output, option);
        else
        pSAP = logmmse_SPU(filename, aux_output, 1);
        end
    else
        wiener_as(filename, aux_output); % Wiener filter
    end
    if plots
    figure();
    if option ~= 1
        subpl_n = 4;
    else
        subpl_n = 3;
    end

    [CleanedSignal, Srate]= audioread(aux_output);

    subplot(subpl_n,1,1);
    plot(NoisySignal, 'b');
    title('Noisy Signal');
    xlim([0 size(CleanedSignal,1)]);

    subplot(subpl_n,1,2);
    plot(CleanSignal, 'k');
    title('Clean Signal');
    xlim([0 size(CleanedSignal,1)]);

    subplot(subpl_n,1,3);
    plot(CleanedSignal,'r');
    title('Cleaned Signal');
    xlim([0 size(CleanedSignal,1)]);

    if option ~=1
    subplot(subpl_n,1,4);
    imagesc(pSAP(1:size(pSAP,1)/2-10,:)*100);
    title('Probability of speech presence per band');

    end

    saveas(gcf,'results/plots/Signals_' + extractBefore(C(end), '.') + '_' + names(option) + "_" + experiment.replace('/', '_') +'.png');
    end
    
    % Compute evaluation measures
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

%Variances
snr_v=var(snr_mean);
segsnr_v=var(segsnr_mean);
pesq_v=var(Pesq);

sig_v=var(sig); % predicted rating [1-5] of speech distortion
bak_v=var(bak); % predicted rating [1-5] of noise distortion
ovl_v=var(ovl); % predicted rating [1-5] of overall quality


% Print results in file results.txt
fprintf(fileID,['\n segsnr_m=%1.1f pesq_m=%1.1f sig_m=%1.1f bak_m=%1.1f ovl_m=%1.1f\n \n segsnr_v=%1.1f pesq_v=%1.1f sig_v=%1.1f bak_v=%1.1f ovl_v=%1.1f\n '],segsnr_m, pesq_m, sig_m, bak_m, ovl_m,segsnr_v, pesq_v, sig_v, bak_v, ovl_v);
end