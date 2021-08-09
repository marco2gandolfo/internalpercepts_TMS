  %%%%%%%%%                                               %%%%%%%%%%
  % Here we set some parameters that are relevant to the experiment% 
  %%%%%%%%%                                               %%%%%%%%%%
  rootDir = 'C:/Users/uomom/Documents/internalpercepts_TMS/';		% root directory for the experiment - Windows

  imageDir = [rootDir whichset '/']; 								% the folder where we keep the images
  theFlips = char('flip', 'flop');                               % the orientations of the images, define matrix with strings, then pick one randomly
  whichFlip = theFlips(randi([1 2]),:);                           % pick either flip or flop
  imageDirFlip = [imageDir whichset '_' whichFlip '/'];           % pick the folder with the random flip of the right set
  thememorisationdir = [imageDirFlip, memorisation, '/'];         % pick the right folder for the memorisation images
  exp_phase_dir = [thememorisationdir, 'test/'];
  miniblocks = char('block1', 'block2', 'block3', 'block4', ...
  'block5', 'block6', 'block7', 'block8');                        % the miniblocks
  memocondNames = char('full', 'box', 'foil');					          % the folder names == the prefix of each image name
  expphaseNames = char('seen', 'not_seen');
  sh_miniblocks = Shuffle(miniblocks);                            %% shuffle the order of the blocks in which folders will be read

  numImages = 4; 												                        % number of pictures in each condition and block
  numBlocks = 1;											                        % how many blocks of 32 trials do I want to test?
  numDurs = 5;                                                % number of fixation durations, to jitter fixation cross durations
  memotestpixDur = 2-0.5;                                     % number of screen frames for target stimuli in the memotestphase
  testphasepixDur = 24;                                       % number of screen frames for the experimental test phase for the target picture
  maskDur = 18;                                               % number of screen frames for the Mask
  studyphasePixDur = 360;                                     % 6 seconds duration or keypress
  numStudyReps = 1;                                           % how many times they repeat
  fixDur = [45 60 90 105 120] - 0.5;												% number of screen frames for the Fixation; subtract 0.5 to compensate for timing jitter (see DriftWaitDemo.m)
  maxRespDur = 2;												% timeout for the response (in seconds, not frames, because for this we use GetSecs rather than frame timing)
  memtestpixdur = 2 - 0.5; %% duration of the picture for the memtest in frames
  maxCatRespDur = 3; %% maximum time for categorical response in seconds
  expphasepixDur = 21 - 0.5; %% 357 msecs
  expphaseMaskDur = 6 -0.5; %% 100 ms
  
  
  
  %% define things for slidescale
  
  question  = 'How Well did you see the blurry object?';
  endPoints = {'Not at all', 'Quite well'};