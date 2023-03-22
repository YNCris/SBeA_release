for k = 1:10000
    plot3(data(1:3:end,k),data(2:3:end,k),data(3:3:end,k),'r*');
    view(2)
    pause
end