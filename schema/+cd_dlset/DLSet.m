%{
-> cd_decoder.TrainedDecoder
-> cd_dlset.ShuffleParam
%}

classdef DLSet < dj.Computed
    properties
        popRel = cd_decoder.TrainedDecoder * cd_dlset.ShuffleParam & 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"'
    end

	methods(Access=protected)
		function makeTuples(self, key)
			 self.insert(key)
		end
    end
    
    methods
        function [dataSet, decoder] = getDataSet(self, key, nori, fresh)
            if nargin < 4
                fresh = false;
            end
            if nargin < 3
                nori = [];
            end
            if nargin < 2 || isempty(key)
                key = fetch(self);
            end
            
            % arguably this is such a circular dependency that it's a bad
            % idea but this does make cache based retrieval logic 
            % simpler to implement
            if ~fresh && exists(cd_dlset.DLSetInfo & key)
                path = '/lab/users/eywalker/v1_project/data';
                localPath = getLocalPath(path);
                fname = sprintf('%s_%d_%d.mat', key.dec_trainset_hash, key.decoder_id, key.lc_shuffle_id);
                fullPath = fullfile(localPath, fname);
                fprintf('Attempting to load from cache %s...\n', fullPath);
                try
                    dt = load(fullPath);
                    dataSet = dt.dataSet;
                    return;
                catch
                    fprintf('Failed to retrieve from cache...\n');
                    % pass it out
                end
            end
            
            [dataSet, decoder] = getAll(cd_decoder.TrainedDecoder & key);
            dataSet = prepareDataSet(dataSet, decoder, key, nori);
            dataSet = shuffleDataSet(cd_dlset.ShuffleParam & key, dataSet);
        end
    end

end