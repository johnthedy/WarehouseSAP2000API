function [W,RecRatio,BARSCHEDULE,recpattern]=SAPSIMULATION(sparam,gparam,DL,LL,EQset,Wlist,Clist,Plist)

BARSCHEDULE=[];

Req=EQset(1);
Omega=EQset(2);
Cd=EQset(3);
Ss=EQset(4);
S1=EQset(5);
Ct=EQset(6);
x=EQset(7);

%% Geometry Parameter
%gparam1=warehouse length, gparam2=warehouse width,
%gparam3=warehouse column height, gparam4=warehouse total height
%gparam5=number of portal, gparam6=purlin spacing
gparam1=gparam(1);
gparam2=gparam(2);
gparam3=round(gparam(3)/100)*100;
gparam4=gparam(4);
gparam5=gparam(5);
gparam6=gparam(6);
gparam7=round(gparam(7)/100)*100;

if sparam(end)<=0.15
    sparam(end)=0;
end
%% Section Parameter
%Column WF Section
if sparam(1)<sparam(2)*1.25
    sparam(1)=sparam(2)*1.25;
end
d1=sparam(1);
d2=abs(Wlist(:,8)-d1);
[~,d3]=min(d2);
sparam1=Wlist(d3,2);
sparam2=Wlist(d3,4);
sparam3=Wlist(d3,5);
sparam4=Wlist(d3,3);
COLNAMEIDX=d3;

%Girder WF Section
d1=sparam(2);
d2=abs(Wlist(:,8)-d1);
[~,d3]=min(d2);
sparam5=Wlist(d3,2);
sparam6=Wlist(d3,4);
sparam7=Wlist(d3,5);
sparam8=Wlist(d3,3);
GIRNAMEIDX=d3;

%Tie Beam WF Section
d1=sparam(3);
d2=abs(Wlist(:,8)-d1);
[~,d3]=min(d2);
sparam9=Wlist(d3,2);
sparam10=Wlist(d3,4);
sparam11=Wlist(d3,5);
sparam12=Wlist(d3,3);
TIENAMEIDX=d3;

%Purlin
d1=sparam(4);
d2=abs(Clist(:,8)-d1);
[~,d3]=min(d2);
sparam13=Clist(d3,2);
sparam14=Clist(d3,4);
sparam15=Clist(d3,5);
sparam16=Clist(d3,3);
PURNAMEIDX=d3;

%Bracing
d1=sparam(5);
d2=abs(Plist(:,3)-d1);
[~,d3]=min(d2);
sparam17=Plist(d3,4);
sparam18=Plist(d3,4)-Plist(d3,5);
BRCNAMEIDX=d3;

%% Preparation
fpath=sprintf('%s\\Structure\\',pwd);
NET.addAssembly('C:\Program Files\Computers and Structures\SAP2000 21\SAP2000v1.dll');
helper=SAP2000v1.Helper;
helper=NET.explicitCast(helper,'SAP2000v1.cHelper');
SapObject=helper.CreateObject('C:\Program Files\Computers and Structures\SAP2000 21\SAP2000.exe');
SapObject=NET.explicitCast(SapObject,'SAP2000v1.cOAPI');
SapModel=NET.explicitCast(SapObject.SapModel,'SAP2000v1.cSapModel');
clear helper

