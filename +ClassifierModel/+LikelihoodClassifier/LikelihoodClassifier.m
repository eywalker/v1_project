classdef (Abstract) LikelihoodClassifier < handle
    %LIKELIHOODCLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        
        pA = pRespA(self, decodeOri, likelihood);
        
    end
    
    methods
       function classResp = classifyLikelihood(self, decodeOri, likelihood)
            % classifyLikelihood Classifies the given likelihood
            % distribution over decodeOri. Note that this is a stochastic
            % classifier and thus response vaies from run to run. 
            pA = self.pRespA(decodeOri, likelihood); % probability of responding A
            nTrials = size(likelihood, 2);
            randRoll = rand(nTrials, 1);
            classResp = cell(nTrials, 1);
            pos = (pA >= randRoll);
            [classResp{pos}] = deal('A');
            [classResp{~pos}] = deal('B');
        end
    end
    
end

