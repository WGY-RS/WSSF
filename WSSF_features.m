function [position_1, position_2, Bolb_gradient_cell, Corner_gradient_cell, Bolb_angle_cell, Corner_angle_cell] = WSSF_features(nonelinear_space, E_space, Max_space, Min_space, Phase_space, sigma_1, ratio, Scale_Invariance,nOctaves)
    [Bolb_space,Corner_space,Bolb_gradient_cell,Corner_gradient_cell,Bolb_angle_cell,Corner_angle_cell] = WSSF_gradient_feature(nonelinear_space, E_space, Max_space, Min_space, Phase_space, Scale_Invariance,nOctaves);
    points_layer1 = 5000; points_layer2 = 5000;
    [Blob_key_point_array,Corner_key_point_array] = FeatureDetection(Bolb_space,Corner_space,nOctaves,points_layer1,points_layer2,sigma_1, ratio);
   
    uni1=Blob_key_point_array(:,[1,2]);
    [~,i,~]=unique(uni1,'rows','first');
    Blob_key_point_array=Blob_key_point_array(sort(i)',:);  
    uni1=Corner_key_point_array(:,[1,2]);
    [~,i,~]=unique(uni1,'rows','first');
    Corner_key_point_array=Corner_key_point_array(sort(i)',:);      
    
    window = 5;
    [keypoints,~]=WSSF_selectMax_NMS(Blob_key_point_array,window);
    Blob_key_point_array = keypoints.kpts; Blob_key_point_array = Blob_key_point_array(:,1:4);
    [keypoints,~]=WSSF_selectMax_NMS(Corner_key_point_array,window);
    Corner_key_point_array = keypoints.kpts; Corner_key_point_array = Corner_key_point_array(:,1:4);   

    position_1=kptsOrientation(Blob_key_point_array,Bolb_gradient_cell,Bolb_angle_cell,nonelinear_space,sigma_1,ratio);   
    position_2=kptsOrientation(Corner_key_point_array,Corner_gradient_cell,Corner_angle_cell,nonelinear_space,sigma_1,ratio);   
end
