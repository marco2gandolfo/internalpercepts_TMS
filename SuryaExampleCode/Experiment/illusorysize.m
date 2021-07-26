function illusorysize( ppn, wrun, whatnow)
%addpath( genpath( fullfile( pwd, 'functions'))); startup1; ppn = '99'; wrun = 2; whatnow = 1;

%% ===================== load settings and stimuli ===================== %%

% load settings
mysettings;

% scene types
s_types = {'persp', 'flat'};

% iterate over scene types
for s_type = 1:length(s_types)
    
    % load scenes
    imdir      =    fullfile( pwd, 'stimuli', sprintf( 'scenes_%s', s_types{s_type}));
    f          =    dir( imdir);
    filelist   =    f( ~cellfun( @isempty, regexpi( {f.name}, '.*(jpg|jpeg|png|bmp|gif)')));
    nims       =    size( filelist, 1);
    
    SceTex(s_type,:) = NaN( 1, nims);
    
    % iterate over scenes within category
    for nim    =    1:nims
        thisim              =   imread( fullfile( imdir, filelist( nim).name)); % load this image
        SceTex(s_type, nim) =   Screen('MakeTexture', w, thisim);
    end
end

% load objects
imdir      =   [pwd '/stimuli/objects/'];
f          =   dir( imdir);
filelist   =   f( ~cellfun( @isempty, regexpi( {f.name}, '.*(jpg|jpeg|png|bmp|gif)')));
nobj       =   size( filelist, 1);

ObjTex     =   NaN( 1, nims);
for nim    =   1:nobj
    [thisob(:,:,1:3), ~, thisob(:,:,4)]     =   imread( fullfile( imdir, filelist( nim).name)); % load this image
    ObjTex(nim)                             =   Screen( 'MakeTexture', w, thisob);
end
ObjTex      =  reshape( ObjTex, size( ObjTex, 2)/2, 2)';
nobj        =  nobj/2;


%% ============ Conditions, blocks, and counterbalancing =============== %%

% counterbalanced conditions (intermixed)
nlocations  =   2;                  % stimulus (1) bottom or (2) top        - CON 1
nscenes     =   nims;               % which scene (16 variations/depth)     - CON 2
ndepths     =   2;                  % (1) depth-inducing or (2) flat scene  - CON 3
nshaps      =   2;                  % (1) cube or (2) sphere                - CON 4

% uncounterbalanced conditions (intermixed)
nobjsizes   =   nobjsize;           % size of object (16 variations)        - CON 5
nobjs       =   nobj;               % which object (16 variations/shape)    - CON 6
testsize    =   numtests;           % initial size of test object           - CON 7
xvarsn      =   xjitvars;           % horizontal jitter of near object      - CON 8
xvarsf      =   xjitvars;           % horizontal jitter of far object       - CON 9

% matched conditions (intermixed)
ntimings    =   length( p_timings); % pulse at 100, 200, 300 or 400 ms      - CON 10 

% repetitions per condition
tpc         =   1;
subdivs     =   1;

% assign balancing types
cbcons      =   [nlocations nscenes ndepths nshaps];         % counterbalanced conditions
ubcons      =   [nobjsizes nobjs testsize xvarsn xvarsf];    % uncounterbalanced conditions

% create counterbalanced design matrix
if whatnow < 2
    small_cons  =   counterbalance( cbcons, tpc, [], subdivs, ubcons, 'full');  % small design matrix of 2*64 trials, with all conditions of non-interest shuffled
    all_cons    =   [repmat(  small_cons, 1, ntimings); ...                     % repeat this exact design matrix [ntimings] times
                     repelem( 1:ntimings, 1, prod( cbcons))];                   % add a row for these [mtimings] timings
    conditions  =   all_cons(:, randperm( size( all_cons, 2)));                 % shuffle the resulting large condition matrix

% or load previous one, to continue an aborted experiment    
else
    load( fullfile( pwd, 'data', ppn, [ppn '-results.mat'] ));
end

