classdef FullPSLLC < ClassifierModel.FlexibileLikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    
    methods
        function obj = FullPSLLC(sigmaA, sigmaB, stimCenter, modelName)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 4
                modelName = 'FullPSLLC';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.FlexibileLikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
        end
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct)% decodeOri, likelihood)
            decodeOri = dataStruct.decodeOri(:);
            likelihood = dataStruct.likelihood;
            psA = normpdf(decodeOri, self.stimCenter, self.sigmaA); % p(s | C = 'A')
            psB = normpdf(decodeOri, self.stimCenter, self.sigmaB); % p(s | C = 'B')
            prA = likelihood' * psA; % p(r | C = 'A')
            prB = likelihood' * psB; % p(r | C = 'B')
            logLRatio = log(prA) - log(prB); % log(p(r | C = 'A') / p(r | C = 'B'))
        end
    end
    
end