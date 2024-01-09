function [Nonelinear_Scalespace,E_Scalespace,Max_Scalespace,Min_Scalespace,Phase_Scalespace]=Create_Image_space(im,nOctaves,Scale_Invariance,ScaleValue,...
                                                        ratio,sigma_1,...
                                                        filter)
addpath('./edges-master/');
model = load('./edges-master/models/forest/modelBsds.mat'); 

if (size(im, 3)==3)
    dst=rgb2gray(im);
else
    dst = im;
end
image=double(dst(:,:,1));

[M,N]=size(image);

if (strcmp(Scale_Invariance  ,'YES'))
    Layers=nOctaves;
else
    Layers=1;
end

Nonelinear_Scalespace=cell(1,Layers);
Image_Scalespace=cell(1,Layers);
E_Scalespace=cell(1,Layers);
Max_Scalespace=cell(1,Layers);
Min_Scalespace=cell(1,Layers);
Phase_Scalespace=cell(1,Layers);

for i=1:1:Layers
    Nonelinear_Scalespace{i}=zeros(M,N);
    Image_Scalespace{i}=zeros(M,N);
    E_Scalespace{i}=zeros(M,N);
end

[Max_Scalespace{1}, Min_Scalespace{1},Phase_Scalespace{1}, ~] = phasecong(image,4,6);
E = gpuArray(edgesDetect(gather(cat(3,image,image,image)), model.model));
E_Scalespace{1} = gather(E);  

windows_size=round(filter);
W=fspecial('gaussian',[windows_size windows_size],sigma_1);      
image=imfilter(image,W,'replicate');                                            
Nonelinear_Scalespace{1}=image;       
sigma=zeros(1,Layers);
for i=1:Layers
    sigma(i)=sigma_1*ratio^(i-1);
end


for i=2:Layers

    prev_image = Nonelinear_Scalespace{1,i-1};
    prev_image2 = imresize(prev_image,1/ScaleValue,'bilinear');    
    if size(prev_image2,3)~=1
        phase_image = rgb2gray(prev_image2); 
    else
        prev_image2 = cat(3, prev_image2,prev_image2,prev_image2);
        phase_image = rgb2gray(prev_image2); 
    end    
    [Max_Scalespace{i}, Min_Scalespace{i},Phase_Scalespace{i}, ~] = phasecong(phase_image,4,6);
    params.sigmaW = sigma(i);
    params.LineRadius = round(filter*sigma(i)*sigma(i)/2);
    [Nonelinear_Scalespace{i},E_Scalespace{i}]=SAF(prev_image2, params);    
end

end

