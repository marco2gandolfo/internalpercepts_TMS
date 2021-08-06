if Stimlist{i}(1) == 'A'
    presented_stim = 'Airplane';
    presented_stimno = 7;
elseif Stimlist{i}(1) == 'B'
    presented_stim = 'Bird';
    presented_stimno = 6;
elseif Stimlist{i}(1) == 'C'
    presented_stim = 'Car';
    presented_stimno = 1;
elseif Stimlist{i}(1) == 'F'
    presented_stim = 'Fish';
    presented_stimno = 2;
elseif Stimlist{i}(1) == 'M'
    presented_stim = 'Mammal';
    presented_stimno = 8;
elseif Stimlist{i}(1) == 'P'
    presented_stim = 'Human';
    presented_stimno = 4;
elseif Stimlist{i}(1) == 'S'
    presented_stim = 'Ship';
    presented_stimno = 5;
elseif Stimlist{i}(1) == 'T'
    presented_stim = 'Train';
    presented_stimno = 3;
end;

if Stimlist{i}(2) == 'A'
    presented_cat = 'Object_in_Scene';
elseif Stimlist{i}(2) == 'B'
    presented_cat = 'Object_alone_deg';
elseif Stimlist{i}(2) == 'C'
    presented_cat = 'Object_alone';
elseif Stimlist{i}(2) == 'D'
    presented_cat = 'Scene_alone';
end;

if Stimlist{i}(3) == 'N'
    stim_created = 'New';
elseif Stimlist{i}(3) == 'O'
    stim_created = 'Old';
end;