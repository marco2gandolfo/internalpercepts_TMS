function InversionEffect_human_TMS(subjID)
% function InversionEffect(subjID)
%
% tested on [OSX10.13.6 + MatlabR2015b + PTB 3.0.15]; [Xubuntu 16.04 + Octave 4.0.0 + PTB 3.0.14]; [OSX10.13.6 + Matlab2018a + PTB version 3.0.14]
% 1.0 PED July 17 2019
% 1.1 JL edits to improve key code identification
% 1.2 PD edits to add "page_screen_output(0)" for Octave

%%%%%%%%%
% A few lines you might need to edit in order to get underway
%%%%%%%%%

rootDir = '/home/psp905/Documents/Exp_InversionEffect_human_TMS/'; 			    % root directory for the experiment - change this!
rand('twister',sum(100*clock)); 								                  % use this to reset the random number generator in Octave
Screen('Preference', 'SkipSyncTests', 0); 						            % set to 1 for debugging, 0 when doing real testing
KbName('UnifyKeyNames');                                          % see help KbName for more details, basically tries to unify key codes across OS
theKeyCodes = KbName({'j','f'});                                  % get key codes for your keys that you want alternative
page_screen_output(0, 'local');								                    % use in Octave to stop less/more from catching text output to the workspace

%%%%%%%%%
% This ugly block of code is about setting up the screens/windows, checking timing, etc.
%%%%%%%%%
screens = Screen('Screens');									                % how many screens do we have?
screenNumber = max(screens);									                % take the last one by default
[window, screenRect] = Screen('OpenWindow',screenNumber,153); 	% 153 == grey background
info = Screen('GetWindowInfo', window); 						          % records some technical detail about screen and graphics card
[ifi, nvalid, stddev] = Screen('GetFlipInterval', window); 		% ifi is the duration of one screen refresh in sec (inter-frame interval)
fprintf('Interframe interval is %3.3f.\n', ifi); 				      % report ifi onscreen. You may want to crash out if it's not set correctly (to preserve timing)
HideCursor; 													                        % guess what
ListenChar(2);                                                % suppresses the output of key presses to the command window/editor; press Ctrl+C in event of a crash
WaitSecs(1); 													                        % Give the display a moment to recover

%%%%%%%%%
% Here we set some parameters that are relevant to the experiment
%%%%%%%%%
imageDir = [rootDir 'stimuli/']; 				        % the folder where we keep the stimuli
trainingDir = [rootDir 'training/'];                    % the folder where we keep the training stimuli
dataDir = [rootDir 'data/'];
catNames = char('chairs', 'targets');			              % catNames(1) = chairs | catNames(2) = bodies/faces
orientNames = char('upright','inverted');               % orinetNames(1) = upright | catNames(2) = inverted
dirNames = char('facing', 'nonFacing');							    % dirNames(1) = facing | catNames(2) = non_facing
numImages = 30; 												                % number of pictures in each condition
numMasks = 240;                                         % number of masks for each category_mapping
numBlocks = 9; % First block will be practise
numDurs = 5;                                           % number of fixation durations, to jitter fixation cross durations
pixDur = 2-0.5;                                         % number of screen frames for target stimuli
practicePixDur = 20-0.5;                                % number of screen frames for the target during training trials
maskDur = 18-0.5;                                       % number of screen frames for mask
blankDur = 12-0.5;
preblankDur = 60-0.5;												              % number of screen frames for blank
fixDurs = [60 75 90 105 120]-0.5;                               % number of screen frames for the Fixation
maxRespDur = 2.5;												                % timeout for the response (in seconds)
% practiceMaxRespDur = 4.5;
ctrPoint = [screenRect(3)./2 screenRect(4)./2];					                   % the point at the middle of the screen
btleftPoint = [0 screenRect(4)];

%%%%%%%%%
% IMAGE MATRIX: (2x2x2x30)
% 2 (category) x 2 (orientations) x 2 (facing) x 30 (images) matrix
% Let's load all of the images into offscreen textures
% each one will be a pointer to a texture that holds one of our stimuli
%%%%%%%%%
cd(imageDir);
cd('bodiesChairs');

