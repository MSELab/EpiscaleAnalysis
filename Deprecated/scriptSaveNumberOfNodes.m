
labels = getLabels(settings, {}, 2);
for j = 1:length(labels)
    disp(['Loading data simulation ' num2str(j) ' of ' num2str(length(labels))]);
    load([settings.matDir labels{j} '.mat'], 'rawDetails');

    for i = length(rawDetails):-1:1
        memNodes{i} = str2double({rawDetails{i}.CurrentActiveMembrNodes});
        intNodes{i} = str2double({rawDetails{i}.CurrentActiveIntnlNode});
    end
    
    save([settings.matDir labels{j} '.mat'], 'memNodes', 'intNodes', '-append');
end