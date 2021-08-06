%% Clear the workspace and the screen
sca; %screen clear all from previous times
close all; %close all from previous times
clear; %remove all variables from previous times
Screen('Preference', 'SkipSyncTests', 0); %some standard test for the screen
KbName('UnifyKeyNames');
TOOC_variables; %load all variables
o = magventure('COM1');
o.connect();
[e, r]=o.getStatus();
o.setTrain(25,2,1,1);


%% Login prompt and open file for writing data out
ppn = inputdlg('Subject''s number:'); %a pop up window is created to enter participant number
ppn = deal(ppn{:}); %this comment allows ppn to be recognized as string (inputdlg otherwise saves it as cell type)
outputname = ['TOOCbeh_' ppn '.xls']; %outputname for the eventual file is created

if exist(outputname)==2 % check to avoid overiding an existing file
    fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) | fileproblem==3
        return;
    elseif fileproblem==1
        outputname = [outputname '.x'];
    end
end
outfile = fopen(outputname,'w'); % open a file for writing data out
fprintf(outfile, 'Trailnr\t Stimcode\t Stimulus\t Category\t old_new\t answer\t correctness\t RT\t stimprestime\t \n');
%alreadd print all the headers

HideCursor(0);

%% load images
% screen parameters
[mainwin, screenrect] = Screen('OpenWindow', 0);
Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];
Screen(mainwin, 'Flip');

stimulus = cell(1,Num_Stim); %here an empty cell is created, which makes it more time efficient
stimulus{1,Num_Stim} = [];
im_stim = cell(1,Num_Stim); %same here
im_stim{1,Num_Stim} = [];
for i = 1:Num_Stim %and here this cell is filled with all the pictures
    stimulus{i} = imread([Stimlist{i}(1:5) '.jpg']); 
    im_stim{i} = Screen('MakeTexture', mainwin, stimulus{i}); 
end

%here all other screens are prepared
fixation = imread('fix.jpg');
im_fix = Screen('MakeTexture', mainwin, fixation);

categories = imread('categories.jpg'); 
im_cat = Screen('MakeTexture', mainwin, categories);

pause = imread('Pause.jpg');
im_pause = Screen('MakeTexture', mainwin, pause);

welcome1 = imread('Welcome.jpg'); 
im_wel1 = Screen('MakeTexture', mainwin, welcome1);
Screen('DrawTexture', mainwin, im_wel1); %the welcome screen is presented
Screen('Flip', mainwin);
keyIsDown=0; %the task continues when space (and nothing else) is pressed
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        end
    end
end
WaitSecs(0.5);
welcome2 = imread('Instruction.jpg'); 
im_wel2 = Screen('MakeTexture', mainwin, welcome2);
Screen('DrawTexture', mainwin, im_wel2); %the welcome screen is presented
Screen('Flip', mainwin);
keyIsDown=0; %the task continues when space (and nothing else) is pressed
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        end
    end
end

[e,r]=o.arm();
o.setAmplitude(TMS_intensity);

%% present stimuli
for i = 1:Num_Stim
    
    if i == 48 || i == 96 || i == 144 || i == 192 || i == 240 || i == 288 || i == 336 || i == 384 || i == 432 || i == 480 || i == 528
        Screen('DrawTexture', mainwin, im_pause); %a fixation cross is shown 
        Screen('Flip', mainwin);
        keyIsDown=0; %the task continues when space (and nothing else) is pressed
        while 1
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(spaceKey)
                    break ;
                end
            end
        end
    end    
    
        TOOC_additional %there is a inter-trial interval with a black screen
        Screen('FillRect', mainwin, bgcolor);
        Screen('Flip', mainwin);
        WaitSecs(3); %the ITI is set to 2 seconds

        Screen('DrawTexture', mainwin, im_fix); %a fixation cross is shown 
        Screen('Flip', mainwin);
        WaitSecs(preDurSec); %for 0.5 seconds

        for nframe = 1: nframes %The stimulus is shown for nframes
            Screen('DrawTexture', mainwin, im_stim{i}); %in the variables file this 
            % is made in such a way that it reflects the time set in stimDurSec
            if nframe == 1
              [~,~,Time_start_trial] = Screen('Flip', mainwin); %on the first frame a timestamp is made
            else
              Screen('Flip', mainwin); %later frames are just flipped
            end
        end
        Screen('FillRect', mainwin, bgcolor);
        [~,~,Time_start_cat] = Screen('Flip', mainwin);
        presentation_time = 1000*(Time_start_cat - Time_start_trial); %the stim presentation time is calculated in ms
        
        if Stimlist{i}(7) == "1"
            WaitSecs(0.026);
            Time_start_TMS = GetSecs();
            o.sendTrain();
            WaitSecs(0.4);
        elseif Stimlist{i}(7) == "2"
            WaitSecs(0.126);
            Time_start_TMS = GetSecs();
            o.sendTrain();
            WaitSecs(0.3);
        elseif Stimlist{i}(7) == "3"
            WaitSecs(0.226); 
            Time_start_TMS = GetSecs();
            o.sendTrain();
            WaitSecs(0.2);
        end

        TMS_time = 1000*(Time_start_TMS - Time_start_trial);
        Screen('DrawTexture', mainwin, im_cat); %the category picture will be made
        Screen('Flip', mainwin); %and flipped and a time stamp is made again to check how long the sitmulus was presented
        while x
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(numpad1) || keyCode(numpad2) || keyCode(numpad3) || keyCode(numpad4) || keyCode(numpad5) || keyCode(numpad6) || keyCode(numpad7) || keyCode(numpad8)
                    break ;
                elseif keyCode(escKey)
                    fclose(outfile);
                    Screen('CloseAll');
                    x=0;
                end
            end
        end

        RT = 1000*(GetSecs-Time_start_trial); %calculate reaction time
        keypressed=find(keyCode); %write down which key was pressed

        TOOC_additional2;

        fprintf(outfile, '%d\t %s\t %s\t %s\t %s\t %s\t %s\t %6.2f\t %6.2f\t%6.2f\t \n', i, Stimlist{i},..., 
        presented_stim, presented_cat, stim_created, given_answer, correctness, RT, presentation_time, TMS_time);
    
end

%% Final screen
finalscreen = imread('Final_screen.jpg'); 
im_fin = Screen('MakeTexture', mainwin, finalscreen);
Screen('DrawTexture', mainwin, im_fin);
Screen('Flip', mainwin);
WaitSecs(2);

[e,r]=o.disarm(1);
Screen('CloseAll');
fclose(outfile);
o.disconnect();