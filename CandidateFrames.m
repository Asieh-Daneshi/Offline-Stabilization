% Keeps the frames with the most high-frequency detail (sharpest frames) as
% candidates for the reference frame.
videoName=FileName;
vRead=VideoReader(videoName);
NomFrames=floor(vRead.Duration*vRead.FrameRate);
sums=zeros(NomFrames,4);
for nframe=1:NomFrames
    Im=read(vRead,nframe);
    ImF=fft2(Im);
    ImFShift=log10(abs(fftshift(ImF)));
    centralCircle=ImFShift.*Circle_mask();
    centralSum=sum(centralCircle(:));
    outerSum=sum(ImFShift(:))-centralSum;
    sums(nframe,1)=nframe;
    sums(nframe,2:4)=[centralSum/1000 outerSum/1000 centralSum/outerSum];
end
sums_ratio=sums(:,4);
frequency_ok=find(sums_ratio>0.999*max(sums_ratio));
if size(frequency_ok,1)<10
    % fewer than 10 frames passed: take the 10 frames with the highest ratio
    % (bug fix 2026: this used "delete frequency_ok", which tries to delete a
    % file instead of clearing the variable)
    clear frequency_ok
    sorted_sums=sortrows(sums,4,'descend');
    frequency_ok=sorted_sums(1:min(10,NomFrames),1);
end
frequency_ok=frequency_ok';
% -------------------------------------------------------------------------
% save frames with acceptable frequency content for further process .......
for nframe=frequency_ok
    filename=strcat('frame',num2str(nframe),'.tif');
    Im=read(vRead,nframe);
    Im=padarray(Im,[50 50],0,'both');
    imwrite(uint8(Im),filename);
end
