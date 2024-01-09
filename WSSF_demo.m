%  ******* Code: Multi-Modal Remote Sensing Image Matching Based on Weighted Structure Saliency Feature
%  author: Created  in 2024/1/9.
%  note:第一次启动由于使用GPU加速会很慢。大概需要5分钟左右。
%  ********************************************************* 
close all;
beep off;
warning('off');
addpath(genpath('PSATF'));
addpath(genpath('Others'));
%% 1 Import and display reference and image to be registered
file_image= '..\..\配准性能图像2\';

[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select Image',file_image);image_3=imread(strcat(pathname,filename));
[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select Image',file_image);image_4=imread(strcat(pathname,filename));

image1 = image_3; image2 = image_4;

if size(image_3,3)==1
    image_3 = cat(3, image_3,image_3,image_3);
end
if size(image_4,3)==1
    image_4 = cat(3, image_4,image_4,image_4);
end

image_3 = adapthisteq(rgb2gray(image_3));image_4 = adapthisteq(rgb2gray(image_4));
image_3 = cat(3, image_3,image_3,image_3);image_4 = cat(3, image_4,image_4,image_4);
image_1 = im2double(image_3);image_2 = im2double(image_4);



%% 2  Setting of initial parameters 
%Key parameters:
Path_Block=48;                   
sigma_1=1.6;   
ratio=2^(1/3);                     
ScaleValue = 1.6;
nOctaves = 3;
filter = 5;
Scale ='YES';


%% 3 影像空间
t1=clock;
disp('Start WSSF algorithm processing, please waiting...');
tic;
[nonelinear_space_1,E_space_1,Max_space_1,Min_space_1,Phase_space_1]=Create_Image_space(image_1,nOctaves,Scale, ScaleValue, ratio,sigma_1,filter);
[nonelinear_space_2,E_space_2,Max_space_2,Min_space_2,Phase_space_2]=Create_Image_space(image_2,nOctaves,Scale, ScaleValue, ratio,sigma_1,filter);
disp(['构造影像尺度空间花费时间：',num2str(toc),' 秒']);

%% 4 特征提取
tic;
[Bolb_KeyPts_1,Corner_KeyPts_1,Bolb_gradient_1,Corner_gradient_1,Bolb_angle_1,Corner_angle_1]  =  WSSF_features(nonelinear_space_1,E_space_1,Max_space_1,Min_space_1,Phase_space_1,sigma_1,ratio,Scale,nOctaves);
[Bolb_KeyPts_2,Corner_KeyPts_2,Bolb_gradient_2,Corner_gradient_2,Bolb_angle_2,Corner_angle_2]  =  WSSF_features(nonelinear_space_2,E_space_2,Max_space_2,Min_space_2,Phase_space_2,sigma_1,ratio,Scale,nOctaves);
disp(['特征点提取花费时间:  ',num2str(toc),' 秒']);
%% 5 GLOH Descriptor 
tic;

Bolb_descriptors_1 = GLOH_descriptors(Bolb_gradient_1, Bolb_angle_1, Bolb_KeyPts_1, Path_Block, ratio,sigma_1);
Corner_descriptors_1 = GLOH_descriptors(Corner_gradient_1, Corner_angle_1, Corner_KeyPts_1, Path_Block, ratio,sigma_1);
Bolb_descriptors_2 = GLOH_descriptors(Bolb_gradient_2, Bolb_angle_2, Bolb_KeyPts_2, Path_Block, ratio,sigma_1);
Corner_descriptors_2 = GLOH_descriptors(Corner_gradient_2, Corner_angle_2, Corner_KeyPts_2, Path_Block, ratio,sigma_1);

disp(['特征描述子花费时间:  ',num2str(toc),' 秒']); 


%% 6 Matching by FSC
[indexPairs,~]= matchFeatures(Bolb_descriptors_1.des,Bolb_descriptors_2.des,'MaxRatio',1,'MatchThreshold', 50,'Unique',true ); 
[matchedPoints_1_1,matchedPoints_1_2] = BackProjection(Bolb_descriptors_1.locs(indexPairs(:, 1), :),Bolb_descriptors_2.locs(indexPairs(:, 2), :),ScaleValue); 
[indexPairs,~]= matchFeatures(Corner_descriptors_1.des,Corner_descriptors_2.des,'MaxRatio',1,'MatchThreshold', 50,'Unique',true ); 
[matchedPoints_2_1,matchedPoints_2_2] = BackProjection(Corner_descriptors_1.locs(indexPairs(:, 1), :),Corner_descriptors_2.locs(indexPairs(:, 2), :),ScaleValue); 

matchedPoints_1 = [matchedPoints_1_1;matchedPoints_2_1];
matchedPoints_2 = [matchedPoints_1_2;matchedPoints_2_2];
allNCM = size(matchedPoints_1,1);


[H1,rmse]=FSC(matchedPoints_1,matchedPoints_2,'affine',3);
Y_=H1*[matchedPoints_1(:,[1,2])';ones(1,size(matchedPoints_1,1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-matchedPoints_2(:,[1,2])').^2));
inliersIndex=E < 3;
clearedPoints1 = matchedPoints_1(inliersIndex, :);
clearedPoints2 = matchedPoints_2(inliersIndex, :);

[clearedPoints2,IA]=unique(clearedPoints2,'rows');
clearedPoints1=clearedPoints1(IA,:);
 


disp(['暴力匹配花费时间:  ',num2str(toc),' 秒']); 
tic; 

cp_showMatch(image1, image2, clearedPoints1,clearedPoints2,[],'');
RCM = size(clearedPoints1,1)/allNCM;
image_fusion(image2,image1,double(H1));


fprintf('\n');
disp(['正确匹配数量：',num2str(size(clearedPoints1,1))]);
disp(['匹配的成功率RCM：',num2str(RCM*100),'%']);
disp(['RMSE of Matching results: ',num2str(rmse),'  像素']); 
t2=clock;
disp(['粗配准花费时间:  ',num2str(etime(t2,t1)),' 秒']); 
tic;

