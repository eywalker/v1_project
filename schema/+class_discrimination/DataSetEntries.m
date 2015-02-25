%{
class_discrimination.DataSetEntries (computed) # my newest table
-> class_discrimination.DataSets
dataset_entry_id      : int         # unique id for the entry
-----
stimulus_class              : enum('A','B')                 # The stimulus class (A or B)
selected_class              : enum('A','B')                 # The selected stimulus class (A or B)
correct_response            : tinyint                       # True for a correct response
correct_direction           : enum('Left','Right')          # Direction for correct answer
selected_direction          : enum('Left','Right')          # Direction for correct answer
orientation                 : float                         # Orientation of the grating
posterior_a                 : float                         # Posterior probability of A
contrast                    : float                         # Contrast of stimulus
r                           : longblob                      # Population response
%}

classdef DataSetEntries < dj.Relvar
    methods
        function self=DataSetEntries(varargin)
            self.restrict(varargin{:});
        end
        function makeTuples(self, key, dataSet)
            key = fetch(class_discrimination.DataSets & key);
            tuples(length(dataSet)) = struct();
            
            [tuples.dataset_id] = deal(key.dataset_id);
            if isfield(dataSet, 'id')
                [tuples.dataset_entry_id] = deal(dataSet.id);
            else
                entry_id = num2cell(1:length(dataSet));
                [tuples.dataset_entry_id] = deal(entry_id{:});
            end
            [tuples.stimulus_class] = deal(dataSet.stimulus_class);
            [tuples.selected_class] = deal(dataSet.selected_class);
            [tuples.correct_response] = deal(dataSet.correct_response);
            [tuples.correct_direction] = deal(dataSet.correct_direction);
            [tuples.selected_direction] = deal(dataSet.selected_direction);
            [tuples.orientation] = deal(dataSet.orientation);
            [tuples.posterior_a] = deal(dataSet.posterior_a);
            [tuples.contrast] = deal(dataSet.contrast);
            [tuples.r] = deal(dataSet.r);
            insert(self, tuples);
        end
        
    end
end