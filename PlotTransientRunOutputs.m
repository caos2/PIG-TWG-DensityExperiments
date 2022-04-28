
%% Transient Run: Read in the outputs and plot VAF
% Can run this for three configuration:
% --converged 25, dhdt=-10  :   ext='25'
% --converged 25, dhdt=0    :   ext='25-nodhdt'
% --converged 30, dhdt=-10  :   ext='30'

ext='25';
%ext='25-nodhdt';
%ext='30';

%% LOAD and PLOT VAF
DVBFt=load(sprintf('ResultsFiles/PIG-TWG-Transient_DV-BF%s-timestamps.mat', ext));
D2Tt=load(sprintf('ResultsFiles/PIG-TWG-Transient_D2T%s-timestamps.mat', ext));
NVt=load(sprintf('ResultsFiles/PIG-TWG-Transient_NV%s-timestamps.mat', ext));
DVBF=load(sprintf('ResultsFiles/VAF_DV-BF%s.mat', ext));
D2T=load(sprintf('ResultsFiles/VAF_D2T%s.mat', ext));
NV=load(sprintf('ResultsFiles/VAF_NV%s.mat', ext));

% VAF is in m^3 (ocean equivalent)
% Plot Loss in VAF so that positive. Convert to km^3.
% Loss in VAF(km^3) = -VAF / 10^9
change_vaf_DVBF=-(DVBF.vaf-DVBF.vaf(1))/1e9;
change_vaf_D2T=-(D2T.vaf-D2T.vaf(1))/1e9;
change_vaf_NV=-(NV.vaf-NV.vaf(1))/1e9;

%Also plot the equiv sea level change on RH axis (just need to scale axis)
Aocean=3.625e14; %m^2
VAF_max=8000;
%convert back to m^3 ocean equiv and then divide by ocean area. 
sea_level_max=(VAF_max*1e9)*1e3/Aocean;  % in mm

FindOrCreateFigure('VAF') ;
plot(DVBFt.timestamps,change_vaf_DVBF, 'b')
hold on
plot(D2Tt.timestamps,change_vaf_D2T,'r')
plot(NVt.timestamps,change_vaf_NV,'g')
xlabel('Time (yrs)' ); 
ylabel('Loss of VAF (ocean equivalent) in km^3' ) ; 
ylim([0 VAF_max])
%Also plot the equiv sea level change on RHS
yyaxis right
ylabel('\Delta Sea Level (mm)' ) ;
ylim([0 sea_level_max])
legend('DV-BF','D2T', 'NV')
hold off
f=gcf; %get current figure
%exportgraphics(f, sprintf('Figures/VAFplot_%s.pdf', ext));
 
%% Zoom into the PIG-TWG domain 
xl=-1700;
xr=-1300;
yu=0;
yd=-550;

%% Transient Run: Plot horizontal velocities and Grounding Line
% At t=0
D2T0=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_D2T%s.mat',0, ext));
DVBF0=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_DV-BF%s.mat',0, ext));
NV0=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_NV%s.mat',0, ext));
% At t=40
D2T40=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_D2T%s.mat',4000, ext));
DVBF40=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_DV-BF%s.mat',4000, ext));
NV40=load(sprintf('ResultsFiles/%07i-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Transient_NV%s.mat',4000, ext));

name_run_list={...
              {'DV-BF',DVBF0, DVBF40},...
              {'D2T',D2T0, D2T40},...
              {'NV',NV0, NV40},...             
              };

figure           
t=tiledlayout(2,3);
for name_runs = name_run_list
    name=name_runs{1,1}{1,1};
    run0=name_runs{1,1}{1,2};
    run1=name_runs{1,1}{1,3};
    %outright velocities. ignore run0
    u=run1.F.ub;
    v=run1.F.vb;
    
    nexttile;
    run0.CtrlVar.VelPlotIntervalSpacing='log10';
    run0.CtrlVar.QuiverColorSpeedLimits=[100 4000];
    QuiverColorGHG(run0.F.x,run0.F.y,u,v,run0.CtrlVar);
    hold on ; 
    PlotMuaBoundary(run0.CtrlVar,run0.MUA,'b')
    title(name)
    
    if strcmp(name,'DV-BF')
        colorbar off
    elseif strcmp(name, 'D2T')
        colorbar off
        yticklabels({})
    else
        yticklabels({})
    end
  
    xticklabels({})
    xlim([xl xr])
    ylim([yd yu])

end


%% Plot evolution of the grounding line

for name_runs = name_run_list
    name=name_runs{1,1}{1,1};
    run0=name_runs{1,1}{1,2};
    run1=name_runs{1,1}{1,3};
    nexttile;
    PlotGroundingLines(run0.CtrlVar,run0.MUA,run0.F.GF,[],[],[],'b');
    hold on
    PlotGroundingLines(run1.CtrlVar,run1.MUA,run1.F.GF,[],[],[],'r');
    PlotMuaBoundary(run0.CtrlVar,run0.MUA,'k')
    legend(sprintf('GL at t=%-g',run0.CtrlVar.time), sprintf('GL at t=%-g',run1.CtrlVar.time))
    
    if strcmp(name, 'SL40')
        yticklabels({})
    elseif strcmp(name, 'NO40')
        yticklabels({})
    end
    
    xlim([xl xr])
    ylim([yd yu])
    
end

xlabel(t, 'x (km)') ; 
ylabel(t, 'y (km)');
t.TileSpacing='tight';
t.Padding='tight';


f=gcf; %get current figure
%exportgraphics(f, 'Figures/VelocityAndGL_panelplot.pdf');
