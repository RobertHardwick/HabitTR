function pOpt = fit_speed_accuracy_AE(RT,hit)
% generates parametric fit to speed-accuracy trade-off data
% Input: RT - reaction time data
%        hit - outcome; 1=succes, 0=failure
% Output: params = [mu sigma upper_asympt lower_asympt]

sigma = .1; % slope
mu = .4; % middle of slope
AE = [.9 .25]; % asymptotic error [upper, lower];

pInit = [mu sigma -log(1./AE - 1)];

% Regularization:
% include penalty equal to alpha*(sigma-slope0)^2
alpha = 1000; % regularization parameter
slope0 = .06; % slope prior

% log-likelihood of all data
sigg = @(xx) (1/(1+exp(-xx)));
LL = @(params) -sum(hit.*log(sigg(params(4))+normcdf(RT,params(1),params(2))*((sigg(params(3))-sigg(params(4))))) + (1-hit).*log(1-(sigg(params(4))+normcdf(RT,params(1),params(2))*(sigg(params(3))-sigg(params(4)))))) + alpha*(params(2)-slope0)^2;
LL([mu sigma AE]);

pOpt = [mu sigma AE];
pOpt = fminsearch(LL,pInit); % try to find the optimum
LL(pOpt);
%pOpt(3) = AE;
% transform constrained variables (lower and upper asymptote)
pOpt(3) = sigg(pOpt(3));
pOpt(4) = sigg(pOpt(4));
%% sliding window to visualize data
%{
xplot=[0:0.001:1];
w = 0.1;
for i=1:length(xplot)
    igood = find(RT>xplot(i)-w/2 & RT<=xplot(i)+w/2);
    phit_sliding(i) = mean(hit(igood));
end
% plot fit
%
subplot(2,1,2); hold on
ycdf = normcdf(xplot,pOpt(1),pOpt(2));
plot(xplot,pOpt(4) + ycdf*(pOpt(3)-pOpt(4)),'b','linewidth',2);
plot(xplot,phit_sliding)
%}
