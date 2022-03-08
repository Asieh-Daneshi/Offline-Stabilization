function [myI]=Circle_mask()
Cx=512/2;
Cy=512/2;
for a1=1:512
    for a2=1:512
        distC(a1,a2)=sqrt((a1-Cx)^2+(a2-Cy)^2);
    end
end
myI=zeros(512,512);
myI(distC<=85)=1;