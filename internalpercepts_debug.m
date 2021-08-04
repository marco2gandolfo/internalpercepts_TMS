function internalpercepts_debug(subjID, whichset, memorisation)
% function PTBlearn(subjID, set, memorisation)
% subjID should be a string e.g. 'P101' % for convenience also add the TMS site with underscore - e.g. 'P101_LO'
% whichset should be a string 'set1 or 'set2', 
% memorisation should be a string too, 'memorisation_1', 'memorisation_2'
% this is a the internalpercepts version for TMS. Built on Octave but eventually will run on Matlab, hopefully
% some limits (for now) - will accept any keypress; will not collect responses during image presentation; randomly picks images on each trial
% some benefits - all self-contained, depends only on PTB; easy to edit (images, durations, responses, etc); data ready for R;
% To do Randomisation of blocks, Experimental Phase, and TMS Trigger.
% tested on Octave 6.2.0 and Windows 10; Octave 6.2.0 and OSx


%%%%%%%%%
% A few lines you might need to edit in order to get underway
%%%%%%%%%
rootDir = 'C:/Users/uomom/Documents/internalpercepts_TMS/';		% root directory for the experiment - Windows
%rootDir = '~/Documents/internalpercepts_TMS/';    	% root directory for the experiment - Mac
rand('twister',sum(100*clock)); 								% use this to reset the random number generator in Octave
%rng('shuffle'); 												% use this to reset the random number generator in Matlab
Screen('Preference', 'SkipSyncTests', 0); 						% set to 1 for debugging, 0 when doing real testing
KbName('UnifyKeyNames');                                        % see help KbName for more details, basically tries to unify key codes across OS
theKeyCodes = KbName({'a','s','d','f','UpArrow','DownArrow', 'space'});                                % get key codes for your keys that you want alternative
page_screen_output(0, 'local');								% use in Octave to stop less/more from catching text output to the workspace

%%%%%%%%%
% This ugly block of code is about setting up the screens/windows, checking timing, etc.
%%%%%%%%%
ptbv = PsychtoolboxVersion;										% record the version of PTB that was being used
scriptVersion = 1.3;											% record the version of this script that is running
screens = Screen('Screens');									% how many screens do we have?
screenNumber = max(screens);								% take the last one by default
%screenRect = [100 100 600 600];            %% uncomment this and next line for small screen for debugging
%[window, screenRect] = Screen('OpenWindow', 0, [127 127 127], screenRect);

[window, screenRect] = Screen('OpenWindow', screenNumber, 0); 	% 0 == black background; also record the size of the screen in a Rect
info = Screen('GetWindowInfo', window); 						% records some technical detail about screen and graphics card
#[ifi, nvalid, stddev] = Screen('GetFlipInterval', window, ...	% ifi is the duration of one screen refresh in sec (inter-frame interval)
#100, 0.01, 30);												% set up for very rigourous checking; results reported in next lines
ifi = Screen('GetFlipInterval', window);

fprintf('Refresh interval is %2.5f ms.', ifi*1000);
#fprintf('samples = %i, std = %2.5f ms\n', nvalid, stddev*1000); % reports the results of the ifi measurements to the workspace
HideCursor; 													% guess what
ListenChar(2);                        % suppresses the output of key presses to the command window/editor; press Ctrl+C in event of a crash
WaitSecs(1); 													% Give the display a moment to recover 

%%%%%%%%%                                               %%%%%%%%%%
% Here we set some parameters that are relevant to the experiment% 
%%%%%%%%%                                               %%%%%%%%%%


