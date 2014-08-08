j=1;
for n = 1:size(allpuncta,2)
    for i = 1:size(allpuncta(n).puncta,2)
        for z = 2:size(allpuncta(n).puncta(i).x,2)
            xtrajstart = allpuncta(n).puncta(i).x(z-1);
            xtrajend = allpuncta(n).puncta(i).x(z);
            lenx = xtrajstart-xtrajend;
            ytrajstart = allpuncta(n).puncta(i).y(z-1);
            ytrajend = allpuncta(n).puncta(i).y(z);
            leny = ytrajstart-ytrajend;
            length(j) = sqrt((lenx^2)+(leny^2));
            j = j+1;
        end
    end
end

ecdf(length);