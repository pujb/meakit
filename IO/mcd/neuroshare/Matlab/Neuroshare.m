examplepath = pwd
% remember the current path where Neuroshare.m is located

cd 'c:\Program Files\FIND\'
% or include FIND into the search path

[nsresult] = ns_SetLibrary('nsMCDlibrary.dll')
[nsresult,info] = ns_GetLibraryInfo()
[nsresult, hfile] = ns_OpenFile([examplepath '/../ExampleMCD/NeuroshareExample.mcd'])
[nsresult,info]=ns_GetFileInfo(hfile)

% Find out about the Entity types
% Then read specific entity info and data

% Trigger
[nsresult,entity] = ns_GetEntityInfo(hfile,1)
[nsresult,event] = ns_GetEventInfo(hfile,1)
[nsresult,timestamp,data,datasize] = ns_GetEventData(hfile,1,1)

% Digital data
[nsresult,entity] = ns_GetEntityInfo(hfile,6)
[nsresult,analog] = ns_GetAnalogInfo(hfile,6)
[nsresult,count,data]=ns_GetAnalogData(hfile,6,1,entity.ItemCount);
plot(data)

% Digital event
[nsresult,entity] = ns_GetEntityInfo(hfile,8)
[nsresult,event] = ns_GetEventInfo(hfile,8)
[nsresult,timestamp,data,datasize] = ns_GetEventData(hfile,8,1)

% spike data
[nsresult,entity] = ns_GetEntityInfo(hfile,4)
[nsresult,segment] = ns_GetSegmentInfo(hfile,4)
[nsresult, segmentsource] = ns_GetSegmentSourceInfo(hfile,4,1)
[nsresult,timestamp,data,samplecount,unitid] = ns_GetSegmentData(hfile,4,1)
plot(data)

% raw electrode data
[nsresult,entity] = ns_GetEntityInfo(hfile,25)
[nsresult,analog] = ns_GetAnalogInfo(hfile,25)
[nsresult,count,data]=ns_GetAnalogData(hfile,25,1,entity.ItemCount);
plot(data)

% filteres data entity
[nsresult,entity] = ns_GetEntityInfo(hfile,23)
[nsresult,analog] = ns_GetAnalogInfo(hfile,23)
[nsresult,count,data]=ns_GetAnalogData(hfile,23,1,entity.ItemCount);
plot(data)

% channel tool  data entity
[nsresult,entity] = ns_GetEntityInfo(hfile,2)
[nsresult,analog] = ns_GetAnalogInfo(hfile,2)
[nsresult,count,data]=ns_GetAnalogData(hfile,2,1,entity.ItemCount);
plot(data)
