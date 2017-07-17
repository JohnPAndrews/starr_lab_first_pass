function out = parseXMLstruc2(xmlstruc)
if length(xmlstruc) > 1 & ~isempty(xmlstruc) % if structure bigger than 1 recurse 
    for s = 1:length(xmlstruc)
        if isstruct(xmlstruc(s).Children)
            out.(xmlstruc(s).Name) = parseXMLstruc2(xmlstruc(s).Children);
        elseif length(xmlstruc(s).Data) ==3 & strcmp(xmlstruc(s).Data(2),' ')
            continue  
        end
    end
else
    if isstruct(xmlstruc.Children)
        out.(xmlstruc.Name) = parseXMLstruc2(xmlstruc.Children);
    else
        out = xmlstruc.Data; 
    end
end
end
