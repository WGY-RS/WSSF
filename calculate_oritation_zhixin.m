function [angle_1]=calculate_oritation_zhixin(x,y,radius,nonelinear_space)

radius_x_left=x-radius;
radius_x_right=x+radius;
radius_y_up=y-radius;
radius_y_down=y+radius;
[M, N] = size(nonelinear_space);

    if (radius_x_left <= 0)
        radius_x_left = 1;
    end

    if (radius_x_right > N)
        radius_x_right = N;
    end

    if (radius_y_up <= 0)
        radius_y_up = 1;
    end

    if (radius_y_down > M)
        radius_y_down = M;
    end

sub_nonelinear_space=nonelinear_space(radius_y_up:radius_y_down,radius_x_left:radius_x_right);

[x_zhixin,y_zhixin] = zhixin(sub_nonelinear_space);
if isnan(atan2(y_zhixin, x_zhixin))
    angle_1 = 0;
else
angle_1 = atan2(y_zhixin, x_zhixin);
angle_1 = angle_1 * 180 / pi;
n = 12;
bin = round(angle_1 * n / 360);
% bin(bin>=n)=bin(bin>=n)-n;
% bin(bin<0)=bin(bin<0)+n;
angle_1 = bin;
end


end



