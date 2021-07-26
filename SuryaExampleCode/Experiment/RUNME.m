%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% RUN EXPERIMENT: TMS & size constancy (version 1.1)                      %
%                                                                         %
%                  >> January 2020 @ Donders Institute <<                 %
%                                                                         %
%                         Miles Wischnewski, Surya Gayet, & Marius Peelen %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: input '00' as participant number for a shortened test run


%% ======================= Start and clean up ========================== %%

% initialize experiment
addpath( genpath( fullfile( pwd, 'functions')));   startup1;

% Assign participant number
while 1
    pp      =   input( 'pp ID: ');
    ppn     =   sprintf( '%02g', pp);
    
    % check if result file already exists
    rfiles  =   dir( fullfile( pwd, 'data', ppn,  [ppn '-results.mat'] ));
    
    % if it does, ask what experimenter wants to do
    if size( rfiles, 1) && ~strcmp( ppn, '00')
        fprintf( '\nParticipant %s already participated. What now? \n', ppn);
        whatnow     =   input( '> Assign new participant number (0), overwrite session (1), or start at block (N)?: ');
        
        % if experimenter wants to proceed, back up old data file first
        if whatnow > 0
            copyfile( fullfile( pwd, 'data', ppn, rfiles(1).name), fullfile( pwd, 'data', ppn, sprintf( 'backup_%s', rfiles(1).name)), 'f');
            break
        end
    else
        % if it does not, create a participant directory and proceed
        mkdir( fullfile( pwd, 'data', ppn));
        whatnow = 1;
        break
    end
end

% determine starting run (i.e., include practice or not)
if whatnow > 1
    startrun = 2;
else
    startrun = 1;
end


%% ========================== Run experiment =========================== %%

% run experiment (and by default also the practice session)
for wrun = startrun:2
    illusorysize( ppn, wrun, whatnow);
end


%% ===================== Shut down and clean up ======================== %%

% clean up
ListenChar(1); ShowCursor; sca;
