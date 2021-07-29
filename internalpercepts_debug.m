function internalpercepts_debug(subjID, whichset, memorisation)
% function PTBlearn(subjID, set, memorisation)
% subjID should be a string e.g. 'P101' % for convenience also add the TMS site with underscore - e.g. 'P101_LO'
% whichset should be a string 'set1 or 'set2', 
% memorisation should be a string too, 'memorisation_1', 'memorisation_2'
% this is a the internalpercepts version for TMS. Built on Octave but eventually will run on Matlab, hopefully
% this introduces some basic PTB; some design counterbalancing; image loading, manipulation, and presentation; response collection with RT; etc.
% some limits (for now) - will accept any keypress; will not collect responses during image presentation; randomly picks images on each trial
% some benefits - all self-contained, depends only on PTB; easy to edit (images, durations, responses, etc); data ready for R;
%
% tested on [OSX10.13.6 + MatlabR2015b + PTB 3.0.15]; [Xubuntu 16.04 + Octave 4.0.0 + PTB 3.0.14]; [OSX10.13.6 + Matlab2018a + PTB version 3.0.14]
% 1.0 PED July 17 2019
% 1.1 JL edits to improve key code identification 
% 1.2 PD edits to add "page_screen_output(0)" for Octave
% 1.3 PD remove redundant windowRect; major update to Screen('Flip') calls to ensure accurate timing; much more detailed recording of timestamps


%%%%%%%%%
% A few lines you might need to edit in order to get underway
%%%%%%%%%
rootDir = 'C:/Users/uomom/Documents/internalpercepts_TMS/';		% root directory for the experiment - Windows
%rootDir = '~/Documents/internalpercepts_TMS/';    	% root directory for the experiment - Mac
rand('twister',sum(100*clock)); 								% use this to reset the random number generator in Octave
%rng('shuffle'); 												% use this to reset the random number generator in Matlab
Screen('Preference', 'SkipSyncTests', 1); 						% set to 1 for debugging, 0 when doing real testing
KbName('UnifyKeyNames');                                        % see help KbName for more details, basically tries to unify key codes across OS
theKeyCodes = KbName({'f','j'});                                % get key codes for your keys that you want alternative
page_screen_output(0, 'local');								% use in Octave to stop less/more from catching text output to the workspace

%%%%%%%%%
% This ugly block of code is about setting up the screens/windows, checking timing, etc.
%%%%%%%%%
ptbv = PsychtoolboxVersion;										% record the version of PTB that was being used
scriptVersion = 1.3;											% record the version of this script that is running
screens = Screen('Screens');									% how many screens do we have?
screenNumber = max(screens);								% take the last one by default
screenRect = [100 100 600 600];
%[window, screenRect] = Screen('OpenWindow', 0, [127 127 127], screenRect);

[window, screenRect] = Screen('OpenWindow', screenNumber, 0); 	% 0 == black background; also record the size of the screen in a Rect
info = Screen('GetWindowInfo', window); 						% records some technical detail about screen and graphics card
#[ifi, nvalid, stddev] = Screen('GetFlipInterval', window, ...	% ifi is the duration of one screen refresh in sec (inter-frame interval)
#100, 0.01, 30);												% set up for very rigourous checking; results reported in next lines
ifi = Screen('GetFlipInterval', window);

fprintf('Refresh interval is %2.5f ms.', ifi*1000);
#fprintf('samples = %i, std = %2.5f ms\n', nvalid, stddev*1000); % reports the results of the ifi measurements to the workspace
HideCursor; 													% guess what
ListenChar(2);                                                  % suppresses the output of key presses to the command window/editor; press Ctrl+C in event of a crash
WaitSecs(1); 													% Give the display a moment to recover 

%%%%%%%%%
% Here we set some parameters that are relevant to the experiment 
%%%%%%%%%
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
memophasepixDur = 120;                                      % number of screen frames for the memorisation phase, 2 secs for now
testphasepixDur = 24;                                       % number of screen frames for the experimental test phase for the target picture
maskdur = 30;                                               % number of screen frames for the Mask

ctrPoint = [screenRect(3)./2 screenRect(4)./2];					% the point at the middle of the screen
ctrRect = CenterRect([0 0 200 300], screenRect);				% a rectangle that puts our image at the center of the screen
pixDurs = [4 10] - 0.5;											% number of screen frames for Short and Long trials; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
fixDur = 30 - 0.5;												% number of screen frames for the Fixation; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
maxRespDur = 1.5;												% timeout for the response (in seconds, not frames, because for this we use GetSecs rather than frame timing)

