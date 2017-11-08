        function Kole_Vishal_play()
        %% video device initialization
        video_device = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
            'ROI', [1 1 640 480], ...
            'ReturnedColorSpace', 'rgb');

        video_info = imaqhwinfo(video_device); % Acquire input video property
        Videoin_object = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
            'Position', [100 100 video_info.MaxWidth+20 video_info.MaxHeight+30]);
        nFrame = 0; % Frame number initialization

        %%

        iterator = 400;

        fileID = fopen('centroids.txt','w');

        [y , f]=audioread('../drum sounds/short-kick-808.wav');
        ba = audioplayer(y,f);
        [y , f]=audioread('../drum sounds/short-crash-acoustic.wav');
        tiss = audioplayer(y,f);

        pauses = 0.3;

        Qg = zeros(10,1);
        Qr = zeros(10,1);
        
        %%loop to compute on each frame
        while(nFrame < iterator)
            rgbFrame = (step(video_device)); % Acquire single frame

            diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
            diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
            binary_green = imbinarize(diffFrameGreen, 0.06); % Convert the image into binary image with the green objects as white

            diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
            diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
            binary_red = imbinarize(diffFrameRed, 0.15); % Convert the image into binary image with the green objects as white

            %binary_erode = binFrameGreen;

            %% red blob calculation and detection
            stick_centroid_red = regionprops(binary_red,'centroid','Area');
            rr = size(stick_centroid_red);
            centroids_red = zeros(1,2);

            for hh = 1 : rr(1)
                if  stick_centroid_red(hh).Area > 100
                    centroids_red = stick_centroid_red(hh).Centroid;

                end
            end

            %this is the blob centroid calculation
            dimmr = size(Qr)-1;
            for index =1 : dimmr(1)-1
                Qr(index) = Qr(index+1);
            end
            Qr(dimmr(1))= centroids_red(1,2);

            %playing the sound
            if ((Qr(1)-Qr(dimmr(1))) > 100 ) && ( Qr(dimmr(1))<Qr(dimmr(1)-1) ) % change in direction
                if( centroids_red(1,1) <300 )&& ( centroids_red(1,1) >10 )
                    play(ba);
                    %                         disp(centroids_red(1,1));
                    %                         disp(centroids_red(1,2));
                    %                         disp('ba');
                elseif ( centroids_red(1,1) >300 )&& ( centroids_red(1,1) <630 )
                    play(tiss);
                    %                         disp(centroids_red(1,1));
                    %                         disp(centroids_red(1,2));
                    %                         disp('tiss');
                end
            end



            %% green blob detection and calculation
            stick_centroid_green = regionprops(binary_green,'centroid','Area');



            ee = size(stick_centroid_green);

            centroids_green = zeros(1,2);


            for ff = 1 : ee(1)
                if  stick_centroid_green(ff).Area > 100
                    centroids_green = stick_centroid_green(ff).Centroid;

                end
            end
            %this is the blob centroid calculation

            dimm = size(Qg)-1;
            for index =1 : dimm(1)-1
                Qg(index) = Qg(index+1);
            end

            Qg(dimm(1))= centroids_green(1,2);
            %playing the sound

            if ((Qg(1)-Qg(dimm(1))) > 150 ) && ( Qg(dimm(1))<Qg(dimm(1)-1) ) % change in direction
                if( centroids_green(1,1) <300 )&& ( centroids_green(1,1) >10 )
                    play(ba);
                    %                         disp(centroids_green(1,1));
                    %                         disp(centroids_green(1,2));
                    %                         disp('ba');
                elseif ( centroids_green(1,1) >300 )&& ( centroids_green(1,1) <630 )
                    play(tiss);
                    %                         disp(centroids_green(1,1));
                    %                         disp(centroids_green(1,2));
                    %                         disp('tiss');
                end
            end

            %%storing the output values for analysis
            imshow(binary_red);

            fprintf(fileID,'%f %f\n',[centroids_green(1,2), centroids_green(1,1)]);

            dlmwrite('Location.txt',Qg,'-append', 'delimiter',' ','roffset',1);

            step(Videoin_object, (binary_green)); % Output video stream
            nFrame = nFrame+1;
        end

        %% Clearing Memory and releasing the video objects
        fclose(fileID);
        release(Videoin_object); % Release all memory and buffer used
        release(video_device);

        end