imageDir = [rootDir whichset '/']; 								% the folder where we keep the images
theFlips = char('flip', 'flop');                               % the orientations of the images, define matrix with strings, then pick one randomly
whichFlip = theFlips(randi([1 2]),:);                           % pick either flip or flop
imageDirFlip = [imageDir whichset '_' whichFlip '/'];           % pick the folder with the random flip of the right set
thememorisationdir = [imageDirFlip, memorisation, '/'];         % pick the right folder for the memorisation images
exp_phase_dir = [imageDirFlip, 'test/'];
miniblocks = char('block1', 'block2', 'block3', 'block4', ...
'block5', 'block6', 'block7', 'block8'); % the miniblocks
memocondNames = char('full', 'box', 'foil');					          % the folder names == the prefix of each image name


numImages = 4; 												                        % number of pictures in each condition and block
numBlocks = 8;											                        % how many blocks of 32 trials do I want to test?
numDurs = 5;                                                % number of fixation durations, to jitter fixation cross durations
memotestpixDur = 2-0.5;                                     % number of screen frames for target stimuli in the memotestphase
testphasepixDur = 24;                                       % number of screen frames for the experimental test phase for the target picture
maskDur = 18;                                               % number of screen frames for the Mask
studyphasePixDur = 240; % 4 seconds


ctrPoint = [screenRect(3)./2 screenRect(4)./2];					% the point at the middle of the screen
ctrRect = CenterRect([0 0 200 300], screenRect);				% a rectangle that puts our image at the center of the screen
fixDur = [45 60 90 105 120] - 0.5;												% number of screen frames for the Fixation; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
maxRespDur = 1;												% timeout for the response (in seconds, not frames, because for this we use GetSecs rather than frame timing)
memtestpixdur = 2 - 0.5; %% duration of the picture for the memtest in frames
maxCatRespDur = 3; %% maximum time for categorical response in seconds



%%%%%%%%%                                             %%%%%%%%%%%%%%%%%%
% Let's load all of the images into offscreen textures                 %
% "images" will be for the study phase and the memory test             %
% "exp images" will be the textures for the experimental phase         %
% each one will be a pointer to a texture that holds one of our stimuli%
%%%%%%%%%                                             %%%%%%%%%%%%%%%%%%

cd(thememorisationdir);
%% prepare textures for images, that now will have 3 dimensions, Dim 1 is the block, Dim 2 is the Foil vs box vs full Dim 3 is the imgnumber
for i = 1:8 % go down into each block directory 
  cd(deblank(miniblocks(i,:)));
  for g = 1:3  %%% full box foil
    cd(deblank(memocondNames(g,:)));
    d = dir('*.jpg');
    for f = 1:size(d,1) %% category exemplar 1 = person 2 = furniture 3 = car 4 = animal
      img = imread(d(f).name, 'jpg');
      fprintf('Loading file %s.\n', d(f).name);
      images(i,g,f) = Screen('MakeTexture', window, img);  %3 * 8 
    end
    cd ..
  end
  cd ..
end 
cd ..
clear img;

%% prepare textures for the experimental phase

cd(exp_phase_dir); %navigate to the folder of the expphase images
for m = 1:8
  cd(deblank(miniblocks(m,:)));
  d = dir('*.jpg');
  for h = 1:size(d,1);
    img = imread(d(h).name, 'jpg');
    fprintf('Loading file %s.\n', d(h).name);
    expimages(m,h) = Screen('MakeTexture', window, img);
  end
  cd ..
end
cd ..
clear img;

%% prepare texture for the maskdur
cd(rootDir);

mask = imread('themask.jpg');

maskTexture = Screen('MakeTexture', window, mask);

%% prepare texture for the response screen
respscreen = imread('bresponsescreen.jpg');

respscreenTexture = Screen('MakeTexture', window, respscreen);

