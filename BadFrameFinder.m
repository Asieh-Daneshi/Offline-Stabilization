% read the non-stabilized video file ......................................
% [FileName,~]=uigetfile('*.avi','Please select the video file');
keep current_folder files sfiles pnom FileName
videoName=FileName;
vRead=VideoReader(videoName);
NomFrames=floor(vRead.Duration*vRead.FrameRate);

% Frames are rejected if they are too dark (intensity below this fraction of
% the brightest frame) or sheared (their spectral left/right balance deviates
% from the video's typical value by more than shearThreshold).
% Set shearThreshold=Inf to switch the shear test off.
intensityThreshold=0.8;
shearThreshold=0.005;

Intensity_array=zeros(NomFrames,1);
ratio=zeros(NomFrames,1);
height=floor(vRead.Height);
width=floor(vRead.Width);
parfor nframe=1:NomFrames
    Im=read(vRead,nframe);
    if ndims(Im)==3
        Im=Im(:,:,1);
    end
    Intensity_array(nframe)=mean(Im(:));
    ImFShift=log10(abs(fftshift(fft2(double(Im))))+eps);
    Q1=ImFShift(1:floor(height/2),1:floor(width/2));
    Q2=ImFShift(1:floor(height/2),floor(width/2)+1:width);
    ratio(nframe)=sum(Q1(:))/sum(Q2(:));
end
% Bug fix (2026): the deviation used to be computed inside the loop against
% the frame's own ratio, so Q was always 0 and no frame was ever flagged as
% sheared. It is now measured against the median ratio of the whole video.
Q=abs(ratio-median(ratio));
shearedFrames=find(Q>=shearThreshold);
Intensity_metric=Intensity_array/max(Intensity_array);
Intensity_accepted=(find(Intensity_metric>=intensityThreshold))';
Accepted=setdiff(Intensity_accepted,shearedFrames);
fprintf('%s: %d of %d frames kept (%d too dark, %d sheared)\n',videoName, ...
    numel(Accepted),NomFrames,NomFrames-numel(Intensity_accepted),numel(shearedFrames));

%% writing video (after removing bad frames)
% frames are written directly, without temporary TIFF files, so no other
% TIFF files in the folder are touched
vWrite=VideoWriter(strcat(strrep(videoName,'.avi',''),'_cleaned.avi'),'Grayscale AVI');
open(vWrite)
for nframe=Accepted
    Im=read(vRead,nframe);
    if ndims(Im)==3
        Im=Im(:,:,1);
    end
    writeVideo(vWrite,uint8(Im))
end
close(vWrite)