% reduce number of trials for test run and practice run
if  strcmp( ppn, '00')
    if wrun == 1
        nblocks = 1;
    else
        nblocks = 2;
    end
    conditions  =   conditions(:, 1:debugtrials*nblocks);
else
    if wrun == 1
        nblocks = 1;
        conditions  =   conditions(:, 1:npracticetrials);
    else
        nblocks = ntimings*2;
    end
end

% compute number of trials per block
ntrials     =   size( conditions, 2);
tpb         =   ntrials/nblocks;


%% =================== Determine sizes and locations =================== %%

% determine presentation rectangles
imrect      =   CenterRect( [0 0 natsize(2) natsize(1)], screenrect);

fixrect1    =   CenterRect( [0 0 fixsize(1) fixsize(1)], screenrect);
fixrect2    =   CenterRect( [0 0 fixsize(2) fixsize(2)], screenrect);

fixrects    =   [fixrect1 ; fixrect2]';

% response task size and location (relative to y dimension)
maxtestsize     =   ceil(  natobjs * objfrac * max( max( memfracs)) * (1+testrange) * (1+sizejit));
mintestsize     =   floor( natobjs * objfrac * min( min( memfracs)) * (1-testrange) * (1-sizejit));

teststart(:, 1) =    linspace( mintestsize(1), maxtestsize(1), numtests)';
teststart(:, 2) =    linspace( mintestsize(2), maxtestsize(2), numtests)';
teststart       =    round( teststart);

maxobjsize      =    ceil(  natobjs * objfrac * max( max( memfracs)) * (1+sizejit));
minobjsize      =    floor( natobjs * objfrac * min( min( memfracs)) * (1-sizejit));

objsizes(:, 1)  =    linspace( minobjsize(1), maxobjsize(1), nobjsize)';
objsizes(:, 2)  =    linspace( minobjsize(2), maxobjsize(2), nobjsize)';
objsizes        =    round( objsizes);


%% ======================== Instructions =============================== %%

% show instructions if first (practice) block
if wrun==1
    for ntext   =   1 : length( mytexts) 
        sgtext( w, mytexts{ ntext}, screenrect, fontsize, textfont, textcol);
        Screen( 'Flip', w);
        waitforspace;   waitfornokey;
    end
end


%% ============================ Run trials ============================= %%
       
% preallocate matrices, and set trial/block numbers
if whatnow < 2
    responses   =   NaN(1, ntrials);
    raw_data    =   NaN(3, ntrials);
    starttrial  =   1;
    nblock      =   0;
else
    nblock      =   whatnow-1;
    starttrial  =   (nblock)*tpb+1; 
end

