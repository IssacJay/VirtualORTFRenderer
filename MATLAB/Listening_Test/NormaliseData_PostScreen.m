%% Post Screen Data and Normalise

%% Get length of Data
data = table2cell(ListeningTestRawData); %Listening Test Data
numRows = height(data); %Number of results
refIndex = 7;
ref2Index = 2;
AncIndex = 1;
MonoIndex = 3;
StereoIndex = 8; 

%% Output variables
Trial_ = {'Ext_dry'};
Participant_ = 1;
Renderer_ = {'KU 100'};
Score_ = 25;
NormalisedScore_ = 30;
Reference_ = 1;
Dark_ = 0;
Mono_ = 0;
Stereo_ = 0;

normalisedData = table(Trial_,Participant_,Renderer_,Score_,NormalisedScore_,Reference_, Dark_,Mono_,Stereo_);

Score = 11;
Trial = 9;
Participant = 8;
StimuliInd = 10;

%%  Loop
for i = 1:numRows/8
    %% Read first 8 Data points
    trialRaw = zeros(8,6); 
    textRaw = cell(8,3);
    for d = 1:8
        index = (8*i) + d - 8; 
        trialRaw(d) = string(data(index,Score));
        textRaw(d, 1) = {string(data(index, Trial))};
        textRaw(d, 2) = data(index, Participant);
        textRaw(d, 3) = {string(data(index, StimuliInd))};

        %% Problem here - convert to table after
    end
    meanRaw = mean(trialRaw(1,:));
    sdRaw = std(trialRaw(1,:));
    Min_ = min(trialRaw(:,1));
    Max_ = max(trialRaw(:,1));
    for d = 1:8
        trialRaw(d,2) = (trialRaw(d,1) - Min_)/(Max_-Min_) * 100;
    end
    
    %% Test Reference Validity (0 good - 1 bad)
    if abs(diff([trialRaw(refIndex,1) trialRaw(ref2Index,1)])) > 20
        trialRaw(:,3) = 1;
    else
        trialRaw(:,3) = 0;
    end
    
    %% Test Dark Anchor
    if trialRaw(AncIndex,1) >= 20
        trialRaw(:,4) = 1;
    else
        trialRaw(:,4) = 0;
    end

    %% Test Mono Anchor
    if trialRaw(MonoIndex,1) >= 20
        trialRaw(:,5) = 1;
    else
        trialRaw(:,5) = 0;
    end 

    %% Test Stereo Anchor
    if trialRaw(StereoIndex,1) >= 20
        trialRaw(:,6) = 1;
    else
        trialRaw(:,6) = 0;
    end


    trialRawTable = array2table(trialRaw);
    outputdata = [textRaw trialRawTable];
    outputdata = renamevars(outputdata,["Var1","Var2","Var3","trialRaw1","trialRaw2","trialRaw3","trialRaw4","trialRaw5","trialRaw6"],...
        ["Trial_","Participant_","Renderer_","Score_","NormalisedScore_","Reference_","Dark_","Mono_","Stereo_"]);
    normalisedData = [normalisedData; outputdata];
end

normalisedData = renamevars(normalisedData,["Trial_","Participant_","Renderer_","Score_","NormalisedScore_","Reference_","Dark_","Mono_","Stereo_"],...
    ["Trial","Participant","Renderer","Score","NormalisedScore","Reference","Dark","Mono","Stereo"]);

normalisedData(1,:) = []; % Delete Example Row
writetable(normalisedData,'NormalisedQoEData.csv');