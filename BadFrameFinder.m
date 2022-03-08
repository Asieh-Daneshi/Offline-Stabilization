% read the non-stabilized video file ......................................
% [FileName,~]=uigetfile('*.avi','Please select the video file');
keep current_folder files sfiles pnom FileName
videoName=FileName;
vRead=VideoReader(videoName);
NomFrames=vRead.Duration*vRead.FrameRate;

Intensity_array=zeros(NomFrames,1);
Q=zeros(NomFrames,1);
height=floor(vRead.Height);
width=floor(vRead.Width);
parfor nframe=1:NomFrames
    filename=strcat('frame',num2str(nframe),'.tiff');
    Im=read(vRead,nframe);
    Intensity_array(nframe)=mean(Im(:));
    ImF=fft2(Im);
    ImFShift=log10(abs(fftshift(ImF)));
    Q1=ImFShift(1:height/2,1:width/2);
    Q2=ImFShift(1:height/2,width/2:width);
    Q(nframe)=abs(sum(Q1(:))/sum(Q2(:))-mean(sum(Q1(:))/sum(Q2(:))));
end
shearedFrames=find(Q>=0.005);
Intensity_metric=Intensity_array/max(Intensity_array);
Intensity_accepted=(find(Intensity_metric>=0.8))'; 
Accepted=setdiff(Intensity_accepted,shearedFrames);

for nframe=Accepted
    filename=strcat('frame',num2str(nframe),'.tiff');
    Im=read(vRead,nframe);
    imwrite(uint8(Im),filename); 
end

%% writing video (after removing bad frames)
vWrite=VideoWriter(strcat(strrep(videoName,'.avi',''),'_cleaned.avi'),'Grayscale AVI');
open(vWrite)
for nframe=Accepted
    filename=strcat('frame',num2str(nframe),'.tiff');
    Im=imread(filename);
    writeVideo(vWrite,Im)
end
close(vWrite)
delete *.tiff*