%% Sperical Coordinates to Cartesian Plot
%clear all
data = table2cell(ListeningTestRawDataS2); %Listening Test Data
numRows = height(data); %Number of results
coords = cell2mat(data(:,11:13));

Participant = 1;
Renderer = {'KU 100'};
x = 0;% Test Coordinates
y = 0;% Test Coordinates
z = 0;% Test Coordinates

X = 0;% Measured Cartesian Values
Y = 0;% Measured Cartesian Values
Z = 0;% Measured Cartesian Values

azi = 0;
ele = 0;
Azi = 0;
Ele = 0;
localData = table(Renderer,Participant,x,y,z,X,Y,Z,azi,ele,Azi,Ele);

for n = 1:numRows/12
    localRaw = zeros(12,11);
    textRaw = cell(12,1);
    for i = 1:12
        index = 12 * n + i - 12;
        localRaw(i,1) = n;
        [X,Y,Z] = sph2cart(deg2rad(coords(index,1)),deg2rad(coords(index,3)),1);
        localRaw(i,5) = X; localRaw(i,6) = Y; localRaw(i,7) = Z;
        localRaw(i,10) = coords(index,1); localRaw(i,11) = coords(index,3);


        %% Get File Name and Coordinate Variables
        r_File = string(data(index,9)); % Column header = 'responses_name'
        [~,r_file,~]=fileparts(r_File); %Get Filename from full file
        azi_ele = strsplit(r_file, '_'); %Split filename by '_'
        SourceAzi = str2num(azi_ele(4));
        SourceEle = str2num(azi_ele(5));
        [x,y,z] = sph2cart(deg2rad(SourceAzi),deg2rad(SourceEle),1);
        localRaw(i,2) = x; localRaw(i,3) = y; localRaw(i,4) = z;
        localRaw(i,8) = SourceAzi; localRaw(i,9) = SourceEle;
        %% Get Stimuli Name
        r_Rend = string(data(index,10)); % Column header = 'responses_stimulus'
        r_Rend = strsplit(r_Rend, '_'); % Remove suffix
        r_Rend = r_Rend(1); % Use prefix (rendering format
        textRaw(i) = {r_Rend};
    end

    trialRawTable = array2table(localRaw);
    outputdata = [textRaw trialRawTable];
    outputdata = renamevars(outputdata, ["Var1","localRaw1","localRaw2","localRaw3","localRaw4","localRaw5","localRaw6","localRaw7","localRaw8","localRaw9","localRaw10","localRaw11"],...
        ["Renderer","Participant","x","y","z","X","Y","Z","azi","ele","Azi","Ele"]);
    localData = [localData; outputdata];

end

localData(1,:) = []; % Delete Example Row
writetable(localData,'LocalisationData.csv');
