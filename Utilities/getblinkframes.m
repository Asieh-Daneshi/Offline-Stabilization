function blinkframes = getblinkframes(videoname,blinkthreshold,minframemean,verbose)
% getbadframes.m. This is a utility program that locates blinks in a AOSLO video. The start of a blink is accompanied by a sudden sharp decrease in
% luminance captured by the instrument. Therefore this program marks the start of a blink if the difference in mean pixel level between two frames
% is below a cetain thresold.
%
% Usage: blinkframes = getblinkframes(videoname,blinkthreshold,verbose)
%
% videoname                 - The string that is the name of a video or a 3D % matrix containing a collection of frames. If  neither type of datatype is
%                                   supplied the program will query the user to choose a video.
% blinkthreshold            - The minimum drop mean pixel level that indicates the start of a blink.If the user does not supply this he will be prompted by
%                                   a dialog box. This threshold has to be within 15 and 75. If the user supplies a threshold that is not in this range the program
%                                   alters the value to be within this range. Default is 25.
% minframemean              - The minimum mean pixel level of a frame that will not be included in the blink frame array. Default is 15.
% verbose                   - If the user wants a plot of the difference in frame means obtained from the video with the frames that were tagged as bad marked then
%                                   verbose should 1. Default is 0.
%
% blinkframes               - The frame numbers tagged as blink frames.
%
%
% Program Creator: Girish Kumar
% Make Peaceful Love not War

% Get the name of the video file or the 3-D array of frames
if (nargin < 1) || isempty(videoname)
    [videoname,avifilename,avipath] = getvideoname;
    processfullvideo = 1;
