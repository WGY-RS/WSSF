function [Bolb_space,Corner_space,Bolb_gradient_cell,Corner_gradient_cell,Bolb_angle_cell,Corner_angle_cell] = WSSF_gradient_feature(Scalespace, E_Scalespace, Max_Scalespace, Min_Scalespace, Phase_Scalespace, Scale_Invariance, nOctaves)


    if (strcmp(Scale_Invariance, 'YES'))
        Layers = nOctaves;
    else
        Layers = 1;
    end

    [M, N] = size(Scalespace{1});
    Bolb_gradient_cell = cell(1, Layers);
    Corner_gradient_cell = cell(1, Layers);

    Bolb_angle_cell = cell(1, Layers);
    Corner_angle_cell = cell(1, Layers);
    
    Bolb_space = cell(1, Layers);
    Corner_space = cell(1, Layers);


    for j = 1:Layers
    
    Bolb_gradient_cell{j} = zeros(M, N);
    Corner_gradient_cell{j} = zeros(M, N);

    Bolb_angle_cell{j} = zeros(M, N);
    Corner_angle_cell{j} = zeros(M, N);
        
    Bolb_space{j} = zeros(M, N);
    Corner_space{j} = zeros(M, N);       
    end


   %sobel
    h1 = [- 1, 0, 1; - 2, 0, 2; - 1, 0, 1];
    h2 = [- 1, - 2, - 1; 0, 0, 0; 1, 2, 1];
    
    
    for j = 1:Layers
        if size(Scalespace{j},3)~=1
           Scalespace{j} = rgb2gray(Scalespace{j});
        end
        



        Bolbspace  = double(1 * Max_Scalespace{j}) + double(2 * E_Scalespace{j})  + double(0 * Scalespace{j});         
        Bolbspace = steerable_gaussians2(Bolbspace,5,5)/6; 
        Bolb_space{j} = double(Max_Scalespace{j});
        
        
        Scalespace{j} = mapminmax(Scalespace{j},0,1);
        Cornerspace  = double(Scalespace{j});      
        Cornerspace = steerable_gaussians2(Cornerspace,5,5)/6; 
        Corner_space{j} = double(Max_Scalespace{j});
 

        
        %Bolb        
        gradient_x_Bolb_1 = imfilter(Bolbspace, h1, 'replicate');
        gradient_y_Bolb_1 = imfilter(Bolbspace, h2, 'replicate');       
        gradient_Bolb_1 = sqrt(gradient_x_Bolb_1.^2 + gradient_y_Bolb_1.^2);        
        Bolb_gradient_cell{j} = single(gradient_Bolb_1);
        %Bolb_gradient_cell{j} = Bolbspace;
        
        Bolb_angle = atan2(gradient_y_Bolb_1, gradient_x_Bolb_1);
        Bolb_angle = Bolb_angle * 180 / pi;
        Bolb_angle(Bolb_angle < 0) = Bolb_angle(Bolb_angle < 0) + 360;
        Bolb_angle_cell{j} = single(Bolb_angle);  


        %Corner
        gradient_x_Corner_1 = imfilter(Cornerspace, h1, 'replicate');
        gradient_y_Corner_1 = imfilter(Cornerspace, h2, 'replicate');       
        gradient_Corner_1 = sqrt(gradient_x_Corner_1.^2 + gradient_y_Corner_1.^2);
        
        gradient_x_Corner_2 = imfilter(gradient_Corner_1, h1, 'replicate');
        gradient_y_Corner_2 = imfilter(gradient_Corner_1, h2, 'replicate');
        gradient_Corner_2 = sqrt(gradient_x_Corner_2.^2 + gradient_y_Corner_2.^2);
        Corner_gradient_cell{j} = single(gradient_Corner_2);
    
        Corner_angle = atan2(gradient_y_Corner_2, gradient_x_Corner_2);
        Corner_angle = Corner_angle * 180 / pi;
        Corner_angle(Corner_angle < 0) = Corner_angle(Corner_angle < 0) + 360;
        Corner_angle_cell{j} = single(Corner_angle);  


    end
end
    
  
    



