function figure6()

results = load('data/results/classification/all-libsvmccv.mat');
results = results.results;
rnnResults = convertRnnResults();
rnnResults = mergeRnnResults(...
    filterResults(results, @(r) strcmp(r.name, 'caffenet_fc7')), ...
    rnnResults);
% timeResults = load('data/results/classification/hoptimes_fullhopsize.mat');
timeResults = load('data/results/classification/hoptimes-1_5_25.mat');
timeResults = timeResults.results;
timeResults = mergeResults(...
    filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0'})), ... % include -1 (no bipolar)
    ...%{'caffenet_fc7'})), ...
    filterResults(timeResults, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, 'caffenet_fc7-bipolar0-hop_t(1|6|11|16|21)-libsvmccv'))));

figure('units', 'normalized', 'outerposition', [0 0 1 1]); % full-screen
subplot(1, 3, 1);
fc7RnnHop = filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0-hop', 'rnn'}));
displayResults(fc7RnnHop);

subplot(1, 3, 2);
plotOverallPerformanceOverTime(mergeRnnResults(timeResults, rnnResults));

subplot(1, 3, 3);
corrResults = mergeRnnResults(...
    filterResults(timeResults, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^caffenet_fc7(-bipolar0-hop_t(1|6|21)-libsvmccv)?$'))), ...
    filterResults(rnnResults, @(r) ismember(r.name, ...
    {'RNN_t0', 'RNN_t2', 'RNN_t4'})));
corrData = collectModelHumanCorrelationData(corrResults);
plotModelHumanCorrelationOverTime(corrData);
end

