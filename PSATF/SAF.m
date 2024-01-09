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
%��������
%LineRadius��Line�İ뾶�������˿����˳�������Ŀռ�߶ȴ�С, Ĭ��Ϊ3��
%�������ͼ��ȡֵ2~5֮�䣻
%��PatchShift�㷨��PatchSize�Ĺ�ϵ��k = 2*LineRadius+1��
params.LineRadius = LineRadius;
%�����sigmaֵ��Ĭ��5��
params.sigmaW = sigmaW;
%��ѭ��������Ĭ��Ϊ1��
params.niter = 1;
%���ɭ��̽��ǰ���о�ֵ�˲����Լ�����̽���Ե��Ĭ��Ϊ1��
params.BoxFilterSize = 1;
%ÿ����ѭ���У�����ָ��˫���˲�ѭ��������Ĭ��Ϊ2��
params.JBFniter = 2;
%��ȡ��������Linesʱ�����ַ���ռ�ļ����Ĭ��Ϊ30��
params.AngleInterval = 30;
%Option��ȡֵ1/2��
%1:����һ��Line��Խ��Ե�����Ŷȣ�ʹ�ñ�Ե����ͼE���Line�ϵ����ص�������ֵ�ľ�ֵ��
%2:����һ��Line��Խ��Ե�����Ŷȣ�ʹ�ñ�Ե����ͼE���Line�ϵ����ص�������ֵ�ķ��
%3:����һ��Line��Խ��Ե�����Ŷȣ�ʹ�ñ�Ե����ͼE���Line�ϵ����ص�������ֵ�����ֵ��
params.Option = 2;
%�Ƿ���ʾ������㷨�������й����и��������ϲ�����Guidanceͼ��
% params.isShowGuiandceSlant = true;
%�Ƿ���ʾ������㷨�������й����в�����Guidanceͼ��
% params.isShowGuiandce = true;
%�Ƿ���ʾ������㷨�������й����в������˲�ͼ��
% params.isShowFilt = true;
%Line�ĳ���hj

[FiltImg,E] = ShapeAwareFiltering(Img, model, params);


end

