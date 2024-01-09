function [G, Alpha] = GetGuidanceImgGPU(E, I, params)
%
%Input:
%       E                               �ɱ�Ե̽���㷨�õ��ı�Ե����ͼ��
%       I                                 ����ͼ��
%       LineRadius                 Line�İ뾶���������˳�����Ŀռ�߶ȴ�С;
%       t                                 �Ƕȿռ�ָ�ļ������90������
%Output:
%       G                               �õ�ָ��ͼ��
%       alpha                          alpha.


%Sigma = params.LineRadius*10;
Sigma = 1;
%��ȡͼ�������ͨ����
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