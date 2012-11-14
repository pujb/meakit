function mycell=tline2cell(tline)
% breaks up a single char array at the blanks (for blank separated input)
blanks=find(isspace(tline));
mycell={};
blanks=[0 blanks];
blanks(find(diff(blanks)==1))=[];
for ii=1:length(blanks)-1
    mycell{ii}=tline(blanks(ii)+1:blanks(ii+1)-1);
end