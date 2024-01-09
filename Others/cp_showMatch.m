
function cp_showMatch(I1,I2,loc1,loc2,correctPos,tname)
%% 首先确保图像都是三通道影像
[~,~,num_1] =size(I1);
[~,~,num_2] =size(I2);
if num_1>3
    I1=I1(:,:,1:3);
else
     I1=I1;
end
if num_2>3
    I2=I2(:,:,1:3);
else
     I2=I2;
end
if size(I1,3)==1
    temp=I1;
    I1(:,:,1)=temp;
    I1(:,:,2)=temp;
    I1(:,:,3)=temp;
end
if size(I2,3)==1
    temp=I2;
    I2(:,:,1)=temp;
    I2(:,:,2)=temp;
    I2(:,:,3)=temp;
end
%% 显示图像与匹配结果
cols = size(I1,2);
if size(I1,1) < size(I2,1)
    I1_p = [I1; zeros(size(I2,1)-size(I1,1),size(I1,2),size(I1,3))];
    im3 = [I1_p I2];
elseif size(I1,1) > size(I2,1)
    zeros(size(I1,1)-size(I2,1),size(I2,2));
    I2_p = [I2; zeros(size(I1,1)-size(I2,1),size(I2,2),size(I1,3))];
    im3 = [I1 I2_p];
else
    im3 = [I1 I2];
end

figure,imshow(im3,[]);
% title(tname);
hold on
if ~isempty(correctPos)
    line([loc1(:,1) loc2(:,1)+cols]',[loc1(:,2) loc2(:,2)]', 'Color', 'r','LineWidth',0.5);
    plot(loc1(:,1),loc1(:,2),'r+');
    plot(loc2(:,1)+cols,loc2(:,2),'r+');
%     loc1(correctPos,:) = [];
%     loc2(correctPos,:) = [];
hold on
    line([loc1(correctPos,1) loc2(correctPos,1)+cols]',[loc1(correctPos,2) loc2(correctPos,2)]', 'Color', 'b','LineWidth',1.5);
    plot(loc1(correctPos,1),loc1(correctPos,2),'g*');
    plot(loc2(correctPos,1)+cols,loc2(correctPos,2),'g*');

else
    line([loc1(:,1) loc2(:,1)+cols]',[loc1(:,2) loc2(:,2)]', 'Color', 'b','LineWidth',1.3);
    plot(loc1(:,1),loc1(:,2),'rs','LineWidth',1.0);
    plot(loc2(:,1)+cols,loc2(:,2),'gs','LineWidth',1.0);
end
set(gca,'LooseInset', get(gca,'TightInset'));
