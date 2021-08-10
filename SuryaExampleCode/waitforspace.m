function [] = waitforspace

if IsWin
    spacebar = 32;  esckey  =   27;
elseif IsOSX
    spacebar = 44;  esckey  =   41; 
end

while 1
    [a,~,c] = KbCheck;
    if a && ismember(spacebar,find(c))
        break
    elseif a && ismember(esckey,find(c))
        sca; ShowCursor;
        error('[!!!] Program aborted by user');
    end
end