function StabilizeFromRaw_Function(FileToRepair,RefFrame)
%% Stabilize from raw video
% (c) 2009 SBStevenson@uh.edu and GKR
% Editted by bethan@berkeley.edu
% Parameters of interest start on line 100
% This script creates a stabilized version of multiple raw AVI format videos.
% It is designed to work with AOSLO retinal images and will not work very
% well with conventional SLO images.
% This script is essentially a macro that calls a series of functions to
% carry out the analysis steps. These functions should be in
% ~\MatlabXXXX\toolbox\AOSLO\
%
% FileToRepair = Full Path and Filename of video
% RefFrame = image for reference frame

[PathNameAVI,~] = fileparts(FileToRepair);

rand('state',sum(100 * clock));
randn('state',sum(100 * clock));

currentdir = PathNameAVI;
screensize = get(0,'ScreenSize');
if ispc
    pathslash = '\';
else
    pathslash = '/';
end

numfiletoanalyse = 1;

% Get the image format in which to save the stabilised image from the user
formatofstabframe = ['.',lower('TIFF')];

cd(currentdir);

%% Set the parameters for the various functions used inthis script
blinkthreshold = 25;                % This is a maximum change in mean pixel value between
                                    % frames before the function tags the frames as blink
                                    % frames. Leave between 20-30
%% for poor quality videos minimummeanlevel may have to be lowered should stay above 5 and below 15
%leave tofilter at 0 it tends to make the cross correlation less accurate
minimummeanlevel = 8;              % This is minimum mean pixel value that a frame has to
                                    % have for it to be considered for analyses.
tofilter = 0;                       % If the video has luminance gradients or has too much pixel noise
                                    % then it would be wise to filter the video prior to analyses by setting
                                    % this flag to 1. If not set it to 0.
%% Only need 1 or 2 for gausslowcutoff and leave toremmeanlum at 1
%keep smoothsd low (between 2 & 3)
gausslowcutoff = 2;                 % Low Frequency cutoff  for the gaussbandfilter.m function 
smoothsd = 3;                       % The std. deviation of the gaussian smothing filter that is
                                    % applied by the gaussbandfilter.m    
toremmeanlum = 0;                   % If the video has luminance artifacts that has high frequency content
                                    % set this flag to 1 to use the removemeanlum.m function, otherwise
                                    % set to 0;
%% Keep smoothsdformeanremoval large (>15 especially for low quality videos)
smoothsdformeanremoval = 15;        % The std. deviation of the smoothing function used by the removemeanlum.m
                                    % function. 
numframestoaverage = -1;            % The number of frame to average toget if you want to remove the influence of
                                    % the mean frame luminance. If you set it to -1 then the program averages all
                                    % the frames
                                    
peakratiodiff = 0.5;                % Maximum Change in ratio between the secondpeak and firstpeak
                                    % between two frames for the frames before the function tags the frames as "bad".
%% keep maxmotionthreshold large to get most frames if you find your reference 
%looks bad you can decrease this value.
maxmotionthreshold = 0.3;           % Maximum motion between frames, expressed as a percentage
                                    % of the frame dimensions, before frames are tagged as "bad".
coarseframeincrement = 3;          % The step size used when choosing a subset of frames
                                    % from the frames that are good. This is used by the
                                    % makereference_framerate.m function.
                                    % This value is not important since if
                                    % it doesn't use enough frames the code
                                    % automatically changes it
%% samplerateincrement should be at 16 which =480Hz. helps make sure each strip has enough data
samplerateincrement_priorref = 32;  % The multiple of the framerate that is used
                                    % to obtain the sample rate of the ocular motion
                                    % trace when using the makereference_priorref.m function.
samplerateincrement = 32;           % The multiple of the framerate that is used
                                    % to obtain the sample rate of the ocular motion
                                    % trace when using the analysevideo_priorref.m function.
%% High value=more strips included keep above 0.6 below 0.9
badsamplethreshold = 0.75;           % The threshold that is used to locate the strips that had
                                    % good correlations during the analysis procedure. The lower
                                    % the number the more samples are discarded as "bad matches".
%% Always keep maintaintimerelationships at 1
maintaintimerelationships = 1;      % Certain post analysis questions require the stabilised video
                                    % to reflect accurate time relationships between frames. However
                                    % over the course of the analysis we drop frames that can't be
                                    % analysed accurately. If the user requires accurate time
                                    % relationships then this flag should be set to one, otherwise
                                    % set it to 0. When this flag is turned on, dropped frames are
                                    % replaced by a blank frame in the stabilised video.
%% Leave numlinesperfullframe at 512 for raw video
numlinesperfullframe = 512;         % The number of pixel lines that would have been present in a video
                                    % frame if data was collected during the vertical mirror flyback.
