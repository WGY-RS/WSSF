function [x,y] = zhixin(img)
img = uint8(img);
[m,n] = size(img);
sumImg = sum(img(:));
x = sum(img)*(1:n)'/sumImg;
y = (1:m)*sum(img,2)/sumImg;
end

