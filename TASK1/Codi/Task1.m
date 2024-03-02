clear;

%% %%%% PREPROCESSING
%INPUT PARAMETERS
ndim=6;
g=9.81;
fixnodes=[10735 13699 16620 19625 22511 4747];
refnode=1305;

% LOADING DATA
load("fe_model.mat");

% PARAMETERS
TotalDOF=size(K,1);
nnodes = TotalDOF/ndim;

% UNITS
M = M*1e3; % From tons to kg
K = K*1e3; % From N/mm to N/m


%% %%% STATIC ANALYSIS
%%% PART 1
%%% DIRICHLETT AND NEUMANN LOCATIONS
Part='Part1';
Support=1;
[u,F,DirichlettDOF] = StaticSolver(K,M,TotalDOF,nnodes,g,fixnodes,ndim,Part,Support);

%%% REACTIONS CHECK
% Calculation of the mass in kg
mass = sum(diag(M))/3;
%Check if Dirichlett forces in y direction are equal to weight
w_error = repmat([0 1 0 0 0 0],1,6)*F(DirichlettDOF)+mass*g;
w_error<1e-6;

%PRINT RESULTS TO HDF5
uhdf=zeros(nnodes,ndim);
for i=1:ndim
    uhdf(:,i)=u(i:ndim:end);
end
fillhdf("template.h5","Part1Output.h5",uhdf);

%% %%%%
%%% PART 2
%%% DISPLACEMENTS AND ROTATIONS
%Compute the displacements and rotations of the referencenode due
%to enforced unit displacements in y direction in each support.

% Displacements of reference node
u_ref=u((refnode-1)*ndim+1:refnode*ndim);

%Change of prescribed displacements 
Support=1;
Part='Part2a';
[u,F] = StaticSolver(K,M,TotalDOF,nnodes,g,fixnodes,ndim,Part,Support);


% SHIMS CALCULATIONS
%fixnodes=[10735 13699 16620 19625 22511 4747 1305];
Part='Part2b';
[u,F] = StaticSolver(K,M,TotalDOF,nnodes,g,fixnodes,ndim,Part,Support);

ushims=u(DirichlettDOF);
ushims=ushims(2:6:end);

% %% %%% DYNAMIC ANALYSIS
% %%% MODAL ANALYSIS
% neig=10;
% 
% [KNN,KND, KDN, KDD] = KSubparts(K, NeumannDOF, DirichlettDOF);
% % Constrained masses
% MNN = M(NeumannDOF,NeumannDOF);
% 
% % Modal response constrained
% [MODES, FREQ] = modResponse(KNN,MNN,neig);
% 
% % Modal response unconstrained
% [MODES_U, FREQ_U] = modResponse(K,M,neig);
% 
% %%% RESPONSE ANALYSIS


