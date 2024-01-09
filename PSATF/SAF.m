function [FiltImg,E] = SAF(Img, params_initial)


if(size(Img,3)==1)
    Img = cat(3, Img,Img,Img);
else
    Img = rgb2gray(Img);
    Img = cat(3, Img,Img,Img);
end

addpath('./edges-master/');
model = load('./edges-master/models/forest/modelBsds.mat'); 

LineRadius = params_initial.LineRadius;
sigmaW = params_initial.sigmaW;
%参数设置
%LineRadius：Line的半径，控制了可以滤除的纹理的空间尺度大小, 默认为3；
%针对纹理图像，取值2~5之间；
%与PatchShift算法的PatchSize的关系：k = 2*LineRadius+1。
params.LineRadius = LineRadius;
%空域的sigma值，默认5；
params.sigmaW = sigmaW;
%主循环次数，默认为1；
params.niter = 1;
%随机森林探测前进行均值滤波，以减少误探测边缘，默认为1；
params.BoxFilterSize = 1;
%每次主循环中，联合指导双边滤波循环次数，默认为2；
params.JBFniter = 2;
%求取各个方向Lines时，划分方向空间的间隔，默认为30；
params.AngleInterval = 30;
%Option：取值1/2，
%1:评判一个Line穿越边缘的置信度：使用边缘置信图E里该Line上的像素点们置信值的均值；
%2:评判一个Line穿越边缘的置信度：使用边缘置信图E里该Line上的像素点们置信值的方差。
%3:评判一个Line穿越边缘的置信度：使用边缘置信图E里该Line上的像素点们置信值的最大值。
params.Option = 2;
%是否显示并输出算法迭代运行过程中各个方向上产生的Guidance图像
% params.isShowGuiandceSlant = true;
%是否显示并输出算法迭代运行过程中产生的Guidance图像
% params.isShowGuiandce = true;
%是否显示并输出算法迭代运行过程中产生的滤波图像
% params.isShowFilt = true;
%Line的长度hj

[FiltImg,E] = ShapeAwareFiltering(Img, model, params);


end

