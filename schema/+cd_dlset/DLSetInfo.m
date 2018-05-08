%{
-> cd_dlset.DLSet
-----
dataset_path: varchar(255)    # path to the MAT file
%}

classdef DLSetInfo < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
            path = '/lab/users/eywalker/v1_project/data';
            localPath = getLocalPath(path);
            fname = sprintf('%s_%d_%d.mat', key.dec_trainset_hash, key.decoder_id, key.lc_shuffle_id);
            fullPath = fullfile(localPath, fname);
            [dataSet, decoder] = getDataSet(cd_dlset.DLSet & key);
            fprintf('Saving to %s...\n', fullPath);
            dataSet = rmfield(dataSet, {'key', 'decoder', 'event_type'});
            save(fullPath, 'dataSet');
            savePath = fullfile('/v1_data', fname);
            key.dataset_path = savePath;
            insert(self, key);
		end
	end

end