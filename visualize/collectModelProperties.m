function [abbreviatedNames, timestepNames, timesteps] = ...
    collectModelProperties(modelResults)
modelPrefixes = {'rnn', 'caffe'};
typeAbbreviations = {'RNN', 'hop'};
uniqueNames = sort(unique(modelResults.name));
modelOccurrences = cell2mat(...
    cellfun(@(s) sum(cell2mat(strfind(lower(uniqueNames), s))), ...
    modelPrefixes, 'UniformOutput', false));
abbreviatedNames = typeAbbreviations(logical(modelOccurrences));
rows = numel(abbreviatedNames);
cols = max(modelOccurrences);
timestepNames = cell(rows, cols);
timesteps = NaN(rows, cols);
for modelType = 1:length(abbreviatedNames)
    typePrefix = modelPrefixes{modelType};
    typeTimestepNames = uniqueNames(~cellfun(@isempty, ...
        strfind(lower(uniqueNames), typePrefix)));
    typeTimesteps = cell2mat(cellfun(@(name) timestepFromName(name), ...
        typeTimestepNames, 'UniformOutput', false));
    [typeTimesteps, sortIndices] = sort(typeTimesteps, 'ascend');
    typeTimestepNames = typeTimestepNames(sortIndices);
    timestepNames(modelType, 1:length(typeTimestepNames)) = typeTimestepNames;
    timesteps(modelType, 1:length(typeTimesteps)) = typeTimesteps;
end
% shift RNN one to the right if -1 (unpolarized) in hop
if(rows == 2 && all(timesteps(2, 1:2) == [-1, 0]) && isnan(timesteps(1, end)))
    timesteps(1, :) = [NaN, timesteps(1, 1:end-1)];
    timestepNames(1, :) = [{[]}, timestepNames(1, 1:end-1)];
end
end

function timestep = timestepFromName(classifierName)
token = regexp(classifierName, '_t([0-9]+)', 'tokens');
if isempty(token)
    if strcmp(classifierName, 'caffenet_fc7')
        timestep = -1;
    else
        timestep = 0;
    end
else
    timestep = str2double(token{1}{1});
end
end