%%%%%%%%%                                                                                                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now to set up the design                                                                                                                               %
% In the memorisation test and study phase we will present either a full cue image, a box image and a foil image in 8 blocks. Each of these 3 visibility %
% conditions will have 4 object categories  Person Furniture Car Animal                                                                                  %
% we will have for three visibility (full box foil) and 4 categories in the memo phase (1 - Person 2 - Furniture 3 - Car 4 - Animal)                     %
%                                                                                                                                                        %
% Build a design matrix:                                                                                                                                 % 
%                                                                                                                                                        %
% column 1: full box foil                                                                                                                                % 
% column 2: Person Furniture Car Animal                                                                                                                  %
%%%%%%%%%                                                                                                                      %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  cd(rootDir);
  %%% design for the memorisation phase and memorisation test %% Dimension 1 full box foil/ Dimension 2 is category Person Furniture Car Animal
  memorisation_design = [1 1 ;1 2 ;1 3; 1 4; 2 1; 2 2; 2 3; 2 4; 3 1; 3 2; 3 3; 3 4];
  
 
    
  %% create empty cell array to fill (like an R list or JS object) for the memorytest phase
  memorisation_list = {};

for b = 1:numBlocks
  
  memorisation_list{b}= [];
 
    memorisation_list{b} = [memorisation_list{b}; dt_randomize(memorisation_design)];

end

  %% create empty cell array to fill for the study phase %% SAME design of the memorytest but this has to be randomised
  studyphase_list = {};

%% now randomise this studyphase list.  
for b = 1:numBlocks
  
  studyphase_list{b} = [];
    
    studyphase_list{b} = [studyphase_list{b}; dt_randomize(memorisation_design)];
    
end

%%% TO DO create the experimental phase design and then the experimental phase list


%%%%%%%%%                                        %%%%%%%
% Prepare a few final things before starting the trials%
%%%%%%%%%                                        %%%%%%%   

%% may be  cell(1,:) = zeros(size(memorisation_list{1},1),1) to respect structure of design?
keys = zeros(size(memorisation_list{1},1), 1);								% vector to hold the keycodes for keypress responses
RTs = zeros(size(memorisation_list{1},1), 1);							% vector to hold the response times
acc = zeros(size(memorisation_list{1},1), 1);							% vector to hold accuracy variable (1=correct, 0=incorrect)

catRTs = zeros(size(memorisation_list{1},1),1);
catkeys = zeros(size(memorisation_list{1},1),1);
catacc = zeros(size(memorisation_list{1},1),1);



cd(rootDir);													% change to the main experiment directory
fout = fopen([subjID '_intpercs_' datestr(now, 30) '.txt'],'w');% open a text file to write out data - one line per trial
Screen('FillRect', window, 128);								% grey background
Screen('TextColor', window, [0 0 0]);							% black text
Screen('TextSize', window, 48);									% big font
Screen('DrawText', window, 'Press a key when ready.', 20, 20);	% draw the ready signal offscreen
vbl = Screen('Flip', window);									% flip it onscreen

%% set the base rectangle for the study phase
baseRect = [0 0 883 583];
%% Center this rectangle to Screen Center
centeredRect = CenterRectOnPointd(baseRect, ctrPoint(1), ctrPoint(2));
%% red and green color vectors
redcolor = [255 0 0];
greencolor = [0 255 0];

 


%% create all the labels for the future datafile, hopefully
fprintf(fout, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...	    % fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
    'subjectID', ...													                      % Header for the data output
    'set', ...
    'memorisation', ...
    'flip', ...
    'block', ...								                                  % category (string, %s)
    'visibility', ...								                              % orientation (string, %s)
    'category', ...									                              % direction (string, %s)												                            % keycode of that trial (string, %s)
    'rt', ...													                              % response time of that trial (string, %s)
    'acc', ...													                            % accuracy of that trial (string, %s)
    'catacc', ...
    'keys', ...
    'catkeys',
    'catRTs');



KbWait; KbReleaseWait;											% hold on until any key is pressed and then released
experimentStart = GetSecs;			

