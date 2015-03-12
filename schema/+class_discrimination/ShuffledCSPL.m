%{
class_discrimination.ShuffledCSPL (computed) # shuffled contrast session PL
-> class_discrimination.ContrastSessionParameterizedLikelihoods
-> class_discrimination.ShuffleCSPLParams
-----
shuffled_indices: longblob     # indiex for shuffled widths
-> class_discrimination.ParameterizedLikelihoodSets
%}

classdef ShuffledCSPL < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.ContrastSessionParameterizedLikelihoods * class_discrimination.ShuffleCSPLParams
    end
    
    methods
        function self=ShuffledCSPL(varargin)
            self.restrict(varargin{:});
        end
        
        function plSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            plSet = fetchPLSet(class_discrimination.ContrastSessionParameterizedLikelihoods & pro(self));
            info = fetch(self, '*');
            plSet.likelihood_width = plSet.likelihood_width(info.shuffled_indices);
        end
    end

	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            params = fetch(class_discrimination.ShuffleCSPLParams & key, '*');
            plSet = fetchPLSet(class_discrimination.ContrastSessionParameterizedLikelihoods & key);
            rng(params.shuffle_cspl_seed, 'twister');
            binWidth = params.shuffle_cspl_binwidth;
            
            binnedOri = round(plSet.orientation / binWidth) * binWidth;
            ori = sort(unique(binnedOri));
            
            indices = 1:length(plSet.orientation);
            for i = 1:length(ori)
                pos = find(binnedOri == ori(i));
                randpos = pos(randperm(length(pos)));
                indices(pos) = indices(randpos);
            end
            assert(all(binnedOri(indices) == binnedOri), 'Something went wrong with shuffling...');
            
            tuple.shuffled_indices = indices;
            tuple.plset_id = registerPLSet(class_discrimination.ParameterizedLikelihoodSets, self, 'Shuffled width');
            insert(self, tuple);
		end
    end
    
    

end