for i = 1:2
    cd(deblank(catNames(i,:)))    % chairs + targets
    for j = 1:2
        cd(deblank(orientNames(j,:)))      % upright + inverted
        for k = 1:2
            cd(deblank(dirNames(k,:)))        % facing + nonFacing
            d = dir('*.jpg'); 											                      % "d" now holds names etc of all of the jpgs in that folder
            for f = 1:size(d,1) 										                      % loop over all of the images
                fprintf('Loading file %s.\n', d(f).name); 				          % for debugging in case something goes wrong; d(f).name is the name of the fth file
                img = imread(d(f).name, 'jpg');                             % "img" now holds the jpg image in numerical form as a matrix
                images(i,j,k,f) = Screen('MakeTexture', window, img); 		% 2 (category) x 2 (orientations) x 2 (facing) x 30 (images) matrix
            end
            cd ..
        end
        cd ..
    end
    cd ..
end
cd ..															                                     % end of loop over conditions

%%%%%%%%%%%%%%%
% MASK MATRIX: (240)
%%%%%%%%%%%%%%%%%%%%
cd(imageDir);
cd('bodiesChairs/masks'); 								        % go down into masks directory
d = dir('*.jpg'); 											              % "d" now holds names etc of all of the jpgs in that folder
for f = 1:size(d,1) 										              % loop over all of the images
    fprintf('Loading file %s.\n', d(f).name); 				  % for debugging in case something goes wrong; d(f).name is the name of the fth file
    img = imread(d(f).name, 'jpg'); 						        % "img" now holds the jpg image in numerical form as a matrix
    img = img(1:511,1:473,:);   %MARCO: Are we selecting a subset of the mask here?
    masks(f) = Screen('MakeTexture', window, img); 		% builds a 2(condition)x40(picture) matrix of pointers to the offscreen textures for the stimuli
end															                      % end of loop over images
cd .. 													                      % go back up one directory
cd ..                                                 % go back up one directory
% end of loop over conditions
%%%%%%%%%%%%%%%
% TRAINING MATRIX: (32)
% 32 (images)
%%%%%%%%%%%%%%%%%%%%
cd(trainingDir);
cd('bodiesChairs');

d = dir('*.jpg'); 											                    % "d" now holds names etc of all of the jpgs in that folder
for f = 1:size(d,1)
    fprintf('Loading file %s.\n', d(f).name); 				        % for debugging in case something goes wrong; d(f).name is the name of the fth file
    img = imread(d(f).name, 'jpg'); 	                        % "img" now holds the jpg image in numerical form as a matrix
    trainings(f) = Screen('MakeTexture', window, img); 		  % builds a 2(category_mapping)x)x16(picture) matrix of pointers to the offscreen textures for the stimuli
end
cd ..

clear img;

%%%%%%%%%
% Now to set up the design
% We will present either a targets bodies or chairs, upright or inverted, facing or nonFacing
% (body/chair) x (upright/inverted) x (facing/nonFacing) = 8 unique conditions for each category_mapping
% I want to block randomize so that the whole design is counterbalanced over each set 32 trials
% Build a design matrix:
% column 1: chairs = 1       | bodies  = 2
% column 2: upright = 1      | inverted = 2
% column 3: facing = 1       | nonfacing = 2
%%%%%%%%%
b = [1 1 1; 1 1 2; 1 2 1; 1 2 2; 2 1 1; 2 1 2; 2 2 1; 2 2 2];
oneBlock = repmat(b, 4, 1); % generates 32 trial blocks
design = [];
for i = 1:numBlocks
    design = [design; dt_randomize(oneBlock)];
end

%%%%%%%%%
% Prepare a few final things before starting the trials
%%%%%%%%%
keys = zeros(size(design,1), 1);								                           % vector to hold the keycodes for keypress responses
RTs = zeros(size(design,1), 1);									                           % vector to hold the response times
acc = zeros(size(design,1), 1);									                             % vector to hold accuracy variable (1=correct, 0=incorrect)
pracPix = randperm(32,32);      % pictures that will be used from the trainings items
cd(rootDir);														                                     % change to the main experiment directory
fout = fopen([dataDir subjID '_InvEff_human_TMS' datestr(now, 30) '.txt'],'w');    % open a text file to write out data - one line per trial
Screen('FillRect', window, 153);								                           % grey background                                                          $edit to same color as stimuli?
Screen('TextColor', window, [0 0 0]);							                         % black text
Screen('TextSize', window, 48);									                           % big font
Screen('DrawText', window, 'Press a key when ready.', 20, 20);	           % draw the ready signal offscreen
vbl = Screen('Flip', window);									                             % flip it onscreen

