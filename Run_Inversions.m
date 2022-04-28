
%% Invert to find optimal AGlen and C 
% This will do an inverse run starting with the estimates in 'StartingAGlenC-estimate'. 
% And will save better estimates to C-Estimate.mat and AGlen-Estimate.mat

% Slow. You will want to batch with 500 iterations at a time, and read in the
% restart file. You need to manually save outputs to the folders:
% 'InverseRunOutputs_DV-BF30', after the cost function reaches J=30,
% 'InverseRunOutputs_DV-BF25', after the cost function reaches J=25, etc.

%% Clear any persistent Ua states between runs - very important!
Klear

%% Run this for each one of the density formulation:
density_flag='DV-BF';
% density_flag='D2T';
% density_flag='NV';

%%
UserVar=[];
UserVar.RunType='Inverse-MatOpt';
UserVar.SurfaceVelocityInterpolant='Interpolants/SurfVelMeasures990mInterpolants.mat';
UserVar.GeometryInterpolant=sprintf('../../BedMachineData/BedMachineGriddedInterpolants_%s.mat',density_flag);
UserVar.MeshBoundaryCoordinatesFile='../../BedMachineData/MeshBoundaryCoordinatesForAntarcticaBasedOnBedmachine'; 
CtrlVar=[];
CtrlVar.Inverse.Iterations=500;  % Needs to be a few thousands
CtrlVar.Restart=0;  % Set to 1 after the first run so that it reads in restart file 
UserVar.CFile='StartingAGlenC-estimate/C-Estimate.mat'; 
UserVar.AFile='StartingAGlenC-estimate/AGlen-Estimate.mat';
UserVar=Ua(UserVar,CtrlVar);
