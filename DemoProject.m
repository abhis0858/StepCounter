% Connect to device
m = mobiledev;

%input for time interval
prompt = 'Enter pause value: ';
x = input(prompt);


% Enable Sensors
m.AccelerationSensorEnabled=1;
m.PositionSensorEnabled=1;


% start logging
m.Logging=1; 


% Walk around.
% Changes in Acceleration Sensors will indicate steps
arr = ['Now, Walk for ',num2str(x),' seconds'];
disp(arr)
pause(x)


%storing data from sensors
[a, t] = accellog(m);
[lat, lon, t1, speed] = poslog(m);

% Stop Acquiring Data & Disable Sensor
m.Logging=0;
m.AccelerationSensorEnabled=0;
m.PositionSensorEnabled = 0;

%average speed
avspeed=sum(speed)/length(speed);

%move time or last recorded time
lrtime=t(length(t));

%distance
distance=avspeed*lrtime;


%extracting scalar value along X-Y-Z direction from acceleration data
x = a(:,1);
y = a(:,2);
z = a(:,3);

%calculating magnitude of acceleration
mag = sqrt(sum(x.^2 + y.^2 + z.^2, 2));


%emove gravity vector
magNoGrav = mag - mean(mag);


%plotting
subplot(3,1,1);
stem(t, magNoGrav);
xlabel('Time (in seconds)-->');
ylabel('Acceleration (in m/s^2)');
title('Net Acceleration (Without gravity)');
%Absolute Acceleration
amag = abs(magNoGrav);
subplot(3,1,2);
plot(t, amag);
title('Absolute Magnitude (Continuous)')
xlabel('Time (in seconds)-->');
ylabel('Acceleration (in m/s^2)');

%Multiplication Factor
mf = 1.3;
i = 1;
peaks = [];
peakstime = [];

%creating a minimum required acceleration variable to ensure that the peak
%acceleration is high enough for considering it as a step.
minreq = 3.2;

for k = 5:length(amag)-4
    
    if (amag(k) > minreq) && ...
       (amag(k) > mf*amag(k-4)) && ...
       (amag(k) > mf*amag(k+4)) && ...
       (amag(k) > amag(k-1)) &&...
       (amag(k) > amag(k+1))
   
            peaks(i) = amag(k);
            peakstime(i) = t(k);
            i = i + 1;
    end
end


if isempty(peaks)
    disp('No Steps')
    return
end

nSteps = length(peaks);
disp('Number of Steps:')
disp(nSteps)

disp('Total Distance (in m):')
disp(distance);
disp('Average Speed (in m/s):')
disp(avspeed);
disp('Move Time (in s)')
disp(lrtime);


% Plotting markers at peaks
hold on;
plot(peakstime, peaks, 'r', 'Marker', 'v', 'LineStyle', 'none');
hold off;

subplot(3,1,3);
stem(t, amag);
title('Absolute Magnitude (Discrete)')
xlabel('Time (in seconds)-->');
ylabel('Acc without gravity vector(m/s^2)');

hold on;
plot(peakstime, peaks, 'r', 'Marker', 'v', 'LineStyle', 'none');
hold off;

figure; 
plot(lon,lat,'Marker','O');
title('Latitude v/s Longitude');
ylabel('Latitude -->');
xlabel('Longitude -->');

% Clean up
clear m