function [maxhz] = getmaxhz(dispres,screenNumber)

% Retreive the heighest refreshrate (in Hz) for a given
% resolution [width x heigth] and screen number (e.g., 1).

resolutions=Screen('Resolutions',screenNumber);
resfields=fieldnames(resolutions(1));
resovars=zeros(length(resfields),length(resolutions));
for i=1:length(resolutions);
   for j = 1:length(resfields);
       resovars(j,i)=resolutions(i).(resfields{j});
   end
end

maxhz=max(resovars(4,resovars(1,:)==dispres(1)&resovars(2,:)==dispres(2)));