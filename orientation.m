function ANG = orientation(x,y,gradientImg,gradientAng, Scalespace, radius, patch_size_zhixin, sigma_1, ratio, layer, n, ORI_PEAK_RATIO)
if size(Scalespace,3)~=1
   Scalespace = rgb2gray(Scalespace);
end
se=strel('disk',radius,0); %半径为r的圆,
Sa=getnhood(se); %圆的邻域值，即表示圆的矩阵
 %统计梯度直方图，并给出最大方向上的值
[hist,max_value]=calculate_oritation_hist(x,y,radius,gradientImg,gradientAng,Scalespace,n,Sa,sigma_1,ratio,layer);
mag_thr = max_value*ORI_PEAK_RATIO;
angle_zhixin=calculate_oritation_zhixin(x,y,patch_size_zhixin,Scalespace);
%对关键点邻域的梯度大小进行高斯加权。每相邻三个bin采用高斯加权，根据Lowe的建议，模板采用[0.25,0.5,0.25]。方向包括主方向和辅助方向
ANG=[];
ANG=[ANG,angle_zhixin];
for k=1:n
    if(k==1)
        k1=n;
    else       
        k1=k-1;
    end
    
    if(k==n)
        k2=1;
    else
        k2=k+1;
    end
    if(hist(k)>hist(k1) && hist(k)>hist(k2)&& hist(k)>=mag_thr)
        bin=k-1+0.5*(hist(k1)-hist(k2))/(hist(k1)+hist(k2)-2*hist(k));
        if(bin<0)
            bin=n+bin;
        elseif(bin>=n)
            bin=bin-n;
        end
        angle=((360/n)*bin);%0-360
        ANG=[ANG,angle];
    end
end

