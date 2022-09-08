%Get Array for Lebydev Index
clear all
close all
clc

irPath = uigetdir; %Path to IR's
IRSet = dir(fullfile(irPath, '*.wav')); %Get all IR's in Path
Index = zeros(length(IRSet), 2);

for k = 1:length(IRSet)
    IRname = IRSet(k).name; 
    [~,IRName,~]=fileparts(IRname);
    azi_ele = strsplit(IRName, '_');
    
    azi = strrep(azi_ele(2), ',', '.');
    ele = strrep(azi_ele(4), ',', '.');
    
    
    Index(k, 1) = str2num(cell2mat(azi(1)));
    Index(k, 2) = str2num(cell2mat(ele(1)));
end