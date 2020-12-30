function [subjectNames, protocol, attention] = InputOptions()
prompt = {'Enter Subject Names/IDs (separate by commas) in order of folder:' ;...
    'Protocol (BBB/B)';'Attention (Overt/Covert)'}; % 
dlgtitle = 'Experiment Information';
dims = [5 60; 2 60; 2 60];
definput = {'Name', 'B', 'Covert'};
userInput = inputdlg(prompt,dlgtitle,dims,definput);
subjectNames = strsplit(userInput{1}, ',');
protocol = userInput{2};
attention = userInput{3};
attention = lower(attention);
end