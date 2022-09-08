%% Get Results from Localisation Test
clc;
%% Input Variables
data = table2cell(ListeningTestRawData1); %Listening Test Data
numRows = height(data); %Number of results

%% Output Variables
Renderer = {'KU100'}; % Renderer type
File = {'BRK_C2'}; % Test audio file
SourceAzi = 0; % Source Azimuth
SourceEle = 0; % Source Elevation
Azi = 0; % Perceived Azimuth
Ele = 0; % Perceived Elevations
FrontBack = 0;
localData = table(Renderer,File,SourceAzi,SourceEle,Azi,Ele, FrontBack);


%% Localisation Table
for row = 1:numRows
    if string(data(row,19)) == "localization" % Column header = 'wm_type'"
        %% Get Renderer
        r_Rend = string(data(row,8)); % Column header = 'responses_stimulus'
        r_Rend = strsplit(r_Rend, '_'); % Remove suffix
        r_Rend = r_Rend(1); % Use prefix (rendering format)
        %% Get File Name and Coordinate Variables
        r_File = string(data(row,21)); % Column header = 'responses_name'
        [~,r_file,~]=fileparts(r_File); %Get Filename from full file
        azi_ele = strsplit(r_file, '_'); %Split filename by '_'
        SourceAzi = str2num(azi_ele(4));
        SourceEle = str2num(azi_ele(5));
        
        %% Get User Coordinate Data
        Coord = string(data(row,7)); % Column header = 'responses_position' 
        Coord = extractNumFromStr(Coord); %Get Numbers from String
        [Th,Phi,~] = cart2sph(Coord(1),-Coord(3),Coord(2) - 125); 
        Th = rad2deg(Th);
        if Th < 0
            Th = -90 - Th;
        elseif Th >= 0
            Th = 90 - Th;
        end
        Phi = rad2deg(Phi);

        %% Check if is front back error
        if SourceAzi < 0
            fbPoint = -90 + (-90 - SourceAzi);
        elseif SourceAzi >= 0
            fbPoint = 90 + (90 - SourceAzi);
        end
        fbPoint = [fbPoint * 0.8, fbPoint * 1.2];
        if SourceAzi < 0
            if Th < fbPoint(1) && Th > fbPoint(2)
                isFB = 1;
            else
                isFB = 0;
            end
        elseif SourceAzi >= 0
            if Th > fbPoint(1) && Th < fbPoint(2)
                isFB = 1;
            else
                isFB = 0;
            end
        end



        %% Add output to table 
        outdata = {r_Rend,r_File,SourceAzi,SourceEle,Th, Phi, isFB};
        localData = [localData; outdata];
    end
end
localData(1,:) = []; % Delete Example Row
 
%% Get Numbers from String
% [https://www.mathworks.com/matlabcentral/answers/44049-extract-numbers-from-mixed-string]
function numArray = extractNumFromStr(str)
str1 = regexprep(str,'[,;=]', ' ');
str2 = regexprep(regexprep(str1,'[^- 0-9.eE(,)/]',''), ' \D* ',' ');
str3 = regexprep(str2, {'\.\s','\E\s','\e\s','\s\E','\s\e'},' ');
numArray = str2num(str3);

end

