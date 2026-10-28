% Chooses reference-frame candidates: the frames that are most similar, on
% average, to all other (registered) frames of the video. Such frames are the
% least distorted by eye movements and make good references for stabilisation.
nom=size(frequency_ok,2);
files2 = dir(fullfile(current_folder,'Ireg1_*.tiff'));
sfiles1=size(files2,1);
% here we compute the similarity between each candidate frame and all
% registered frames ......................................................
Diff_structural=zeros(nom,sfiles1);
for b1=1:nom
    I1=imread(strcat('Ireg1_',num2str(frequency_ok(b1)),'.tiff'));
    parfor b2=1:sfiles1
        I2=imread(strcat('Ireg1_',num2str(b2),'.tiff'));
        Diff_structural(b1,b2)=ssim(I1,I2);
    end
    Diff_structural(b1,frequency_ok(b1))=NaN;   % ignore the comparison of a frame with itself
end

% mean similarity of each candidate to all the other frames
mean_Diff_structural=mean(Diff_structural,2,'omitnan');
% Bug fix (2026): sort in descending order. The previous ascending sort
% returned the candidates with the LOWEST similarity, i.e. the worst frames.
% Sorting indices (instead of searching for equal values) also handles ties.
[~,order]=sort(mean_Diff_structural,'descend');
if nom<20
    n=nom;
else
    n=10;
end
% "Selected_Frame(1)" is the best reference frame, followed by the next best
Selected_Frame=frequency_ok(order(1:n));
