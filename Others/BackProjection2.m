function [ClearPoints_1, ClearPoints_2] = BackProjection2(InteriorPoints1, InteriorPoints2, scale_value)

    Key_nums1 = size(InteriorPoints1, 1);
    Key_nums2 = size(InteriorPoints2, 1);


    for i = 1:1:Key_nums1
        x = InteriorPoints1(i, 1);
        y = InteriorPoints1(i, 2);
        L_layer = InteriorPoints1(i, 4);

        if (L_layer == 1)
            x = x;
            y = y;
        else
            x = x * scale_value^(L_layer - 1);
            y = y * scale_value^(L_layer - 1);
        end
        InteriorPoints1(i,1)= x;
        InteriorPoints1(i,2)= y;
    end

    ClearPoints_1 = InteriorPoints1;

    for j = 1:1:Key_nums2
        xx = InteriorPoints2(j, 1);
        yy = InteriorPoints2(j, 2);
        R_layer = InteriorPoints2(j, 4);

        if (R_layer == 1)
            xx = xx;
            yy = yy;
        else
            xx = xx * scale_value^(R_layer - 1);
            yy = yy * scale_value^(R_layer - 1);
        end
        InteriorPoints2(j,1)= xx;
        InteriorPoints2(j,2)= yy;
    end

    ClearPoints_2 = InteriorPoints2;
end