%%%%%%%%%
% Let's load all of the images into offscreen textures
% "images" will be a 2 (condition) x 40 (image) matrix of numbers
% each one will be a pointer to a texture that holds one of our stimuli
%%%%%%%%%
cd(thememorisationdir);
%% prepare textures for images, that now will have 3 dimensions, Dim 1 is the block, Dim 2 is the Foil vs box vs full Dim 3 is the imgnumber
for i = 1:8 % go down into each block directory 
  cd(deblank(miniblocks(i,:)));
  for g = 1:3
    cd(deblank(memocondNames(g,:)));
    d = dir('*.jpg');
    for f = 1:size(d,1)
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

%%%%%%%%%
% Now to set up the design
% We will present either a fish or a car, left or right of fixation, brief or longer display duration
% (fish/car) x (left/right) x (short/long) = 8 conditions
% I want to block randomize so that the whole design is counterbalanced over each set 32 trials
% Build a design matrix:
% 
% column 1: box foil full
%%%%%%%%%
  cd(rootDir);
  %%% design for the memorisation phase and memorisation test
  memorisation_design = [1 2 3]';
  
  %% create design for memorisation_test SEE tomorrow!! here I have to have 12 images 4 per category
  memorytest_list = {};
  for g = 1:numBlocks
    
    memorytest_list{g} = [dt_randomize(memorisation_design)];
    
   end
    
    
  %% create empty cell array to fill (like an R list or JS object) for the study phase
  memorisation_list = {};

for b = 1:numBlocks
  
  memorisation_list{b}= [];
  for i = 1:4
    memorisation_list{b} = [memorisation_list{b}; dt_randomize(memorisation_design)];
  end

end

%%%%%%%%%
% Prepare a few final things before starting the trials
%%%%%%%%%

%% may be  cell(1,:) = zeros(size(memorisation_list{1},1),1) to respect structure of design?
keys = zeros(size(memorisation_list{1},1), 1);								% vector to hold the keycodes for keypress responses
RTs = zeros(size(memorisation_list{1},1), 1);							% vector to hold the response times
acc = zeros(size(memorisation_list{1},1), 1);							% vector to hold accuracy variable (1=correct, 0=incorrect)
cd(rootDir);													% change to the main experiment directory
fout = fopen([subjID '_intpercs_' datestr(now, 30) '.txt'],'w');% open a text file to write out data - one line per trial
Screen('FillRect', window, 128);								% grey background
Screen('TextColor', window, [0 0 0]);							% black text
Screen('TextSize', window, 48);									% big font
Screen('DrawText', window, 'Press a key when ready.', 20, 20);	% draw the ready signal offscreen
vbl = Screen('Flip', window);									% flip it onscreen
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
    
    item(t) = Randi(numImages);
    Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
	  vbl = Screen('Flip', window);	
    Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
	images(b, memorisation_list{b}(t,1),item(t)), []);
 [vbl imgOnset(t) fts(t,1) mis(t,1) beam(t,1)] = ...			% (keep track of lots of Flip output)
	Screen('Flip', window, vbl + (fixDur .* ifi));
 Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
	maskTexture, []);
  Screen('Flip', window, ...									% flip again, to replace with a fixation point 
	vbl + (2 .* ifi)); 
 Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % keep a fixation offscreen	
	[vbl imgOffset(t) fts(t,2) mis(t,2) beam(t,2)] = ...		% (keep track of lots of Flip output)
	Screen('Flip', window, ...									% flip again, to replace with a fixation point 
	vbl + (30 .* ifi)); 
  
  b 
  memorisation_list{b}(t,1)
  item(t)
  
  responded = 0; 												% reset the response flag for each trial
      while ((GetSecs - imgOnset(t)) < maxRespDur)				% keep checking for a keypress until the clock runs out
        [keyIsDown, secs, keyCode] = KbCheck;					% check for a key press(es)
        if ~responded && keyIsDown								% if they didn't respond already and a key is down, then ...
          RTs(t) = GetSecs - imgOnset(t);						% response time, in seconds, since the onset of the image			
          responded = 1;										% set the flag - now they have responded (so now we won't take any later keypresses on this trial)
          oneKey = find(keyCode);								% use find to figure out which key(s) they pressed
          keys(t) = oneKey(1);	       % maybe they mashed multiple keys! then just pick one (the first one, in keyCode order)
          oneKey
        end
      end
      
      
   
  end
end

experimentEnd = GetSecs;										                          % time stamp the end of the study (more useful for fMRI/ERP?)
Screen('CloseAll');												                            % close all the offscreen and onscreen windows
ShowCursor;														                                % guess what?
ListenChar(0);         

