
%% Before the start of the experiment
%addpath("E:\Users\MAGIC-0.1-beta\")
o = magventure('COM1'); 
o.connect(); 
[e, r]=o.getStatus();
o.setTrain(25,2,1,1); %a pulse train of 25 Hz, 2 pulses, 1 repetition, 1 second between repetitions (irrelevant here)
TMS_intensity = 50; %TMS intensity is based on phosphene threshold. Different for each participant.

%% Each run
[e,r]=o.arm(); %This arms the TMS so that it is ready to fire
o.setAmplitude(TMS_intensity); %Tms intensity can only be set in the machine when it is armed

%
% Code
% for
% experimental
% run
%

%% At the end
[e,r]=o.disarm(1);
o.disconnect();