blacklineflag = 0;                  % When the eye moves faster than the vertical scan rate black lines are present
                                    % in the stabilised video. This occurs because no image data was collected at
                                    % this location. If you find these lines disconcerting, then set this flag to 1,
                                    % otherwise set to 0. These lines are removed by averaging the image data from
                                    % the lines above and below the black lines.
%% Keep maxsizeinvrement at least at 2 This defines the size of you border. If videos have lots of motion increase to 2.5
maxsizeincrement = 2;               % When creating stabilised movies and frames, physical memory is a big issue.
                                    % If the maximum motion in the raw video is too high, MATLAB runs out of
                                    % memory and crashes. To prevent that we have to set a maximum size for the
                                    % stabilised video and frame. The maxsizeincrement sets this limit, as a multiple
                                    % of the raw frame size. The maximum value for this parameter that we have
                                    % tested is 2.5. Any image that is outside is set limit is cropped.
%% Keep Splineflag at 0
splineflag = 0;                     % When calculating splines during the stabilisation, we could calculate
                                    % splines for individual frames (splineflag = 1), or calculate on spline
                                    % for the full video (splineflag = 0).
%% Here is the input structure for analyzing the videos if you find you are getting bad references make changes to priorref_inputstruct
%if there's a bunch of junk in your reference you can decrease bad strip
%threshold to 0.5 and increase minpercentgoodstripsperframe to 0.6
% priorref_inputstruct = struct('samplerate',[],'vertsearchzone',55,'stripheight',9,...
%     'badstripthreshold',0.65,'frameincrement',8,'minpercentofgoodstripsperframe',0.4,...
%     'numlinesperfullframe',numlinesperfullframe); % Structure that contains input arguments for the makereference_priorref.m function.

priorref_inputstruct = struct('samplerate',[],'vertsearchzone',55,'stripheight',9,...
    'badstripthreshold',0.55,'frameincrement',8,'minpercentofgoodstripsperframe',0.5,...
    'numlinesperfullframe',numlinesperfullframe); % Structure that contains input arguments for the makereference_priorref.m function.


%%
analyse_inputstruct = struct('samplerate',[],'vertsearchzone',55,'horisearchzone',[],...
    'startframe',1,'endframe',-1,'stripheight',9,'badstripthreshold',0.8,'minpercentofgoodstripsperframe',0.4,...
    'numlinesperfullframe',numlinesperfullframe); % Structure that contains input arguments for the analysevideo_priorref.m function.

%% Set the correlation flags for the analyses programs keep these set to [1;1]
%if you want to use a single reference frame for stablization the second
%value in these should be set to 0. 
correlationflags_framerate =[1;1];% Array that controls the cross-correlations conducted by makereference_framerate
correlationflags_priorref = [1;1];% Array that controls the cross-correlations conducted by makereference_priorref
correlationflags_analyse = [1;1];% Array that controls the cross-correlations conducted by analysevideo_priorref
% For all of the previous correlation flag array, the first element if set to 1 forces the programs to return the
% shift with sub-pixel accuracy, while the second force the programs to multiply the test matrix with a raised cosine
% window prior to the cross-correlation
analyse_programflags = [0 0]; % Array with the analysis flags used by the analysevideo_priorref.m function.
% Note at moment have not implemented the correction factor, so do not set
% the second flag in the above array to 1, until otherwise informed.

%% Set the feedback options for the various functions used inthis script
% leave these at 0 unless you need to troubleshoot something. FOr
% troubleshooting it can be helpful to set analyverbosity=[1 0 0 0] but it
% can get very annoying
blinkverbosity = 0;                 % Set to 1 if you want feedback from the getblinkframes.m
% function, otherwise set to 0.
meanlumverbosity = 0;               % Set to 1 if you want feedback from the removemeanlum.m
% function, otherwise set to 0.
badframeverbosity = 0;              % Set to 1 if you want feedback from the getbadframes.m
% function, otherwise set to 0.
coarserefverbosity = [0 0];         % The verbose array used by the makereference_framerate.m
% function.
finerefverbosity = [0 0 0 0];       % The verbose array used by the makereference_priorref.m
% function.
analyverbosity = [0 0 0 0];         % The verbose array used by the analysevideo_priorref.m
% function.
stabverbosity = 0;                  % Set to 1 if you want feedback from the makestabilizedvideo.m
% function, otherwise set to 0.
%% Don't touch anything past here it may screw up the progress bar which will cause the program to crash. 
totalnumofframesanalysed = 0;

tic

ReferenceImage = double(RefFrame(101:612,101:612));    

