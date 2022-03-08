% current_folder = pwd;
% vRead=VideoReader(videoName);
sfiles1=vRead.Duration*vRead.FrameRate;
% here we align all the frames to the first frame. We can do it for any
% other frame from with acceptable intensity. We just need to line up them,
% so that we can compare their similarity .................................
Iref=double(read(vRead,1));
[sx,sy]=size(read(vRead,1));
Iref=padarray(Iref,[sx/2 sy/2],0,'both');
[optimizer,metric]=imregconfig('monomodal');

parfor pnom = 1:sfiles1
    Imov=double(read(vRead,pnom));
    Imov=padarray(Imov,[sx/2 sy/2],0,'both');
%     Imov=double(imread(strcat('frame',num2str(frequency_ok(pnom)),'.tif')));
    tform=imregtform(Imov,Iref,'translation', optimizer, metric);   
    Ireg=imwarp(Imov,tform);
%     imwrite(uint8(Ireg),strcat('Ireg',num2str(Intensity_ok(1)),'_',num2str(Intensity_ok(pnom)),'.tif'));
    imwrite(uint8(Ireg),strcat('Ireg1_',num2str(pnom),'.tiff'));
end