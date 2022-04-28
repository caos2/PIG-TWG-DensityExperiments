%% Clear any Ua persistent states between runs - very important! 
Klear

%% Set up parameters for this run. We have two choices for the convergence
% less convergence, J=30
% more convergence, J=25
convergence = '25';

% and three choices for the density formulation: 
% 'DV-BF', 'D2T', 'NV'
density_flag='DV-BF';


%% Diagnostic Run to find model velocities

UserVar=[];
UserVar.RunType='Forward-Diagnostic';
UserVar.GeometryInterpolant=sprintf('../../BedMachineData/BedMachineGriddedInterpolants_%s.mat',density_flag);
UserVar.MeshBoundaryCoordinatesFile='../../BedMachineData/MeshBoundaryCoordinatesForAntarcticaBasedOnBedmachine'; 
UserVar.SurfaceVelocityInterpolant='Interpolants/SurfVelMeasures990mInterpolants.mat';
folder=sprintf('InverseRunOutputs%s%s',density_flag,convergence);
UserVar.CFile=sprintf('%s/C-Estimate.mat',folder); 
UserVar.AFile=sprintf('%s/AGlen-Estimate.mat',folder);
CtrlVar=[];
CtrlVar.Experiment=sprintf("PIG-TWG-Diagnostic_%s%s",density_flag,convergence);    
UserVar=Ua(UserVar,CtrlVar);