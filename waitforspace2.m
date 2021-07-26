while 1
    [a,~,c] = KbCheck;
    if a && ismember(space,find(c))
        break
    elseif a && ismember(esckey,find(c))
        keeprunning = 0;
        break
    end
end

