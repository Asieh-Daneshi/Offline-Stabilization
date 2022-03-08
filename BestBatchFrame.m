% nom=size(Intensity_ok,2);
% nom=size(frequency_ok,2);
files2 = dir(fullfile(current_folder,'*.tiff'));
files2 = {files2.name};
files2 = sort(files2);
sfiles1=size(files2,2);
% here we compute the similarity between each pair of frames with
% acceptable intensity ....................................................
% Diff_structural_sub=zeros(nom,sfiles1);
for b=1:32
    frequency_ok_b=CandidateBatchFrames(FileName,b);
    nom=size(frequency_ok_b,2);
    for b1=1:nom
        I1=imread(strcat('Ireg1_',num2str(frequency_ok_b(b1)),'.tiff'));
        I1=I1(257:768,257:768);
        I1_sub=I1((b-1)*16+1:(b-1)*16+16,:);
        for b2=1:sfiles1
            I2=imread(strcat('Ireg1_',num2str(b2),'.tiff'));
            I2=I2(257:768,257:768);
            I2_sub=I2((b-1)*16+1:(b-1)*16+16,:);
            Diff_structural_sub(b1,b2)=ssim(I1_sub,I2_sub);
        end
    end
    mean_Diff_structural=mean(Diff_structural_sub,2);
    Selected_Frame=find(mean_Diff_structural==max(mean_Diff_structural));
    SelectedI=read(vRead,Selected_Frame);
    I_final((b-1)*16+1:(b-1)*16+16,:)=SelectedI((b-1)*16+1:(b-1)*16+16,:);
end
% make a complete matrix (Final_Diff_structural) from the triangular matrix
% (Diff_structural)
% Final_Diff_structural=Diff_structural(:,:)+(Diff_structural(:,:))';

% compute mean similarity value between each frame and all the other frames

% "Selected_Frame" represents the index of the best frame .................
% Selected_Frame=Intensity_ok(find(mean_Diff_structural==max(mean_Diff_structural)));
I_final=padarray(I_final,[10 10],0,'both');
delete *.tif*
imwrite(I_final,strcat(strrep(FileName,'_cleaned.avi',''),'_RefFrame.tif'));
% Selected_Frame=find(mean_Diff_structural==min(mean_Diff_structural));