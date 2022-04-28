function CreateBasalMeltScatteredInterpolant(FasInterpolantFile,DiagnosticUaFile,dhdt,OutputFile)
    % Calculate the Ocean induced melt, a_{b}
    
    fprintf('CreateBasalMeltScatteredInterpolant: loading file: %-s ',FasInterpolantFile)
    load(FasInterpolantFile,'Fas')
    fprintf(' done \n')
    % Need the horizonal velocities from the diagnostic run:
    fprintf('CreateBasalMeltScatteredInterpolant: loading file: %-s ',DiagnosticUaFile)
    load(DiagnosticUaFile,'F', 'MUA', 'CtrlVar')
    fprintf(' done \n')

    dsdt=0;
    % Optionally include a term for dhdt to encourage Pine Island Glacier to retreat
    % which then infers a much larger meltrate to compensate
    if nargin==3
        fprintf('dhdt not specified. Will default to dhdt=0\n')
        dhdt=0;
    end
        
    % We require the horizonal velocities - get these from the model velocities
    % of a previous diagnostic run (not the observed velocities)
    % since these will be smoother and the gradients (needed for the mass
    % balance) will be more reliable
    x=MUA.coordinates(:,1);
    y=MUA.coordinates(:,2);
    as=Fas(x,y);
    
    [ab,qx,qy,dqxdx,dqxdy,dqydx,dqydy]=CalcIceShelfMeltRates(CtrlVar,MUA,F.ub,...
        F.vb,F.s,F.b,F.S,F.B,F.rho,F.rhow,dsdt,as,dhdt);

    % Need some ad-hoc smoothing to remove high freq noise.
    % Use Helmholtz equation in the form:
    % f(x)-L^2 f''(x)=ab(x), where f(x) is the smoothed field
    % Take F.T. => f(k)=ab(k)/(1+(2piL/lambda)^2), where k=2pi/lambda
    % For lambda>>L, f(k)=ab(k), i.e. no effect at large scales
    % for lambda<<L, f(k)=A*ab(k), where A<<1, i.e. attenuation at high freq
    
    % Trial and error for the smoothing length scale. Tried 1e3, but that
    % still has significant (unphysical) positive peaks
    % L=1e4 gives a range from 0 to -100 which fits observations.
    L=1e4 ;  % Smoothing length scale

    [UserVar,SmoothedField]=HelmholtzEquation([],CtrlVar,MUA,1,L^2,ab,0);

    % Put melt rates over grounded areas to zero.
    GF=GL2d(F.B,F.S,F.h,F.rhow,F.rho,MUA.connectivity,CtrlVar);
    smooth_ab=SmoothedField.*(1-GF.node);
    
    % Plot ab and smoothed ab to check output
    FindOrCreateFigure('Fas') ; 
    [~,cbar]=PlotMeshScalarVariable(CtrlVar,MUA,as);
    xlabel('xps (km)' ) ; ylabel('yps (km)' ) ; title('as') ; title(cbar,'m a.s.l')
    FindOrCreateFigure('Fab') ; 
    [~,cbar]=PlotMeshScalarVariable(CtrlVar,MUA,ab);
    xlabel('xps (km)' ) ; ylabel('yps (km)' ) ; title('ab') ; title(cbar,'m a.s.l')
    FindOrCreateFigure('Smoothed Fab') ; 
    [~,cbar]=PlotMeshScalarVariable(CtrlVar,MUA,smooth_ab);
    xlabel('xps (km)' ) ; ylabel('yps (km)' ) ; title('Smoothed ab') ; title(cbar,'m a.s.l')
   
    % Convert and store as a ScatteredInterpolant
    Fab=scatteredInterpolant(x,y,SmoothedField);
    
    save(OutputFile,'Fab')

    