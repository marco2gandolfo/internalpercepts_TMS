function internalTMS(subjID, whichset, memorisation)
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
rootDir = 'C:/Users/uomom/Documents/internalpercepts_TMS/';		% root directory for the experiment - change this!
rand('twister',sum(100*clock)); 								% use this to reset the random number generator in Octave
%rng('shuffle'); 												% use this to reset the random number generator in Matlab
Screen('Preference', 'SkipSyncTests', 0); 						% set to 1 for debugging, 0 when doing real testing
KbName('UnifyKeyNames');                                        % see help KbName for more details, basically tries to unify key codes across OS
theKeyCodes = KbName({'f','j'});                                % get key codes for your keys that you want alternative
page_screen_output(0, 'local');								% use in Octave to stop less/more from catching text output to the workspace

%%%%%%%%%
% This ugly block of code is about setting up the screens/windows, checking timing, etc.
%%%%%%%%%
ptbv = PsychtoolboxVersion;										% record the version of PTB that was being used
scriptVersion = 1.3;											% record the version of this script that is running
screens = Screen('Screens');									% how many screens do we have?
screenNumber = max(screens);									% take the last one by default
[window, screenRect] = Screen('OpenWindow', screenNumber, 0); 	% 0 == black background; also record the size of the screen in a Rect
info = Screen('GetWindowInfo', window); 						% records some technical detail about screen and graphics card
[ifi, nvalid, stddev] = Screen('GetFlipInterval', window, ...	% ifi is the duration of one screen refresh in sec (inter-frame interval)
100, 0.00005, 20);												% set up for very rigourous checking; results reported in next lines
fprintf('Refresh interval is %2.5f ms.', ifi*1000);
fprintf('samples = %i, std = %2.5f ms\n', nvalid, stddev*1000); % reports the results of the ifi measurements to the workspace
HideCursor; 													% guess what
ListenChar(2);                                                  % suppresses the output of key presses to the command window/editor; press Ctrl+C in event of a crash
WaitSecs(1); 													% Give the display a moment to recover 

%%%%%%%%%
% Here we set some parameters that are relevant to the experiment 
%%%%%%%%%
imageDir = [rootDir whichset '/']; 								% the folder where we keep the images
theFlips = char('flip', 'flop');                                % the orientations of the images, define matrix with strings, then pick one randomly
whichFlip = theFlips(randi([1 2]),:);                           % pick either flip or flop
imageDirFlip = [imageDir whichset '_' whichFlip '/'];           % pick the folder with the random flip of the right set
thememorisationdir = [imageDirFlip, memorisation, '/'];         % pick the right folder for the memorisation images
memocondNames = char('full', 'box', 'foil');					          % the folder names == the prefix of each image name

numImages = 32; 												                        % number of pictures in each condition
numBlocks = 1; 													                        % how many blocks of 32 trials do I want to test?
ctrPoint = [screenRect(3)./2 screenRect(4)./2];					% the point at the middle of the screen
ctrRect = CenterRect([0 0 400 400], screenRect);				% a rectangle that puts our image at the center of the screen
imgPosns{1} = OffsetRect(ctrRect, -250, 0);						% a rectangle that puts our image to the left of centre by 500 pixels
imgPosns{2} = OffsetRect(ctrRect, 250, 0);						% a rectangle that puts our image to the right of centre by 500 pixels
pixDurs = [4 10] - 0.5;											% number of screen frames for Short and Long trials; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
fixDur = 30 - 0.5;												% number of screen frames for the Fixation; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
maxRespDur = 1.5;												% timeout for the response (in seconds, not frames, because for this we use GetSecs rather than frame timing)

%%%%%%%%%
% Let's load all of the images into offscreen textures
% "images" will be a 2 (condition) x 40 (image) matrix of numbers
% each one will be a pointer to a texture that holds one of our stimuli
%%%%%%%%%
cd(thememorisationdir);
for i = 1:2
	cd(deblank(memocondNames(i,:))); 								% go down into either fish or car image directory
	d = dir('*.jpg'); 											% "d" now holds names etc of all of the jpgs in that folder
  for f = 1:size(d,1) 										% loop over all of the images
    fprintf('Loading file %s.\n', d(f).name); 				% for debugging in case something goes wrong; d(f).name is the name of the fth file
		img = imread(d(f).name, 'jpg'); 						% "img" now holds the jpg image in numerical form as a matrix 
																                % you can do some math on the image data before you make it into a texture
																                % we are starting with colour images that are 400x400x3 (3 colour channels, RGB)
		images(i,f) = Screen('MakeTexture', window, img); 		% builds a 3(condition)x32(picture) matrix of pointers to the offscreen textures for the stimuli
  end															% end of loop over images
	cd .. 														% go back up one directory
end																% end of loop over conditions
clear img;														% so that this is not saved along with all the data etc.

%%%%%%%%%
% Now to set up the design
% We will present either a fish or a car, left or right of fixation, brief or longer display duration
% (fish/car) x (left/right) x (short/long) = 8 conditions
% I want to block randomize so that the whole design is counterbalanced over each set 32 trials
% Build a design matrix:
% column 1: Fish = 1 Car = 2
% column 2: Left = 1 Right = 2
% column 3: Short = 1 Long = 2 
%%%%%%%%%
b = [1 1 1; 1 1 2; 1 2 1; 1 2 2; 2 1 1; 2 1 2; 2 2 1; 2 2 2];	% one trial for each combination of levels (paste into the workspace to see it!)
oneBlock = repmat(b, 4, 1);										% copy this four times to make one full block of 32 trials
design = [];													% now we'll build the whole design out of randomised blocks; start with an empty matrix and add to it
for i = 1:numBlocks												% each chunk of 32 is a randomized, balanced copy of the full design
	design = [design; dt_randomize(oneBlock)];					% now we know what to do for each trial (== each row of "design")
end



%%%%%%%%%
% Prepare a few final things before starting the trials
%%%%%%%%%
keys = zeros(size(design,1), 1);								% vector to hold the keycodes for keypress responses
RTs = zeros(size(design,1), 1);									% vector to hold the response times
acc = zeros(size(design,1), 1);									% vector to hold accuracy variable (1=correct, 0=incorrect)
cd(rootDir);													% change to the main experiment directory
fout = fopen([subjID '_PTBlearn_' datestr(now, 30) '.txt'],'w');% open a text file to write out data - one line per trial
Screen('FillRect', window, 128);								% grey background
Screen('TextColor', window, [0 0 0]);							% black text
Screen('TextSize', window, 48);									% big font
Screen('DrawText', window, 'Press a key when ready.', 20, 20);	% draw the ready signal offscreen
vbl = Screen('Flip', window);									% flip it onscreen
KbWait; KbReleaseWait;											% hold on until any key is pressed and then released
experimentStart = GetSecs;			


%%%%%%%%%
% Clean up at the end!
%%%%%%%%%
experimentEnd = GetSecs;										% time stamp the end of the study (more useful for fMRI/ERP?)
Screen('CloseAll');												% close all the offscreen and onscreen windows
ShowCursor;														% guess what?
ListenChar(0);                                                  % reinsates the output of key presses to the command window/editor
fclose(fout);													% close off the data text file
save([subjID '_PTBlearn_' datestr(now, 30) '.mat'], '-v7');		% all of the variables are saved in a .mat file; datestamp stops overwriting; '-v7' helps Octave read it
fprintf('%d misses on key Flip commands.\n', sum(sum(mis>0)));  % based on the "miss" output variable from Flip, on target onset + target offset

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