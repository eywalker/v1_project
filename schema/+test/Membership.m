%{
test.Membership (lookup) # my newest table
-> test.Student
-----
-> test.Master
%}

classdef Membership < dj.Relvar
end