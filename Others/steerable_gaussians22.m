function [Y] = steerable_gaussians22(X1,filter,sigmas,angles)

if size(X1,3)~=1
    X1=rgb2gray(X1);
end 
%% Parameter checking


%% Init. operations
[a,b]=size(X1);
G=[];
%% Construct steerable Gaussians
angle_step = pi/angles;
for i=1:1
    Wx = filter;
    if Wx < 1
       Wx = 1;
    end
    Wy = filter;
    if Wy < 1
       Wy = 1;
    end
    [X,Y]=meshgrid(-Wy:Wy,-Wx:Wx);

    g0 = exp(-(X.^2+Y.^2)/(2*sigmas^2))/(sigmas*sqrt(2*pi));
    G2a = -g0/sigmas^2+g0.*X.^2/sigmas^4;
    G2b =  g0.*X.*Y/sigmas^4;
    G2c = -g0/sigmas^2+g0.*Y.^2/sigmas^4;
    %produce final filters
    for j=1:angles
       angle = (j-1)*angle_step;
       G{j}=cos(angle)^2*G2a+sin(angle)^2*G2c-2*cos(angle)*sin(angle)*G2b;   
    end  
end

%% Perform filtering
Y=zeros(a,b);
for j=1:angles     %orientation
    Y = Y + (imfilter(X1,G{i,j},'replicate','same')); 
end

end
