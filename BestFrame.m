% nom=size(Intensity_ok,2);
nom=size(frequency_ok,2);
files2 = dir(fullfile(current_folder,'*.tiff'));
files2 = {files2.name};
files2 = sort(files2);
sfiles1=size(files2,2); 
% here we compute the similarity between each pair of frames with
% acceptable intensity ....................................................
Diff_structural=zeros(nom,sfiles1);
for b1=1:nom
%     I1=imread(strcat('Ireg',num2str(Intensity_ok(1)),'_',num2str(Intensity_ok(b1)),'.tif'));
%     I1=imread(strcat('Ireg',num2str(frequency_ok(1)),'_',num2str(frequency_ok(b1)),'.tiff'));
    I1=imread(strcat('Ireg1_',num2str(frequency_ok(b1)),'.tiff'));
    parfor b2=1:sfiles1
%         I2=imread(strcat('Ireg',num2str(Intensity_ok(1)),'_',num2str(Intensity_ok(b2)),'.tif'));
%         I2=imread(strcat('Ireg',num2str(frequency_ok(1)),'_',num2str(b2),'.tiff'));
        I2=imread(strcat('Ireg1_',num2str(b2),'.tiff'));
        Diff_structural(b1,b2)=ssim(I1,I2);
%         Diff_structural(b1,b2)=immse(I1,I2);
    end
end
% make a complete matrix (Final_Diff_structural) from the triangular matrix
% (Diff_structural)
% Final_Diff_structural=Diff_structural(:,:)+(Diff_structural(:,:))';

% compute mean similarity value between each frame and all the other frames
mean_Diff_structural=mean(Diff_structural,2);
sorted_mean=sort(mean_Diff_structural);
% "Selected_Frame" represents the index of the best frame .................
% Selected_Frame=Intensity_ok(find(mean_Diff_structural==max(mean_Diff_structural))); 
if size(sorted_mean,1)<20
    n=size(sorted_mean,1);
else
    n=10;
end
for a=1:n
    Selected_Frame(a)=frequency_ok(find(mean_Diff_structural==sorted_mean(a))); 
end
% SelectedI=padarray(imread(strcat('frame',num2str(Selected_Frame),'.tif')),[50 50],0,'both');
% SelectedI=read(vRead,Selected_Frame);
% SelectedI=padarray(SelectedI,[10 10],0,'both');
% delete *.tif*
% imwrite(SelectedI,strcat('frame',num2str(Selected_Frame),'.tif')); 
% Selected_Frame=find(mean_Diff_structural==min(mean_Diff_structural)); 