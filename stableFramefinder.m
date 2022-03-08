function [mystabilizedframe]=stableFramefinder(stabilisedvideoname)
% function [mystabilizedframe_O,mystabilizedframe]=stableFramefinder(stabilisedvideoname)
keep stabilisedvideoname
FileName=stabilisedvideoname;
videoName=FileName;
vRead=VideoReader(videoName);
NomFrames=vRead.Duration*vRead.FrameRate;
sumFrames=zeros(vRead.Height,vRead.Width,NomFrames);
parfor nframe=1:NomFrames
    Im=read(vRead,nframe);
    sumFrames(:,:,nframe)=Im;
end


% mystabilizedframe_O=zeros(vRead.Height,vRead.Width);
% for a1=1:vRead.Height
%     for a2=1:vRead.Width
%         findNonOnes=find(sumFrames(a1,a2,:)~=1);
%         dat=sumFrames(a1,a2,findNonOnes);
%         dati=reshape(dat,size(dat,3),1);
%         datil=dati(find(dati<=median(dati)));
%         datiu=dati(find(dati>median(dati)));
%         if ~isempty(datil)
%             ml=median(datil);
%         else
%             ml=median(dati);
%         end
%         if ~isempty(datiu)
%             mu=median(datiu);
%         else
%             mu=median(dati);
%         end
%         OkDataInd=find((dati<=mu+(mu-ml)*1.5)&(dati>=ml-(mu-ml)*1.5));
%         OkData=dati(OkDataInd);
%         if ~isempty(OkData)
%             mystabilizedframe_O(a1,a2)=sum(OkData)/size(OkData,1);
%         end
%         if ~isempty(findNonOnes)
%             frameCounter(a1,a2)=size(findNonOnes,1);
%         end
%     end
% end


frameCounter=ones(vRead.Height,vRead.Width);
for a1=1:vRead.Height
    for a2=1:vRead.Width
        findNonOnes=find(sumFrames(a1,a2,:)~=1);
        if ~isempty(findNonOnes)
            frameCounter(a1,a2)=size(findNonOnes,1);
        end
    end
end
mystabilizedframe=(sum(sumFrames,3)-(NomFrames-frameCounter))./frameCounter;