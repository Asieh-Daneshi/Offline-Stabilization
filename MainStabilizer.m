close all
clear
clc
%% ========================================================================
% read names of all the files with format '.avi' in the current folder ----
current_folder = pwd;
files = dir(fullfile(current_folder,'\*.avi'));
files = {files.name};
files = sort(files);
sfiles=size(files,2);  
% Eliminating bad frames ==================================================
for pnom = 1
% for pnom = 1:sfiles
    FileName = cell2mat(files(pnom));
%     [FileName,~]=uigetfile('*.avi','Please select the video file');
    BadFrameFinder
end
%% ========================================================================
clear
current_folder = pwd;
files = dir(fullfile(current_folder,'\*_cleaned.avi'));
files = {files.name};
files = sort(files);
sfiles = size(files,2); 
mkdir(strcat(current_folder,'\New Folder1'))
for pnom = 1
% for pnom = 1:sfiles
    keep current_folder files sfiles pnom
    FileName = cell2mat(files(pnom));
    clc
    fprintf(FileName);fprintf('\n');
    fprintf('>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ');fprintf(num2str(pnom));
    fprintf('  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n');
    % Extract the frames form the video we want to stabilize ==============
    fprintf('Extracting single frames from the avi file  ------------------\n');
    CandidateFrames
    % Align the frames with acceptable intensity so we can compare their
    % similarity ..........................................................
    fprintf('Registering all frames to the first selected frame  ----------\n');
    videoName=FileName;
    vRead=VideoReader(videoName);
    MyRegBatch

    % Finding a suitable reference frame ..................................
    fprintf('Finding the best frame as a reference frame ------------------\n');
    BestFrame
    
%     keep files sfiles pnom FileName current_folder
%     imagefiles = dir(fullfile(current_folder,'\*.tif'));
%     imagefiles = {imagefiles.name};
%     MyReferenceFrame=cell2mat(imagefiles(1));
%     MyVideoName=strcat(current_folder,'\',FileName);
%     fprintf('Stabilizing --------------------------------------------------\n');
% %     stabilizefromraw_multiple_JLR_10_2019_Asi(MyReferenceFrame,MyVideoName)
%     stabilizefromraw_multiple_2020_07_08(MyReferenceFrame,MyVideoName)
%     stabilizedImageName=strcat(strrep(FileName,'.avi',''),'_blacklineFree.tiff');
%     [mystabilizedframe]=stableFramefinder(strcat(strrep(FileName,'.avi',''),'_stab_A.avi'));
%     imwrite(uint8(mystabilizedframe),stabilizedImageName);
%     movefile(stabilizedImageName,strcat(current_folder,'\New Folder1'));
%     movefile(strcat(strrep(FileName,'.avi',''),'_stab_A.avi'),strcat(current_folder,'\New Folder1'));
%     delete *.tif*
%     delete *.mat*
%     delete(strcat(strrep(FileName,'.avi',''),'_meanrem.avi'));
end
% cd(strcat(current_folder,'\New Folder1'));
%% ========================================================================
% Padding stabilized images for automontaging =============================
% clear
% clc
% current_folder=pwd;
% files = dir(fullfile(current_folder,'\*.tiff'));
% files = {files.name};
% files = sort(files);
% sfiles=size(files,2); 
% sxF=1024;
% syF=1024;
% for pnom = 1:sfiles
%     FileName = cell2mat(files(pnom));
%     I=imread(FileName);
%     [sx,sy]=size(I);
%     modx=mod(sxF-sx,2);
%     mody=mod(syF-sy,2);
%     if modx==0
%         padxB=(sxF-sx)/2;
%         padxA=padxB;
%     else
%         padxB=floor((sxF-sx)/2);
%         padxA=padxB+1;
%     end
%     
%     if mody==0
%         padyB=(syF-sy)/2;
%         padyA=padyB;
%     else
%         padyB=floor((syF-sy)/2);
%         padyA=padyB+1;
%     end
%     I_padded=padarray(I,[padxB padyB],0,'pre');
%     I_padded=padarray(I_padded,[padxA padyA],0,'post');
%     imwrite(I_padded,strcat(strrep(FileName,'.tiff',''),'.tif'));
% end