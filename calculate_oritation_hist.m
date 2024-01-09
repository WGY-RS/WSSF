function [hist,max_value]=calculate_oritation_hist(x,y,radius,gradient,angle,nonelinear_space,n,Sa,sigma_1,ratio,layer)

sigma= 1.5 * sigma_1 * ratio^(layer-1);
%sigma= radius/3;
radius_x_left=x-radius;
radius_x_right=x+radius;
radius_y_up=y-radius;
radius_y_down=y+radius;

    
sub_gradient=gradient(radius_y_up:radius_y_down,radius_x_left:radius_x_right);
sub_angle=angle(radius_y_up:radius_y_down,radius_x_left:radius_x_right);


X=-(x-radius_x_left):(radius_x_right-x);
Y=-(y-radius_y_up):(radius_y_down-y);
[XX,YY]=meshgrid(X,Y);

gaussian_weight=exp(-(XX.^2+YY.^2)/(2*sigma^2));
W1=sub_gradient.*gaussian_weight;
W=double(Sa).*double(W1);  

bin=round(sub_angle*n/360);
bin(bin>=n)=bin(bin>=n)-n;
bin(bin<0)=bin(bin<0)+n;
temp_hist=zeros(1,n);

for i=1:n
    wM = W(bin==i);
    if ~isempty(wM)
        temp_hist(i)=sum(wM(:));
    end
end

hist=zeros(1,n);
hist(1)=(temp_hist(n-1)+temp_hist(3))/16+...
    4*(temp_hist(n)+temp_hist(2))/16+temp_hist(1)*6/16;
hist(2)=(temp_hist(n)+temp_hist(4))/16+...
    4*(temp_hist(1)+temp_hist(3))/16+temp_hist(2)*6/16;
hist(3:n-2)=(temp_hist(1:n-4)+temp_hist(5:n))/16+...
4*(temp_hist(2:n-3)+temp_hist(4:n-1))/16+temp_hist(3:n-2)*6/16;
hist(n-1)=(temp_hist(n-3)+temp_hist(1))/16+...
    4*(temp_hist(n-2)+temp_hist(n))/16+temp_hist(n-1)*6/16;
hist(n)=(temp_hist(n-2)+temp_hist(2))/16+...
    4*(temp_hist(n-1)+temp_hist(1))/16+temp_hist(n)*6/16;

max_value=max(hist);
end



