% drop all
drop(test.Master); % respond yes to this at the prompt

% insert masters
master.master_name = 'Master Kung Fu';
insert(test.Master, master);
master.master_name = 'Dragon Shin';
insert(test.Master, master);

% who trained which students?
student.master_name = 'Master Kung Fu';
student.student_name = 'Domon';
insert(test.Student, student);
student.student_name = 'Ryu';
insert(test.Student, student);

student.master_name = 'Dragon Shin';
student.student_name = 'Genbu';
insert(test.Student, student);
student.student_name = 'Byakko';
insert(test.Student, student);


% where are they at now?
membership.master_name = 'Master Kung Fu';
membership.student_name = 'Ryu';
insert(test.Membership, membership);
membership.student_name = 'Genbu';
insert(test.Membership, membership);

membership.master_name = 'Dragon Shin';
membership.student_name = 'Domon';
insert(test.Membership, membership);
membership.student_name = 'Byakko';
insert(test.Membership, membership);

%%
% Actually Dragon Shin is fake, let's delete all his association!
del(test.Master & 'master_name = "Dragon Shin"');