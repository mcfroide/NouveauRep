clear all;
%clearvars;
close all;
display('--- Algo 1: ALS ---');
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Missing pixels are marked with -1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('./ALS/');

N=16; % Size of the Macro-Block

% % ****** To work on a "new" movie ***********
% load BusMovie.mat
% 
% OriginalMovie=mov(N+1:floor(200/N)*N,1:floor(240/N)*N,1:40); % For speed
% 
% fraction=0.15;
% CorruptedMovie=CorruptRandomly(OriginalMovie,N/2,fraction);
% RecoveredMovie=CorruptedMovie;

load BusCorruptedMovie015.mat

RecoveredMovie=CorruptedMovie;

s=size(OriginalMovie);
Mrows=s(1);
Mcols=s(2);
Mframe=s(3);

K=Mframe+1;

R1=N; R2=N; R3=3;

sigma=1e-2; itMax=60; sigmaIterative=5e-6;
nbNeighbours=5; % Nb of nearest previously recovered and corrupted future frames used in the tensor building step
% Set to -1 to use all frames

nFrame_=1:30;
lengthNFrame_=length(nFrame_);

ErrorFro=zeros(lengthNFrame_, 1);
PSNR=zeros(lengthNFrame_, 1);

for iFrame=1:lengthNFrame_
    disp(['---- Frame ', num2str(iFrame),' out of ', num2str(lengthNFrame_),' ----']);
    nFrame=nFrame_(iFrame);
    Frame=double(RecoveredMovie(:, :, nFrame));
    [Coordinates]=SortAllP0Tensor(RecoveredMovie,N,Frame);
    nbIt=length(Coordinates);
    
    for n=1:nbIt
        if (mod(n,30)==1)
            display(['Iteration ',num2str(n),' out of ', num2str(nbIt)]);
        end
        i=Coordinates(n,1);
        j=Coordinates(n,2);
        
        P0=Frame(i:i+N-1, j:j+N-1);
        
        if min(min(P0))<0
            if max(max(P0))<0
                Coordinates=ReSortP0(Coordinates, n, Frame,N);
                i=Coordinates(n,1);
                j=Coordinates(n,1);
                P0=Frame(i:i+N-1, j:j+N-1);
            end
            
            [P0_new, err]=RecoverSubBlockTensor(RecoveredMovie,P0, K, R1, R2, R3, sigma, sigmaIterative, itMax,nFrame, nbNeighbours);
            RecoveredMovie(i:i+N-1, j:j+N-1,nFrame)=P0_new;
            Frame(i:i+N-1, j:j+N-1)=P0_new;
        end
    end
    OriginalFrame=double(OriginalMovie(:,:,iFrame));
    
    ErrorFro(iFrame)=FrobeniusRelativeError(OriginalFrame, Frame);
    PSNR(iFrame)=psnr(Frame, OriginalFrame);
    
    %S=svd(Frame);
    %SVErrorEstimate=SingularValueErrorEstimate(Frame, R3);
end



filename=['Algo1_Bus_N',num2str(N), '.mat'];
%save(filename, 'ErrorFro', 'PSNR', 'RecoveredMovie');


figure
%plot(nFrame_,PSNR, '-*r');
%hold on;
plot(nFrame_,ErrorFro, '--*b');
xlabel('Frame index');
ylabel('Relative error (Frobenius norm)');
%legend('PSNR (dB)','||A_{restored}-A||_F/||A||_F (%)');