%%
Files2Delete = 0;
try
    videotoanalyse = FileToRepair;
    
    currentvideoinfo = VideoReader(videotoanalyse);
    frameheight = currentvideoinfo.Height;
    framewidth = currentvideoinfo.Width;
    framerate = round(currentvideoinfo.FrameRate);
    numberofframes = round(currentvideoinfo.FrameRate*currentvideoinfo.Duration);
    
    totalnumofframesanalysed = totalnumofframesanalysed + numberofframes;
    
    priorref_inputstruct.samplerate = round(framerate * samplerateincrement_priorref);
    analyse_inputstruct.samplerate = round(framerate * samplerateincrement);
    analyse_inputstruct.horisearchzone = (3 * framewidth) / 4;
    
    blinkfilename = strcat(videotoanalyse(1:end - 4),'_blinkframes.mat');
    
    if tofilter
        filteredname = strcat(videotoanalyse(1:end - 4),'_bandfilt.avi');
    else
        filteredname = videotoanalyse;
    end
    
    if toremmeanlum
        finalname =  strcat(filteredname(1:end-4),'_meanrem.avi');
    else
        finalname = filteredname;
    end
    
    stabimagename_noext = videotoanalyse(1:end - 4);
    
    blinkframes = getblinkframes(videotoanalyse, blinkthreshold,minimummeanlevel,blinkverbosity);
    
    if tofilter
        gaussbandfilter(videotoanalyse, gausslowcutoff, smoothsd);
    end
    
    if toremmeanlum
        removemeanlum(filteredname,smoothsdformeanremoval,numframestoaverage,meanlumverbosity);
    end
    
    [goodframesegmentinfo,largemovementframes] = getbadframes(finalname,blinkfilename,...
        peakratiodiff, maxmotionthreshold, badframeverbosity);
    
    [coarsereffilename, coarsereferimage] = makereference_framerate_ND(finalname,...
        blinkfilename, coarseframeincrement, badsamplethreshold,correlationflags_framerate,coarserefverbosity,'global',ReferenceImage);
    
    %         figure,imshow(coarsereferimage./255)
    
    [finereffilename, finerefimage] = makereference_priorref_ND(finalname,...
        coarsereffilename,blinkfilename, 'GlobalReference', priorref_inputstruct,correlationflags_priorref,...
        finerefverbosity);
    
    %         figure,imshow(finerefimage./255)
    
    analyseddatafilename = analysevideo_priorref(finalname, finereffilename, blinkfilename,...
        'referenceimage_prior', analyse_inputstruct, analyse_programflags,correlationflags_analyse, analyverbosity);
    
    
    load(analyseddatafilename,'analysedframes','frameshifts_strips_spline','peakratios_strips',...
        'stripidx','referenceimage');
    
    [stabilisedvideoname,stabilizedmatrix,stabilizedmatrix_full] =...
        makestabilizedvideoandframe_ND(videotoanalyse, analysedframes,...
        frameshifts_strips_spline, peakratios_strips, stripidx, badsamplethreshold,...
        maintaintimerelationships, numlinesperfullframe, blacklineflag, maxsizeincrement,...
        splineflag, stabverbosity);
    
    stabilizedframe = stabilizedmatrix(:,:,3);
    
    save(analyseddatafilename,'blinkframes','goodframesegmentinfo','largemovementframes',...
        'coarsereferimage','finerefimage','stabilizedframe','stabilizedmatrix','stabilizedmatrix_full','-append');
    
    Files2Delete = Files2Delete+1;
    AllAnalyseFiles{Files2Delete} = analyseddatafilename;
    
    switch formatofstabframe
        case '.jpeg'
            stabimagename = strcat(stabimagename_noext,formatofstabframe);
            imwrite(stabilizedmatrix(:,:,3) / 256,stabimagename,'Quality',100);
        case '.tiff'
            stabimagename = strcat(stabimagename_noext,'.tiff');
            imwrite(stabilizedmatrix(:,:,3) / 256,stabimagename,'Compression','none');
        case '.gif'
            stabimagename = strcat(stabimagename_noext,'.gif');
            imwrite(stabilizedmatrix(:,:,3) / 256,stabimagename);
    end

catch exception_object
    disp(exception_object.identifier);
    disp(videotoanalyse);
end

timeelapsed = toc;

fprintf('Total time elapsed %03.1f minutes\n', timeelapsed/60);
fprintf('Average time per video %03.1f seconds\n', timeelapsed / numfiletoanalyse);
fprintf('Average time per frame %03.1f seconds\n', timeelapsed / totalnumofframesanalysed);

% clean up 
if Files2Delete~=0
    for ax = 1:Files2Delete
        delete(AllAnalyseFiles{ax})
    end
end