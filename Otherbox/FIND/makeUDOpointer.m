function myudo=makeUDOpointer(entityIDs, filename, dllname, gridlayout)
% 
% %% check if all entities are of the same type
% entityinfo=FIND_loader('fileName',filename,'DLLpath',dllname,'entityInfo',entityIDs,'tovar',1);
% 
% if length(unique([entityinfo.EntityType]))>1
%     errordlg('UDO may only contain entities of one type','more than one entitytype selected')
% end
% 
% switch(entityinfo(1).EntityType)
%     
%     %%event
%     case 1
%         
%         %%analog
%     case 2
%         
%         %%segment
%     case 3
%         myudo=udo_pointer;
%         myudo.entityID=entityIDs;
%         myudo.paths.dll=dllname; 
%         myudo.paths.file=filename;
%         
%         %%neural
%     case 4
% end

%%
%% create object and assign properties
myudo=udo_pointer(filename,dllname,entityIDs,gridlayout);