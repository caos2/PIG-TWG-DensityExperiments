
%% Load one of the Diagnostic Run Datasets to extract PIG-TWG domain boundary
ua=load('ResultsFiles/0000000-Nodes41364-Ele81785-Tri3-kH1000-PIG-TWG-Diagnostic_DV-BF25');

%% Load raw BedMachine geometry
GeometryInterpolant = '../../BedMachineData/BedMachineGriddedInterpolants_DV-BF.mat';
fprintf('Loading file: %-s ',GeometryInterpolant)
load(GeometryInterpolant,'FB','Fb','Fs','Frho')
fprintf(' done \n')

load('../../UaSource/UaUtilities/MUA_Antarctica.mat', 'MUA'); 
xFE=MUA.coordinates(:,1) ; yFE=MUA.coordinates(:,2) ; 

%% Load velocities
% Observed velocities.
obs_vel=load('Interpolants/SurfVelMeasures990mInterpolants.mat');
% sample observed velocities at the Ua grid points
obs_u=obs_vel.FuMeas(ua.F.x,ua.F.y); 
obs_v=obs_vel.FvMeas(ua.F.x,ua.F.y); 


%% Plot the variation in vertically averaged density for all Antarctica
% Include grounding line where B=b
rho=Frho(xFE,yFE);
I=(FB(xFE,yFE)==Fb(xFE,yFE)); %grounded area

% Mask grounded area from density plot
shelf_density = rho;
shelf_density(I)=917;

FindOrCreateFigure('fulldensity');
CtrlVar.PlotXYscale=1000;
[~,cbar]=PlotMeshScalarVariable(CtrlVar,MUA, shelf_density); title(cbar,'kg/m^3')
hold on
PlotMuaBoundary(CtrlVar,MUA,'k');
PlotLatLonGrid(CtrlVar.PlotXYscale,5,45,500,'k',1);
%Add a legth scale and remove axis:
plot([-2300; -1300], [-1900; -1900], '-k', 'LineWidth', 2)
hold off
text(-2250,-1800, '0', 'HorizontalAlignment','right')
text(-1300,-1800, '1000 km', 'HorizontalAlignment','center')
set(gca,'XTick',[], 'YTick', []);
caxis([750 917])

f=gcf;
f.Colormap(length(f.Colormap),:)=[0.8 0.8 0.8];
%exportgraphics(f, 'Figures/AntarcticDensity.pdf');



%% Plot Antarctic and PIG-TWG PanelPlot of surface topography 
figure
t=tiledlayout(1,2);

% Full Antarctic plot LH plot
ax1=nexttile;
CtrlVar.PlotXYscale=1000;
[~,cbar]=PlotMeshScalarVariable(CtrlVar,MUA,Fs(xFE,yFE)); title(cbar,'m a.s.l')
hold on
PlotMuaBoundary(CtrlVar,ua.MUA,'r','LineWidth',2);
PlotMuaBoundary(CtrlVar,MUA,'k');
PlotLatLonGrid(CtrlVar.PlotXYscale,5,30,400,'k',1);
%Add a length scale and remove axis:
plot([-1800; -800], [-1900; -1900], '-k', 'LineWidth', 2)
hold off
text(-1700,-1700, '0', 'HorizontalAlignment','right')
text(-800,-1700, '1000 km', 'HorizontalAlignment','center')
set(gca,'XTick',[], 'YTick', []);
xlim([-2550 2750])
ylim([-2150 2210])

%set shared cbar
bottom=min(Fs(xFE,yFE));
top=max(Fs(xFE,yFE));
caxis([bottom top])
colorbar off

%PIG and Thwaites domain RH plot
ax2=nexttile;
[~,cbar]=PlotMeshScalarVariable(ua.CtrlVar,ua.MUA,Fs(ua.F.x,ua.F.y)); title(cbar,'m a.s.l')
hold on
PlotMuaBoundary(CtrlVar,ua.MUA,'r', 'LineWidth',2);
PlotGroundingLines(ua.CtrlVar,ua.MUA,ua.F.GF,[],[],[],'g', 'LineWidth',2);
PlotLatLonGrid(CtrlVar.PlotXYscale,5,30,400,'k',0);
xlabel('xps (km)') ; ylabel('yps (km)'); 
text(-1613,-204,'Pine Island Glacier')
text(-1540,-405,'Thwaites Glacier')
hold off
xlim([-2010 -700])
ylim([-970 165])
caxis([bottom top])

t.Padding = 'tight';
t.TileSpacing = 'tight';

f=gcf;
%exportgraphics(f, 'Figures/PIGTWG.pdf');



%% Zoom into the PIG-TWG domain 
xl=-1700;
xr=-1300;
yu=0;
yd=-550;

%% Plot Zoomed-in Observed Velocity and Density
figure
t=tiledlayout(1,2);

% Observed Velocity LH plot
ax1=nexttile;
ua.CtrlVar.QuiverColorSpeedLimits=[100 4000];
QuiverColorGHG(ua.F.x,ua.F.y,obs_u,obs_v,ua.CtrlVar);
hold on ; 
PlotMuaBoundary(ua.CtrlVar,ua.MUA,'b')
text(-1613,-50,'Pine Island Glacier', 'FontSize',12 )
text(-1540,-380,'Thwaites Glacier', 'FontSize',12)
ylim([yd yu])
xlim([xl xr])

%Density RH plot
ax2=nexttile;
ua.CtrlVar.PlotXYscale=1000;
[~,cbar]=PlotMeshScalarVariable(ua.CtrlVar,ua.MUA,ua.F.rho);
title(cbar,'(kg m^{-3})')
colormap(ax2,flipud(cool));
caxis([820 920])
hold on
ylim([yd yu])
xlim([xl xr])

yticklabels(ax2,{}); ylabel(ax2,{});
title(ax1,'Observed Velocity');
title(ax2,'Density');
linkaxes([ax1, ax2], 'x');
xlabel(ax1,'xps (km)'); xlabel(ax2,'xps (km)'); ylabel(t,'yps (km)')
t.Padding = 'tight';
t.TileSpacing = 'tight';

%exportgraphics(f, 'Figures/DensityAndVelocity.pdf');
