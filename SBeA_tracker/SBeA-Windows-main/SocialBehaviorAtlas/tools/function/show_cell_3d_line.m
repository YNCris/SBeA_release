function show_cell_3d_line(data,clr,lw)
x_s = data(:,1);
x_e = data(:,2);
y_s = data(:,3);
y_e = data(:,4);
z_s = data(:,5);
z_e = data(:,6);

for k = 1:size(x_s,1)
    plot3([x_s(k),x_e(k)],...
        [y_s(k),y_e(k)],...
        [z_s(k),z_e(k)],'-','Color',clr,'LineWidth',lw);
    hold on
end
hold off
grid on