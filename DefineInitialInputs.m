
function [UserVar,CtrlVar,MeshBoundaryCoordinates]=DefineInitialInputs(UserVar,CtrlVar)

%% This experiment largely follows the code in UaExamples/PIG-TWG


%%
UserVar.DistanceBetweenPointsAlongBoundary=5e3 ; 

CtrlVar.SlidingLaw="Weertman" ;

%%
switch UserVar.RunType
    
    case 'Inverse-MatOpt'
        
        CtrlVar.InverseRun=1;
        
        CtrlVar.Restart=0;
        CtrlVar.Inverse.InfoLevel=1;
        CtrlVar.InfoLevelNonLinIt=0;
        CtrlVar.InfoLevel=0;
        
        UserVar.Slipperiness.ReadFromFile=0;
        UserVar.AGlen.ReadFromFile=0;
        
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
        
        CtrlVar.Inverse.Iterations=10;
        
        CtrlVar.Inverse.InvertFor="-logA-logC-" ; % {'C','logC','AGlen','logAGlen'}
        CtrlVar.Inverse.Regularize.Field=CtrlVar.Inverse.InvertFor;
        CtrlVar.Inverse.DataMisfit.GradientCalculation="-adjoint-" ; % "-FixpointC-"; "adjoint";
        CtrlVar.Inverse.Measurements="-uv-" ;  % {'-uv-,'-uv-dhdt-','-dhdt-'}
  
        
        CtrlVar.Inverse.Regularize.logC.ga=1;
        CtrlVar.Inverse.Regularize.logC.gs=1e4;  
        CtrlVar.Inverse.Regularize.logAGlen.ga=1;
        CtrlVar.Inverse.Regularize.logAGlen.gs=1e4 ; 
        
        
        % [----------- Testing adjoint gradents
        CtrlVar.Inverse.TestAdjoint.isTrue=0; % If true then perform a brute force calculation
        % of the directional derivative of the objective function.
        CtrlVar.TestAdjointFiniteDifferenceType="central-second-order" ;
        CtrlVar.Inverse.TestAdjoint.FiniteDifferenceStepSize=0.01 ;
        CtrlVar.Inverse.TestAdjoint.iRange=[100,121] ;  % range of nodes/elements over which brute force gradient is to be calculated.
        % if left empty, values are calulated for every node/element within the mesh.
        % If set to for example [1,10,45] values are calculated for these three
        % nodes/elements.
        % ----------------------- ]end, testing adjoint parameters.
        
        
    case 'Forward-Transient'
        
        CtrlVar.InverseRun=0;
        CtrlVar.TimeDependentRun=1;
        CtrlVar.Restart=0;
        CtrlVar.InfoLevelNonLinIt=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
        
    case 'Forward-Diagnostic'
               
        CtrlVar.InverseRun=0;
        CtrlVar.TimeDependentRun=0;
        CtrlVar.Restart=0;
        CtrlVar.InfoLevelNonLinIt=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
  
end


CtrlVar.dt=0.01;
CtrlVar.time=0;
CtrlVar.TotalNumberOfForwardRunSteps=1; 
CtrlVar.TotalTime=10;

% Element type
CtrlVar.TriNodes=3 ;


%%
CtrlVar.doplots=1;
CtrlVar.PlotMesh=0;  
CtrlVar.PlotBCs=1 ;
CtrlVar.PlotXYscale=1000;
CtrlVar.doAdaptMeshPlots=5; 

%% Meshing 

CtrlVar.ReadInitialMeshFileName='PIG-TWG-Mesh';
CtrlVar.SaveInitialMeshFileName='MeshFile';
CtrlVar.MaxNumberOfElements=70e3;

CtrlVar.MeshRefinementMethod='explicit:local:newest vertex bisection';   
CtrlVar.MeshRefinementMethod='explicit:global';   

CtrlVar.MeshGenerator='gmsh' ; % 'mesh2d';
CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';
CtrlVar.GmshMeshingAlgorithm=8; 

CtrlVar.MeshSizeMax=20e3;
CtrlVar.MeshSize=CtrlVar.MeshSizeMax/2;
CtrlVar.MeshSizeMin=CtrlVar.MeshSizeMax/20;

UserVar.MeshSizeIceShelves=CtrlVar.MeshSizeMax/5;

MeshBoundaryCoordinates=CreateMeshBoundaryCoordinatesForPIGandTWG(UserVar,CtrlVar);
                                         
CtrlVar.AdaptMeshInitial=1  ;       % remesh in first iteration (Itime=1)  even if mod(Itime,CtrlVar.AdaptMeshRunStepInterval)~=0.
CtrlVar.AdaptMeshAndThenStop=1;    % if true, then mesh will be adapted but no further calculations performed
                                   % useful, for example, when trying out different remeshing options (then use CtrlVar.doAdaptMeshPlots=1 to get plots)
CtrlVar.AdaptMeshMaxIterations=5;
CtrlVar.SaveAdaptMeshFileName='MeshFileAdapt';    %  file name for saving adapt mesh. If left empty, no file is written
CtrlVar.AdaptMeshRunStepInterval=1 ; % remesh whenever mod(Itime,CtrlVar.AdaptMeshRunStepInterval)==0



I=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='effective strain rates';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.001;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=true;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='flotation';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.0001;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;

I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='thickness gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='upper surface gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;



%%
UserVar.AddDataErrors=0;



%%
CtrlVar.ThicknessConstraints=0;
CtrlVar.ResetThicknessToMinThickness=1;  % change this later on
CtrlVar.ThickMin=50;


%%

if CtrlVar.InverseRun
    CtrlVar.Experiment="PIG-TWG-Inverse-"...
       +CtrlVar.ReadInitialMeshFileName...
        +CtrlVar.Inverse.InvertFor...
        +CtrlVar.Inverse.MinimisationMethod...
        +"-"+CtrlVar.Inverse.AdjointGradientPreMultiplier...
        +CtrlVar.Inverse.DataMisfit.GradientCalculation...
        +CtrlVar.Inverse.Hessian...
        +"-"+CtrlVar.SlidingLaw...
        +"-"+num2str(CtrlVar.DevelopmentVersion);
else
    CtrlVar.Experiment="PIG-TWG-Forward"...
        +CtrlVar.ReadInitialMeshFileName;
    
end

CtrlVar.Experiment=replace(CtrlVar.Experiment," ","-"); 
CtrlVar.Experiment=replace(CtrlVar.Experiment,".","k"); 


CtrlVar.NameOfRestartFiletoWrite=CtrlVar.Experiment+"-ForwardRestartFile.mat"; %Set to be identical
CtrlVar.NameOfRestartFiletoRead=CtrlVar.NameOfRestartFiletoWrite; %Set to be identical

CtrlVar.Inverse.NameOfRestartOutputFile=CtrlVar.Experiment+"-InverseRestartFile.mat";
CtrlVar.Inverse.NameOfRestartInputFile=CtrlVar.Inverse.NameOfRestartOutputFile; 


end
