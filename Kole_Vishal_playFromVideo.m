        function Kole_Vishal_playFromVideo()
        %initialization of iterator
        currentFrame = 0; % Frame number initialization
        %file input name
        file_name = 'input.mp4';
        %opticFlow  = opticalFlowLK( 'NoiseThreshold',0.00000009);
        opticFlow  = opticalFlowLK('NoiseThreshold',0.05 );
        %video object
        vidObj = VideoReader(file_name);

        %%

        iterations = 200;
        %file to save calculations
        fileID = fopen('centroids.txt','w');
        %sound read
        [y , f]=audioread('../drum sounds/short-kick-808.wav');
        sound_one = audioplayer(y,f);
        [y , f]=audioread('../drum sounds/short-crash-acoustic.wav');
        sound_two = audioplayer(y,f);

        pauses = 0.3;
        %queue to store the flow of blob
        queue_for_green_blob = zeros(10,1);
        
        %%
        %iteration to loop and calculate
        while(currentFrame < iterations)
            rgbFrame = 	readFrame(vidObj);% read in a frame from the video
            %   figure(44),imagesc(rgbFrame);

            diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
            diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
            binary_green = imbinarize(diffFrameGreen, 0.06); % Convert the image into binary image with the green objects as white

            Green_area_size= 100;

            %%
            
            %erode and dilate here
            se = strel('disk',5);
            binary_green = imerode(binary_green,se);
            binary_green = imdilate(binary_green,se);


            %%
            %centroid calculation
            stick_centroid_green = regionprops(binary_green,'centroid','Area');
            dimension_centroids = size(stick_centroid_green);
            centroids_green = ones(1,2);

            %threshold for the centroid
            for index = 1 : dimension_centroids(1)
                if  stick_centroid_green(index).Area > Green_area_size
                    centroids_green = stick_centroid_green(index).Centroid;
                end
            end

            %adding to queue
            dimention_blob = size(queue_for_green_blob)-1;
            for index =1 : dimention_blob(1)-1
                queue_for_green_blob(index) = queue_for_green_blob(index+1);
            end
            queue_for_green_blob(dimention_blob(1))= centroids_green(1,2);
            blob_center_image = zeros(720,1280);
            
            %inserting shapr to detect center
            %just_point_img(floor(centroids_green(1,2)),floor(centroids_green(1,1)))=1;
            drum_circle_rgb = insertShape(blob_center_image,'FilledCircle',[centroids_green(1,1) centroids_green(1,2) 5],'Color','white');
            % figure(7),imagesc(drum_circle_rgb);

            %calculating the optical flow
            opticalflow_estimation = estimateFlow(opticFlow,drum_circle_rgb(:,:,1));

            figure(1),  plot(opticalflow_estimation,'DecimationFactor',[10 10],'ScaleFactor',90);
            figure(2),imshow(drum_circle_rgb);

            %  fprintf(fileID,'%f %f\n',[centroids_green(1,2), centroids_green(1,1)]);
            % dlmwrite('Location.txt',queue_for_green_blob,'-append', 'delimiter',' ','roffset',1);
            currentFrame = currentFrame+1;
        end

        %% Clearing Memory
        fclose(fileID);
        close all ;
        clc;
        end