else
    if ischar(videoname)
        processfullvideo = 1;
        if ~exist(videoname,'file')
            warning('Video name does not point to a valid file');
            [videoname,avifilename,avipath] = getvideoname;
        else
            maxslashindex = 0;
            for charcounter = 1:length(videoname)
                testvariable = strcmp(videoname(charcounter),'\');
                if testvariable
                    maxslashindex = charcounter;
                end
            end
            avifilename = videoname(maxslashindex + 1:end);
        end
    else
        processfullvideo = 0;
        if length(size(videoname)) ~= 3
            disp('Provide a video name or a 3 dimensional array of frames');
            error('Type ''help getblinkframes'' for usage');
        end
    end
end

% Decide if the program haas to get the blink threshold  from the user
if (nargin < 2) || isempty(blinkthreshold) || ~isscalar(blinkthreshold)
    togetblinkthreshold = 1;
else
    togetblinkthreshold = 0;
end

% Decide if the program haas to get the minimum frame mean from the user
if (nargin < 3) || isempty(minframemean) || ~isscalar(minframemean)
    togetminframemean = 1;
else
    togetminframemean = 0;
end

% Get either the blink threshold or the minimum frame mean if required
if togetblinkthreshold || togetminframemean
    name = 'Input for getblinkframes.m';
    numlines = 1;
    prompt = {};
    defaultanswer = {};

    if togetblinkthreshold
        prompt = {'Blink Threshold'};
        defaultanswer = {num2str(25)};
    end

    if togetminframemean
        prompt{end + 1} = 'Minimum Mean Pixel Mean';
        defaultanswer{end + 1} = num2str(15);
    end

    userresponse = inputdlg(prompt,name,numlines,defaultanswer);

    if isempty(userresponse)
        if togetblinkthreshold
            warning('Using default blink threshold of 25');
            blinkthreshold = 25;
        end

        if totogetminframemean
            warning('Using default minimum pixel mean of 15');
            minframemean = 15;
        end
    else
        index = 1;
        if togetblinkthreshold
            if ~isempty(userresponse{index})
                blinkthreshold = str2double(userresponse{index});
            else
                disp('User has not entered blink threshold');
                warning('Using default of 25');
                blinkthreshold = 25;
            end
            index = index + 1;
        end

        if togetminframemean
            if ~isempty(userresponse{index})
                minframemean = str2double(userresponse{index});
            else
                disp('User has not entered minimum mean pixel level');
                warning('Using default of 15');
                minframemean = 15;
            end
        end
    end
end


if nargin < 4 || isempty(verbose)
    verbose = 1;
end

% Error check the value if the blink threshold
if blinkthreshold > 75
    warning('Blink Threshold is to high.');
    disp('Reducing Blink threshold to 75');
    blinkthreshold = 75;
end
if blinkthreshold < 2
    warning('Blink Threshold is too low');
    disp('Increasing Blink threshold to 2');
    blinkthreshold = 2;
end

% Error check the value if the minimum frame mean
if minframemean > 50
    warning('Minimum Frame Mean is to high.');
    disp('Reducing Minimum Frame Mean to 50');
    minframemean = 50;
end
if minframemean < 1
    warning('Minimum Frame Mean is too low');
    disp('Increasing Minimum Frame Mean to 2');
    minframemean = 1;
end

if processfullvideo
    vid_obj = VideoReader(videoname); % Get important info of the avifile
    numbervideoframes = round(vid_obj.FrameRate*vid_obj.Duration); % The number of frames in the video
else
    numbervideoframes = size(videoname,3);
end

framemeans = zeros(numbervideoframes,1);

% The main program loop - here we get the mean pixel value for all the
% frames
blinkprog = waitbar(0,'Getting Frame Means');
oldposition = get(blinkprog,'Position');
newstartindex = round(oldposition(1) + (oldposition(3) / 2));
newposition = [newstartindex (oldposition(4) + 20) ...
    oldposition(3) oldposition(4)];
set(blinkprog,'Position',newposition);

vidObject = VideoReader(videoname);
for framecounter = 1:numbervideoframes
    if processfullvideo        
        frametoread = double(readFrame(vidObject));
    else
        frametoread = videoname(:,:,framecounter);
    end

    framemeans(framecounter) = mean(frametoread(:));

    prog = framecounter / numbervideoframes;
    waitbar(prog,blinkprog);
end

close(blinkprog);

% The basic logic of the program is too find where the difference in mean pixel value of two adjacent frames dips below the threshold (this is where a blink
% starts) and the find where the difference rises above the threshold (this is wher the blink ends). However we have got two problems - sometimes
% (alright most of the the time) the blink starts/ends in midframe so for two continuous frames, the difference in mean pixel level cross the
% threshold. Second it is very likely that the first/last frame in the video is a blink, if this occurs there will be a mismatch in the number
% of frames that are below/above the threshold. These must be caught and dealt with. Now we try to reduce the number of iterations in a for loop
% by using diff to find where exactly in the frame mean array do increase and decreases occur and then concetrate only on these locations.

diffinmeans = diff([framemeans(1);framemeans(:)]);
possibleblinkstartframenumbers = find(diffinmeans <= (-1.0 * blinkthreshold));
possibleblinkendframenumbers = find(diffinmeans >= blinkthreshold);

if (~isempty(possibleblinkstartframenumbers)) && (~isempty(possibleblinkendframenumbers))
% Now this should get the frame numbers where there is a sudden dip in mean luminance and where the luminance picks up again. These ranges should
% straddle the blinks inthe video. However sometimes the blink starts/ends midframe so there are two frames ar returned by the procedure so we need
% to take care of that.

    blinkstartframenumbers = [];
    blinkendframenumbers = [];

% First take care of the instance of a video starting with a blink. This would mean there is a increase in mean pixel level early in the video but no corresponding
% decrease before it
    if possibleblinkendframenumbers(1) < possibleblinkstartframenumbers(1)
        blinkstartframenumbers = [1];
        blinkendframenumbers = [possibleblinkendframenumbers(1)];
    end

% Similarly if a video ends in a blink there is a decrease in pixel mean with no corresponding increase
    if possibleblinkendframenumbers(end) < possibleblinkstartframenumbers(end)
        blinkstartframenumbers = [blinkstartframenumbers;possibleblinkstartframenumbers(end)];
        blinkendframenumbers = [blinkendframenumbers;numbervideoframes];
    end

% Now that we taken care of the beginning and end of the video, we can go thorugh the frame means and load the blink start and end frames in to the respective frames.
    for framecounter = 1:length(possibleblinkstartframenumbers)
        currentnumber = possibleblinkstartframenumbers(framecounter);
% Check if the currentstart frame is already loaded, or if the current frame is close to a number already loaded. Sometimes a blink starts in midframe so two frames show
% a decrease in mean pixel level

        tempdifference = abs(blinkstartframenumbers - currentnumber);
        if ~isempty(find(tempdifference <= 1)) %#ok<EFIND>
            continue;
        end

% Now get the closest increase in mean pixel level that is greater than the current frame, there should be atleast 2 frames but no more than 6 frames infront of the current frame.
        tempdifference = possibleblinkendframenumbers - currentnumber;
        tempindices = find((tempdifference >= 2) & (tempdifference <= 6));
        if isempty(tempindices)
            continue;
        else
            blinkstartframenumbers = [blinkstartframenumbers;currentnumber];
            blinkendframenumbers = [blinkendframenumbers;...
                possibleblinkendframenumbers(max(tempindices(:)))];
        end
    end
    blinkframes = [];
    for framecounter = 1:length(blinkstartframenumbers);
        startframe = blinkstartframenumbers(framecounter);
        endframe = blinkendframenumbers(framecounter);

        blinkframes = [blinkframes;[startframe:endframe]'];
    end
else
    blinkframes = [];
end


reallybadframes = find(framemeans <= minframemean); % These are frames whose mean
% pixel value is just too low for any worth while analysis to be made.

blinkframes = union(blinkframes,reallybadframes(:));

if ~isempty(blinkframes)
    % Since the blink could start well before the mean pixel level starts to drop we need to mark adjacent frames just to be on the safe side.

    numblinkframes = length(blinkframes);
    blinkframes = repmat([-1:1],numblinkframes,1) + repmat(blinkframes,1,3);
    blinkframes = blinkframes(:);
    blinkframes = sort(unique(min(max(blinkframes,1),numbervideoframes)));

    framesafterblinks = blinkframes([find(diff(blinkframes) > 1);end]) + 1;
else
    framesafterblinks = [];
end

if verbose
    figure;
    subplot(2,1,1);
    plot(framemeans);
    hold on;
    plot(blinkframes,framemeans(blinkframes),'r*')
    hold off;
    title('Mean Pixel Level');
    subplot(2,1,2);
    plot(diffinmeans);
    hold on;
    plot(zeros(numbervideoframes,1) + blinkthreshold,'k');
    plot(zeros(numbervideoframes,1) - blinkthreshold,'k');
    plot(blinkframes,diffinmeans(blinkframes),'r*')
    hold off;
    title('Difference in Mean Pixel Level');
end

if processfullvideo
    videoname_check = avifilename;

    matfilename = strcat(videoname(1:end-4),'_blinkframes.mat');
    save(matfilename,'videoname_check','blinkframes','framesafterblinks',...
        'blinkthreshold','framemeans','minframemean');
end


%--------------------------------------------------------------------------
function [fullvideoname,videofilename,videopath] = getvideoname()

[videofilename,videopath] = uigetfile('*.avi','Please enter filename of video to analyse');
if videofilename == 0
    disp('No video to filter,stoping program');
    error('Type ''help getblinkframes'' for usage');
end
fullvideoname = strcat(videopath,videofilename);
%--------------------------------------------------------------------------