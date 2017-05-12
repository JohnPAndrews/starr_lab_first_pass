function import_crf_data_save_as_json()
filenameuse = 'patient-brpd_05_visit-v11_01_yer_pdf01';
filenameload = [filenameuse '.csv'];
cellText = csv2cell('patient-brpd_05_visit-v11_01_yer_pdf01.csv','fromfile');
% find idx of tests
firstcol = cellText(:,1);
testnums = cell2mat(cellText(8:end,1));
for t = 1:length(testnums)
    idxtst(t) = find(strcmp(firstcol, testnums(t))==1);
end

% loop on each test and get the crf data
for t = 1:length(idxtst)
    for L1 = 0:10
        fieldname = genvarname(cellText{idxtst(t)+L1,2});
        switch fieldname
            case 'headings'
                strcmp(fieldname, 'headings')
                foundlabels = cellText(idxtst(t)+L1,3:end);
                for L2 = 0:length(foundlabels)-1
                    headname = genvarname(cellText{idxtst(t)+L1,3+L2});
                    foundnum = str2num( cellText{idxtst(t)+L1 + 1,3+L2} );
                    if ~isempty(foundnum)
                        crfdata(t).headings.(headname) = foundnum;
                    end
                end
            case 'score'
            otherwise
                crfdata(t).(fieldname) = cellText{idxtst(t)+L1,3};
        end
    end
end
jsonfn = [filenameuse '.json'];
savejson('',crfdata, jsonfn);
end