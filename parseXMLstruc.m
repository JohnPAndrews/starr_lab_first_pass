function xmlstruc = parseXMLstruc(xmlstruc)
sf = subfieldnames(xmlstruc); 
for s = 1:length(sf)
    if strcmp(sf{s}(end-4:end),'.Text')
        evalc(['xmlstruc.' sf{s}(1:end-5) '=' 'xmlstruc.' sf{s}]);
    end
end
end

function sf = subfieldnames(ThisStruct)
   sf = fieldnames(ThisStruct);
   for fnum = 1:length(sf)
     if isstruct(ThisStruct.(sf{fnum}))
       cn = subfieldnames(ThisStruct.(sf{fnum}));
       sf(end+1:end+length(cn)) = cellstr( horzcat(repmat([sf{fnum} '.'], length(cn), 1),char(cn)));
     end
   end
end