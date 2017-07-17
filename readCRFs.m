function readCRFs()
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/CRF/CRF'; 
fdirs = findFilesBVQX(rootdir,'Sub*',struct('dirs',1,'depth',1));
for d = 1:length(fdirs)
    ff = findFilesBVQX(fdirs{d},'*.txt'); 
    for f = 1:length(ff) 
        crfstruc = readCRFfile(ff{f});
        [pn,fn,ext] = fileparts(ff{f}); 
        jsonfn = fullfile(pn,[fn, '.json']); 
        matfn  = fullfile(pn,[fn, '.mat']); 
        savejson('',crfstruc,jsonfn);
        save(matfn,'crfstruc'); 
    end
end
%% XX fix UDPRS test headings not reading in well 
end

function outdat = readCRFfile(fn)
% fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/CRF/CRF/Subject 4/patient-brpd_04_visit-v09_06_mnt_pdf01.txt'; 
data = textread(fn,'%s','delimiter','\n','whitespace','');
outdat.filename = fn; 
outdat.visit_num = cellfun(@str2num,regexp(data{2},'[0-9]+','match'));
outdat.num_tests = cellfun(@str2num,regexp(data{2},'[0-9]+','match'));
datestrraw = strsplit(data{4},'\t');
outdat.date      = datetime(datestrraw{2},'Format','MM/dd/yy'); 
if any(regexp(data{5},'l')); side = 'l'; else side = 'r'; end 
outdat.side      = side;
outdat.skiplegratins = regexp(data{6},'w\','match'); 
outdat.nexus = regexp(data{6},'w\','match'); ; 
% loop on test lines 
curidx = 8; 
tstcnt = 1; 
while curidx < size(data,1)
    lineraw = strsplit(data{curidx},'\t');
    if cellfun(@any,strfind(lineraw(2),'testname'))
        startidx(tstcnt) = curidx; 
        tstcnt = tstcnt  + 1; 
    end
    curidx = curidx + 1; 
end
% extract test chunks and read test 
for i = 1:length(startidx)
    if i == length(startidx)
    else
        rawTest = data(startidx(i):startidx(i+1)-1,:); 
        [test, testname] = readTest(rawTest); 
        if ~isempty(test)
            outdat.(testname) = test;
            if isfield(outdat,testname)
                idx = length(outdat.(testname) );
                outdat.([testname num2str(idx)]) = test;
            else
                outdat.(testname) = test;
            end
        end
    end
end

end

function [test, testname] = readTest(rawTest)
tmptstname = strsplit(rawTest{1,:},'\t');
testname = tmptstname{3}; 
r =2; 
while r < size(rawTest,1)
    tmptstname = strsplit(rawTest{r,:},'\t');
    if sum(cellfun(@(x) strcmp(x,'') ,tmptstname) == 1) == length(tmptstname) % empty row
        r = r + 1;
    else % not an empty row 
        if cellfun(@any,strfind(tmptstname(2),'headings'))
            headings = tmptstname(3:end-1);
            scoresraw = strsplit(rawTest{r+1,:},'\t');
            % check if all scores are numbers / mixed number string 
            %scores = cellfun(@str2num,scoresraw(3:end-1));
            scores = scoresraw(3:end-1); 
            scoretype = cellfun(@(x) any(regexp(x,'[0-9]+')),scores); 
            if isempty(scores)
            else
            for h = 1:length(headings)
                if h > length(scores) % score missing
                    test.(matlab.lang.makeValidName(headings{h})) = [];
                else % score is not missing for heading 
                    if scoretype(h)
                        test.(matlab.lang.makeValidName(headings{h})) = str2num(scores{h});
                    else
                        test.(matlab.lang.makeValidName(headings{h})) = scores{h};
                    end
                end
            end
            end
            r = r +2;
        elseif strcmp(tmptstname(2),'impedences_greater_than_500ohms')
            test.(tmptstname{2}) = tmptstname(3:end-1);
            r = r + 1; 
        else
            tesname = matlab.lang.makeValidName(tmptstname{2});
            test.(tesname) = tmptstname{3};
            r = r + 1;
        end
    end
end
if ~exist('test','var')
    test = []; 
    testname = []; 
end
x = 2; 
end