%% ========================== Quick settings =========================== %%

% number of trials for practice session, and for debugging (i.e., ptc '00')
npracticetrials     =   10;                     
debugtrials         =   2;

% pulse timings
p_timings           =   [100 200 300 400];      % in ms


%% ========================= Screen settings =========================== %%

% determine screen number
screens             =   Screen('Screens');

if max( screens)    ==  0
    scrnum  =   0;
else
    scrnum  =   1;
end

% retrieve screen properties
screendim                   =   Screen('Rect',        scrnum);
[dispsize(1), dispsize(2)]  =   Screen('DisplaySize', scrnum);
hz                          =   Screen('FrameRate',   scrnum);
dispdist                    =   570; % in mm

if hz == 0
    hz  =   60;
    warning( 'A framerate of 0 Hz was returned, default framerate of 60 Hz is used');
end

% check presentation duration given refresh rate
pres_t =  p_timings/1000;  
real_t =  round( pres_t/(1/hz)).*(1/hz);
for n_p = 1: length( pres_t)
    if abs( pres_t(n_p) - real_t(n_p)) > .001
        warning( 'At the current framerate (%g Hz), the requested presentation duration of %g ms will actually be %g ms', hz, round( pres_t(n_p)*1000), round( real_t(n_p)*1000));
    end
end

% silence warnings
if ~checkcomp('DCC-B.00.3X-Beh')
    Screen( 'Preference', 'SkipSyncTests', 1);
    warning( 'Unknown computer, viewing distance estimated at %g cm.', round( dispdist/10));
end


%% ========================= Stimulus settings ========================= %%

% colors and gray values
c3          =   ones(1,3)*255;
backgr      =   round(0.5*c3);          % background color (0 = black, 1 = white)

% native stimulus sizes (dva)
natsize     =   [6.3 14];       % native size vert x hori (scene is 288 x 640 pix) = factor 0.45
natobjs     =   [2.05 2.13];    % native size (big object is 103 x 107 pix) -> object itself is 2 dva
objfrac     =   0.70;           % size of probe object, fraction from native size

% displacements
xjitrangen  =   1.6;            % horizontal jitter range of near target (dva)
xjitrangef  =   0.8;            % horizontal jitter range of near target (dva)
xjitvars    =   10;             % number of jitter variations
targshift   =   2.1;            % target eccentricity (rel. to fixation)

% object size variations (used to match size range of Gayet & Peelen, 2019)
nvars       =   10;         % number of size variation per size category
memfrac     =   0.285;      % size of memory objects, relative to objfrac 
bigrange    =   0.08;       % size range (fraction) of big memory object
smarange    =   0.08;       % size range (fraction) of small memory object
sizejit     =   0.15;       % size jitter range of all objects within a trial (0 is no jitter)
jitvars     =   20;         % number of jitter size variations
testrange   =   0.2;        % additional fraction range for test items
deltatest   =   0.01;       % fraction adjustment change for size test

% fixation color and size
fixcol      =   [c3*0; c3]';
fixsize     =   [0.2 0.1];

% text settings
textcol     =   c3*0;       % text color
fontsize    =   20;         % font size in pixels

% timing settings (s)
iti         =   2.0;        % inter trial interval (1 sec in Gayet & Peelen (2019), but longer for TMS)
objpres     =   0.15;       % presentation time (seconds) of object and scene (from Gayet & Peelen, 2019)
pretest     =   1.0;        % delay between offset of object/scene and onset test stimulus (from Gayet & Peelen, 2019)
countd      =   0.8;        % timing of 3, 2, 1 count down at block start

% number of stimuli
numtests    =   32;         % number of different sizes for initial presentation of test object
nobjsize    =   16;         % number of different object sizes


%% ========================= Keyboard settings ========================= %%

% response keys (key-codes)
if IsWin
    
    rhk     =   [37 40 39 38];  % LDRU
    esckey  =   27; 
    space   =   32;
    lhk     =   [65 83 68 87];  % asdw
    
    textfont    =   'Calibri';  % font

elseif IsOSX

    rhk     =   [80 81 79 82];  % LDRU
    esckey  =   41; 
    space   =   44;
    lhk     =   [4 22 7 26];    % asdw
    
    textfont    =   'Arial';    % font
end


%% =========================== Open screen ============================= %%

% open screen and set transparancy mode
[w, screenrect]  =   Screen( 'OpenWindow', scrnum, backgr);
Screen( w, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen( 'FillRect', w, backgr);    Screen( 'Flip', w);

% find (and set) max refresh rate
maxhz = getmaxhz( screenrect(3:4), scrnum);
if hz < maxhz
    try
        SetResolution( scrnum, screenrect(3), screenrect(4), maxhz);
        hz = maxhz;
    catch
    end
end
    
% test refreshrate
itis     =  50;     
x        =  NaN( 1, itis+1);

for i    =  1 : itis+1    
        x(i)    = Screen( 'Flip', w);     
end
x(1)=[];

% compute and report results
estirate =  1/mean( diff( x));

if estirate < (hz-2) || estirate > (hz+2)
    sca;    ShowCursor;
    error( '[!!!] Warning: refreshrate estimated at %g Hz in stead of %g Hz!', estirate, hz);
end


%% =========================== Instructions ============================ %%
mytexts =   {'Press [SPACEBAR] to read through the instructions...',...
             'You will see an OBJECT presented very briefly within a scene.', ...
             'Use the [LEFT] and [RIGHT] arrow keys to reproduce the size of this object.',...
             'Remember: always fixate on the bullseye in the center when there is one.'};

mymsgs  =   {'Good job! We will now start the actual experiment.', ...
             'The End! Thanks for participating :-)'};

         
%% ======================= Variable conversions ======================== %%

% degrees to pixels
fixsize     =   ang2pix( fixsize,    dispdist, dispsize(1), screendim(3), 1);
xjitrangen  =   ang2pix( xjitrangen, dispdist, dispsize(1), screendim(3), 0);
xjitrangef  =   ang2pix( xjitrangef, dispdist, dispsize(1), screendim(3), 0);
natsize     =   ang2pix( natsize,    dispdist, dispsize(1), screendim(3), 1);
natobjs     =   ang2pix( natobjs,    dispdist, dispsize(1), screendim(3), 1);
targshift   =   ang2pix( targshift,  dispdist, dispsize(1), screendim(3), 1); 

% ensure symmetrical bullseye
if bitget( fixsize(1), 1) ~= bitget( fixsize(2) ,1)
    fixsize(1)  =   fixsize(1) - 1;
end

% location jitter
nearjits        =   round( linspace( -xjitrangen, xjitrangen, xjitvars));
farjits         =   round( linspace( -xjitrangef, xjitrangef, xjitvars));

% size jitter
memfracs(1,:)   =   linspace( 1 - memfrac - smarange, 1 - memfrac + smarange, nvars);
memfracs(2,:)   =   linspace( 1 + memfrac - bigrange, 1 + memfrac + bigrange, nvars);

% pulse timings in frames
f_timings       =   hz*p_timings/1000;

