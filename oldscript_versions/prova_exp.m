       
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
      %% flip it after 
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
   
   end 