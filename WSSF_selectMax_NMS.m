function[keypoints,keypoints_error]=WSSF_selectMax_NMS(AFPts,window)

    r=window/2;
    Numbners=size(AFPts,1);
    B=ones(Numbners,1);
    key_points=[AFPts,B];
    if(window~=0)

        for i=1:Numbners
            for j=(i+1):Numbners
                distance=(abs(key_points(i,1)-key_points(j,1)))^2+(abs(key_points(i,2)-key_points(j,2)))^2;
                if distance<r^2||distance==r^2
                    if(key_points(i,4)<key_points(j,4))
                        key_points(i,5)=0;
                    else
                        key_points(j,5)=0;
                    end
                end

            end
        end
        kpts_nms=key_points;
    end
    keypoints=struct('kpts',kpts_nms(kpts_nms(:,5)==1,:));
    keypoints_error=struct('kpts',kpts_nms(kpts_nms(:,5)==0,:));
end