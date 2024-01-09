function [G, Alpha] = GetGuidanceImgGPU(E, I, params)
%
%Input:
%       E                               由边缘探测算法得到的边缘置信图；
%       I                                 输入图像；
%       LineRadius                 Line的半径，控制了滤除纹理的空间尺度大小;
%       t                                 角度空间分割的间隔，与90度整除
%Output:
%       G                               得到指导图像；
%       alpha                          alpha.


%Sigma = params.LineRadius*10;
Sigma = 1;
%获取图像的亮度通道！
l = rgb2lab(gather(I));
l = l(:,:,1)/100;
G = gpuArray(zeros(size(l)));
Alpha = gpuArray(zeros(size(l)));
%LineRadius = params.LineRadius;
t = params.AngleInterval;
for theta=0:t:89
    if theta==0
        [GX, GY, AlphaX, AlphaY] = LineShiftGPU(E, l, params);
    else
        [GX, GY, AlphaX, AlphaY] = LineShiftGPU_Slant(E, l, theta, params);
    end
    AlphaX = exp(-Sigma.*AlphaX);
    AlphaY = exp(-Sigma.*AlphaY); 
%      AlphaX = 2.^(-Sigma.*AlphaX);
%      AlphaY = 2.^(-Sigma.*AlphaY);   
    G = G + bsxfun(@times, GX, AlphaX) + bsxfun(@times, GY, AlphaY);
    Alpha = Alpha + AlphaX + AlphaY;
end

G = bsxfun(@rdivide, G, Alpha);


end