File=NET.explicitCast(SapModel.File,'SAP2000v1.cFile');
View=NET.explicitCast(SapModel.View,'SAP2000v1.cView');
PointObj=NET.explicitCast(SapModel.PointObj,'SAP2000v1.cPointObj');
FrameObj=NET.explicitCast(SapModel.FrameObj,'SAP2000v1.cFrameObj');
AreaObj=NET.explicitCast(SapModel.AreaObj,'SAP2000v1.cAreaObj');
LinkObj=NET.explicitCast(SapModel.LinkObj,'SAP2000v1.cLinkObj');
PropMaterial=NET.explicitCast(SapModel.PropMaterial,'SAP2000v1.cPropMaterial');
PropFrame=NET.explicitCast(SapModel.PropFrame,'SAP2000v1.cPropFrame');
PropArea=NET.explicitCast(SapModel.PropArea,'SAP2000v1.cPropArea');
PropLink=NET.explicitCast(SapModel.PropLink,'SAP2000v1.cPropLink');
LoadPatterns=NET.explicitCast(SapModel.LoadPatterns,'SAP2000v1.cLoadPatterns');
SourceMass=NET.explicitCast(SapModel.SourceMass,'SAP2000v1.cMassSource');
NamedAssign=NET.explicitCast(SapModel.NamedAssign,'SAP2000v1.cNamedAssign');
Func=NET.explicitCast(SapModel.Func,'SAP2000v1.cFunction');
FuncTH=NET.explicitCast(Func.FuncTH,'SAP2000v1.cFunctionTH');
FuncRS=NET.explicitCast(Func.FuncRS,'SAP2000v1.cFunctionRS');
LoadCases=NET.explicitCast(SapModel.LoadCases,'SAP2000v1.cLoadCases');
ModalRitz=NET.explicitCast(LoadCases.ModalRitz,'SAP2000v1.cCaseModalRitz');
ModalEigen=NET.explicitCast(LoadCases.ModalEigen,'SAP2000v1.cCaseModalEigen');
DirHistNonlinear=NET.explicitCast(LoadCases.DirHistNonlinear,'SAP2000v1.cCaseDirectHistoryNonlinear');
ModHistNonlinear=NET.explicitCast(LoadCases.ModHistNonlinear,'SAP2000v1.cCaseModalHistoryNonlinear');
StaticNonlinear=NET.explicitCast(LoadCases.StaticNonlinear,'SAP2000v1.cCaseStaticNonlinear');
ResponseSpectrum=NET.explicitCast(LoadCases.ResponseSpectrum,'SAP2000v1.cCaseResponseSpectrum');
Analyze=NET.explicitCast(SapModel.Analyze,'SAP2000v1.cAnalyze');
AnalysisResults = NET.explicitCast(SapModel.Results,'SAP2000v1.cAnalysisResults');
AnalysisResultsSetup = NET.explicitCast(AnalysisResults.Setup,'SAP2000v1.cAnalysisResultsSetup');
RespCombo = NET.explicitCast(SapModel.RespCombo,'SAP2000v1.cCombo');
DesignSteel = NET.explicitCast(SapModel.DesignSteel,'SAP2000v1.cDesignSteel');
ConstraintDef = NET.explicitCast(SapModel.ConstraintDef,'SAP2000v1.cConstraint');
AISC360_10 = NET.explicitCast(DesignSteel.AISC360_10,'SAP2000v1.cDStAISC360_10');

SapObject.ApplicationStart;
SapObject.Hide;
SapModel.SetPresentUnits(SAP2000v1.eUnits.N_mm_C);
File.NewBlank;

%% Geometry Coordinate
%Column Coordinate
CCoord=[];
Cx=[0 gparam2];
Cy=[0 round(linspace(gparam7,gparam1,gparam5-1))];
Cz=[0 gparam3];
for i=1:length(Cx)
    for j=1:length(Cy)
        for k=1:length(Cz)
            CCoord=vertcat(CCoord,[Cx(i) Cy(j) Cz(k)]);
        end
    end
end

%Girder Coordinate
GCoord=[];
d1=round(linspace(0,sqrt((gparam2/2)^2+(gparam4-gparam3)^2),gparam6+1));d1=sort(horzcat(d1,d1(end)-200));
d21=(gparam2/2)/sqrt((gparam2/2)^2+(gparam4-gparam3)^2);
d22=(gparam4-gparam3)/sqrt((gparam2/2)^2+(gparam4-gparam3)^2);
d3=round(d1.*d21);
d4=round(d1.*d22);

Gx=sort([d3 gparam2-d3(1:end-1)]);
Gz=[d4 fliplr(d4(1:end-1))]+gparam3;
Gy=[0 round(linspace(gparam7,gparam1,gparam5-1))];

for i=1:length(Gy)
    for j=1:length(Gx)
        GCoord=vertcat(GCoord,[Gx(j) Gy(i) Gz(j)]);
    end
end

%% Material Setup
[~,uidx,MN]=PropMaterial.GetNameList(0,[]);
for i=1:uidx
    PropMaterial.Delete(MN(i));
end
PropMaterial.SetMaterial('STEEL',SAP2000v1.eMatType.Steel);
PropMaterial.SetMPIsotropic('STEEL',200000,0.3,1.17e-5);
PropMaterial.SetOSteel_1('STEEL',350,450,350,450,1,1,0.015,0.11,0.17,-0.1);
PropMaterial.SetWeightAndMass('STEEL',1,7.7E-05);
PropMaterial.SetWeightAndMass('STEEL',2,7.85E-09);
clear uidx i MN

%% Set Section
PropFrame.SetISection('COL','STEEL',sparam1,sparam2,sparam3,sparam4,sparam2,sparam3);
PropFrame.SetISection('GIR','STEEL',sparam5,sparam6,sparam7,sparam8,sparam6,sparam7);
PropFrame.SetISection('TIE','STEEL',sparam9,sparam10,sparam11,sparam12,sparam10,sparam11);
PropFrame.SetChannel('PUR','STEEL',sparam13,sparam14,sparam15,sparam16);
PropFrame.SetChannel('PUR','STEEL',sparam13,sparam14,sparam15,sparam16);
PropFrame.SetPipe('BRC','STEEL',sparam17,sparam18);
PropFrame.SetModifiers('BRC', [1 1 1 1 1 1 0 0]);

