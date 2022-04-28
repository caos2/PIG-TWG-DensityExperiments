
%% Environment variables for remote jobs
% setenv('UaHomeDirectory', '/home/<username..>/MyPIG-TWG/UaSource') 
% setenv('GmshHomeDirectory','/home/<username..>/MyPIG-TWG/gmsh-4.8.4-Windows64/gmsh-4.8.4-Windows64')
% UaHomeDirectory=getenv('UaHomeDirectory'); addpath(genpath('/home/<username..>/MyPIG-TWG/'))
% 
% cd '/home/<username..>/MyPIG-TWG/'


%% Set up parameters for this run. We have two choices for the convergence
% less convergence, J=30
% more convergence, J=25
convergence = '25';

% and three choices for the density formulation: 
% 'DV-BF', 'D2T', 'NV'
density_flag='DV-BF';

% and two choices for basal melt
% dhdt=0
% dhdt=-10
dhdt=-10;


%% 
UserVar=Ua_Transient_Run(convergence, density_flag, dhdt);