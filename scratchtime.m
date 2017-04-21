frame = ones(1000,1000,3) * 255;
for i = 1:200
    neighbors{i} = randperm(200, round(rand * 5) + 3);
end

time = zeros(2,10);

for i = 1:10
    i
    
    positions = rand(1000,4) * 1000;
    newFrame1 = frame;
    newFrame2 = frame;
    
    tic
    newFrame1 = insertShape(newFrame1,'Line',positions);
    time(1,i) = toc;
    
    tic
    for t = 1:10:1000
        newFrame2 = insertShape(newFrame2,'Line',positions(t:t+9,:));
    end
    time(2,i) = toc;
    
end
    
%%
mean(time(1,:))
std(time(1,:))

mean(time(2,:))
std(time(2,:))
