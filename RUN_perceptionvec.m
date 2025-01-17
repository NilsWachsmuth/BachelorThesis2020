close all, clear

%%% Obtain the resonant data: can be generated by calling 
%%% [res,V]=resonances()
%%% load('res22');  
%%% N = length(res);

res = zeros(22,1);
V = eye(22);
lambda = 1.2;
res(1) = 630 - 150i;

for j = 1:21
    res(j+1) = (630*lambda^(j) - 150i*(lambda^(j)));
end



%%% Obtain the filtered: can be generated by calling, for example
[a,Fs] = audiofilter('Bb Trumpet/trumpet-C5.wav',res,V);
%%% load('trumpet')
L = size(a,2) + 1;
T = 1/Fs;

%% Hilbert transform

a_H = hilbert(a');
a_H = transpose(a_H);

%% Normalisation (to ensure invariance)

lA = log10(abs(a_H));
lA = lA - repmat(mean(lA,2),1,L-1);         % zero mean
A = diag(mean(lA.^2,2).^(-1))*lA;           % unit variance

arg = angle(a_H);
lambda = diff(arg,1,2)/T;
lam = abs(lambda);
lam = lam - repmat(mean(lam,2),1,L-2);      % zero mean
lam = diag(mean(lam.^2,2).^(-1))*lam;       % unit variance

%% Temporal averages of A and lamba
k = Fs/100;     % interval length

avA = zeros(N,L-k-2);
avL = zeros(N,L-k-2);
for i = 1:L-k-2
    avA(:,i) = mean(A(:,i:i+k),2);
    avL(:,i) = mean(lam(:,i:i+k),2);
end
%%
parvec = zeros(6,1);        % vector to store the natural sound parameters
%% Fit PDF to data using least squares
%% p_A

[grid,data,fit,vals] = pdffit_exp(avA(:),1,2);
figure
plot(grid,data)
hold on
plot(grid,fit,'LineWidth',2)
legend('$\langle\log A\rangle$','$p_{A}$','interpreter','latex')
parvec(2:3) = vals(1:2);
set(gca,'TickLabelInterpreter','latex')

%% p_lambda

scale = 1e6;                 % rescale the data for numerical convenience
[grid,data,fit,vals] = pdffit_modcau(scale*avL(:),1,5,1e3);
figure
plot(grid/scale,data*scale)
hold on
plot(grid/scale,fit*scale,'LineWidth',2)
legend('$\langle|\lambda|\rangle$','$p_{\lambda}$','interpreter','latex')
parvec(5:6) = [vals(1)/scale, vals(2)];
set(gca,'TickLabelInterpreter','latex')


%% Fit 1/f power law behaviour
%% A power law
figure
[f,S,p] = powerlaw(A,Fs,2e2);
plot(f,S,'.-');
set(gca,'xscale','log')
set(gca,'yscale','log')
y = polyval(p,log10(f));
hold on
plot(f,10.^y,'LineWidth',2);
parvec(1) = -p(1);
xlabel('$\omega$','interpreter','latex')
ylabel('$S(\omega)$','interpreter','latex')
legend('$\overline{S_{A}}$','$S_{A}$','interpreter','latex');
set(gca,'TickLabelInterpreter','latex')


%% phi power law
figure
[f,S,p] = powerlaw(lam,Fs,1e2);
plot(f,S,'.-');
set(gca,'xscale','log')
set(gca,'yscale','log')
y = polyval(p,log10(f(1,:)));
hold on
plot(f(1,:),10.^y,'LineWidth',2);
parvec(4) = -p(1);
xlabel('$\omega$','interpreter','latex')
ylabel('$S(\omega)$','interpreter','latex')
legend('$\overline{S_{\phi}}$','$S_{\phi}$','interpreter','latex');
parvec(5) = parvec(5)*10^6;
parvec

v = 0;
t = 0;
f = 0;
avv = [1.61571, 1.04611, 1.66239, 1.57971, 1.69538, 11.20476];
avt =[1.7739, 1.40628, 3.16817, 1.45322, 0.96209, 1.68705];
avf = [1.948971429, 1.799828571, 2.495078571, 1.601407143, 4.8193, 6.159192857];
totv = 0;
tott = 0;
totf = 0;


for i = 1:6
    dv = abs(avv(i) - parvec(i));
    dt = abs(avt(i) - parvec(i));
    df = abs(avf(i)- parvec(i));
    
    totv = totv + dv;
    tott = tott + dt;
    totf = totf + df;
    
    if (dv < dt && dv < df)
        v = v+1;
    end
    if (dt < dv && dt < df)
        t = t+1;
    end
        if (df < dv && df < dt)
        f = f+1;
    end
end
if (t > v && t > f) 
    disp('It is a trumpet,majority.')
end
if (v > t && v > f) 
    disp('It is a violin, majority.')

end

if (f > t && f > v) 
    disp('It is a flute, majority.')

end   

if (tott < totv && tott < totf) 
    disp('It is a trumpet, actual distance.')
end
if (totv < tott && totv < totf) 
    disp('It is a violin, actual distance.')

end

if (totf < tott && totf < totv) 
    disp('It is a flute, actual distance.')

end   


