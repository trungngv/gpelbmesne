x = randn(100,1);
z = (-3:0.01:3)';
pz = parzenEstimator(z,x,log(0.5));
figure; hold on;
plot(z,normpdf(z),'r');
plot(z,pz,'b');
legend('true density', 'parzen density');
