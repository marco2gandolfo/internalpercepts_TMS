function [labcomp] = checkcomp(wcomp)

% Detect computer from MAC address
systemInfo = Screen('Computer');
if ~isfield(systemInfo,'MACAddress')
    [~, output] = system('getmac');
    startchar=160;
    systemInfo.MACAddress = output(startchar:startchar+16);
    while sum(strcmp({'Dis','N/A'},systemInfo.MACAddress(1:3)));
        startchar=startchar+79; % check if deviant rowlength
        systemInfo.MACAddress = output(startchar:startchar+16);
    end
end

% compare computers
switch systemInfo.MACAddress
    case {'28-16-AD-0B-7D-86','40-B0-34-E7-D4-67'}  % Donders Laptop (on network or eduroam)
        thiscomp = 'DondersLaptop';
    case {'F8-B1-56-E1-3C-CC'};                     % Test computer DCC - B.00.31b 
        thiscomp = 'DCC-B.00.3X-Beh';
    otherwise
        thiscomp='other';
end

% output
if nargin == 1
    labcomp=strcmp(wcomp,thiscomp);
else
    if strcmp(thiscomp,'other')
        labcomp = systemInfo.MACAddress;    % return mac address OR
    else
        labcomp=thiscomp;                   % return lab name
    end
end