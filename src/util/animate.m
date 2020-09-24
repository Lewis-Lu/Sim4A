function animate(CONFIG)
%     fps = 1/CONFIG.deltaT;
    fps = 10;
    startFrame = 1;
    endFrame = CONFIG.frame-1;
    % video handle
    aviobj = VideoWriter(CONFIG.videoName);
    aviobj.FrameRate = fps;
    % write video
    open(aviobj);
    for i = startFrame:endFrame
        frameName = ['im/' num2str(i) '.jpg'];
        frame = imread(frameName);
        writeVideo(aviobj, frame);
    end
    close(aviobj);
end