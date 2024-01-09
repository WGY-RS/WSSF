function [Blob_key_point_array,Corner_key_point_array] = FeatureDetection(Bolb_space,Corner_space,layers,npt1,npt2,sigma_1, ratio)
   Blob_key_point_array = [];
   Blob_key_number = 1;
   
   Corner_key_point_array = [];
   Corner_key_number = 1;  
   for i = 1:1:layers
       Blob_temp_current = Bolb_space{i};    
       im1=Blob_temp_current;
       Corner_temp_current = Corner_space{i};
       im2=Corner_temp_current;
    
       a=max(im1(:));  b=min(im1(:));  im1=(im1-b)/(a-b);       
       Bolb_kpts =  detectKAZEFeatures(im1);
       Bolb_kpts = Bolb_kpts.selectStrongest(npt1);   
       NumBlobs=Bolb_kpts.Count;
       Blobs_Kpts=Bolb_kpts.Location;
       Blobs_nom=Bolb_kpts.Metric;
       Blobs_scale=Bolb_kpts.Scale;
       Blobs_nom=mapminmax(Blobs_nom(:)',0,1)';       
       PointsBlobs=[Blobs_Kpts(:,1),Blobs_Kpts(:,2)];

       
       a=max(im2(:));  b=min(im2(:));  im2=(im2-b)/(a-b);       
       Corner_kpts =  detectKAZEFeatures(im2);
       Corner_kpts = Corner_kpts.selectStrongest(npt2);      
       NumCorners=Corner_kpts.Count;
       Corner_Kpts=Corner_kpts.Location;
       Corner_nom=Corner_kpts.Metric;
       Corner_scale=Corner_kpts.Scale;
       Corner_nom=mapminmax(Corner_nom(:)',0,1)';       
       PointsCorners=[Corner_Kpts(:,1),Corner_Kpts(:,2)];
    
       for j=1:NumBlobs
          if(floor(Blobs_scale(j,1)) < 4)          
           Blob_key_point_array(Blob_key_number, 1) = floor(PointsBlobs(j,1));
           Blob_key_point_array(Blob_key_number, 2) = floor(PointsBlobs(j,2));
           Blob_key_point_array(Blob_key_number, 3) =i;
           Blob_key_point_array(Blob_key_number, 4) = Blobs_nom(j,1);
           Blob_key_number = Blob_key_number + 1;
           end
       end
       
      for j=1:NumCorners
         if(floor(Corner_scale(j,1)) < 4)              
           Corner_key_point_array(Corner_key_number, 1) = floor(PointsCorners(j,1));
           Corner_key_point_array(Corner_key_number, 2) = floor(PointsCorners(j,2));
           Corner_key_point_array(Corner_key_number, 3) =i;
           Corner_key_point_array(Corner_key_number, 4) = Corner_nom(j,1);
           Corner_key_number = Corner_key_number + 1;
         end
       end
   end





