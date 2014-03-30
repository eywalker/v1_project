
for k = 1:16
plot(fft(eye(k+16)))
axis equal
axis([-1,1,-1,1]);
writeVideo(vidObj, getframe);
end
close(vidObj);