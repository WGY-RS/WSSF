function [f,e] = ShapeAwareFiltering(I, model,  params)
%
% Input:
%    I                         输入图像；
%    model                 随机森林边缘探测算法模型；
%    params               程序运行控制参数；
%Output:
%    f                         滤波后图像。
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