# V1 decision making
===========

This repository is for work on the CNRC grant between Wei Ji and
Andreas.

The animal observes a grating sampled either from a gaussian with 3
degrees or 12 degrees standard deviation, and must indicate which
class it infers the grating came from.  Contrast is manipulated to
alter the sensory uncertainty.

# Preprocessing
===========
processSession(sess,'Utah','MultiUnit')
populate(detect.Sets, sess)
populate(sort.MultiUnit, sess)
populate(sort.Sets, sess);
populate(sort.SetsCompleted, sess)
populate(ephys.SpikeSet, sess);

populate(stimulation.StimTrialGroup, sess);
populate(class_discrimination.ClassDiscriminationExperiment, sess);

# Processing
===========
populate(v1.ReceptiveFields,acq.Subjects('subject_name="Leo"'))
populate(v1.QuickOrientationTuning,acq.Subjects('subject_name="Leo"'))

