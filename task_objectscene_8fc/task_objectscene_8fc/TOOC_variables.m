%% Define at the beginning

listID = "B"; %A or B
TMS_intensity = 60; %85 percent of pt

%% in this script the variables will be defined.
%response keys
numpad1 = 97;
numpad2 = 98;
numpad3 = 99;
numpad4 = 100;
numpad5 = 101;
numpad6 = 102;
numpad7 = 103;
numpad8 = 104;
spaceKey = 32; escKey = 27;
x=1;    

%color settings
gray = [127 127 127 ]; white = [ 255 255 255]; black = [ 0 0 0];
bgcolor = white; textcolor = black;
mainwin = 0;

%timings
preDurSec            = 0.500;   % Fixation before new stimulus
stimDurSec          = 0.033;    % Stimulus - Pic
%maskDurSec          = 0.200;  
hz = Screen('FrameRate', mainwin);
nframes = ceil(stimDurSec*hz);

%Stimuli
addpath([pwd '/Stimuli']);
StimlistunshA = strsplit(fileread('Stimuli_listA.txt'));
new_orderA = randperm(numel(StimlistunshA));
sort(new_orderA);
StimlistA = StimlistunshA(new_orderA);
Num_StimA  = numel(StimlistA); 

StimlistunshB = strsplit(fileread('Stimuli_listB.txt'));
new_orderB = randperm(numel(StimlistunshB));
sort(new_orderB);
StimlistB = StimlistunshB(new_orderB);
Num_StimB  = numel(StimlistB); 

if listID == "A"
    Stimlist = StimlistA;
    Num_Stim = Num_StimA;
else 
    Stimlist = StimlistB;
    Num_Stim = Num_StimB;
end
