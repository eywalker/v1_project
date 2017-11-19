%{
# set of trained decoder
-> cd_decoder.DecoderTrainSets
-> cd_point.PointDecoderModels
-----
ptdec_trained_config   : longblob            # structure for configuring the model
ptdec_mse : float                            # mean squared error 
%}

classdef TrainedPointDecoder < dj.Computed

	properties
		popRel = cd_decoder.DecoderTrainSets * cd_point.PointDecoderModels;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            
            ptdec = getPointDecoder(cd_point.PointDecoderModels & key);
            dataSet = fetchDataSet(cd_decoder.DecoderTrainSets & key);
            tuple.ptdec_mse = ptdec.train(dataSet);
            tuple.ptdec_trained_config = ptdec.getModelConfigs();
            
			self.insert(tuple)
		end
    end
    
    methods
        function self= TrainedPointDecoder(varargin)
            self.restrict(varargin{:});
        end
        
        function [dataSet, model] = getAll(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            dataSet = fetchDataSet(cd_decoder.DecoderTrainSets & self);
            model = getPointDecoder(self);
        end
        
        function model=getPointDecoder(self)
            model = getPointDecoder(cd_point.PointDecoderModels & self);
            % load trained configuration
            config = fetch1(self, 'ptdec_trained_config');
            model.setModelConfigs(config);
        end
    end

end