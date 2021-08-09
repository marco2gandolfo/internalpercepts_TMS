  %%%%%%%%%                                             %%%%%%%%%%%%%%%%%%
  % Let's load all of the images into offscreen textures                 %
  % "images" will be for the study phase and the memory test             %
  % "exp images" will be the textures for the experimental phase         %
  % each one will be a pointer to a texture that holds one of our stimuli%
  %%%%%%%%%                                             %%%%%%%%%%%%%%%%%%

  cd(thememorisationdir);
  memorisation_names = {};
  %% prepare textures for images, that now will have 3 dimensions, Dim 1 is the block, Dim 2 is the Foil vs box vs full Dim 3 is the imgnumber
  for i = 1:8 % go down into each block directory 
    cd(deblank(sh_miniblocks(i,:)));
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
    for n = 1:2
      cd(deblank(expphaseNames(n,:))); 
      d = dir('*.jpg');
      for h = 1:size(d,1);
        img = imread(d(h).name, 'jpg');
        fprintf('Loading file %s.\n', d(h).name);
        expimages(m, n, h) = Screen('MakeTexture', window, img);
      end
    cd ..
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