% iterate through trials
for ntrial = starttrial : ntrials
    
    % if new block
    if mod( ntrial, tpb)  ==  1       
        nblock  =   nblock + 1;
        
        if wrun > 1
            sgtext(w, sprintf( 'Block %g/%g', nblock, nblocks), screenrect, fontsize, textfont, textcol);
            Screen( 'Flip', w);  waitforspace;   waitfornokey;
        end
        
        sgtext(w, 'Ready?', screenrect, fontsize, textfont, textcol);
        Screen( 'Flip', w);  waitforspace;   waitfornokey;
        
        for nc = 1:3
            sgtext( w, sprintf( '%g',4-nc), screenrect, fontsize, textfont, textcol);
            Screen( 'Flip', w);  WaitSecs( countd);
        end

    end % end of break
    
    
    %%%%%%%%%%%%%%%
    % start trial %
    %%%%%%%%%%%%%%%
    
    % draw fixation (inter trial interval)
    Screen( 'FillOval', w, fixcol, fixrects);
    Screen( 'DrawingFinished', w);
    Screen( 'Flip', w);  tic;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine condition values %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % determine horizontal jitter
    xnear       =   nearjits( conditions(8, ntrial));
    xfar        =   farjits( conditions(9, ntrial));
        
    % all stimulus sizes
    objsize     =   objsizes( conditions(5, ntrial), :);
    testsize    =   teststart( conditions(7, ntrial), :);
        
    % object location location
    if conditions( 1, ntrial) == 1
        objrect    =   CenterRect( [0 0 objsize(2) objsize(1)], screenrect)     +   [xnear targshift xnear targshift];
    else
        objrect    =   CenterRect( [0 0 objsize(2) objsize(1)], screenrect)     -   [xfar targshift xfar targshift];
    end
        
    % end of ITI    
    WaitSecs( iti - toc);       % wait for inter trial interval to end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stimulus presentation               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % compute number of frames 
    f_obj   =   objpres*hz;
    f_pre   =   pretest*hz;
    
    % iterate over frames
    for nframe = 1: (f_obj + f_pre)
        
        % draw scene and object
        if nframe < f_obj
            Screen( 'DrawTexture', w, SceTex( conditions( 3, ntrial), conditions( 2, ntrial)), [], imrect);
            Screen( 'DrawTexture', w, ObjTex( conditions( 4, ntrial), conditions( 6, ntrial)), [], objrect);
        end
        Screen( 'FillOval',        w, fixcol, fixrects);
        Screen( 'DrawingFinished', w);
        Screen( 'Flip',            w);
        
        % send pulse
        if ismember( nframe, f_timings)
            % SEND PULSE (NOT IMPLEMENTED YET)              [!!!!!]
        end
        
    end % end of visual/tms stimulation

    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Size adjustment task %
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    % stimulus presentation / adjustment
    while 1
        
        % determine object size and triangle location on each iteration
        testrect    =   CenterRect( [0 0 round( [testsize(2) testsize(1)]) ], screenrect);
        
        
        % draw object
        sgtext(w, 'smaller < ---- > larger', screenrect, fontsize, textfont, textcol, [0 0.6*maxtestsize(1)]);
        Screen( 'DrawTexture', w, ObjTex( conditions( 4, ntrial), conditions( 6, ntrial)), [], testrect);
        Screen( 'DrawingFinished', w);
        Screen( 'Flip', w);
        
        
        % check responses
        [keydown, ~, keyCode]   =   KbCheck;
        if keydown
            wkey    =   find( keyCode);
            wkey    =   wkey( end);
            if wkey == space
                respsize    =   testsize(1);
                break
            elseif sum( wkey == [rhk(1) lhk(1)] ) && testsize(1) > mintestsize(1)       % smaller
                testsize    =   testsize * (1-deltatest);
            elseif sum( wkey == [rhk(3) lhk(3)] ) && testsize(1) < maxtestsize(1)       % bigger
                testsize    =   testsize * (1+deltatest);
            elseif wkey == esckey
                sca; ShowCursor;
                error( '[!!!] Program aborted by user.')
            end
        end % end of kbcheck
        
    end % end of test
    
    %%%%%%%%%%%%%%%%%%%%%%
    % register responses %
    %%%%%%%%%%%%%%%%%%%%%%
    
    % metric of interest
    responses( 1, ntrial)   =   (respsize - objsize(1))/objsize(1);     % Signed error fraction
    
    % raw data
    raw_data(  1, ntrial)   =   respsize;                               % 1: responded size (in pixels)
    raw_data(  2, ntrial)   =   objsize(1);                             % 2: object size  (in pixels)
    raw_data(  3, ntrial)   =   teststart( conditions(7, ntrial), 1);   % 3: start size of test item (in pixels)
        
    % clear screen
    Screen( 'FillOval', w, fixcol, fixrects);
    Screen( 'DrawingFinished', w);
    Screen( 'Flip', w); 
    waitfornokey;
    
    % save data at end of blocks
    if ~mod( ntrial, tpb) || ntrial==ntrials
        save( fullfile( pwd, 'data', ppn, [ppn '-results.mat'] ), 'responses', 'raw_data', 'conditions');
    end
    
end % end of trial


%% ============================ Shut down ============================== %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% final message
sgtext( w, mymsgs{wrun}, screenrect, fontsize, textfont, textcol); 
Screen( 'Flip', w);  waitfornokey;   waitforspace;