%% Column Setup
[szA,~]=size(CCoord);idxframe={};idx=1;
d1=1:2:szA;
for i=1:length(d1)
    FrameObj.AddByCoord(CCoord(d1(i),1),CCoord(d1(i),2),CCoord(d1(i),3),CCoord(d1(i)+1,1),CCoord(d1(i)+1,2),CCoord(d1(i)+1,3),'','COL');
    idxframe=vertcat(idxframe,{'COL',idx});
    idx=idx+1;
end
nCOL=length(d1);
lCOL=gparam3;
if lCOL<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 COLNAMEIDX nCOL lCOL]);
else
    d1=lCOL;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[1 COLNAMEIDX nCOL 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 COLNAMEIDX nCOL d1]);
end

%% Tie Beam Setup
d1=find(CCoord(:,1)==0 & CCoord(:,3)==gparam3);
for i=1:length(d1)-1
    FrameObj.AddByCoord(CCoord(d1(i),1),CCoord(d1(i),2),CCoord(d1(i),3),CCoord(d1(i+1),1),CCoord(d1(i+1),2),CCoord(d1(i+1),3),'','TIE');
    idxframe=vertcat(idxframe,{'TIE',idx});
    idx=idx+1;
end

d2=find(CCoord(:,1)==gparam2 & CCoord(:,3)==gparam3);
for i=1:length(d2)-1
    FrameObj.AddByCoord(CCoord(d2(i),1),CCoord(d2(i),2),CCoord(d2(i),3),CCoord(d2(i+1),1),CCoord(d2(i+1),2),CCoord(d2(i+1),3),'','TIE');
    idxframe=vertcat(idxframe,{'TIE',idx});
    idx=idx+1;
end
nTIE1=2;
lTIE1=gparam7;
if lTIE1<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE1 lTIE1]);
else
    d1=lTIE1;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE1 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE1 d1]);
end
nTIE2=2*(gparam5-2);
lTIE2=(gparam1-gparam7)/(gparam5-2);
if lTIE2<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE2 lTIE2]);
else
    d1=lTIE2;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE2 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 TIENAMEIDX nTIE2 d1]);
end

%% Girder Setup
d1=unique(GCoord(:,2));
for i=1:length(d1)
    d2=find(GCoord(:,2)==d1(i));
    for j=1:length(d2)-1
        FrameObj.AddByCoord(GCoord(d2(j),1),GCoord(d2(j),2),GCoord(d2(j),3),GCoord(d2(j+1),1),GCoord(d2(j+1),2),GCoord(d2(j+1),3),'','GIR');
        idxframe=vertcat(idxframe,{'GIR',idx});
        idx=idx+1;
    end
end
d1=false(6,1);
d1(1:2)=true;
ConstraintDef.SetDiaphragm("DIAPH1",SAP2000v1.eConstraintAxis.Z);

d1=find(CCoord(:,3)~=0);
for i=1:length(d1)
    PointObj.SetConstraint(sprintf("%d",d1(i)), "DIAPH1");
end
[d2,~]=size(CCoord);
[d3,~]=size(GCoord);
for i=d2+1:d2+d3-length(d1)
    PointObj.SetConstraint(sprintf("%d",i), "DIAPH1");
end

nGIR=gparam5*2;
lGIR=sqrt((gparam2/2)^2+(gparam4-gparam3)^2);
if sparam(end)~=0
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 GIRNAMEIDX nGIR sparam(end)*lGIR]);
    lGIR=lGIR-sparam(end)*lGIR;
end
if lGIR<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 GIRNAMEIDX nGIR lGIR]);
else
    d1=lGIR;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[1 GIRNAMEIDX nGIR 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[1 GIRNAMEIDX nGIR d1]);
end
BARSCHEDULE=vertcat(BARSCHEDULE,[1 GIRNAMEIDX nGIR 0.1*lGIR]);

%% Purlin Setup
d1=unique(GCoord(:,2));
for i=1:length(d1)-1
    d2=find(GCoord(:,2)==d1(i) & GCoord(:,1)~=0 & GCoord(:,1)~=gparam2);
    for j=1:length(d2)
        if j~=gparam6+1
            FrameObj.AddByCoord(GCoord(d2(j),1),d1(i),GCoord(d2(j),3),GCoord(d2(j),1),d1(i+1),GCoord(d2(j),3),'','PUR');
            idxframe=vertcat(idxframe,{'PUR',idx});
            idx=idx+1;
        end
    end
