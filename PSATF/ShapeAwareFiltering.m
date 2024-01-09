function [f,e] = ShapeAwareFiltering(I, model,  params)
%
% Input:
%    I                         ����ͼ��
%    model                 ���ɭ�ֱ�Ե̽���㷨ģ�ͣ�
%    params               �������п��Ʋ�����
%Output:
%    f                         �˲���ͼ��
    niter = params.niter;
    f = gpuArray(I);  
    
    for  iter = 1:niter
        E = gpuArray(edgesDetect(gather(f), model.model));
        %imwrite(gather(E), './overall/E.jpg')
        [G, ~] = GetGuidanceImgGPU(E, f, params);
        f = GuidanceFilter(f, G, params);
    end
    f = gather(f);
    e = gather(E);    
end