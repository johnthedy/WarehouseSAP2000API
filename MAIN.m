clc;clear;tic;close all
ntrial=10000;
load('profile.mat')
ngparam=6;

fixfeatures=[60 60 4.5 0.0488 0.75];

lb=[30 0.6 0.2 20000 15000 6000 12000 3 10 min(Wlist(:,8)) min(Wlist(:,8)) min(Wlist(:,8)) min(Clist(:,8)) min(Plist(:,3))];
ub=[100 0.8 0.45 50000 30000 4000 8000 10 15 max(Wlist(:,8)) max(Wlist(:,8)) max(Wlist(:,8)) max(Clist(:,8)) max(Plist(:,3))];

for i=2254:ntrial
    %% Generate features
    eco=lb+rand(1,length(lb)).*(ub-lb);
    %Dead and Live Load
    DL=fixfeatures(1);LL=fixfeatures(2);WL=eco(1);
    %Response Spectra Params consist of R, Ss, S1, Ct, x
    EQset=[fixfeatures(3) eco(2) eco(3) fixfeatures(4) fixfeatures(5)];
    %gparam1=warehouse length, gparam2=warehouse width,
    %gparam3=warehouse column height, gparam4=warehouse total height
    %gparam5=number of portal, gparam6=purlin spacing
    gparam=round(eco(4:4+ngparam-1));
    %sparam consist of section Inertia for column, girder, purlin, pipe
    sparam=eco(ngparam+4:end);

    %% Simulation
    [RecRatio,idxframe]=SAPSIMULATION(sparam,gparam,DL,LL,WL,EQset,Wlist,Clist,Plist);

    d1=find(strcmp(idxframe(:,1),'COL'));
    d2=find(strcmp(idxframe(:,1),'GIR'));
    d3=find(strcmp(idxframe(:,1),'TIE'));
    d4=find(strcmp(idxframe(:,1),'PUR'));
    d5=find(strcmp(idxframe(:,1),'BRC'));
    COLr=max(RecRatio(d1));
    GIRr=max(RecRatio(d2));
    TIEr=max(RecRatio(d3));
    PURr=max(RecRatio(d4));
    BRCr=max(RecRatio(d5));

    %% Record
    ResultInput(i,:)=eco;
    ResultOutput(i,:)=[COLr GIRr TIEr PURr BRCr];
    save('Database.mat')
end