clear all;

% Load  data
load data_real_catM1.mat;
load result_real_catM1.mat;

% Dimension of X (# Channels x # Samples x # Trials)
[CHN SMP TRL] = size(X);

% Selected spiking history orders by AIC
ht = 3*[1 11 1 5 18 17 1 1 15 17 1 11 1 9 5];
% ht = [1 1 1 1 1 1 1 1 1 1 1 7 1 2 1];       % Non-movement

for neuron = 1:CHN:

    NEURON = num2str(neuron);
    HHT = num2str(ht(neuron));

    [z_sorted,b,bp,bn] = ksplot_trial(X,bhat{ht(neuron),neuron},ht(neuron),neuron);
    % load(['KSplotting_neuron' NEURON '_ht' HHT]);

    figure(neuron);plot(b,z_sorted);ylim([0 1]);
    hold on
    plot(b,b,'r');
    plot(b,bp,':');
    plot(b,bn,':');
    xlabel('Qunatiles');
    ylabel('Cumulative Distribution Function');
    title(['Neuron-' NEURON ' order-' HHT]);

    % save(['KSplotting_neuron' NEURON '_ht' HHT],'z_sorted','b','bn','bp');

end

