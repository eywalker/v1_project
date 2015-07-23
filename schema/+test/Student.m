%{
test.Student (manual) # my newest table
student_name    :varchar(128)    # name of the student
-----
-> test.Master
%}

classdef Student < dj.Relvar
end