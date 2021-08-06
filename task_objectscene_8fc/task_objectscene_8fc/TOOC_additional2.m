if keyCode(numpad1)
    given_answer = 'Car';
    given_answerno = 1;
elseif keyCode(numpad2)
    given_answer = 'Fish';
    given_answerno = 2;
elseif keyCode(numpad3)
    given_answer = 'Train';
    given_answerno = 3;
elseif keyCode(numpad4)
    given_answer = 'Human';
    given_answerno = 4;
elseif keyCode(numpad5)
    given_answer = 'Ship';
    given_answerno = 5;
elseif keyCode(numpad6)
    given_answer = 'Bird';
    given_answerno = 6;
elseif keyCode(numpad7)
    given_answer = 'Airplane';
    given_answerno = 7;
elseif keyCode(numpad8)
    given_answer = 'Mammal';
    given_answerno = 8;
% elseif keyCode(escKey)
%     fclose(outfile);
%     Screen('CloseAll');
%     return;  
end

if given_answerno == presented_stimno
    correctness = 'Correct';
else
    correctness = 'Wrong';
end
