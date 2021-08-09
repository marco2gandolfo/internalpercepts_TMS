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
    memorisation_design = [1 1; 1 2; 1 3; 1 4; 2 1; 2 2; 2 3; 2 4; 3 1; 3 2; 3 3; 3 4];
    
   
      
    %% create empty cell array to fill (like an R list or JS object) for the memorytest phase
    memorisation_list = {}; %% empty first memorytest list
    memorisation_list_2 = {}; %% Empty second memorytest list
    
  for b = 1:numBlocks
    %% an empty vector for each cell
    memorisation_list{b}= [];
    memorisation_list_2{b}= [];
    %% stuff the vectore with randomised list 
    memorisation_list{b} = [memorisation_list{b}; dt_randomize(memorisation_design)];
    memorisation_list_2{b} = [memorisation_list_2{b}; dt_randomize(memorisation_design)];

  end

    
  %% create empty cell array to fill for the study phase %% SAME design of the memorytest but this has to be randomised
  studyphase_list = {};

  %% now randomise this studyphase list.  
  for b = 1:numBlocks
    
    studyphase_list{b} = [];
      
    studyphase_list{b} = [studyphase_list{b}; dt_randomize(memorisation_design)];
      
  end

   

  
  %%% TO DO create the experimental phase design and then the experimental phase list
  %% for now this has 2 x 4 x 4 dimensions == seen not seen x category x onset
  %exp_phase_design = [1 1 1; 1 1 2; 1 1 3; 1 1 4; 1 2 1; 1 2 2; 1 2 3; 1 2 4; 1 3 1; 1 3 2; 1 3 3; 1 3 4; 1 4 1; 1 4 2; 1 4 3; 1 4 4; ...
  %                    2 1 1; 2 1 2; 2 1 3; 2 1 4; 2 2 1; 2 2 2; 2 2 3; 2 2 4; 2 3 1; 2 3 2; 2 3 3; 2 3 4; 2 4 1; 2 4 2; 2 4 3; 2 4 4];
   exp_phase_design = [1 1; 1 2; 1 3; 1 4; 2 1; 2 2; 2 3; 2 4];

   exp_phase_design_rep = repmat(exp_phase_design, 3, 1);   

   
  exp_phase_list = {};
  
   for d = 1:numBlocks
    
    exp_phase_list{d} = [];
      
    exp_phase_list{d} = [exp_phase_list{d}; dt_randomize(exp_phase_design_rep)];
      
  end
  
