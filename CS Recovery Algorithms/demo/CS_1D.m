%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(����ƥ��׷�ٷ�Orthogonal Matching Pursuit)   
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��
%---------------------------------------------------------------------------------%
clc
clear all
close all
%% 1. ����ԭʼ�ź�
fs=400;     %����Ƶ��
f1=25;         %��һ���ź�Ƶ��
f2=50;      %�ڶ����ź�Ƶ��
f3=100;     %�������ź�Ƶ��
f4=200;    %���ĸ��ź�Ƶ��
N=1024;    %�źų���
t=0:1/fs:(N-1)/fs;   
% x=0.3*cos(2*pi*f1*t)+0.6*cos(2*pi*f2*t)+0.1*cos(2*pi*f3*t)+0.9*cos(2*pi*f4*t);  %�����ź�
x=cos(2*pi*f1*t)+cos(2*pi*f2*t)+cos(2*pi*f3*t)+cos(2*pi*f4*t);  %�����ź�

%% 1.1�鿴ʱ��͸���Ҷ��
% fx=abs(fftshift(fft(x)))*2/N;
% fsf=(fs/N)*((1:N)-N/2-1);
% figure
% plot(fsf,fx)
%% �������������ֱ�ӽ���С��ֵ����Ϊ0
% fft_x=fft(x);
% fft_x(find(abs(fft_x)*2/N<0.1))=0;
% figure
% plot(fsf,fx,fsf,fftshift(fft_x*2/N),'--')
% xx=real(ifft(fft_x));
% figure
% plot(t,x,t,xx,'--')
% x=xx;
%% 2. ʱ���ź�ѹ�����У���ȡ����ֵ
K=8;   %�ź�ϡ��ȣ�����Ҷ���п�����
M=ceil(K*log(N/K));  %������,��������ѹ���̶ȣ����鹫ʽ
Phi=randn(M,N);  %  ��������(��˹�ֲ�������)
Phi=orth(Phi')';    %������
y=Phi*x';     %  ������Բ��� 

%% 3. L_1�������Ż��ع��źţ��в���ֵy�ع�x��
Psi=fft(eye(N,N))/sqrt(N);    %  ����Ҷ���任����,��Ϊ�ź�x�ڸ���Ҷ�ֵ���ϡ�裺theta=Psi*x.  ��x=Psi'*theta.
% ��С������ minimize:       ||theta||_0;
%                  subject to:     y=Phi*Psi'*theta;     ==   �� A=Phi*Psi'.   
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.

%%  4. ����ƥ��׷���ع��ź�
m=2*K;                  %  �㷨��������(m>=K)
fft_y=zeros(1,N);   %  ���ع�������(�任��)����    
Base_t=[];              %  ��¼�������ľ���
r_n=y;                  %  �в�ֵ
figure
for times=1:m;                                    %  ��������(�������������,�õ�������ΪK)
    for col=1:N;                                  %  �ָ����������������
        product(col)=abs(A(:,col)'*r_n);          %  �ָ�������������Ͳв��ͶӰϵ��(�ڻ�ֵ) 
    end
    [val,pos]=max(product);                       %  ���ͶӰϵ����Ӧ��λ�ã�valֵ��posλ��
    Base_t=[Base_t,A(:,pos)];                       %  �������䣬��¼���ͶӰ�Ļ�����
    A(:,pos)=zeros(M,1);                          %  ѡ�е������㣨ʵ����Ӧ��ȥ����Ϊ�˼��Ұ������㣩
    aug_y=(Base_t'*Base_t)^(-1)*Base_t'*y;   %  ��С����,ʹ�в���С
    r_n=y-Base_t*aug_y;                            %  �в�
    erro_rn(times)=norm(r_n,2);
    plot(erro_rn,'r-*')                                        %�������
    pos_array(times)=pos;                         %  ��¼���ͶӰϵ����λ��
    if erro_rn(times)<1e-6 %
            break; %����forѭ��
    end
end
legend('OMP����ƥ��׷�����')
fft_y(pos_array)=aug_y;                           %  �ع�����������
r_x=real(Psi'*fft_y');                         %  ���渵��Ҷ�任�ع��õ�ʱ���ź�

%% 5. �ָ��źź�ԭʼ�źŶԱ�

figure;
hold on;
plot(t,r_x,'k.-')                                 %  �ؽ��ź�
plot(t,x,'r')                                       %  ԭʼ�ź�
xlim([0,t(end)])
legend('OMP�ָ��ź�','ԭʼ�ź�')
norm(r_x.'-x)/norm(x)                      %  �ع����

%% 6. CoSaMP ����ѹ������ƥ��ķ�����l1��С������
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.
%function xh=CS_CoSaMP( y,A,K );
    [m,n] = size(y);
    if m<n
        y = y'; %y should be a column vector
    end
    [M,N] = size(A); %���о���AΪM*N����
    theta = zeros(N,1); %�����洢�ָ���theta(������)
    pos_num = []; %�������������д洢A��ѡ��������
    res = y; %��ʼ���в�(residual)Ϊy
    figure
    for kk=1:K %������K��
        %(1) Identification
        product = A'*res; %���о���A������в���ڻ�
        [val,pos]=sort(abs(product),'descend');
        Js = pos(1:2*K); %ѡ���ڻ�ֵ����2K��
        %(2) Support Merger
        Is = union(pos_num,Js); %Pos_theta��Js����
        %(3) Estimation
        %At������Ҫ������������Ϊ��С���˵Ļ���(�������޹�)
        if length(Is)<=M
            At = A(:,Is); %��A���⼸����ɾ���At
        else %At�����������������б�Ϊ������ص�,At'*At��������
            if kk == 1
                theta_ls = 0;
            end
            break; %����forѭ��
        end
        %y=At*theta��������theta����С���˽�(Least Square)
        theta_ls = (At'*At)^(-1)*At'*y; %��С���˽�
        %(4) Pruning
        [val,pos]=sort(abs(theta_ls),'descend');
        %(5) Sample Update
        pos_num = Is(pos(1:K));
        theta_ls = theta_ls(pos(1:K));
        %At(:,pos(1:K))*theta_ls��y��At(:,pos(1:K))�пռ��ϵ�����ͶӰ
        res = y - At(:,pos(1:K))*theta_ls; %���²в� 
        erro_res(kk)=norm(res,2);
        plot(erro_res,'r-*')                                        %�������
        if norm(res)<1e-6 %Repeat the steps until r=0
            break; %����forѭ��
        end
    end
    theta(pos_num)=theta_ls; %�ָ�����theta
%  end
legend('CoSaMPѹ������׷�����')
%% �ع����Ա�
cor_x=real(Psi'*theta);                         %  ���渵��Ҷ�任�ع��õ�ʱ���ź�
figure;
hold on;
plot(t,cor_x,'k.-')                                 %  �ؽ��ź�
plot(t,x,'r')                                       %  ԭʼ�ź�
xlim([0,t(end)])
legend('CoSaMP�ָ��ź�','ԭʼ�ź�')
norm(r_x.'-x)/norm(x)                      %  �ع����



%%
%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(l1-MAGIC��l1_ls��l1����)   
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��
%---------------------------------------------------------------------------------%
%% 1. �����ź�
fs=100;     %����Ƶ��
N=100;    %�źų���
t=0:1/fs:(N-1)/fs; 
x2=cos(2*pi*50*t);  %�����ź�
%% 2. ��ɢ���ұ任��������Сֵ����Ϊ0��ȷ��ϡ��ȣ����ع����ź�
% C=gen_dct(N);
C=dctmtx(N);     %��ɢ���ұ任����
cx=C*x2';
cx(find(abs(cx)<0.5))=0;   %����С�������㣬��ȻӰ��ԭʼ�źţ���ȷ����ϡ���
% figure
% plot([x2',C'*cx])
x2=C'*cx;    %�ع����źţ����źŵ���ɢ���ұض�ϡ��
x2=x2';
%% 3. �����ź�   
% ��44�����źŵ����ݻָ�100��������ݣ������ο�˹��Nyquist��������1s�����100������ָܻ�ԭʼ�źţ�
% ����CS����ֻ��Ҫ44��������ݾ��ָܻ�������ȫͻ����Nyquist������������ơ�

K=length(find(abs(cx)>0.5));   %�ź�ϡ���,�鿴��ɢ���ұ任��ͼ
M=2*ceil(K*log(N/K)); %K=9�ǣ���ֵΪ22��������,��������ѹ���̶ȣ����鹫ʽ
randn('state',4)
Phi=randn(M,N);  %  ��������(��˹�ֲ�������)
Phi=orth(Phi')';    %������
y=Phi*x2.';     %  ������Բ��� ---ֻ��44���㣬

%% 4. l1������С�� l1-Magic������ 
A=Phi*C';  
% x0=A'*y;   %��С������Ϊl1��С���ĳ�ʼֵ����
% ��l1-MAGIC��MATLAB�������l1��С������
% xh1=l1eq_pd(x0,A,[],y,1e-3);
xh1=l1eq_pd(zeros(N,1),A,[],y,1e-3);  %���Բ�����ʼ�Ĺ���
%%  l1������С��  l1_ls������
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh2,status]=l1_ls(A,y,lambda,rel_tol,quiet);
% At=A';
% [xh2,status]=l1_ls(A,At,M,N,y,lambda,rel_tol,quiet);
%% 5.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,C'*xh1,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('l1-MAGIC�ָ��ź�','ԭʼ�ź�')

figure
plot(t,C'*xh2,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('l1-ls�ָ��ź�','ԭʼ�ź�')


%%
%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(l1-MAGIC��l1_ls��l1����)   
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��27��
%---------------------------------------------------------------------------------%
clc;clear all;
%% 1. ����ϡ����ź�
N=1024;
K=50;
x=zeros(N,1);
rand('state',8)
q=randperm(N); %�������1��N������
randn('state',10)
x(q(1:K))=randn(K,1); %��K�����������ŵ�x��
t=0:N-1;
%% 2. �����֪����
M=2*ceil(K*log(N/K));
Phi=randn(M,N);  %��˹������Ϊ��֪����
Phi=orth(Phi')';  %������
% Phi=(sqrt(N))*eye(M)*Phi;
Psi=(sqrt(N))*eye(N,N);  %����Psi���죬ʹ���ź�xϡ�裬����x�������ϡ��ģ�����������ǵ�λ��������

%% 3. �����ź�
y=Phi*x;
%% 4. �ع��ź� l1��С��   Using  l1-MAGIC
% A=Phi;   %�ָ�����,ϡ�軯����Ϊ��λ������Ϊ�źű������ϡ��ģ�����Ҫ���κ�ϡ��任
A=Phi*Psi';
x0=A'*y;  %��С���˽����һ����ʼֵ
xh1=l1eq_pd(x0,A,[],y,1e-3);

%% 5. �ع��ź�l1��С��   Using l1_ls
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh2,status]=l1_ls(A,y,lambda,rel_tol,quiet);

%% 6.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,Psi*xh1,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-MAGIC�ָ��ź�','ԭʼ�ź�')

figure
plot(t,Psi*xh2,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-ls�ָ��ź�','ԭʼ�ź�')


%%
%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(l1-MAGIC��l1_ls��l1����)     �źű������ϡ��ģ�
%  ����Ҫϡ����󣬻ָ�����A�ǵ�λ����������OMP�������l1����.
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��27��
%---------------------------------------------------------------------------------%
clc;clear all;%close all
%% 1. ����ϡ����ź�
N=1024;
K=50;
x=zeros(N,1);
rand('state',8)
q=randperm(N); %�������1��N������
randn('state',10)
x(q(1:K))=randn(K,1); %��K�����������ŵ�x��
t=0:N-1;
%% 2. �����֪����
M=2*ceil(K*log(N/K));
Phi=randn(M,N);  %��˹������Ϊ��֪����
Phi=orth(Phi')';  %������

%% 3. �����ź�
y=Phi*x;
A=Phi;%�ָ�����,ϡ�軯����Ϊ��λ������Ϊ�źű������ϡ��ģ�����Ҫ���κ�ϡ��任
%% 4. �ع��ź� l1��С��   Using  l1-MAGIC
x0=A'*y;  %��С���˽����һ����ʼֵ
xh1=l1eq_pd(x0,A,[],y,1e-3);

%% 5. �ع��ź�l1��С��   Using l1_ls
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh2,status]=l1_ls(A,y,lambda,rel_tol,quiet);

%% 6. �ָ��źź�ԭʼ�źűȽ�
figure
plot(t,xh1,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-MAGIC�ָ��ź�','ԭʼ�ź�')

figure
plot(t,xh2,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-ls�ָ��ź�','ԭʼ�ź�')

%% 7. ������ƥ��׷�ٵķ�������l1���Ż�����
m=2*K;                  %  �㷨��������(m>=K)
xh=zeros(1,N);   %  �ع�����   
Base_t=[];              %  ��¼�������ľ���
r_n=y;                  %  �в�ֵ
A=Phi;    %�ָ�����
figure
for times=1:m;                                    %  ��������(�������������,�õ�������ΪK)
    for col=1:N;                                  %  �ָ����������������
        product(col)=abs(A(:,col)'*r_n);          %  �ָ�������������Ͳв��ͶӰϵ��(�ڻ�ֵ) 
    end
    [val,pos]=max(product);                       %  ���ͶӰϵ����Ӧ��λ�ã�valֵ��posλ��
    Base_t=[Base_t,A(:,pos)];                       %  �������䣬��¼���ͶӰ�Ļ�����
    A(:,pos)=zeros(M,1);                          %  ѡ�е������㣨ʵ����Ӧ��ȥ����Ϊ�˼��Ұ������㣩
    aug_y=(Base_t'*Base_t)^(-1)*Base_t'*y;   %  ��С����,ʹ�в���С
    r_n=y-Base_t*aug_y;                            %  �в�
    erro_rn(times)=norm(r_n,2);
    plot(erro_rn,'r-*')                                        %�������
    pos_array(times)=pos;                         %  ��¼���ͶӰϵ����λ��
   if erro_rn(times)<1e-6 %
            break; %����forѭ��
    end
end
legend('OMP����ƥ��׷�����')
xh(pos_array)=aug_y;
figure
plot(t,xh,'ko',t,x,'r.')
xlim([0,t(end)])
legend('OMP�ָ��ź�','ԭʼ�ź�')

%% 8. ��ѹ������ƥ��׷��(CoSaMP)�ķ�������l1���Ż�����
%Needell D, Tropp J A. CoSaMP: Iterative signal recovery from incomplete 
% and inaccurate samples [J]. Applied & Computational Harmonic Analysis, 2008, 26(3):301-321.
% һ����ѡ��2*K���ϴ�Ļ���ÿ��ѭ������ɾ���Ͳ���һ����Ŀ�Ļ������ﵽ��������

m=2*K;                  %  �㷨��������(m>=K)
theta=zeros(1,N);   %  �ع�����   
Base_t=[];              %  ��¼�������ľ���
A=Phi;    %�ָ�����

%% CoSaMP
%function xh=CS_CoSaMP( y,A,K );
    [m,n] = size(y);
    if m<n
        y = y'; %y should be a column vector
    end
    [M,N] = size(A); %���о���AΪM*N����
    theta = zeros(N,1); %�����洢�ָ���theta(������)
    pos_num = []; %�������������д洢A��ѡ��������
    res = y; %��ʼ���в�(residual)Ϊy
    figure
    for kk=1:K %������K��
        %(1) Identification
        product = A'*res; %���о���A������в���ڻ�
        [val,pos]=sort(abs(product),'descend');
        Js = pos(1:2*K); %ѡ���ڻ�ֵ����2K��
        %(2) Support Merger
        Is = union(pos_num,Js); %Pos_theta��Js����
        %(3) Estimation
        %At������Ҫ������������Ϊ��С���˵Ļ���(�������޹�)
        if length(Is)<=M
            At = A(:,Is); %��A���⼸����ɾ���At
        else %At�����������������б�Ϊ������ص�,At'*At��������
            if kk == 1
                theta_ls = 0;
            end
            break; %����forѭ��
        end
        %y=At*theta��������theta����С���˽�(Least Square)
        theta_ls = (At'*At)^(-1)*At'*y; %��С���˽�
        %(4) Pruning
        [val,pos]=sort(abs(theta_ls),'descend');
        %(5) Sample Update
        pos_num = Is(pos(1:K));
        theta_ls = theta_ls(pos(1:K));
        %At(:,pos(1:K))*theta_ls��y��At(:,pos(1:K))�пռ��ϵ�����ͶӰ
        res = y - At(:,pos(1:K))*theta_ls; %���²в� 
        erro_res(kk)=norm(res,2);
        plot(erro_res,'r-*')                                        %�������
        if norm(res)<1e-6 %Repeat the steps until r=0
            break; %����forѭ��
        end
    end
    theta(pos_num)=theta_ls; %�ָ�����theta
%  end
legend('CoSaMPѹ������׷�����')
 %%    
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('CoSaMP�ָ��ź�','ԭʼ�ź�')





%%

clc;clear all;

%% A Proximal-Gradient Algorithm Method

%  minimize ||A*x-y||^2 + lambda*||x||_1     (1)
%  ||A*x-y||^2�Ƕ�����ƽ��
%  f(x)= ||A*x-y||^2=x'A'Ax-2x'A'y+y'y
%  һ�׵���Ϊ����f(x)= 2A'Ax-2A'y=2A'(Ax-y)

% (1)����С������ת��Ϊ x_k=argmin{(1/(2*t_k))||x-(x_k-t_k��f(x_k-1))||^2+lambda||x||_1}
% �ȼ�Ϊx_k=argmin{(1/(2*t_k))||x-c_k||^2+lambda||x||_1}
% ����c_k=x_k-t_k��f(x_k-1)=x_k-1-2t_kA'(Ax_k-1-y)

% t_kΪ��ⲽ��
%%




