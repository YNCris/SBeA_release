% KS plot using estimated model parameters

function [z_sorted,b,bp,bn] = ksplot_trial(X,bhat,ht,neuron)

% Size of input data
[CHN SMP TRL] = size(X);

Z = [];
for itrial = 1:TRL

    temp = ones(SMP-ht,1);
    for ichannel = 1:CHN
        for hh = 0:3:ht-3
            temp0 = X(ichannel,ht-hh:SMP-1-hh,itrial)' + X(ichannel,ht-1-hh:SMP-2-hh,itrial)' + X(ichannel,ht-2-hh:SMP-3-hh,itrial)';
            temp = [temp temp0];
        end
    end
    LAMBDA = exp(temp*bhat);

    eventloc{itrial} = find(X(neuron,ht+1:end,itrial));
    
    if length(eventloc{itrial})-1 == 0
        Z = [Z];
    else    
        for ievent = 1:length(eventloc{itrial})-1
            tau(ievent) = sum(LAMBDA(eventloc{itrial}(ievent):eventloc{itrial}(ievent+1)));
            temp = 1 - exp(-tau(ievent));
            Z = [Z temp];
        end        
    end
        
end

z_sorted = sort(Z);
lengz = length(z_sorted);
for iepoch = 1:lengz
    b(iepoch) = (iepoch-.5)/lengz;
    bp(iepoch) = b(iepoch) + 1.36/sqrt(lengz);
    bn(iepoch) = b(iepoch) - 1.36/sqrt(lengz);
end

% figure;plot(b,z_sorted);ylim([0 1]);
% hold on
% plot(b,b);
% plot(b,bp,':');
% plot(b,bn,':');
% xlabel('Qunatiles');
% ylabel('Cumulative Distribution Function');



