% Checks if asdf has already been made in given directory. If not, creates
% asdf and saves in current directory.
%
%% DEPENDENCIES
%1) Vision
%2) NeuronsToASDF.m
%%
function CreateASDF(neurons_dir)
  old_pwd = cd(neurons_dir);
  if (exist([pwd '/asdf.mat'],'file')) %will check that ASDF is in folder - else will create & load one
      disp([pwd, '/asdf.mat already exists.']);
  else
      fileList = dir('*.neurons'); % *.neurons file must be in current folder
      NeuronsToASDF([pwd '/' fileList.name], 'asdf.mat', 512); %generates/saves ASDF file to current folder
  end
  cd(old_pwd);