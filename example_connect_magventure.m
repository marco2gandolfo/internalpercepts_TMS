addpath("E:\Users\MAGIC-0.1-beta\")
o = magventure('COM1');
o.connect();
[e, r]=o.getStatus() %
[e,r]=o.arm(1) %This is to 
% examples
o.setAmplitude(20) 
o.fire()
o.setTrain(2,5,2,5)
o.sendTrain()
