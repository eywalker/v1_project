%{
# CV set member
-> cd_dlset.CVSet
cv_index    : int       # index into the N-way CV
---
train_indices: longblob # trial indices for the training set
test_indices: longblob  # trial indices for the test set
%}

classdef CVSetMember < dj.Part

	properties(SetAccess=protected)
		master= cd_dlset.CVSet
	end

end