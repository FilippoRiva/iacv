classdef utils
    methods ( Static = true)

        % this is assumed to take as input the struct declares in the lines.mat file, having this fields :
        %   - point1 : the first detected point
        %   - point2 : the second detected point
        %   - name : the name of the line (according to the assignment)
        %   - line : in homogeneous coordinates
        function plotLinesFromStruct(lines)
            for k = 1:length(lines)
                xy = [lines(k).point1; lines(k).point2];
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                x = (xy(1,1)+xy(2,1))/2;
                y = (xy(1,2)+xy(2,2))/2;
                text(x, y, lines(k).name, 'FontSize', 10, 'Color', 'blue');
            end
        end

    end
end