end
d1=find(strcmp(idxframe(:,1),'PUR'));
ii=[false false false false true true];
jj=[false false false false true true];
StartValue=zeros(6,1);
EndValue=zeros(6,1);
for i=1:length(d1)
    FrameObj.SetReleases(sprintf('%d',d1(i)), ii, jj, StartValue, EndValue);
end

nPUR1=(gparam6*2);
lPUR1=gparam7;
if lPUR1<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR1 lPUR1]);
else
    d1=lPUR1;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR1 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR1 d1]);
end

nPUR2=(gparam6*2)*(gparam5-2);
lPUR2=(gparam1-gparam7)/(gparam5-2);
if lPUR2<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR2 lPUR2]);
else
    d1=lPUR2;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR2 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[2 PURNAMEIDX nPUR2 d1]);
end

%% Bracing Setup
idxbrc=0;
d1=find(CCoord(:,1)==0);
[szA,~]=size(d1);
d2=d1(2:2:szA);
for j=1:length(d2)-1
    d3=([CCoord(d2(j),1) CCoord(d2(j),2) CCoord(d2(j),3)]+[CCoord(d2(j)+1,1) CCoord(d2(j)+1,2) CCoord(d2(j)+1,3)])./2;
    FrameObj.AddByCoord(CCoord(d2(j),1),CCoord(d2(j),2),CCoord(d2(j),3),d3(1),d3(2),d3(3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
    FrameObj.AddByCoord(d3(1),d3(2),d3(3),CCoord(d2(j)+1,1),CCoord(d2(j)+1,2),CCoord(d2(j)+1,3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
end

d2=d1(1:2:szA);
for j=1:length(d2)-1
    d3=([CCoord(d2(j),1) CCoord(d2(j),2) CCoord(d2(j),3)]+[CCoord(d2(j)+3,1) CCoord(d2(j)+3,2) CCoord(d2(j)+3,3)])./2;
    FrameObj.AddByCoord(CCoord(d2(j),1),CCoord(d2(j),2),CCoord(d2(j),3),d3(1),d3(2),d3(3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
    FrameObj.AddByCoord(d3(1),d3(2),d3(3),CCoord(d2(j)+3,1),CCoord(d2(j)+3,2),CCoord(d2(j)+3,3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
end
d1=find(CCoord(:,1)==gparam2);
[szA,~]=size(d1);
d2=d1(2:2:szA);
for j=1:length(d2)-1
    d3=([CCoord(d2(j),1) CCoord(d2(j),2) CCoord(d2(j),3)]+[CCoord(d2(j)+1,1) CCoord(d2(j)+1,2) CCoord(d2(j)+1,3)])./2;
    FrameObj.AddByCoord(CCoord(d2(j),1),CCoord(d2(j),2),CCoord(d2(j),3),d3(1),d3(2),d3(3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
    FrameObj.AddByCoord(d3(1),d3(2),d3(3),CCoord(d2(j)+1,1),CCoord(d2(j)+1,2),CCoord(d2(j)+1,3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
end
d2=d1(1:2:szA);
for j=1:length(d2)-1
    d3=([CCoord(d2(j),1) CCoord(d2(j),2) CCoord(d2(j),3)]+[CCoord(d2(j)+3,1) CCoord(d2(j)+3,2) CCoord(d2(j)+3,3)])./2;
    FrameObj.AddByCoord(CCoord(d2(j),1),CCoord(d2(j),2),CCoord(d2(j),3),d3(1),d3(2),d3(3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
    FrameObj.AddByCoord(d3(1),d3(2),d3(3),CCoord(d2(j)+3,1),CCoord(d2(j)+3,2),CCoord(d2(j)+3,3),'','BRC');
    idxframe=vertcat(idxframe,{'BRC',idx});
    idx=idx+1;
end
nBRC1=8;
lBRC1=round(sqrt(gparam7^2+gparam3^2))/2;
if lBRC1<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC1 lBRC1]);
else
    d1=lBRC1;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC1 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC1 d1]);
end
nBRC2=8*(gparam5-2);
lBRC2=round(sqrt(((gparam1-gparam7)/(gparam5-2))^2+gparam3^2))/2;
if lBRC2<=12000
    BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC2 lBRC2]);
else
    d1=lBRC2;
    while d1>12000
        BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC2 12000]);
        d1=d1-12000;
    end
    BARSCHEDULE=vertcat(BARSCHEDULE,[3 BRCNAMEIDX nBRC2 d1]);
end

%% Set Restraint
d1=find(CCoord(:,3)==0);
for i=1:length(d1)
    PointObj.SetRestraint(sprintf('%d',d1(i)), [true true true true true true]);
end

%% Load Pattern and Mass Source
[~,dno,dname]=LoadPatterns.GetNameList(0,[]);
for i=1:dno
    LoadPatterns.Delete(dname(i));
end
[~,dno,dname]=SourceMass.GetNameList(0,[]);
for i=1:dno
    SourceMass.Delete(dname(i));
end
LoadPatterns.Add('LIVE',SAP2000v1.eLoadPatternType.Live,0,true);
LoadPatterns.Add('WINDY',SAP2000v1.eLoadPatternType.Wind,0,true);
SourceMass.SetMassSource('MSSSRC1',false,false,true,true,2,{'DEAD','LIVE'},[1 0.5]);

%% Assign Load
[pwind1,pwind2]=WindLoad(gparam1,gparam2,gparam3,gparam4,gparam5,gparam6,gparam7);

for i=1:length(Cy)
    if i==1
        LoadLength(i)=(Cy(i+1)-Cy(i))/2;
    elseif i==length(Cy)
        LoadLength(i)=(Cy(i)-Cy(i-1))/2;
    else
        LoadLength(i)=(Cy(i+1)-Cy(i))/2+(Cy(i)-Cy(i-1))/2;
    end
end
LoadLength=LoadLength./1000;
% Unit in N/mm
UDDL=DL.*LoadLength.*9.8./1000;
UDLL=LL.*LoadLength.*9.8./1000;

d2=find(strcmp(idxframe(:,1),'GIR'));
d3=1:length(d2)/gparam5:length(d2);

for i=1:length(d3)
    for j=d3(i):d3(i)+length(d2)/gparam5-1
        FrameObj.SetLoadDistributed(sprintf('%d',d2(j)), "DEAD", 1, 10, 0, 1, UDDL(i), UDDL(i));
        FrameObj.SetLoadDistributed(sprintf('%d',d2(j)), "LIVE", 1, 10, 0, 1, UDLL(i), UDLL(i));
        if j<((d3(i)+length(d2)/gparam5-1)+d3(i))/2
            UDWY=pwind1*LoadLength(i)/1000;
        else
            UDWY=-pwind2*LoadLength(i)/1000;
        end
        FrameObj.SetLoadDistributed(sprintf('%d',d2(j)), "WINDY", 1, 7, 0, 1, UDWY, UDWY);
    end
end

% d1=sqrt((gparam2/2)^2+(gparam4-gparam3)^2)./gparam6;
% LoadLength=d1./1000;
% UDDL=DL.*LoadLength.*9.8./1000;
UDLL=60*9.8./1000;
d2=find(strcmp(idxframe(:,1),'PUR'));
for i=1:length(d2)
    % FrameObj.SetLoadDistributed(sprintf('%d',d2(i)), "DEAD", 1, 10, 0, 1, UDDL, UDDL);
    FrameObj.SetLoadDistributed(sprintf('%d',d2(i)), "LIVE", 1, 10, 0, 1, UDLL, UDLL);
end

%% EQ Param
d1=[2 0.4 0.3 0.2 0.15 0.1 0];
d2=[1.4 1.4 1.4 1.5 1.6 1.7 1.7];
Cu=interp1(d1, d2, 0.8);
Ta=Ct*(gparam4/1000)^x;
Tlim=Cu*Ta;

T=0:0.01:4;
Value = code(Ss,S1,T);
Sa=interp1(Value(:,1), Value(:,2), Tlim);
FuncRS.SetUser("RS", length(Value(:,1)), Value(:,1), Value(:,2), 0.03);

%% Assign Response Spectrum X and Y direction
MyLoadName1={'U1'};MyLoadName2={'U2'};
MyFunc={'RS'};
ResponseSpectrum.SetCase("DX");
ResponseSpectrum.SetCase("DY");
ResponseSpectrum.SetLoads("DX",1,MyLoadName1,MyFunc,9850/Req,{'Global'},0);
ResponseSpectrum.SetDampConstant("DX", 0.03);
ResponseSpectrum.SetLoads("DY",1,MyLoadName2,MyFunc,9850/Req,{'Global'},0);
ResponseSpectrum.SetDampConstant("DY", 0.03);

ModalEigen.SetNumberModes("MODAL", 30, 1);

%% Save and Run Analysis
delete(sprintf('%s*',fpath))
File.Save(sprintf('%sStructure.sdb',fpath));
Analyze.RunAnalysis();

%% Extract FX and FY information from DX and DY load case
d1=find(CCoord(:,3)==0);

LN='DX';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
for i=1:length(d1)
    NumberResults = 0;
    Obj = NET.createArray('System.String',2);
    Elm = NET.createArray('System.String',2);
    LoadCase = NET.createArray('System.String',2);
    StepType = NET.createArray('System.String',2);
    StepNum = NET.createArray('System.Double',2);
    F1 = NET.createArray('System.Double',2);
    F2 = NET.createArray('System.Double',2);
    F3 = NET.createArray('System.Double',2);
    M1 = NET.createArray('System.Double',2);
    M2 = NET.createArray('System.Double',2);
    M3 = NET.createArray('System.Double',2);
    [~, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3]=AnalysisResults.JointReact(sprintf('%d',d1(i)), SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3);
    FDX(i)=double(F1(1));
end

LN='DY';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
for i=1:length(d1)
    NumberResults = 0;
    Obj = NET.createArray('System.String',2);
    Elm = NET.createArray('System.String',2);
    LoadCase = NET.createArray('System.String',2);
    StepType = NET.createArray('System.String',2);
    StepNum = NET.createArray('System.Double',2);
    F1 = NET.createArray('System.Double',2);
    F2 = NET.createArray('System.Double',2);
    F3 = NET.createArray('System.Double',2);
    M1 = NET.createArray('System.Double',2);
    M2 = NET.createArray('System.Double',2);
    M3 = NET.createArray('System.Double',2);
    [~, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3]=AnalysisResults.JointReact(sprintf('%d',d1(i)), SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3);
    FDY(i)=double(F2(1));
end

%% Extract FZ from DEAD and LIVE load case
LN='DEAD';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
for i=1:length(d1)
    NumberResults = 0;
    Obj = NET.createArray('System.String',2);
    Elm = NET.createArray('System.String',2);
    LoadCase = NET.createArray('System.String',2);
    StepType = NET.createArray('System.String',2);
    StepNum = NET.createArray('System.Double',2);
    F1 = NET.createArray('System.Double',2);
    F2 = NET.createArray('System.Double',2);
    F3 = NET.createArray('System.Double',2);
    M1 = NET.createArray('System.Double',2);
    M2 = NET.createArray('System.Double',2);
    M3 = NET.createArray('System.Double',2);
    [~, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3]=AnalysisResults.JointReact(sprintf('%d',d1(i)), SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3);
    FZDEAD(i)=double(F3(1));
end

LN='LIVE';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
for i=1:length(d1)
    NumberResults = 0;
    Obj = NET.createArray('System.String',2);
    Elm = NET.createArray('System.String',2);
    LoadCase = NET.createArray('System.String',2);
    StepType = NET.createArray('System.String',2);
    StepNum = NET.createArray('System.Double',2);
    F1 = NET.createArray('System.Double',2);
    F2 = NET.createArray('System.Double',2);
    F3 = NET.createArray('System.Double',2);
    M1 = NET.createArray('System.Double',2);
    M2 = NET.createArray('System.Double',2);
    M3 = NET.createArray('System.Double',2);
    [~, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3]=AnalysisResults.JointReact(sprintf('%d',d1(i)), SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, LoadCase, StepType, StepNum, F1, F2, F3, M1, M2, M3);
    FZLIVE(i)=double(F3(1));
end

%% Calibrate RS Force to fulfill 100% VELF
SapModel.SetModelIsLocked(false);
FZTOTAL=sum(FZDEAD+0.5.*FZLIVE);
VELF=FZTOTAL*Sa/Req;
AddDX=VELF/sum(FDX);
if AddDX>1
    ResponseSpectrum.SetLoads("DX",1,MyLoadName1,MyFunc,AddDX*9850/Req,{'Global'},0);
end
AddDY=VELF/sum(FDY);
if AddDY>1
    ResponseSpectrum.SetLoads("DY",1,MyLoadName2,MyFunc,AddDY*9850/Req,{'Global'},0);
end

%% Load Combination
RespCombo.Add('EQ1',3);
RespCombo.SetCaseList('EQ1',SAP2000v1.eCNameType.LoadCase,'DX',1.0);
RespCombo.SetCaseList('EQ1',SAP2000v1.eCNameType.LoadCase,'DY',1.0);
RespCombo.Add('EV',0);
RespCombo.SetCaseList('EV',SAP2000v1.eCNameType.LoadCase,'DEAD',0.2*Ss);
RespCombo.Add('COMB1',0);
RespCombo.SetCaseList('COMB1',SAP2000v1.eCNameType.LoadCase,'DEAD',1.4);
RespCombo.Add('COMB2',0);
RespCombo.SetCaseList('COMB1',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB1',SAP2000v1.eCNameType.LoadCase,'LIVE',1.6);
RespCombo.Add('COMB3',0);
RespCombo.SetCaseList('COMB3',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB3',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB3',SAP2000v1.eCNameType.LoadCombo,'EQ1',1.0);
RespCombo.SetCaseList('COMB3',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB4',0);
RespCombo.SetCaseList('COMB4',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB4',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB4',SAP2000v1.eCNameType.LoadCombo,'EQ1',-1.0);
RespCombo.SetCaseList('COMB4',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB5',0);
RespCombo.SetCaseList('COMB5',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB5',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB5',SAP2000v1.eCNameType.LoadCase,'DX',1.0);
RespCombo.SetCaseList('COMB5',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB6',0);
RespCombo.SetCaseList('COMB6',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB6',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB6',SAP2000v1.eCNameType.LoadCase,'DX',-1.0);
RespCombo.SetCaseList('COMB6',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB7',0);
RespCombo.SetCaseList('COMB7',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB7',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB7',SAP2000v1.eCNameType.LoadCase,'DY',1.0);
RespCombo.SetCaseList('COMB7',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB8',0);
RespCombo.SetCaseList('COMB8',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB8',SAP2000v1.eCNameType.LoadCase,'LIVE',0.5);
RespCombo.SetCaseList('COMB8',SAP2000v1.eCNameType.LoadCase,'DY',-1.0);
RespCombo.SetCaseList('COMB8',SAP2000v1.eCNameType.LoadCombo,'EV',1.0);
RespCombo.Add('COMB9',0);
RespCombo.SetCaseList('COMB9',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB9',SAP2000v1.eCNameType.LoadCombo,'EQ1',1.0);
RespCombo.SetCaseList('COMB9',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB10',0);
RespCombo.SetCaseList('COMB10',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB10',SAP2000v1.eCNameType.LoadCombo,'EQ1',-1.0);
RespCombo.SetCaseList('COMB10',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB11',0);
RespCombo.SetCaseList('COMB11',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB11',SAP2000v1.eCNameType.LoadCase,'DX',1.0);
RespCombo.SetCaseList('COMB11',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB12',0);
RespCombo.SetCaseList('COMB12',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB12',SAP2000v1.eCNameType.LoadCase,'DX',-1.0);
RespCombo.SetCaseList('COMB12',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB13',0);
RespCombo.SetCaseList('COMB13',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB13',SAP2000v1.eCNameType.LoadCase,'DY',1.0);
RespCombo.SetCaseList('COMB13',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB14',0);
RespCombo.SetCaseList('COMB14',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB14',SAP2000v1.eCNameType.LoadCase,'DY',-1.0);
RespCombo.SetCaseList('COMB14',SAP2000v1.eCNameType.LoadCombo,'EV',-1.0);
RespCombo.Add('COMB15',0);
RespCombo.SetCaseList('COMB15',SAP2000v1.eCNameType.LoadCase,'DEAD',1.2);
RespCombo.SetCaseList('COMB15',SAP2000v1.eCNameType.LoadCase,'WINDY',1.0);
RespCombo.SetCaseList('COMB15',SAP2000v1.eCNameType.LoadCombo,'LIVE',1.0);
RespCombo.Add('COMB16',0);
RespCombo.SetCaseList('COMB16',SAP2000v1.eCNameType.LoadCase,'DEAD',0.9);
RespCombo.SetCaseList('COMB16',SAP2000v1.eCNameType.LoadCase,'WINDY',1.0);

%% Run Analysis
Analyze.RunAnalysis();

%% Design Steel
DesignSteel.SetCode("AISC-LRFD93");

[~,d1,d2]=RespCombo.GetNameList(0,cellstr(' '));
for i=1:d1
    DesignSteel.SetComboStrength(sprintf('%s',char(d2(i))),false);
end

DesignSteel.SetComboStrength('COMB1',true);
DesignSteel.SetComboStrength('COMB2',true);
DesignSteel.SetComboStrength('COMB3',true);
DesignSteel.SetComboStrength('COMB4',true);
DesignSteel.SetComboStrength('COMB5',true);
DesignSteel.SetComboStrength('COMB6',true);
DesignSteel.SetComboStrength('COMB7',true);
DesignSteel.SetComboStrength('COMB8',true);
DesignSteel.SetComboStrength('COMB9',true);
DesignSteel.SetComboStrength('COMB10',true);
DesignSteel.SetComboStrength('COMB11',true);
DesignSteel.SetComboStrength('COMB12',true);
DesignSteel.SetComboStrength('COMB13',true);
DesignSteel.SetComboStrength('COMB14',true);
DesignSteel.SetComboStrength('COMB15',true);
DesignSteel.SetComboStrength('COMB16',true);
DesignSteel.SetComboAutoGenerate(false);
DesignSteel.StartDesign;

[d1,d2]=size(idxframe);
RecRatio=[];
for i=1:length(idxframe)
    NumberItems = 0;
    FrameName = cellstr(' ');
    Ratio = zeros(1,1,'double');
    RatioType = zeros(1,1,'double');
    Location = zeros(1,1,'double');
    ComboName = cellstr(' ');
    ErrorSummary = cellstr(' ');
    WarningSummary = cellstr(' ');
    [ret,NumberItems, FrameName, Ratio, RatioType, Location, ComboName, ErrorSummary, WarningSummary] = DesignSteel.GetSummaryResults(sprintf('%d',idxframe{i,2}), NumberItems, FrameName, Ratio, RatioType, Location, ComboName, ErrorSummary, WarningSummary);
    if Ratio(1)==0
        RecRatio(i,:)=3;
    else
        RecRatio(i,:)=Ratio(1);
    end
end

LN='DX';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
AnalysisResultsSetup.SetOptionDirectHist(2);
NumberResults = 0;
Obj = NET.createArray('System.String',2);
Elm = NET.createArray('System.String',2);
ACase = NET.createArray('System.String',2);
StepType = NET.createArray('System.String',2);
StepNum = NET.createArray('System.Double',2);
U1 = NET.createArray('System.Double',2);
U2 = NET.createArray('System.Double',2);
U3 = NET.createArray('System.Double',2);
R1 = NET.createArray('System.Double',2);
R2 = NET.createArray('System.Double',2);
R3 = NET.createArray('System.Double',2);
[~, NumberResults, Obj, Elm, ACase, StepType, StepNum, U1, U2, U3, R1, R2, R3] = AnalysisResults.JointDispl('2', SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, ACase, StepType, StepNum, U1, U2, U3, R1, R2, R3);
dummy1=abs(double(U1));
LN='DY';
AnalysisResultsSetup.DeselectAllCasesAndCombosForOutput;
AnalysisResultsSetup.SetCaseSelectedForOutput(LN);
AnalysisResultsSetup.SetOptionDirectHist(2);
NumberResults = 0;
Obj = NET.createArray('System.String',2);
Elm = NET.createArray('System.String',2);
ACase = NET.createArray('System.String',2);
StepType = NET.createArray('System.String',2);
StepNum = NET.createArray('System.Double',2);
U1 = NET.createArray('System.Double',2);
U2 = NET.createArray('System.Double',2);
U3 = NET.createArray('System.Double',2);
R1 = NET.createArray('System.Double',2);
R2 = NET.createArray('System.Double',2);
R3 = NET.createArray('System.Double',2);
[~, NumberResults, Obj, Elm, ACase, StepType, StepNum, U1, U2, U3, R1, R2, R3] = AnalysisResults.JointDispl('2', SAP2000v1.eItemTypeElm.ObjectElm, NumberResults, Obj, Elm, ACase, StepType, StepNum, U1, U2, U3, R1, R2, R3);
dummy2=abs(double(U2));
EQDrift=Cd*max([dummy1 dummy2])/lCOL;

SapObject.ApplicationExit(false);
disp(BARSCHEDULE)
d1=unique(BARSCHEDULE(:,1));d2=unique(BARSCHEDULE(:,2));
recpattern={};W=0;idxp=1;
for i=1:length(d1)
    for j=1:length(d2)
        d3=find(BARSCHEDULE(:,1)==d1(i));
        d4=find(BARSCHEDULE(:,2)==d2(j));
        d5=intersect(d3,d4);
        if isempty(d5)~=1
            input1=12000;
            input2=BARSCHEDULE(d5,4);
            input3=BARSCHEDULE(d5,3);
            pattern=CSP1D(input1,input2,input3);
            recpattern{idxp}=pattern;idxp=idxp+1;
            if BARSCHEDULE(d5(1),1)==1
                W=W+sum(pattern(:,end-1))*input1*Wlist(BARSCHEDULE(d5(1),2),6);
            elseif BARSCHEDULE(d5(1),1)==2
                W=W+sum(pattern(:,end-1))*input1*Clist(BARSCHEDULE(d5(1),2),6);
            else
                W=W+sum(pattern(:,end-1))*input1*Plist(BARSCHEDULE(d5(1),2),2);
            end
        end
    end
end
[d1,~]=size(BARSCHEDULE);
W=W+d1*50;
W=W./(3e8);

if max(RecRatio)>1 || EQDrift>0.02
    W=inf;
    RecRatio=inf;
end

end