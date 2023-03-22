function [results_gcause_mat, results_gcause_fdr] = calculate_granger_causality(X)

disp('Start computing granger causality...')

% Dimension of X (# Channels x # Samples x # Trials)
[CHN, SMP, TRL] = size(X);

glm_time_range = 60;

% To fit GLM models with different history orders
disp('fit GLM models')
window_size = 3;
parfor neuron = 1:CHN
    for ht = 3:3:glm_time_range                             % history, W=3ms
        %   n: index number of input (neuron) to analyze
        %  ht: model order (using AIC or BIC)
        %   w: duration of non-overlapping spike counting window
        [bhat{ht,neuron}] = glmtrial(X,neuron,ht,window_size);
%         disp(ht)
    end
%     disp(neuron)
end

% To select a model order, calculate AIC
disp('calculate AIC')
for neuron = 1:CHN
    for ht = 3:3:glm_time_range
        LLK(ht,neuron) = log_likelihood_trial(bhat{ht,neuron},X,ht,neuron,glm_time_range);
        aic(ht,neuron) = -2*LLK(ht,neuron) + 2*(CHN*ht/3 + 1);
    end
    
end

% Save results
% save(save_result_file,'bhat','aic','LLK', 'X');

% Identify Granger causality
% CausalTest;
% end

ht = nan(1, CHN);

% h = figure;
for varidx = 1:CHN
%     subplot(2, 3, varidx);
%     plot(aic(3:3:60,varidx));
    [value, index] = nanmin(aic(3:3:glm_time_range,varidx));
    ht(varidx) = index;
end

% Re-optimizing a model after excluding a trigger neuron's effect and then
% Estimating causality matrices based on the likelihood ratio
disp('Estimating causality matrices')
for target = 1:CHN
    LLK0(target) = LLK(3*ht(target),target);
    for trigger = 1:CHN
        % MLE after excluding trigger neuron
        [bhatc{target,trigger},devnewc{target,trigger}] = glmtrialcausal(X,target,trigger,3*ht(target),3);
        
        % Log likelihood obtained using a new GLM parameter and data, which
        % exclude trigger
        LLKC(target,trigger) = log_likelihood_trialcausal(bhatc{target,trigger},X,trigger,3*ht(target),target, glm_time_range);
               
        % Log likelihood ratio
        LLKR(target,trigger) = LLKC(target,trigger) - LLK0(target);
        
        % Sign (excitation and inhibition) of interaction from trigger to target
        % Averaged influence of the spiking history of trigger on target
        SGN(target,trigger) = sign(sum(bhat{3*ht(target),target}(ht(target)*(trigger-1)+2:ht(target)*trigger+1)));
    end
end

% Granger causality matrix, Phi
Phi = -SGN.*LLKR;
results_gcause_mat = Phi;

% ==== Significance Testing ====
% Causal connectivity matrix, Psi, w/o FDR
D = -2*LLKR;                                     % Deviance difference
alpha = 0.05;
for ichannel = 1:CHN
    temp1(ichannel,:) = D(ichannel,:) > chi2inv(1-alpha,ht(ichannel)/2);
end
Psi1 = SGN.*temp1;
results_gcause_sig = Psi1;

% Causal connectivity matrix, Psi, w/ FDR
fdrv = 0.05;
temp2 = FDR(D,fdrv,ht);
Psi2 = SGN.*temp2;
results_gcause_fdr = Psi2;