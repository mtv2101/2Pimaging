function [length] = pathlengths(allpuncta)

j=1;
for n = 1:size(allpuncta,2)
    for i = 1:size(allpuncta(n).puncta,2)
        for k = 2:size(allpuncta(n).puncta(i).x,2)
            xtrajstart = allpuncta(n).puncta(i).x(k-1);
            xtrajend = allpuncta(n).puncta(i).x(k);
            lenx = xtrajstart-xtrajend;
            ytrajstart = allpuncta(n).puncta(i).y(k-1);
            ytrajend = allpuncta(n).puncta(i).y(k);
            leny = ytrajstart-ytrajend;
            length(j) = sqrt((lenx^2)+(leny^2));
            j = j+1;
        end
    end
end

%ecdf(length, 'bounds', 'on');

end