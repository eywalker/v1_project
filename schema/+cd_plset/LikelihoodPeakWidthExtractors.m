%{
cd_plset.LikelihoodPeakWidthExtractors (manual) # set of likelihood peak-width extractors
pwextractor_id              : int                    # unique id for the peak width extractor
-----
pwextractor_name            : varchar(255)           # name of the peak width extractor function
pwextractor_label=''        : varchar(255)           # descriptor for the peak width extractor
%}

classdef LikelihoodPeakWidthExtractors < dj.Relvar
    
    methods
        function self= LikelihoodPeakWidthExtractors(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerPWExtractor(self, pwextractor, label)
            if nargin < 3
                label = '';
            end
            
            last_id = max(fetchn(cd_plset.LikelihoodPeakWidthExtractors, 'pwextractor_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(pwextractor) % if owner given as an object
                pwextractor = func2str(pwextractor);
            end
            
            tuple.pwextractor_id = new_id;
            tuple.pwextractor_name = pwextractor;
            tuple.pwextractor_label = label;
            insert(self, tuple);
        end

        
        function pwextractor=getPWExtractor(self)
            assert(count(self)==1, 'You can only retrieve one pw extractor at a time');
            info = fetch(self, '*');
            pwextractor = eval(['@' info.pwextractor_name]);
        end
    end

end