clear all;

% Load  data
load data_real_catM1.mat;
% load data_real_nonmove.mat;
load result_real_catM1.mat;

% Selected spiking history orders by min AIC
ht = [1 11 1 5 18 17 1 1 15 17 1 11 1 9 5];

CHN = 15;

% To plot the AIC 
for neuron = 1:CHN
    figure(neuron);
    plot(aic(3:3:60,neuron));
end

pause
% ht = [1 1 1 1 1 1 1 1 1 1 1 7 1 2 1];       % Non-movement

% Dimension of X (# Channels x # Samples x # Trials)
[CHN SMP TRL] = size(X);

% Re-optimizing a model after excluding a trigger neuron's effect and then
% Estimating causality matrices based on the likelihood ratio
for target = 1:CHN
    LLK0(target) = LLK(3*ht(target),target);
    for trigger = 1:CHN
        % MLE after excluding trigger neuron
        [bhatc{target,trigger},devnewc{target,trigger}] = glmtrialcausal(X,target,trigger,3*ht(target),3);
        
        % Log likelihood obtained using a new GLM parameter and data, which
        % exclude trigger
        LLKC(target,trigger) = log_likelihood_trialcausal(bhatc{target,trigger},X,trigger,3*ht(target),target);
               
        % Log likelihood ratio
        LLKR(target,trigger) = LLKC(target,trigger) - LLK0(target);
        
        % Sign (excitation and inhibition) of interaction from trigger to target
        % Averaged influence of the spiking history of trigger on target
        SGN(target,trigger) = sign(sum(bhat{3*ht(target),target}(ht(target)*(trigger-1)+2:ht(target)*trigger+1)));
    end
end

% Granger causality matrix, Phi
Phi = -SGN.*LLKR;

% ==== Significance Testing ====
% Causal connectivity matrix, Psi, w/o FDR
D = -2*LLKR;                                     % Deviance difference
alpha = 0.05;
for ichannel = 1:CHN
    temp1(ichannel,:) = D(ichannel,:) > chi2inv(1-alpha,ht(ichannel)/2);
end
Psi1 = SGN.*temp1;

% Causal connectivity matrix, Psi, w/ FDR
fdrv = 0.05;
temp2 = FDR(D,fdrv,ht);
Psi2 = SGN.*temp2;

% Plot the results
figure(1);imagesc(Phi);xlabel('Triggers');ylabel('Targets');
figure(2);imagesc(Psi1);xlabel('Triggers');ylabel('Targets');
figure(3);imagesc(Psi2);xlabel('Triggers');ylabel('Targets');

% Save results
% save('CausalMaps','bhatc','LLK0','LLKC','LLKR','D','SGN','Phi','Psi1','Psi2');
