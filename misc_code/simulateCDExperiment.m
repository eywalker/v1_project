function [stimuli, classResp] = simulateCDExperiment(nTrials)
%SIMULATECDEXPERIMENT Simulates n_trials of the class discrimination 
% experiment by returning stimulus orientation and correct class
    mu = 270;
    sigmaA = 3;
    sigmaB = 15;
    classA = rand(nTrials, 1) > 0.5;
    classResp = cell(nTrials, 1);
    [classResp{classA}] = deal('A');
    [classResp{~classA}] = deal('B');
    
    sigma = classA * sigmaA + ~classA * sigmaB;
    stimuli = randn(nTrials, 1) .* sigma + mu;
end

