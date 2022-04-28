function [UserVar,as,ab,dasdh,dabdh]=DefineMassBalance(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)


persistent Fas
persistent Fab

% If FasInterpolant has been specified in UserVar then we need to include
% the surface mass accumulation, if not set it to zero (e.g. for inverse
% run)
if isfield(UserVar,'FasInterpolant') 
    if isempty(Fas)
        fprintf('DefineMassBalance: loading file: %-s ',UserVar.FasInterpolant)
        load(UserVar.FasInterpolant,'Fas')
        fprintf(' done \n')
    end
    as=Fas(MUA.coordinates(:,1),MUA.coordinates(:,2));
else
    as=0;
end

% If FabInterpolant has been specified in UserVar then we need to include
% the ocean induced basal melt, if not set it to zero (e.g. for inverse
% run)
if isfield(UserVar,'FabInterpolant') 
    if isempty(Fab)
        fprintf('DefineMassBalance: loading file: %-s ',UserVar.FabInterpolant)
        load(UserVar.FabInterpolant,'Fab')
        fprintf(' done \n')
    end
    ab=Fab(MUA.coordinates(:,1),MUA.coordinates(:,2));
else
    ab=0;
end

%The below quanities are only needed for mass-balance feedback. Out of
%scope for this project.
dasdh=0;
dabdh=0;


end