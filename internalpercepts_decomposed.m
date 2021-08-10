function internalpercepts_decomposed(subjID, whichset, memorisation, whichsoftware)
% function internalpercepts_debug(subjID, set, memorisation)
% subjID should be a string e.g. 'P101' % for convenience also add the TMS site with underscore - e.g. 'P101_LO'
% whichset should be a string 'set1 or 'set2', 
% memorisation should be a string too, 'memorisation_1', 'memorisation_2'
% this is a the internalpercepts version for TMS. Built on Octave but eventually will run on Matlab, hopefully
% some limits (for now) - will accept any keypress; will not collect responses during image presentation; randomly picks images on each trial
% some benefits - all self-contained, depends only on PTB; easy to edit (images, durations, responses, etc); data ready for R;
% To do Randomisation of blocks, Experimental Phase, and TMS Trigger.
% tested on Octave 6.2.0 and Windows 10; Octave 6.2.0 and OSx

try 
  %%%%%%%%%
  % A few lines you might need to edit in order to get underway
  %%%%%%%%%
  
  if whichsoftware == 'octave'
  rand('twister',sum(100*clock));% use this to reset the random number generator in Octave
  else
  rng('shuffle') % use this to reset the random number generator in Matlab
  end
  
  Screen('Preference', 'SkipSyncTests', 0); 						% set to 1 for debugging, 0 when doing real testing
  KbName('UnifyKeyNames');                                        % see help KbName for more details, basically tries to unify key codes across OS
  theKeyCodes = KbName({'a','s','d','f','UpArrow','DownArrow', 'space'});                                % get key codes for your keys that you want alternative
  
  if whichsoftware == 'octave'
  page_screen_output(0, 'local');								% use in Octave to stop less/more from catching text output to the workspace
  end
  
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
  %[ifi, nvalid, stddev] = Screen('GetFlipInterval', window, ...	% ifi is the duration of one screen refresh in sec (inter-frame interval)
  %100, 0.01, 30);												% set up for very rigourous checking; results reported in next lines
  ifi = Screen('GetFlipInterval', window);

  fprintf('Refresh interval is %2.5f ms.', ifi*1000);
  %fprintf('samples = %i, std = %2.5f ms\n', nvalid, stddev*1000); % reports the results of the ifi measurements to the workspace
  HideCursor; 													% guess what
  ListenChar(2);                        % suppresses the output of key presses to the command window/editor; press Ctrl+C in event of a crash
  WaitSecs(1); 													% Give the display a moment to recover 
  
  ctrPoint = [screenRect(3)./2 screenRect(4)./2];					% the point at the middle of the screen
  ctrRect = CenterRect([0 0 200 300], screenRect);				% a rectangle that puts our image at the center of the screen
  
  
  %%%%%%%%%                                               %%%%%%%%%%
  % Here we LOAD parameters that are relevant to the experiment    % 
  %%%%%%%%%                                               %%%%%%%%%%
  
  internalpercepts_parameters;

  %%%%%%%%%                                              %%%%%%%%%%%%
  % LOAD All Images into turbo textures                             %
  %%%%%%%%%                                              %%%%%%%%%%%%

  internalpercepts_loadimages;
  
 %%%%%%%%%                                                                                                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Now to set up the design                                                                                                                               %
  % In the memorisation test and study phase we will present either a full cue image, a box image and a foil image in 8 blocks. Each of these 3 visibility %
  % conditions will have 4 object categories  Person Furniture Car Animal                                                                                  %
  % we will have for three visibility (full box foil) and 4 categories in the memo phase (1 - Person 2 - Furniture 3 - Car 4 - Animal)                     %
  %                                                                                                                                                        %
  % Build a design matrix:                                                                                                                                 % 
  %                                                                                                                                                        %
  % column 1: full box foil                                                                                                                                % 
  % column 2: Person Furniture Car Animal      
  %
  % In the study phase design is the same. In the experimental phase our design includes for now 2 (seen notseen) x 4 Category (Person furniture car animal)%
  %  I will probably have to include TMS onset
  %%%%%%%%%                                                                                                                      %%%%%%%%%%%%%%%%%%%%%%%%%%%

  internalpercepts_design;
  
  %%%%%%%%%                                        %%%%%%%
  % Prepare a few final things before starting the trials%
  %%%%%%%%%                                        %%%%%%%   


  %%% create cell arrays with zero vectors to hold my data x block?
  %% may be  cell(1,:) = zeros(size(memorisation_list{1},1),1) to respect structure of design?
  keys = {};
  RTs = {};
  acc = {};
  catRTs = {};
  catkeys = {};
  catacc = {};
  studyKeys = {};
  stRTs = {};

  for theb = 1:numBlocks
    
      keys{theb} = zeros(size(memorisation_list{theb},1), 1);
      RTs{theb} = zeros(size(memorisation_list{theb},1), 1);
      acc{theb} = zeros(size(memorisation_list{theb},1), 1);
      catRTs{theb} = zeros(size(memorisation_list{theb},1), 1);
      catkeys{theb} = zeros(size(memorisation_list{theb},1), 1);
      catacc{theb} = zeros(size(memorisation_list{theb},1), 1);
      studyKeys{theb} = zeros(size(studyphase_list{theb},1), 1);
      stRTs{theb} = zeros(size(studyphase_list{theb},1), 1);
      slideposition{theb} = zeros(size(exp_phase_list{theb},1),1);
      slideRT{theb} = zeros(size(exp_phase_list{theb},1),1);
      answer{theb} = zeros(size(exp_phase_list{theb},1),1);

  end







  cd(rootDir);													% change to the main experiment directory
  fout = fopen([subjID '_intpercs_' datestr(now, 30) '.txt'],'w');% open a text file to write out data - one line per trial
  Screen('FillRect', window, 128);								% grey background
  Screen('TextColor', window, [0 0 0]);							% black text
  Screen('TextSize', window, 48);									% big font
  Screen('DrawText', window, 'Press a key when ready.', 20, 20);	% draw the ready signal offscreen
  vbl = Screen('Flip', window);									% flip it onscreen

  %% set the base rectangle for the study phase
  baseRect = [0 0 823 563];
  %% Center this rectangle to Screen Center
  centeredRect = CenterRectOnPointd(baseRect, ctrPoint(1), ctrPoint(2));
  %% red and green color vectors
  redcolor = [175 0 0];
  greencolor = [0 175 0];

   


  %% create all the labels for the future datafile, hopefully
  fprintf(fout, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...	    % fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
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
      'catkeys', ...
      'catRTs', ...
      'section', ...
      'studyphasekey', ...
      'studyphaseRT');



  KbWait; KbReleaseWait;											% hold on until any key is pressed and then released
  experimentStart = GetSecs;			

  %%%%%%%%%
  % This is the main loop of the experiment (over trials)
  % we will put up a fixation point, followed by the image
  % we select a random fish/car on each trial (could be better!)
  % we collect a keypress and a response time
  %%%%%%%%%
  for b = 1:numBlocks
    for t = 1:size(memorisation_list{b},1)
      
     
      %% fixation dot
      Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
      vbl = Screen('Flip', window);	
      
      %% drawing the image from the right condition    
      Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
    images(b, memorisation_list{b}(t,1),memorisation_list{b}(t,2)), []); % 1st dimension is block, second dimension is full/box/foil 3rd dimension is the exemplar category 1-2-3-4
   [vbl imgOnset(t) fts(t,1) mis(t,1) beam(t,1)] = ...			% (keep track of lots of Flip output)
    Screen('Flip', window, vbl + (fixDur(randi(length(fixDur))) .* ifi)); %% flip image after a random duration of the cross
   
    %% draw texture of the mask
   Screen('DrawTexture', window, maskTexture, []);
   %% flip the mask after 2 frames -- this memtest pixdur indicates the duration of the stimulus
    [vbl imgOffset(t) fts(t,2) mis(t,2) beam(t,2)] = ...
    Screen('Flip', window, vbl + (memtestpixdur .* ifi)); 
    
    %% Now just have a blank screen where participant can respond
    
    Screen('FillRect', window, [128 128 128], []);
    [vbl maskOffset(t) fts(t,2) mis(t,2) beam(t,2)] = ...		% (keep track of lots of Flip output)
    Screen('Flip', window, vbl + (maskDur .* ifi)); 
   
   
    
    responded = 0; 												% reset the response flag for each trial
        while ((GetSecs - imgOnset(t)) < maxRespDur)				% keep checking for a keypress until the clock runs out
          [keyIsDown, secs, keyCode] = KbCheck;					% check for a key press(es)
          if ~responded && keyIsDown								% if they didn't respond already and a key is down, then ...
            RTs{b}(t) = GetSecs - imgOnset(t);						% response time, in seconds, since the onset of the image			
            responded = 1;										% set the flag - now they have responded (so now we won't take any later keypresses on this trial)
            oneKey = find(keyCode);								% use find to figure out which key(s) they pressed
            keys{b}(t) = oneKey(1);	       % maybe they mashed multiple keys! then just pick one (the first one, in keyCode order)
            oneKey;
            KbReleaseWait; %% hold on until the key is released.
            break;          
            
          end
        end
        
       
        if (memorisation_list{b}(t,1) ~= 2 && keys{b}(t) == theKeyCodes(5))					% If press up (present) and Stimulus is not box
            acc{b}(t) = 1;												% if so set accuracy for that trial to 1
        elseif (memorisation_list{b}(t,1) == 2 && keys{b}(t) == theKeyCodes(6))
            acc{b}(t) = 1;
        else
            acc{b}(t) = 0;    
        end		
        
        acc{b}(t)
        
      catresponded = 0;
        % if memorisation_list visibility is not equal to box and participant pressed up then 
        if (memorisation_list{b}(t,1) ~= 2 && keys{b}(t) == theKeyCodes(5)) %% if trial is not box and they responded present now let appear the respscreen
           
           Screen('DrawTexture', window, respscreenTexture, []);
           [vbl respOnset(t) fts(t,1) mis(t,1) beam(t,1)] = Screen('Flip', window);
         
           respOnset(t)
        
           while((GetSecs - respOnset(t)) < maxCatRespDur)
             [catkeyIsDown, catsecs, keyCode1] = KbCheck;
            if ~catresponded && catkeyIsDown
              catresponded = 1;
              catoneKey = find(keyCode1);
              catkeys{b}(t) = catoneKey(1);
              catRTs{b}(t) = GetSecs - respOnset(t);
              catoneKey
              break;
              
              
            end
           end            
     
      end
      
            if (catkeys{b}(t) == theKeyCodes(memorisation_list{b}(t,2)))					% does the keycode match the right key for this condition
            catacc{b}(t) = 1;												% if so set accuracy for that trial to 1
            end		

            catacc{b}(t)
      
          % Write out the data
        fprintf(fout, '%s\t%s\t%s\t%s\t%s\t%s\t%d\t%3.3f\t%d\t%d\t%d\t%d\t%3.3f\t%s\n', ...	% fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
            subjID, ...	          % the part in '' is encoded so that each %s, %d, %f is filled with a string, integer, or float from the remaining arguments
            whichset, ...
            memorisation, ... 
            whichFlip, ...
            sh_miniblocks(b,:), ...                                                     % whichblock -- string
            memocondNames(memorisation_list{b}(t,1),:), ...								        % whichvisibility full box foil (string, %s) [all separated by tab characters \t]
            memorisation_list{b}(t,2), ...								                      % category integer -- 1 - Person 2 - Furniture  3 - Car 4 - Animal 
            RTs{b}(t), ...													                                % response time of that trial (float, %3.3f, 3 digits before and after the decimal)
            acc{b}(t), ...
            catacc{b}(t), ...
            keys{b}(t), ...												                                % keycode of that trial (integer, %d)
            catkeys{b}(t), ...
            catRTs{b}(t), ...
            'memtest_1');
         
        if whichsoftware == 'octave'
            fflush(fout);
        end
     
    end
    
    %% now we are still inside the block loop, start loop for the study phase.
    for rep = 1:numStudyReps
      for st = 1:size(studyphase_list{b},1)
          
          if st == 1 && rep == 1  %% Instruction of the study phase, add FB here if you can
              DrawFormattedText(window, ...                                    %%instructions
                  'Now you have the chance to study the images to get better! \n Press space to start', ...
                  'wrapat', 40, 0, 50);
              vbl = Screen('Flip', window);									                     % flip it onscreen
              waitForSpaceBar;
          end
          
          for crossframe = 1:fixDur(randi(length(fixDur)))
          
            %% fixation dot
            Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
            vbl = Screen('Flip', window);	
          end
                
         
        %% present the image, for the first 3 seconds with the red frame and then with green frame, to indicate they can continue
        for frame = 1:studyphasePixDur
          
          if frame < 180
            
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
                     studyKeys{b}(st) = stoneKey(1);
                     stRTs{b}(st) = GetSecs - studyimgOnset(st);
                    break;
                  end
         
          end
        end %% end of trial ST
        
        % Write out the data
        fprintf(fout, '%s\t%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%d\t%3.3f\n', ...	% fprintf is a powerful way to output formatted text https://www.cs.utah.edu/~germain/PPS/Topics/Matlab/fprintf.html
            subjID, ...	          % the part in '' is encoded so that each %s, %d, %f is filled with a string, integer, or float from the remaining arguments
            whichset, ...
            memorisation, ... 
            whichFlip, ...
            sh_miniblocks(b,:), ...                                                     % whichblock -- string
            memocondNames(studyphase_list{b}(st,1),:), ...								        % whichvisibility full box foil (string, %s) [all separated by tab characters \t]
            studyphase_list{b}(st,2), ...								                      % category integer -- 1 - Person 2 - Furniture  3 - Car 4 - Animal 
            0, ...													                                % response time of that trial (float, %3.3f, 3 digits before and after the decimal)
            0, ...
            0, ...
            0, ...												                                % keycode of that trial (integer, %d)
            0, ...
            0, ...
            'studyphase', ...
            studyKeys{b}(st), ...
            stRTs{b}(st));
         
        if whichsoftware == 'octave'
            fflush(fout);
        end
        
      end 
            
    end
    
    %% if I am in the lab using matlab then load the stimulator just before the experimental phase, commented for now
    %if whichsoftware == 'matlab'
    %    [e,r]=o.arm();
    %    o.setAmplitude(TMS_intensity);
    %end 
        
    
    for et = 1:size(exp_phase_list{b},1)
    
     if et == 1   %% Instruction of the study phase, add FB here if you can
      DrawFormattedText(window, ...                                    %%instructions
          'Experimental Phase \n Press space to start', ...
          'wrapat', 40, 0, 50);
      vbl = Screen('Flip', window);									                     % flip it onscreen
      waitForSpaceBar;
      end
      
      %% fixation dot
      Screen('gluDisk', window, 0, ctrPoint(1), ctrPoint(2), 8);  % draw fixation dot (offscreen)
      vbl = Screen('Flip', window);	
      
      %% drawing the image from the right condition    
      Screen('DrawTexture', window, ...							% draw an image offscreen in the right location -- try "Screen DrawTexture?" in command window
      expimages(b, exp_phase_list{b}(et,1),exp_phase_list{b}(et,2)), []); % 1st dimension is block, second dimension is seen_not seen 3rd dimension is the exemplar category 1-2-3-4
      [vbl expimgOnset(et) fts(et,1) mis(et,1) beam(et,1)] = ...			% (keep track of lots of Flip output)
      Screen('Flip', window, vbl + (fixDur(randi(length(fixDur))) .* ifi)); %% flip image after a random duration of the cross
   
      %% draw texture of the mask
     Screen('DrawTexture', window, maskTexture, []);
     %% flip the mask after 2 frames -- this memtest pixdur indicates the duration of the stimulus
      [vbl expimgOffset(et) fts(et,2) mis(et,2) beam(et,2)] = ...
      Screen('Flip', window, vbl + (expphasepixDur .* ifi)); 
      
      %% Now just have a blank screen where participant can respond
      
      Screen('FillRect', window, [128 128 128], []);
      [vbl expmaskOffset(et) fts(et,2) mis(et,2) beam(et,2)] = ...		% (keep track of lots of Flip output)
      Screen('Flip', window, vbl + (expphaseMaskDur .* ifi)); 
      
      [slideposition{b}(et), slideRT{b}(et), answer{b}(et)] = slideScale(window, ...
                                  question, ...
                                  screenRect, ...
                                  endPoints, ...
                                  'device', 'keyboard', ...
                                  'stepsize', 5, ...
                                  'scalalength', 0.77, ... 
                                  'startposition', 'center', ...
                                  'aborttime', 7, ... 
                                  'range', 2);

     
    end 
 
   
      
 end

  experimentEnd = GetSecs;										                          % time stamp the end of the study (more useful for fMRI/ERP?)
   
  Screen('CloseAll');												                            % close all the offscreen and onscreen windows
  ShowCursor;														                                % guess what?
  ListenChar(0);         
  save([subjID '_internalpercepts_TMS' datestr(now, 30) '.mat'], '-v7');	 
    

%%% if an error occurs it enters the catch statement  
catch 

Screen('CloseAll');												                            % close all the offscreen and onscreen windows
ShowCursor;														                                % guess what?
ListenChar(0);         
save([subjID '_internalpercepts_TMS' datestr(now, 30) '.mat'], '-v7');	
fprintf('We''ve hit an error.\n');
psychrethrow(psychlasterror);

end