% Print a header for the data file.
fprintf(fout, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...	    % fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
    'subjectID', ...													                      % Header for the data output
    'category', ...								                                  % category (string, %s)
    'orientation', ...								                              % orientation (string, %s)
    'direction', ...									                              % direction (string, %s)
    'button', ...												                            % keycode of that trial (string, %s)
    'rt', ...													                              % response time of that trial (string, %s)
    'acc', ...													                            % accuracy of that trial (string, %s)
    'image', ...                                                   % image that was presented (string, %s)
    'stimDuration_ms');                                                % stimulus duraton in ms (string, %s)

KbWait; KbReleaseWait;											                               % hold on until any key is pressed and then released
experimentStart = GetSecs;										                             % time stamp the start of the study (more useful for fMRI/ERP)

% This is the main loop of the experiment (over trials)
% we collect a keypress and a response time
%%%%%%%%%
for t = 1:size(design,1)										                           % this big loop is for each trial (number of rows in "design")
    if t == 1  % do a training between category_mapping switches
        DrawFormattedText(window, ...                                      %training Instructions
            'This is the first training block. \n\n Indicate the category of the stimuli! \n Press LEFT/YELLOW for human  \n and RIGHT/RED for chair! \n\n Press space to start', ...
            'wrapat', 40, 0, 50);
        vbl = Screen('Flip', window);									                     % flip it onscreen
        waitForSpaceBar;
    end
    if t == 17  % do a training between category_mapping switches
        DrawFormattedText(window, ...                                      %training Instructions
            'This is the second training block. \n\n Indicate the category of the stimuli! \n Press LEFT/YELLOW for human  \n and RIGHT/RED for chair! \n\n Press space to start', ...
            'wrapat', 40, 0, 50);
        vbl = Screen('Flip', window);									                     % flip it onscreen
        waitForSpaceBar;
    end
    if t == 33  % start the real thing
        DrawFormattedText(window, ...                                      %training Instructions
            'Ready to start the Experiment. \n\n Press space to start', ...
            'wrapat', 40, 0, 50);
	Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120);
        vbl = Screen('Flip', window);									                     % flip it onscreen
        waitForSpaceBar;
    end
    
    mask(t) = Randi(numMasks);
    dur(t) = Randi(numDurs);
    item(t) = Randi(numImages);
    
   % Screen('FillRect',window,153); % clear the screen
    Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
    vbl = Screen('Flip', window); % flip now
    
    Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);   % draw FIXATION cross (offscreen)
    Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
    vbl = Screen('Flip', window, vbl + (preblankDur .*ifi));                  % FLIP fixation onscreen [WHEN: afterpreblankdur]
    
    %Screen('FillRect', window, 153);								                 % draw BLANK (offscreen)
    Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
    vbl = Screen('Flip', window, vbl + (fixDurs(dur(t)) .* ifi));		 % clear fixation (after fixation duration)
    
    if (t>32)
        Screen('DrawTexture', window, ...							                                % draw STIMULUS offscreen -- try "Screen DrawTexture?" in command window
            images(design(t,1), design(t,2), design(t,3), item(t)), []);  % default position should be center on the screen
        Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
        Screen('gluDisk', window, 255, btleftPoint(1), btleftPoint(2), 70); %LET PHOTODIODE discharge. will 34 ms be enough?
    else
        Screen('DrawTexture', window, trainings(pracPix(t)), []);							                                % draw STIMULUS offscreen -- try "Screen DrawTexture?" in command window
        Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
    end
    vbl = Screen('Flip', window, vbl + (blankDur .* ifi));		     % FLIP the stimulus onscreen [WHEN: after the blank duration is over]
    ciao(t, 1) = vbl;
    imgOnset(t) = GetSecs;
    
    Screen('DrawTexture', window, masks(mask(t)), []);  % draw a MASK offscreen - default position should be center on the screen
    Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120);  %draw bottomleft black dot to keep sensor not discharghing pulses
    if (t>16)
        vbl = Screen('Flip', window, vbl + (pixDur .* ifi));                % FLIP the mask onscreen [WHEN: after the stimulus duration is over]
    else
        vbl = Screen('Flip', window, vbl + (practicePixDur .* ifi));        % FLIP the mask onscreen [WHEN: after the stimulus duration is over]
    end
    ciao(t, 2) = vbl;
    
    %Screen('FillRect', window, 153);                                 % draw BLANK (offscreen)
    Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %blackdot
    vbl = Screen('Flip', window, vbl + (maskDur .* ifi));				   	 % FLIP blank onscreen [WHEN: after the mask duration is over]
    
    responded = 0; 												                           % reset the response flag for each trial
    while ((GetSecs - imgOnset(t)) < maxRespDur)	&& (responded==0)		 % keep checking for a keypress until the clock runs out
        [keyIsDown, secs, keyCode] = KbCheck;					                 % check for a key press(es)
        if ~responded && keyIsDown								                     % if they didn't respond already and a key is down, then ...
            RTs(t) = GetSecs - imgOnset(t);						                     % response time, in seconds, since the onset of the image
            responded = 1;										                           % set the flag - now they have responded (so now we won't take any later keypresses on this trial)
            oneKey = find(keyCode);								                       % use find to figure out which key(s) they pressed
            keys(t) = oneKey(1);								                         % maybe they mashed multiple keys! then just pick one
        end
    end
    
    if (keys(t) == theKeyCodes(design(t,1)))					               % does the keycode match the right key for this condition
        acc(t) = 1;												                             % if so set accuracy for that trial to 1
    end
    stimDuration(t) = ciao(t,2) - ciao(t,1);      %check stimulus Duration in ms (using GetSecs)
    
    
    if  (t>32)
      % Write out the data
      fprintf(fout, '%s\t%s\t%s\t%s\t%d\t%3.3f\t%d\t%d\t%3.3f\n', ...	% fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
          subjID, ...													                                % the part in '' is encoded so that each %s, %d, %f is filled with a string, integer, or float from the remaining arguments
          catNames(design(t,1),:), ...								                        % condition name of that trial (string, %s) [all separated by tab characters \t]
          orientNames(design(t,2),:), ...								                      % side name of that trial (string, %s)
          dirNames(design(t,3),:), ...									                      % duration of that trial (integer, %d)
          keys(t), ...												                                % keycode of that trial (integer, %d)
          RTs(t), ...													                                % response time of that trial (float, %3.3f, 3 digits before and after the decimal)
          acc(t), ...													                                % accuracy of that trial (integer, %d)
          item(t), ...                                                        % which item number was presented on that trial
          stimDuration(t));
    else
        fprintf(fout, '%s\t%d\t%d\t%3.3f\t%3.3f\n', subjID, pracPix(t), keys(t), RTs(t), stimDuration(t));
    end
    fflush(fout);
    
    % make a break every 32 trials
    if mod(t,32) == 0 && (t ~= 288)  %I changed this after participant 4 to have the break in the right place
        %Take a break Instructions
        Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
        Screen('DrawText', window, 'Take a break! Press <space bar> to continue', 20, 20);
        vbl = Screen('Flip', window);									                                   % flip it onscreen
        waitForSpaceBar;
    end
end

Screen('DrawText', window, 'Thank you for your participation.', 20, 20);	           % draw the ready signal offscreen
Screen('gluDisk', window, 0, btleftPoint(1), btleftPoint(2), 120); %draw bottomleft black dot to keep sensor not discharghing pulses
vbl = Screen('Flip', window);									                             % flip it onscreen
waitForSpaceBar;

%%%%%%%%%
% Clean up at the end!
%%%%%%%%%
experimentEnd = GetSecs;										                          % time stamp the end of the study (more useful for fMRI/ERP?)
Screen('CloseAll');												                            % close all the offscreen and onscreen windows
ShowCursor;														                                % guess what?
ListenChar(0);                                                        % reinsates the output of key presses to the command window/editor
fclose(fout);												                                % close off the data text file
save([subjID '_InvEff_human_TMS' datestr(now, 30) '.mat'], '-v7');		% all of the variables are saved in a .mat file; datestamp stops overwriting; '-v7' helps Octave read it


%%%%%%%%%
% A helper function: it randomizes the rows of 2D matrix m, keeping each row intact
%%%%%%%%%
function out = dt_randomize(m)
% function out = dt_randomize(m)
[R C] = size(m);
newInd = randperm(R)';
out = zeros(R, C);
for i = 1:R
    out(i, :) = m(newInd(i), :);
end

function waitForSpaceBar
spaceKeyIdx = KbName('space');                          % specify the key to continue the experiment after the break
[responseTi, keyStateVec] = KbWait;
KbReleaseWait;                                                                    % hold on until spaceKeyIdx, i.e. space bar, is pressed and then released
while ~keyStateVec(spaceKeyIdx)                                                   % check the keyboard until the spaceKeyIdx, i.e. space bar, is pressed
    [~, keyStateVec] = KbWait;
    KbReleaseWait;
end

