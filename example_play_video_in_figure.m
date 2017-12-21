v = VideoReader('/Users/roee/Starr_Lab_Folder/Data_Analysis/1_tremor_visit/data/vids/MVI_0102.MP4');

% Create an axes. Then, read video frames until no more frames are available to read.
hfig; 

currAxes = axes;
while hasFrame(v)
    vidFrame = readFrame(v);
    image(vidFrame, 'Parent', currAxes);
    currAxes.Visible = 'off';
    pause(1/v.FrameRate);
end