%%%%%%%%%
% This is the main loop of the experiment (over trials)
% we will put up a fixation point, followed by the image
% we select a random fish/car on each trial (could be better!)
% we collect a keypress and a response time
%%%%%%%%%
for b = 1:size(memorisation_list,2)
  for t = 1:size(memorisation_list{b},1)
    
   
    %% fixation dot
    Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
	  vbl = Screen('Flip', window);	
    
    %% drawing the image from the right condition    
    Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
	images(b, memorisation_list{b}(t,1),memorisation_list{b}(t,2)), []); % 1st dimension is block, second dimension is full/box/foil 3rd dimension is the exemplar category 1-2-3-4
 [vbl imgOnset(t) fts(t,1) mis(t,1) beam(t,1)] = ...			% (keep track of lots of Flip output)
	  %% flip it after 
  Screen('Flip', window, vbl + (fixDur(randi(length(fixDur))) .* ifi)); %% flip image after a random duration of the cross
 
  %% draw texture of the mask
 Screen('DrawTexture', window, maskTexture, []);
 %% flip the mask after 2 frames -- this memtest pixdur indicates the duration of the stimulus
  Screen('Flip', window, vbl + (memtestpixdur .* ifi)); 
  
  %% Now just have a blank screen where participant can respond
  
  Screen('FillRect', window, [128 128 128], []);
 # [vbl imgOffset(t) fts(t,2) mis(t,2) beam(t,2)] = ...		% (keep track of lots of Flip output)
	Screen('Flip', window, vbl + (maskDur .* ifi)); 
 
 
  
  responded = 0; 												% reset the response flag for each trial
      while ((GetSecs - imgOnset(t)) < maxRespDur)				% keep checking for a keypress until the clock runs out
        [keyIsDown, secs, keyCode] = KbCheck;					% check for a key press(es)
        if ~responded && keyIsDown								% if they didn't respond already and a key is down, then ...
          RTs(t) = GetSecs - imgOnset(t);						% response time, in seconds, since the onset of the image			
          responded = 1;										% set the flag - now they have responded (so now we won't take any later keypresses on this trial)
          oneKey = find(keyCode);								% use find to figure out which key(s) they pressed
          keys(t) = oneKey(1);	       % maybe they mashed multiple keys! then just pick one (the first one, in keyCode order)
          oneKey;
          KbReleaseWait; %% hold on until the key is released.
          break;          
          
        end
      end
      
      keys(t)
      #if memorisation_list{1}(1,1) == 2 & keys(1) == theKeyCodes(5) something like that for present absent question
      memorisation_list{b}(t,1)
      
      if (memorisation_list{b}(t,1) ~= 2 && keys(t) == theKeyCodes(5))					% If press up (present) and Stimulus is not box
		      acc(t) = 1;												% if so set accuracy for that trial to 1
      elseif (memorisation_list{b}(t,1) == 2 && keys(t) == theKeyCodes(6))
          acc(t) = 1;
      else
          acc(t) = 0;    
      end		
      
    catresponded = 0;
      % if memorisation_list visibility is not equal to box and participant pressed up then 
      if (memorisation_list{b}(t,1) ~= 2 && keys(t) == theKeyCodes(5)) %% if trial is not box and they responded present now let appear the respscreen
         
         Screen('DrawTexture', window, respscreenTexture, []);
         [vbl respOnset(t) fts(t,1) mis(t,1) beam(t,1)] = Screen('Flip', window);
       
         respOnset(t)
      
         while((GetSecs - respOnset(t)) < maxCatRespDur)
           [catkeyIsDown, catsecs, keyCode1] = KbCheck;
          if ~catresponded && catkeyIsDown
            catresponded = 1;
            catoneKey = find(keyCode1);
            catkeys(t) = catoneKey(1);
            catRTs(t) = GetSecs - respOnset(t);
            catoneKey
            break;
            
            
          end
         end            
   
    end
    
          if (catkeys(t) == theKeyCodes(memorisation_list{b}(t,2)))					% does the keycode match the right key for this condition
		      catacc(t) = 1;												% if so set accuracy for that trial to 1
	        end		

    
    
        % Write out the data
      fprintf(fout, '%s\t%s\t%s\t%s\t%d\t%s\t%d\t%3.3f\t%d\t%d\t%d\t%d\t%3.3f\n', ...	% fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
          subjID, ...	          % the part in '' is encoded so that each %s, %d, %f is filled with a string, integer, or float from the remaining arguments
          whichset,
          memorisation, 
          whichFlip,
          miniblocks(b,:), ...                                                     % whichblock -- string
          memocondNames(memorisation_list{b}(t,1),:), ...								        % whichvisibility full box foil (string, %s) [all separated by tab characters \t]
          memorisation_list{b}(t,2), ...								                      % category integer -- 1 - Person 2 - Furniture  3 - Car 4 - Animal 
          RTs(t), ...													                                % response time of that trial (float, %3.3f, 3 digits before and after the decimal)
          acc(t), ...
          catacc(t), ...
          keys(t), ...												                                % keycode of that trial (integer, %d)
          catkeys(t), ...
          catRTs(t));
               
   
  end
  
  %% now we are still inside the block loop, start loop for the study phase.
  for st = 1:size(studyphase_list{b},1)
      
      if st == 1  %% Instruction of the study phase, add FB here if you can
          DrawFormattedText(window, ...                                    %%instructions
              'Now you have the chance to study the images to get better! \n Press space to start', ...
              'wrapat', 40, 0, 50);
          vbl = Screen('Flip', window);									                     % flip it onscreen
          waitForSpaceBar;
      end
      
      for crossframe = 1:fixDur(randi(length(fixDur)))
      
      %% fixation dot
      Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
      Screen('Flip', window);	

      end
            
     
      
    while frame < studyphasePixDur
      
        if frame < 120
        
        Screen('FillRect', window, redcolor, centeredRect);
        Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
      images(b, studyphase_list{b}(st,1),studyphase_list{b}(st,2)), []); % 1st dimension is block, second dimension is full/box/foil 3rd dimension is the exemplar category 1-2-3-4
     
     [vbl studyimgOnset(st) fts(st,1) mis(st,1) beam(st,1)] = ...			% (keep track of lots of Flip output) 
      Screen('Flip', window); %% flip image after a random duration of the cross
        else
        Screen('FillRect', window, greencolor, centeredRect);
        Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
      images(b, studyphase_list{b}(st,1),studyphase_list{b}(st,2)), []); % 1st dimension is block, second dimension is full/box/foil 3rd dimension is the exemplar category 1-2-3-4
     
     [vbl studyimgOnset(st) fts(st,1) mis(st,1) beam(st,1)] = ...			% (keep track of lots of Flip output) 
      Screen('Flip', window); %% flip image after a random duration of the cross
      
      [studykeyIsDown, studysecs, keyCodest] = KbCheck;
             if studykeyIsDown
                 stoneKey = find(keyCodest);
                 studykeys(st) = stoneKey(1);
                 stRTs(st) = GetSecs - studyimgOnset(st);
                break;
             end
        end
    end
  end

  
end

experimentEnd = GetSecs;										                          % time stamp the end of the study (more useful for fMRI/ERP?)
Screen('CloseAll');												                            % close all the offscreen and onscreen windows
ShowCursor;														                                % guess what?
ListenChar(0);         
save([subjID '_internalpercepts_TMS' datestr(now, 30) '.mat'], '-v7');	

function waitForSpaceBar
spaceKeyIdx = KbName('space');                          % specify the key to continue the experiment after the break
[responseTi, keyStateVec] = KbWait;
KbReleaseWait;                                                                    % hold on until spaceKeyIdx, i.e. space bar, is pressed and then released
while ~keyStateVec(spaceKeyIdx)                                                   % check the keyboard until the spaceKeyIdx, i.e. space bar, is pressed
    [~, keyStateVec] = KbWait;
    KbReleaseWait;
end
