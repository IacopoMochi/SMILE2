function metrics = measureLines(edges,app)

ps = edges.PS(1); %We assume the PS is the same for all the averaged images
if ~isfield(edges,'Average_PSD_LWR')
    Output = edges;


    Le_f = Output.leadingEdgeProfilesFilledCorrected.*ps;
    Te_f = Output.trailingEdgeProfilesFilledCorrected.*ps;
    LWvar = Output.LWvar*ps;
    %Evaluate average CD
    LW_f = Te_f-Le_f; %line widths

    LC_f = (Te_f+Le_f)/2; %line centers
    ALC_f = mean(LC_f); %mean center per line
    ACD_f = mean(LW_f); %Average CD per line
    ALC_f = ALC_f(ACD_f<1.5*mean(ACD_f)); %Discard lines with missing edges
    ACD_f = ACD_f(ACD_f<1.5*mean(ACD_f)); %Discard lines with missing edges
    LinesCenters = ALC_f;
    LinesCD = ACD_f;
    mCD = mean(ACD_f); %Average CD
    stdCD = std(ACD_f); %CD Standard deviation

    %Evaluate average LWR PSD
    LW = LWvar; %line widths
    LW = LW-mean(LW,1,'omitnan');
    %Evaluate average LER PSD
    Le_f = Le_f-mean(Le_f,1,'omitnan'); %line profiles
    Te_f = Te_f-mean(Te_f,1,'omitnan');

    if app.MultitaperButton.Value
        N = size(LW,1);
        Ntapers = app.NumberoftapersEditField.Value;

        if app.MultitaperButton.Value
            if strcmp(app.TaperfunctionsDropDown.Value,'Slepian')
                dps_seq = dpss(N,Ntapers/2);
            else %Sinusoidal
                dps_seq = zeros(N,Ntapers);
                for nseq = 1:Ntapers
                    %dps_seq(:,nseq) = sqrt(2/(Ntapers+1))*sin(pi*nseq*(1:N)/(N+1));
                    taper = sin(pi*nseq*(1:N)/(N+1));
                    taper = taper./sqrt(sum(taper.*taper));
                    dps_seq(:,nseq) = taper;
                end
            end
        end

        %LWR
        Tap = ones(size(LW,1),size(LW,2),size(dps_seq,2));
        for ntap = 1:Ntapers
            dps = (ones(size(LW,2),1)*dps_seq(:,ntap)')';
            Tap(:,:,ntap) = dps.*LW;
        end
        F_LW = mean(abs(fft(Tap)),3)*sqrt(size(Tap,1));
        %F_LW = fft(LW);
        %LER_l
        Tap = ones(size(Le_f,1),size(Le_f,2),size(dps_seq,2));
        for ntap = 1:Ntapers
            dps = (ones(size(Le_f,2),1)*dps_seq(:,ntap)')';
            Tap(:,:,ntap) = dps.*Le_f;
        end
        F_Le = mean(abs(fft(Tap)),3)*sqrt(size(Tap,1));
        %F_Le = fft(Le_f);
        %LER_t
        Tap = ones(size(Te_f,1),size(Te_f,2),size(dps_seq,2));
        for ntap = 1:Ntapers
            dps = (ones(size(Te_f,2),1)*dps_seq(:,ntap)')';
            Tap(:,:,ntap) = dps.*Te_f;
        end
        F_Te = mean(abs(fft(Tap)),3)*sqrt(size(Tap,1));
        %F_Te = fft(Te_f);
        %LER_lt
        Tap = ones(size([Le_f Te_f],1),size([Le_f Te_f],2),size(dps_seq,2));
        for ntap = 1:Ntapers
            dps = (ones(size([Le_f Te_f],2),1)*dps_seq(:,ntap)')';
            Tap(:,:,ntap) = dps.*[Le_f Te_f];
        end
        F_LTe = mean(abs(fft(Tap)),3)*sqrt(size(Tap,1));
        %F_LTe = fft([Le_f Te_f]);
    else
        F_LW = fft(LW);
        F_Le = fft(Le_f);
        F_Te = fft(Te_f);
        F_LTe = fft([Le_f Te_f]);
    end
    %Calculate the correlation length
    sm = mean(std(LW)); %Average LWR standard deviation
    sml = mean(std(Le_f)); %Average standard deviation Le
    smt = mean(std(Te_f)); %Average standard deviation Te
    smlt = mean(std([Le_f Te_f])); %Average standard deviation Le+Te

    %%%%%%
    CorrLengthGuess = 20;

    %[H1,r_1] = hhcf(LW(:,1)-mean(LW(:,1)),ps);
    if ~isempty(LW)
        try
            [H1,r_1] = hhcf(LW(:,1),ps);
        catch
            disp('buca')
        end
        H1 = zeros(size(H1,1),size(LW,2));
        for k = 1:size(LW,2)
            %[H1(:,k),~] = hhcf(LW(:,k)-mean(LW(:,k)),ps);
            [H1(:,k),~] = hhcf(LW(:,k),ps);
        end
        H1 = mean(H1,2); %Average height-height correlation function
        beta0_1 = [(max(H1)-min(H1))/2 CorrLengthGuess 1 min(H1)];

        %%%%%%

        [H2,r_2] = hhcf(Le_f(:,1)-mean(Le_f(:,1)),ps);
        H2 = zeros(size(H2,1),size(Le_f,2));
        for k = 1:size(Le_f,2)
            [H2(:,k),~] = hhcf(Le_f(:,k)-mean(Le_f(:,k)),ps);
        end
        H2 = mean(H2,2); %Average height-height correlation function
        beta0_2 = [(max(H2)-min(H2))/2 CorrLengthGuess 1 min(H2)];
        %%%%%%
        [H3,r_3] = hhcf(Te_f(:,1)-mean(Te_f(:,1)),ps);
        H3 = zeros(size(H3,1),size(Te_f,2));
        for k = 1:size(Te_f,2)
            [H3(:,k),~] = hhcf(Te_f(:,k)-mean(Te_f(:,k)),ps);
        end
        H3 = mean(H3,2); %Average height-height correlation function
        beta0_3 = [(max(H3)-min(H3))/2 CorrLengthGuess 1 min(H3)];
        %%%%%%
        Ae = [Te_f Le_f];
        [H4,r_4] = hhcf(Ae(:,1)-mean(Ae(:,1)),ps);
        H4 = zeros(size(H4,1),size(Ae,2));
        for k = 1:size(Ae,2)
            [H4(:,k),~] = hhcf(Ae(:,k)-mean(Ae(:,k)),ps);
        end
        H4 = mean(H4,2); %Average height-height correlation function
        beta0_4 = [(max(H4)-min(H4))/2 CorrLengthGuess 1 min(H4)];
        %%%%%%
        try
            beta = nlinfit(r_1',H1,@hhcfmod,beta0_1);
        catch
            beta =beta0_1;
        end
        try
            beta2 = nlinfit(r_2',H2,@hhcfmod,beta0_2);
        catch
            beta2 =beta0_2;
        end
        try
            beta3 = nlinfit(r_3',H3,@hhcfmod,beta0_3);
        catch
            beta3 =beta0_3;
        end
        try
            beta4 = nlinfit(r_4',H4,@hhcfmod,beta0_4);
        catch
            beta4 =beta0_4;
        end




        HHCorrFunc = H1;
        HHCorrFuncFit = real(hhcfmod(beta,r_1));
        LWRCorrLength = 2*beta(2);

        HHCorrFunc2 = H2;
        HHCorrFuncFit2 = real(hhcfmod(beta2,r_2));
        LWRCorrLength2 = 2*beta2(2);

        HHCorrFunc3 = H3;
        HHCorrFuncFit3 = real(hhcfmod(beta3,r_3));
        LWRCorrLength3 = 2*beta3(2);

        HHCorrFunc4 = H4;
        HHCorrFuncFit4 = real(hhcfmod(beta4,r_4));
        LWRCorrLength4 = 2*beta4(2);

    end
    %PSD_LWR = mF_LW;
    %PSD_LER1 = mF_LEl;
    %PSD_LER2 = mF_LEt;
    %PSD_LER = mF_LE;

    LWR3s = 3*sm;
    LER3s = 3*smlt;
    LERl3s = 3*sml;
    LERt3s = 3*smt;

    %%%%Calculate bias


    %Evaluate average LWR
    N = size(LW,1);
    Fs = 1/ps;

    freq = 0:Fs/N:Fs/2-Fs/N;
    freqL = 0:Fs/N:Fs-Fs/N;
    %F_LW = F_LW(1:length(freq),:);

    mF_LW = mean(abs(F_LW).^2,2,'omitnan'); % Average LW PSD (uncut)
    mF_LER = mean(abs(F_LTe).^2,2,'omitnan'); % Average LER PSD (uncut)
    mF_LERl = mean(abs(F_Le).^2,2,'omitnan'); % Average LERl PSD (uncut)
    mF_LERt = mean(abs(F_Te).^2,2,'omitnan'); % Average LERt PSD (uncut)


    %     L = length(mF_LW);
    %
    %     mF_LW = mF_LW/L;


    %Estimate max of PSD  form the first FN elements
    %Estimate floor of PSD  form the last LN elements
    %Guess of the correlation length: CL
    %Exclude the first ExN elements from the fit.

    FN  = app.LowfrequencyaverageEditField.Value;
    LN  = app.HighfrequencyaverageEditField.Value;
    CF = app.CorrelationfrequencyEditField.Value;
    ExN = app.LowfrequencyexclusionEditField.Value;
    ExNe = app.HighfrequencyexclusionEditField.Value;
    Alpha = app.AlphaEditField.Value;
    MFE = app.MaximumfunctionevaluationsEditField.Value;
    MI = app.MaximumnumberofiterationsEditField.Value;

    %Variables for the fit
    freqx = freq(ExN+1:end-ExNe);

    mF_LWx= mF_LW(1:length(freq));
    mF_LWx= mF_LWx(ExN+1:end-ExNe);
    mF_LERx= mF_LER(1:length(freq));
    mF_LERx= mF_LERx(ExN+1:end-ExNe);
    mF_LERlx= mF_LERl(1:length(freq));
    mF_LERlx= mF_LERlx(ExN+1:end-ExNe);
    mF_LERtx= mF_LERt(1:length(freq));
    mF_LERtx= mF_LERtx(ExN+1:end-ExNe);

    Lx = length(mF_LWx);

    PSDmodel = app.PSDmodelDropDown.Value;

    if strcmp(PSDmodel,'Gaussian')
        model = @Gaussian;
        beta0 = [mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LWx(Lx-LN:Lx),'omitnan')];
        f = @(beta,freqx,mF_LWx) sum((Gaussian(beta,freqx)-mF_LWx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LWx),beta0,Options);
        mF_LW_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LW_fit_unbiased = model(betan,freq);
        betaf_LW = betaf;

        beta0 = [mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERx(Lx-LN:Lx),'omitnan')];
        f = @(beta,freqx,mF_LERx) sum((Gaussian(beta,freqx)-mF_LERx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LER = fminsearch(@(beta) f(beta,freqx,mF_LERx),beta0,Options);
        mF_LER_fit = model(betaf_LER,freq);
        betan = betaf_LER;
        betan(3) = 0;
        mF_LER_fit_unbiased = model(betan,freq);

        beta0 = [mean(mF_LERlx(1:FN),'omitnan')-mean(mF_LERlx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERlx(Lx-LN:Lx),'omitnan')];
        f = @(beta,freqx,mF_LERlx) sum((Gaussian(beta,freqx)-mF_LERlx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERl = fminsearch(@(beta) f(beta,freqx,mF_LERlx),beta0,Options);
        mF_LERl_fit = model(betaf_LERl,freq);
        betan = betaf_LERl;
        betan(3) = 0;
        mF_LERl_fit_unbiased = model(betan,freq);

        beta0 = [mean(mF_LERtx(1:FN),'omitnan')-mean(mF_LERtx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERtx(Lx-LN:Lx),'omitnan')];
        f = @(beta,freqx,mF_LERtx) sum((Gaussian(beta,freqx)-mF_LERtx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERt = fminsearch(@(beta) f(beta,freqx,mF_LERtx),beta0,Options);
        mF_LERt_fit = model(betaf_LERt,freq);
        betan = betaf_LERt;
        betan(3) = 0;
        mF_LERt_fit_unbiased = model(betan,freq);


    elseif strcmp(PSDmodel,'Floating alpha')
        model = @FloatingAlpha;
        beta0 = [mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LWx(Lx-LN:Lx),'omitnan'),Alpha];
        f = @(beta,freqx,mF_LWx) sum((FloatingAlpha(beta,freqx)-mF_LWx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LWx),beta0,Options);
        mF_LW_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LW_fit_unbiased = model(betan,freq);
        betaf_LW = betaf;

        beta0 = [mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERx(Lx-LN:Lx),'omitnan'),Alpha];
        f = @(beta,freqx,mF_LERx) sum((FloatingAlpha(beta,freqx)-mF_LERx).^2);
        betaf_LER = fminsearch(@(beta) f(beta,freqx,mF_LERx),beta0,Options);
        mF_LER_fit = model(betaf_LER,freq);
        betan = betaf_LER;
        betan(3) = 0;
        mF_LER_fit_unbiased = model(betan,freq);

        beta0 = [mean(mF_LERlx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERlx(Lx-LN:Lx),'omitnan'),Alpha];
        f = @(beta,freqx,mF_LERlx) sum((FloatingAlpha(beta,freqx)-mF_LERlx).^2);
        betaf_LERl = fminsearch(@(beta) f(beta,freqx,mF_LERlx),beta0,Options);
        mF_LERl_fit = model(betaf_LERl,freq);
        betan = betaf_LERl;
        betan(3) = 0;
        mF_LERl_fit_unbiased = model(betan,freq);

        beta0 = [mean(mF_LERtx(1:FN),'omitnan')-mean(mF_LERtx(Lx-LN:Lx),'omitnan'),1/CF,mean(mF_LERtx(Lx-LN:Lx),'omitnan'),Alpha];
        f = @(beta,freqx,mF_LERtx) sum((FloatingAlpha(beta,freqx)-mF_LERtx).^2);
        betaf_LERt = fminsearch(@(beta) f(beta,freqx,mF_LERtx),beta0,Options);
        mF_LERt_fit = model(betaf_LERt,freq);
        betan = betaf_LERt;
        betan(3) = 0;
        mF_LERt_fit_unbiased = model(betan,freq);

    elseif strcmp(PSDmodel,'No white noise')
        model = @NoWhiteNoise;
        beta0 = [sqrt(mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan')), CF, 2];
        f = @(beta,freqx,mF_LWx) sum((NoWhiteNoise(beta,freqx)-mF_LWx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LWx),beta0,Options);
        mF_LW_fit = model(betaf,freq);
        mF_LW_fit_unbiased = mF_LW_fit;
        betaf_LW = betaf;

        beta0 = [sqrt(mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan')), CF, 2];
        f = @(beta,freqx,mF_LERx) sum((NoWhiteNoise(beta,freqx)-mF_LERx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LER = fminsearch(@(beta) f(beta,freqx,mF_LERx),beta0,Options);
        mF_LER_fit = model(betaf_LER,freq);
        mF_LER_fit_unbiased = mF_LER_fit;

        beta0 = [sqrt(mean(mF_LERlx(1:FN),'omitnan')-mean(mF_LERlx(Lx-LN:Lx),'omitnan')), CF, 2];
        f = @(beta,freqx,mF_LERlx) sum((NoWhiteNoise(beta,freqx)-mF_LERlx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERl = fminsearch(@(beta) f(beta,freqx,mF_LERlx),beta0,Options);
        mF_LERl_fit = model(betaf_LERl,freq);
        mF_LERl_fit_unbiased = mF_LERl_fit;

        beta0 = [sqrt(mean(mF_LERtx(1:FN),'omitnan')-mean(mF_LERtx(Lx-LN:Lx),'omitnan')), CF, 2];
        f = @(beta,freqx,mF_LERtx) sum((NoWhiteNoise(beta,freqx)-mF_LERtx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERt = fminsearch(@(beta) f(beta,freqx,mF_LERtx),beta0,Options);
        mF_LERt_fit = model(betaf_LERt,freq);
        mF_LERt_fit_unbiased = mF_LERt_fit;

    elseif strcmp(PSDmodel,'Palasantzas1')
        model = @Palasantzas1;
        beta0 = [sqrt((mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan'))*CF), CF, (mean(mF_LWx(Lx-LN:Lx),'omitnan')),Alpha,1];
        f = @(beta,freqx,mF_LWx) sum((Palasantzas1(beta,freqx)-mF_LWx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LWx),beta0,Options);
        %betaf = beta0;
        mF_LW_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LW_fit_unbiased = model(betan,freq);
        betaf_LW = betaf;

        beta0 = [sqrt((mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'))*CF), CF, (mean(mF_LERx(Lx-LN:Lx),'omitnan')),Alpha,1];
        f = @(beta,freqx,mF_LERx) sum((Palasantzas1(beta,freqx)-mF_LERx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERx),beta0,Options);
        mF_LER_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LER_fit_unbiased = model(betan,freq);
        betaf_LER = betaf;

        beta0 = [sqrt((mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'))*CF), CF, (mean(mF_LERlx(Lx-LN:Lx),'omitnan')),Alpha,1];
        f = @(beta,freqx,mF_LERlx) sum((Palasantzas1(beta,freqx)-mF_LERlx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERlx),beta0,Options);
        mF_LERl_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LERl_fit_unbiased = model(betan,freq);
        betaf_LERl = betaf;

        beta0 = [sqrt((mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan'))*CF), CF, (mean(mF_LERtx(Lx-LN:Lx),'omitnan')),Alpha,1];
        f = @(beta,freqx,mF_LERtx) sum((Palasantzas1(beta,freqx)-mF_LERtx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERtx),beta0,Options);
        mF_LERt_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LERt_fit_unbiased = model(betan,freq);
        betaf_LERt = betaf;
    elseif strcmp(PSDmodel,'Palasantzas2')
        model = @Palasantzas2;
        beta0 = [sqrt(mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan')), CF, (mean(mF_LWx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,freqx,mF_LWx) sum((Palasantzas2(beta,freqx)-mF_LWx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LWx),beta0,Options);
        mF_LW_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LW_fit_unbiased = model(betan,freq);
        betaf_LW = betaf;

        beta0 = [sqrt(mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan')), CF, (mean(mF_LERx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,freqx,mF_LERx) sum((Palasantzas2(beta,freqx)-mF_LERx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERx),beta0,Options);
        mF_LER_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LER_fit_unbiased = model(betan,freq);
        betaf_LER = betaf;

        beta0 = [sqrt(mean(mF_LERlx(1:FN),'omitnan')-mean(mF_LERlx(Lx-LN:Lx),'omitnan')), CF, (mean(mF_LERlx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,freqx,mF_LERlx) sum((Palasantzas2(beta,freqx)-mF_LERlx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERlx),beta0,Options);
        mF_LERl_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LERl_fit_unbiased = model(betan,freq);
        betaf_LERl = betaf;

        beta0 = [sqrt(mean(mF_LERtx(1:FN),'omitnan')-mean(mF_LERtx(Lx-LN:Lx),'omitnan')), CF, (mean(mF_LERtx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,freqx,mF_LERtx) sum((Palasantzas2(beta,freqx)-mF_LERtx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqx,mF_LERtx),beta0,Options);
        mF_LERt_fit = model(betaf,freq);
        betan = betaf;
        betan(3) = 0;
        mF_LERt_fit_unbiased = model(betan,freq);
        betaf_LERt = betaf;
    elseif strcmp(PSDmodel,'Integral')
        model = @Integral;
        edf=[find(freq==freqx(1),1),find(freq==freqx(end),1)];
        beta0 = [(mean(mF_LWx(1:FN),'omitnan')-mean(mF_LWx(Lx-LN:Lx),'omitnan')), CF, (mean(mF_LWx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,Rv,edf,mF_LW) sum((Integral(beta,freqL,edf)-mF_LW).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf = fminsearch(@(beta) f(beta,freqL,edf,mF_LWx),beta0,Options);
        mF_LW_fit = model(betaf,freqL,[1,length(freq)]);
        betan = betaf;
        betan(3) = 0;
        mF_LW_fit_unbiased = model(betan,freqL,[1,length(freq)]);
        betaf_LW = betaf;

        beta0 = [sqrt(mean(mF_LERx(1:FN),'omitnan')-mean(mF_LERx(Lx-LN:Lx),'omitnan')), 1/CF, (mean(mF_LERx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,Rv,edf,mF_LERx) sum((Integral(beta,freqL,edf)-mF_LERx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LER = fminsearch(@(beta) f(beta,freqL,edf,mF_LERx),beta0,Options);
        %betaf = beta0;
        mF_LER_fit = model(betaf_LER,freq,[1,length(freq)]);
        betan = betaf_LER;
        betan(3) = 0;
        mF_LER_fit_unbiased = model(betan,freq,[1,length(freq)]);

        beta0 = [sqrt(mean(mF_LERlx(1:FN),'omitnan')-mean(mF_LERlx(Lx-LN:Lx),'omitnan')), 1/CF, (mean(mF_LERlx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,Rv,edf,mF_LERlx) sum((Integral(beta,freqL,edf)-mF_LERlx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERl = fminsearch(@(beta) f(beta,freqL,edf,mF_LERlx),beta0,Options);
        %betaf = beta0;
        mF_LERl_fit = model(betaf_LERl,freq,[1,length(freq)]);
        betan = betaf_LERl;
        betan(3) = 0;
        mF_LERl_fit_unbiased = model(betan,freq,[1,length(freq)]);

        beta0 = [sqrt(mean(mF_LERtx(1:FN),'omitnan')-mean(mF_LERtx(Lx-LN:Lx),'omitnan')), 1/CF, (mean(mF_LERtx(Lx-LN:Lx),'omitnan')),Alpha];
        f = @(beta,Rv,edf,mF_LERtx) sum((Integral(beta,freqL,edf)-mF_LERtx).^2);
        Options = optimset('MaxFunEvals',MFE,'MaxIter',MI);
        betaf_LERt = fminsearch(@(beta) f(beta,freqL,edf,mF_LERtx),beta0,Options);
        %betaf = beta0;
        mF_LERt_fit = model(betaf_LERt,freq,[1,length(freq)]);
        betan = betaf_LERt;
        betan(3) = 0;
        mF_LERt_fit_unbiased = model(betan,freq,[1,length(freq)]);
    end



    %L=length(mF_LW)*app.PixelsizenmEditField.Value;
    L=length(mF_LW);

    PSD = mF_LW/L;
    PSDh = mF_LW(1:length(freq))/L;
    PSD_unbiased = PSDh-betaf_LW(3)/L;
    PSD_unbiased(PSD_unbiased<0)=0;
    PSD_LWR_fit = mF_LW_fit/L;
    PSD_LWR_fit_unbiased = mF_LW_fit_unbiased/L;

    %LWR = 3*sqrt(2*ps^2*sum(PSD)/(length(PSD)));
    LWR = 3*sqrt(sum(PSD)/L);
    LWR_unbiased = 3*sqrt(sum(PSD_unbiased)/L);
    LWR_fit = 3*sqrt(sum(PSD_LWR_fit)/L);
    LWR_fit_unbiased = 3*sqrt(sum(PSD_LWR_fit_unbiased)/L);
    PSD_LWR_beta = betaf_LW;

    %LER
    PSD_LER = mF_LER/L;
    PSD_LERh = mF_LER(1:length(freq))/L;
    PSD_LER_unbiased = PSD_LERh-betaf_LER(3)/L;
    PSD_LER_unbiased(PSD_LER_unbiased<0)=0;
    PSD_LER_fit = mF_LER_fit/L;
    PSD_LER_fit_unbiased = mF_LER_fit_unbiased/L;

    LER = 3*sqrt(sum(PSD_LER)/L);
    LER_unbiased = 3*sqrt(sum(PSD_LER_unbiased)/L);
    LER_fit = 3*sqrt(sum(PSD_LER_fit)/L);
    LER_fit_unbiased = 3*sqrt(sum(PSD_LER_fit_unbiased)/L);
    PSD_LER_beta = betaf_LER;

    %LERl
    PSD_LERl = mF_LERl/L;
    PSD_LERlh = mF_LERl(1:length(freq))/L;
    PSD_LERl_unbiased = PSD_LERlh-betaf_LERl(3)/L;
    PSD_LERl_unbiased(PSD_LERl_unbiased<0)=0;
    PSD_LERl_fit = mF_LERl_fit/L;
    PSD_LERl_fit_unbiased = mF_LERl_fit_unbiased/L;

    LERl = 3*sqrt(sum(PSD_LERl)/L);
    LERl_unbiased = 3*sqrt(sum(PSD_LERl_unbiased)/L);
    LERl_fit = 3*sqrt(sum(PSD_LERl_fit)/L);
    LERl_fit_unbiased = 3*sqrt(sum(PSD_LERl_fit_unbiased)/L);
    PSD_LERl_beta = betaf_LERl;

    %LERt
    PSD_LERt = mF_LERt/L;
    PSD_LERth = mF_LERt(1:length(freq))/L;
    PSD_LERt_unbiased = PSD_LERth-betaf_LERt(3)/L;
    PSD_LERt_unbiased(PSD_LERt_unbiased<0)=0;
    PSD_LERt_fit = mF_LERt_fit/L;
    PSD_LERt_fit_unbiased = mF_LERt_fit_unbiased/L;

    LERt = 3*sqrt(sum(PSD_LERt)/L);
    LERt_unbiased = 3*sqrt(sum(PSD_LERt_unbiased)/L);
    LERt_fit = 3*sqrt(sum(PSD_LER_fit)/L);
    LERt_fit_unbiased = 3*sqrt(sum(PSD_LERt_fit_unbiased)/L);
    PSD_LERt_beta = betaf_LERt;

    %     if app.MultitaperButton.Value
    %            %LWR = 3*sqrt(sum(2*mF_LW.^2)/ps);
    %
    %     PSD2 = mF_LW2;
    %     PSDh2 = mF_LW2(1:length(freq));
    %     PSD_unbiased2 = (PSDh2-betaf_LW2(3));
    %     PSD_unbiased2(PSD_unbiased2<0)=0;
    %     PSD_LWR_fit2 = mF_LW_fit2;
    %     PSD_LWR_fit_unbiased2 = mF_LW_fit_unbiased2;
    %
    %     %LWR = 3*sqrt(2*ps^2*sum(PSD)/(length(PSD)));
    %     LWR2 = 3*sqrt(sum(PSD2))/length(PSD2);
    %     LWR_unbiased2 = 3*sqrt(2*sum(PSD_unbiased2))/length(PSD2);
    %     LWR_fit2 = 3*sqrt(2*sum(PSD_LWR_fit2))/length(PSD2);
    %     LWR_fit_unbiased2 = 3*sqrt(2*sum(PSD_LWR_fit_unbiased2))/length(PSD2);
    %     PSD_LWR_beta2 = betaf_LW2;
    %
    %     %LER
    %     PSD_LER = mF_LER;
    %     PSD_LERh = mF_LER(1:length(freq));
    %     PSD_LER_unbiased = (PSD_LERh-betaf_LER(3));
    %     PSD_LER_unbiased(PSD_LER_unbiased<0)=0;
    %     PSD_LER_fit = mF_LER_fit;
    %     PSD_LER_fit_unbiased = mF_LER_fit_unbiased;
    %
    %     LER = 3*sqrt(sum(PSD_LER))/length(PSD_LER);
    %     LER_unbiased = 3*sqrt(2*sum(PSD_LER_unbiased))/length(PSD_LER);
    %     LER_fit = 3*sqrt(2*sum(PSD_LER_fit))/length(PSD_LER);
    %     LER_fit_unbiased = 3*sqrt(2*sum(PSD_LER_fit_unbiased))/length(PSD_LER);
    %     PSD_LER_beta = betaf_LER;
    %
    %     %LERl
    %     PSD_LERl = mF_LERl;
    %     PSD_LERlh = mF_LERl(1:length(freq));
    %     PSD_LERl_unbiased = (PSD_LERlh-betaf_LERl(3));
    %     PSD_LERl_unbiased(PSD_LERl_unbiased<0)=0;
    %     PSD_LERl_fit = mF_LERl_fit;
    %     PSD_LERl_fit_unbiased = mF_LERl_fit_unbiased;
    %
    %     LERl = 3*sqrt(sum(PSD_LERl))/length(PSD_LERl);
    %     LERl_unbiased = 3*sqrt(2*sum(PSD_LERl_unbiased))/length(PSD_LERl);
    %     LERl_fit = 3*sqrt(2*sum(PSD_LERl_fit))/length(PSD_LERl);
    %     LERl_fit_unbiased = 3*sqrt(2*sum(PSD_LERl_fit_unbiased))/length(PSD_LERl);
    %     PSD_LERl_beta = betaf_LERl;
    %
    %     %LERt
    %     PSD_LERt = mF_LERt;
    %     PSD_LERth = mF_LERt(1:length(freq));
    %     PSD_LERt_unbiased = (PSD_LERth-betaf_LERt(3));
    %     PSD_LERt_unbiased(PSD_LERt_unbiased<0)=0;
    %     PSD_LERt_fit = mF_LERt_fit;
    %     PSD_LERt_fit_unbiased = mF_LERt_fit_unbiased;
    %
    %     LERt = 3*sqrt(sum(PSD_LERt))/length(PSD_LERt);
    %     LERt_unbiased = 3*sqrt(2*sum(PSD_LERt_unbiased))/length(PSD_LERt);
    %     LERt_fit = 3*sqrt(2*sum(PSD_LER_fit))/length(PSD_LER);
    %     LERt_fit_unbiased = 3*sqrt(2*sum(PSD_LERt_fit_unbiased))/length(PSD_LERt);
    %     PSD_LERt_beta = betaf_LERt;
    %     end
    %

    %%%%
    % imagesc(Output.Arc);axis image
    % hold on
    % for m = 1:size(Le,2)
    %     plot(squeeze(Le(:,m)./ps),1:size(Output.Arc,1),'linewidth',1,'color','r')
    %     plot(squeeze(Te(:,m)./ps),1:size(Output.Arc,1),'linewidth',1,'color','r')
    % end
    % hold off
    % drawnow

    metrics.LWprofiles = LW;
    if isempty(LW)
        metrics.HHCorrFunc = zeros(size(LW,1),1);
        metrics.HHCorrFuncFit = zeros(size(LW,1),1);
        metrics.LWRCorrLength = 0;
        metrics.HHCorrFunc_LER = zeros(size(LW,1),1);
        metrics.HHCorrFuncFit_LER = zeros(size(LW,1),1);
        metrics.LERCorrLength = 0;
        metrics.HHCorrFunc_LERl = zeros(size(LW,1),1);
        metrics.HHCorrFuncFit_LERl = zeros(size(LW,1),1);
        metrics.LERlCorrLength = 0;
        metrics.HHCorrFunc_LERt = zeros(size(LW,1),1);
        metrics.HHCorrFuncFit_LERt = zeros(size(LW,1),1);
        metrics.LERtCorrLength = 0;
        metrics.r = 0;
    else
        metrics.HHCorrFunc = HHCorrFunc;
        metrics.HHCorrFuncFit = HHCorrFuncFit;
        metrics.LWRCorrLength = LWRCorrLength;
        metrics.HHCorrFunc_LER = HHCorrFunc4;
        metrics.HHCorrFuncFit_LER = HHCorrFuncFit4;
        metrics.LERCorrLength = LWRCorrLength4;
        metrics.HHCorrFunc_LERl = HHCorrFunc2;
        metrics.HHCorrFuncFit_LERl = HHCorrFuncFit2;
        metrics.LERlCorrLength = LWRCorrLength2;
        metrics.HHCorrFunc_LERt = HHCorrFunc3;
        metrics.HHCorrFuncFit_LERt = HHCorrFuncFit3;
        metrics.LERtCorrLength = LWRCorrLength3;
        metrics.r = r_1;
    end
    metrics.LinesCD = LinesCD;
    metrics.PSD_LWR_fit = PSD_LWR_fit;
    metrics.PSD_LWR_fit_unbiased = PSD_LWR_fit_unbiased;
    metrics.PSD_LWR_beta = PSD_LWR_beta;
    metrics.PSD_LWR_unbiased = PSD_unbiased;
    metrics.PSD_LER = PSD_LERh;
    metrics.PSD_LER_fit = PSD_LER_fit;
    metrics.PSD_LER_unbiased = PSD_LER_unbiased;
    metrics.PSD_LER_fit_unbiased = PSD_LER_fit_unbiased;
    metrics.PSD_LER_beta = PSD_LER_beta;
    metrics.PSD_LERl = PSD_LERlh;
    metrics.PSD_LERl_unbiased = PSD_LERl_unbiased;
    metrics.PSD_LERl_fit = PSD_LERl_fit;
    metrics.PSD_LERl_fit_unbiased = PSD_LERl_fit_unbiased;
    metrics.PSD_LERl_beta = PSD_LERl_beta;
    metrics.PSD_LERt = PSD_LERth;
    metrics.PSD_LERt_unbiased = PSD_LERt_unbiased;
    metrics.PSD_LERt_fit = PSD_LERt_fit;
    metrics.PSD_LERt_fit_unbiased = PSD_LERt_fit_unbiased;
    metrics.PSD_LERt_beta = PSD_LERt_beta;

    metrics.LinesCenters = LinesCenters;

    metrics.PSD = PSDh;
    metrics.mCD = mCD;
    metrics.stdCD = stdCD;
    metrics.LWR3s = LWR3s;
    metrics.LER3s = LER3s;
    metrics.LERl3s = LERl3s;
    metrics.LERt3s = LERt3s;
    metrics.LWR = LWR;
    metrics.LWR_unbiased = LWR_unbiased;
    metrics.LWR_fit = LWR_fit;
    metrics.LWR_fit_unbiased = LWR_fit_unbiased;
    %metrics.LWR2 = LWR2;
    %metrics.LWR_unbiased2 = LWR_unbiased2;
    %metrics.LWR_fit2 = LWR_fit2;
    %metrics.LWR_fit_unbiased2 = LWR_fit_unbiased2;
    metrics.LER = LER;
    metrics.LER_unbiased = LER_unbiased;
    metrics.LER_fit = LER_fit;
    metrics.LER_fit_unbiased = LER_fit_unbiased;
    metrics.LERl = LERl;
    metrics.LERl_unbiased = LERl_unbiased;
    metrics.LERl_fit = LERl_fit;
    metrics.LERl_fit_unbiased = LERl_fit_unbiased;
    metrics.LERt = LERt;
    metrics.LERt_unbiased = LERt_unbiased;
    metrics.LERt_fit = LERt_fit;
    metrics.LERt_fit_unbiased = LERt_fit_unbiased;
    metrics.freq = freq;
    metrics.beta0 = beta0;
    metrics.beta = betaf_LW;
    metrics.betaLER = betaf_LER;
    metrics.betaLERl = betaf_LERl;
    metrics.betaLERt = betaf_LERt;
    




end