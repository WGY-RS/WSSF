function [CleandPoints1,CleandPoints2] = Fine_Matching(Image1,Image2,H)
   
     [image_new,~] = transform(Image1,double(H));
     %figure;imshow(image_new);
     %预处理 这里需要空白模板进行边缘填充
     s=4;o=6;d=3;t=0.5; L=108;
     [im1,marg_im1]=preprocessing(image_new,L);[im2,marg_im2]=preprocessing(Image2,L);
     [M1,m1,~,~,~,eo1,~,~] = phasecong3(im1,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
     [~,~,~,~,~,eo2,~,~] = phasecong3(im2,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
     M1=t*M1+(t-1)*m1;a=max(M1(:)); b=min(M1(:)); M1=(M1-b)/(a-b);
     cmpc1 = CMPC(eo1,o,s,d);cmpc2 = CMPC(eo2,o,s,d);
     [matchedPoints3,matchedPoints4] = CMPC_match(M1,cmpc1,cmpc2,H,L);
     %去除填空数组
     for i=1:size(matchedPoints3,1)
         matchedPoints3(i,1)=matchedPoints3(i,1)-marg_im1;
         matchedPoints3(i,2)=matchedPoints3(i,2)-marg_im1;
         matchedPoints4(i,1)=matchedPoints4(i,1)-marg_im2;
         matchedPoints4(i,2)=matchedPoints4(i,2)-marg_im2;
     end
     %恢复到原图像上 目前成功
     finalCleandPoints1 =[];
     finalCleandPoints2 =[];
     for i=1:size(matchedPoints3,1)
        if matchedPoints3(i,1)~=0&&matchedPoints3(i,2)~=0&&matchedPoints4(i,1)>L/2  
           %if matchedPoints3(i,1)~=0&&matchedPoints3(i,2)~=0
           tempCo = [matchedPoints3(i,1);matchedPoints3(i,2);1];
           tempCo1 = inv(H)*tempCo;
           finalCleandPoints1(i,1)=tempCo1(1);
           finalCleandPoints1(i,2)=tempCo1(2);
           finalCleandPoints2(i,1) = matchedPoints4(i,1);
           finalCleandPoints2(i,2) = matchedPoints4(i,2);
        end
     end
    CleandPoints1 = finalCleandPoints1;
    CleandPoints2 = finalCleandPoints2;
end

