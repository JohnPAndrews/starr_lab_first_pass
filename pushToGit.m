function pushToGit()
filenamepublish = 'plot_subject_stats_from_json.m';
repo = 'https://github.com/roeegilron/starr_lab_first_pass/';
htmlpreview = 'http://htmlpreview.github.io/?';
fullpath = [htmlpreview repo 'blob/master/html/' filenamepublish(1:end-2) '.html'];

options_doc_nocode.format = 'html';
options_doc_nocode.showCode = false;

publish('plot_subject_stats_from_json.m',options_doc_nocode);
cd('html'); 
system('git pull origin master');
system('git add *.html');
system('git add *.png');
system('git commit -m "publishing file"');
system('git push origin master'); 
cd('..')

end
