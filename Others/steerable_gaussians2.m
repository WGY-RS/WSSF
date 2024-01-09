
function [Y] = steerable_gaussians2(X1,filter,sigmas,angles)
 if size(X1,3)~=1
     X1=rgb2gray(X1);
 else
     X1=X1;
 end
%% Parameter checking
Y=0;%dummy
angles = 6;


%% Init. operations
[a,b]=size(X1);
%X1=normalize(log(double(X1)+1));
G=[];
%% Construct steerable Gaussians
angle_step = pi/angles;
for i=1:length(sigmas)
    aa=length(sigmas);
    %construct filter support
    %Wx = floor((7/2)*sigmas(1,i)); 
    Wx = filter;
    if Wx < 1
       Wx = 1;
    end

    %Wy = floor((7/2)*sigmas(1,i)); 
    Wy = filter;
    if Wy < 1
       Wy = 1;
    end
    [X,Y]=meshgrid(-Wy:Wy,-Wx:Wx);

    %build base filters
%     Gx = -2.*X.*exp(-(X.^2+Y.^2)./(2*sigmas(1,i)^2));
%     Gy = -2.*Y.*exp(-(X.^2+Y.^2)./(2*sigmas(1,i)^2));
    g0 = exp(-(X.^2+Y.^2)/(2*sigmas(1,i)^2))/(sigmas(1,i)*sqrt(2*pi));
    G2a = -g0/sigmas(1,i)^2+g0.*X.^2/sigmas(1,i)^4;
    G2b =  g0.*X.*Y/sigmas(1,i)^4;
    G2c = -g0/sigmas(1,i)^2+g0.*Y.^2/sigmas(1,i)^4;
    %produce final filters
    for j=1:angles
       angle = (j-1)*angle_step;
       G{i,j}=cos(angle)^2*G2a+sin(angle)^2*G2c-2*cos(angle)*sin(angle)*G2b;   
       %(cos(theta))^2*I2a+sin(theta)^2*I2c-2*cos(theta)*sin(theta)*I2b;
    end  
end

%% Perform filtering
Y=zeros(a,b);
for i=1:length(sigmas) %scale
    tmp = zeros(a,b);
    for j=1:angles     %orientation
        tmp = tmp + (imfilter(X1,G{i,j},'replicate','same')); 
    end
    %Y=Y+normalize(tmp);
    Y=Y+tmp;
end
%Y = Y./6;
%Y = im2double(Y);
%Y=normalize(Y);