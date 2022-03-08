function [myI]=Circle_mask_batch(strip_width)
Cx=strip_width/2;
Cy=712/2;
for a1=1:strip_width
    for a2=1:712
        distC(a1,a2)=sqrt((a1-Cx)^2+(a2-Cy)^2);
    end
end
% figure;imshow(distC,[])
myI=zeros(strip_width,712);
myI(distC<=85)=1;