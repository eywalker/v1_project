%{
class_discrimination.CSCLookup (lookup) # Alias lookup for CleanSpikeCountSets
csc_hash: varchar(128)    # hash for clean spike count set
---
-> class_discrimination.CleanSpikeCountSet
%}

classdef CSCLookup < dj.Relvar

	methods
		function populate(self)
            keys = fetch(class_discrimination.CleanSpikeCountSet - self);
            fprintf('Found %d keys to populate...\n', length(keys));
            for key=keys'
                disp(key);
                hash = gethash(key);
                key.csc_hash = hash;
                insert(self, key);
            end
		end
	end

end