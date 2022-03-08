function [frequency_ok_b]=CandidateBatchFrames(FileName,b)
delete *.tif*
delete *.tiff*
videoName=FileName;
vRead=VideoReader(videoName);
NomFrames=vRead.Duration*vRead.FrameRate;
for nframe=1:NomFrames
% for nframe=1:100
    Img=read(vRead,nframe);
    Im=Img((b-1)*16+101:(b-1)*16+116,:);
    ImF=fft2(Im);
    ImFShift=log10(abs(fftshift(ImF)));
    centralCircle=ImFShift.*Circle_mask_batch(16);
    centralSum=sum(centralCircle(:));
    outerSum=sum(ImFShift(:))-centralSum;
    sums(nframe,1)=nframe;
    sums(nframe,2:4)=[centralSum/1000 outerSum/1000 centralSum/outerSum];
%     figure;imshow(Im,[])
end
sums_ratio=sums(:,4);
frequency_ok=find(sums_ratio>0.999*max(sums_ratio));
% figure;plot(frequency_ok)
if size(frequency_ok,1)<2
    sorted_sums=sortrows(sums,4,'descend');
    frequency_ok=sorted_sums(1:2,1);
end
frequency_ok_b=frequency_ok';
% -------------------------------------------------------------------------
% save frames with acceptable frequency content for further process .......
clear nframe
Im=read(vRead,1);
[sx,sy]=size(Im);
for nframe=frequency_ok_b
    filename=strcat('frame',num2str(nframe),'.tif');
    Im=read(vRead,nframe);
%     Im=padarray(Im,[50 50],0,'both');
    imwrite(uint8(Im),filename); 
end