function [P0_new,err]=RecoverSubBlockTensor(Movie,P0, K, R1, R2, R3, sigma, sigmaIterative, itMax, iFrame, nbNeighbours)

[P,~]=SelectMBsTensor(Movie,K,P0, iFrame, nbNeighbours);

% figure
% subplot(2,3,1)
% imshow(P0)
% subplot(2,3,2)
% imshow(P{1})
% subplot(2,3,3)
% imshow(P{2})
% subplot(2,3,4)
% imshow(P{3})
% subplot(2,3,5)
% imshow(P{4})
% subplot(2,3,6)
% imshow(P{end})
% 
% for i=1:length(P)
%     err(i)=ComputeDistanceBetweenPatches(P0, P{i})
% end
% pause

% P=cell(K-1,1);
% for k=2:K-1
%     P{k}=double(Movie(ii:ii+16-1, jj:jj+15, k));
% end
%display('MBs selected')
X=CreateTensorX(P0,P);
normX=norm(X);
%M=matricize(X(:,:,2:end),3);
%v=svd(M)

%pause 
Keff=size(X,3);

%display('X created')
N=size(P0,1);
A=InitializeA(N,Keff, R1, R2, R3);

[Xl, A_new]=ComputeXl(A,X);

i=0;
err(1)=norm(Xl-X)/normX;
diffErr=1000;
while err(end)>sigma && i<itMax && (diffErr>sigmaIterative || i<3)
   [Xl,A_new]=ComputeXl(A_new,X); 
   i=i+1;
   err(end+1)=norm(Xl-X)/normX;
   diffErr=err(end-1)-err(end);
   X(:,:,1)=P0.*(P0>=0)+double(Xl(:,:,1)).*(P0<0);
end

% if i>=itMax
%    disp(['Tolerance ', num2str(sigma), ' not reached in ', num2str(itMax),' iterations.']); 
% end
%P0_new=P0.*(P0>=0)+double(Xl(:,:,1)).*(P0<0);
P0_new=X(:,:,1);
% if max(max(P0_new(:,:)))>256
%    figure
%    plot(err)
% end
return