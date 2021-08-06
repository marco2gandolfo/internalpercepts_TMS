function waitForSpaceBar
spaceKeyIdx = KbName('space');                          % specify the key to continue the experiment after the break
[responseTi, keyStateVec] = KbWait;
KbReleaseWait;                                                                    % hold on until spaceKeyIdx, i.e. space bar, is pressed and then released
while ~keyStateVec(spaceKeyIdx)                                                   % check the keyboard until the spaceKeyIdx, i.e. space bar, is pressed
    [~, keyStateVec] = KbWait;
    KbReleaseWait;
end