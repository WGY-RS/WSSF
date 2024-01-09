function [GX, GY, AlphaX, AlphaY]= LineShiftGPU(E, I,  params)
%
%Input:
%       E                                �ɱ�Ե̽���㷨�õ��ı�Ե����ͼ��
%       I                                  ��������ͼ��
%       LineRadius                 Line�İ뾶���������˳�����Ŀռ�߶ȴ�С;
%       Option                        1/2
%        1:����һ��Line��Խ��Ե�����Ŷȣ�ʹ�ñ�Ե����ͼE���Line�ϵ����ص�������ֵ�ľ�ֵ��
%        2:����һ��Line��Խ��Ե�����Ŷȣ�ʹ�ñ�Ե����ͼE���Line�ϵ����ص�������ֵ�ķ��
%                                           
%Output:
%       GX                              ��ӦX�����ϱ���Line���洢���Ǳ���Line�����ص��ǵ����Ȼ�ɫ��ֵ�ľ�ֵ
%       AlphaX                        X�����ϱ���Line������Ե�����Ŷȣ�
%       GY                              ��ӦY�����ϵı���Line���洢���Ǳ���Line�����ص��ǵ����Ȼ�ɫ��ֵ�ľ�ֵ
%       AlphaY                        Y�����ϵı���Line������Ե�����Ŷȣ�

if(isfield(params, 'Option'))
    Option = params.Option;
else
    Option = 2;
end
if(isfield(params, 'LineRadius'))
    LineRadius = params.LineRadius;
else
    LineRadius = 3;
end
if((size(E, 3)~=1)||(size(I, 3)~=1))
    disp('Wrong Input Parameter for LineShift');
end

[Height, Width]  = size(I);
LineSize = 2*LineRadius + 1;
p_E = padarray(E, [LineRadius LineRadius], 'symmetric');
p_I = padarray(I, [LineRadius LineRadius], 'symmetric');

pu = LineRadius + 1;
pb = pu + Height - 1;
pl = LineRadius + 1;
pr = pl + Width - 1;

%X����
Mean = gpuArray(zeros(size(E), 'single'));
Max = E;
Var = gpuArray(zeros(size(E), 'single'));
B = gpuArray(zeros(size(I),'single'));
for x = -LineRadius:LineRadius
    Mean =  Mean + p_E(pu:pb, pl+x:pr+x);
    Max = max(Max, p_E(pu:pb, pl+x:pr+x));
    B = B + p_I(pu:pb, pl+x:pr+x, :);
end
Mean = Mean./LineSize;
B = B./LineSize;
if(Option == 2)
    for x = -LineRadius:LineRadius
        Var =  Var + power(Mean - p_E(pu:pb, pl+x:pr+x), 2);
    end
    Var = sqrt(Var);
elseif(Option == 3)
        Var = Max;
else
        Var = Mean;
end
p_Var = padarray(Var, [LineRadius LineRadius], 'symmetric');
p_B = padarray(B, [LineRadius LineRadius], 'symmetric');
AlphaX = Var;
GX = B;
for x = -LineRadius:LineRadius
    curVar =  p_Var(pu:pb, pl+x:pr+x, :);
    curB = p_B(pu:pb, pl+x:pr+x, :);
    GX(curVar<AlphaX) = curB(curVar<AlphaX);
    AlphaX = min(AlphaX, curVar);
end

%Y����
Mean = 0;
Max = E;
Var = 0;
B = 0;
for y = -LineRadius:LineRadius
    Mean =  Mean + p_E(pu+y:pb+y, pl:pr);
    Max = max(Max, p_E(pu+y:pb+y, pl:pr));
    B = B + p_I(pu+y:pb+y, pl:pr, :);
end
Mean = Mean./LineSize;
B = B./LineSize;
if(Option == 2)
    for y = -LineRadius:LineRadius
        Var =  Var + power(Mean - p_E(pu+y:pb+y, pl:pr), 2);
    end
    Var = sqrt(Var);
elseif(Option == 3)
        Var = Max;
else
        Var = Mean;
end
p_Var = padarray(Var, [LineRadius LineRadius], 'symmetric');
p_B = padarray(B, [LineRadius LineRadius], 'symmetric');
AlphaY = Var;
GY = B;
for y = -LineRadius:LineRadius
    curVar =  p_Var(pu+y:pb+y, pl:pr, :);
    curB = p_B(pu+y:pb+y, pl:pr, :);
    GY(curVar<AlphaY) = curB(curVar<AlphaY);
    AlphaY = min(AlphaY, curVar);
end