function [UserVar] = Ua_Transient_Run(convergence, density_flag, dhdt)

    %% Parameters for this run. We have two choices for the convergence
    % less convergence, J=30
    % more convergence, J=25

    % and three choices for the density formulation: 
    % density_flag = 'DV-BF'; %'D2T', 'NV'

    % and two choices for basal melt
    % dhdt=0
    % dhdt=-10

    
    %%
    if dhdt == 0
        experiment_ext='-nodhdt';
    else
        experiment_ext='';
    end

    %% Calculate the Basal Melt rate and store as a ScatteredInterpolant in 'Fab-estimate_%s%s%s.mat'
    FasInterpolantFile='Interpolants/FasRACMO.mat';
    DiagnosticUaFile=sprintf('ResultsFiles/0000000-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Diagnostic_%s%s.mat', density_flag, convergence);
    FabInterpolantFile=sprintf("Fab-estimate_%s%s%s.mat", density_flag, convergence, experiment_ext);
    CreateBasalMeltScatteredInterpolant(FasInterpolantFile, DiagnosticUaFile, dhdt, FabInterpolantFile)


    %% Forward-Transient run 

    UserVar=[]; CtrlVar=[];
    UserVar.RunType='Forward-Transient';
    UserVar.FasInterpolant='Interpolants/FasRACMO.mat'; 
    UserVar.FabInterpolant=FabInterpolantFile;
    UserVar.GeometryInterpolant=sprintf('../../BedMachineData/BedMachineGriddedInterpolants_%s.mat',density_flag);
    UserVar.MeshBoundaryCoordinatesFile='../../BedMachineData/MeshBoundaryCoordinatesForAntarcticaBasedOnBedmachine'; 
    UserVar.SurfaceVelocityInterpolant='Interpolants/SurfVelMeasures990mInterpolants.mat';
    folder=sprintf('InverseRunOutputs%s%s',density_flag,convergence);
    UserVar.CFile=sprintf('%s/C-Estimate.mat', folder);
    UserVar.AFile=sprintf('%s/AGlen-Estimate.mat', folder);

    CtrlVar.Restart=0;  % switch to 1 after the first run if TotalTime not reached
    CtrlVar.Experiment=sprintf("PIG-TWG-Transient_%s%s%s", density_flag, convergence, experiment_ext);    
    CtrlVar.TotalNumberOfForwardRunSteps=1000;  % May need more to reach TotalTime=40yrs
    CtrlVar.TotalTime=40; 

    % Store the CtrlVar.time at each run for reading in ResultsFiles 
    if CtrlVar.Restart==1
        timestamps=load(sprintf('ResultsFiles/%s-timestamps.mat', CtrlVar.Experiment),'timestamps');
        UserVar.timestamps=timestamps.timestamps;
    else
        UserVar.timestamps=NaN(CtrlVar.TotalNumberOfForwardRunSteps+1,1);
    end
    UserVar=Ua(UserVar,CtrlVar);

    %Save the time stamps to file
    timestamps=rmmissing(UserVar.timestamps);
    save(sprintf('ResultsFiles/%s-timestamps.mat', CtrlVar.Experiment),'timestamps');

    %% Generate VAF file
    t=load(sprintf('ResultsFiles/%s-timestamps.mat', CtrlVar.Experiment));
    num_timesteps=size(t.timestamps);
    vaf=NaN(num_timesteps);
    for tindex=1:num_timesteps(1)
        time=t.timestamps(tindex);
        ua=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-%s.mat',round(time*100),CtrlVar.Experiment));
        [VAF,IceVolume,GroundedArea]=CalcVAF(ua.CtrlVar,ua.MUA,ua.F.h,ua.F.B,ua.F.S,ua.F.rho,ua.F.rhow,ua.F.GF);
        vaf(tindex)=VAF.Total;
    end
    save(sprintf('ResultsFiles/VAF_%s%s%s.mat', density_flag, convergence, experiment_ext),'vaf');



end
