function A=InitializeA(N,K, R1, R2, R3)
% Random initialization of the basis matrices A
A{1}=rand(N,R1);
A{2}=rand(N,R2);
A{3}=rand(K,R3);
return