d=1;
clear meanx meany
for n = 1:length(condition(d).allpuncta)
    for i = 1:length(condition(d).allpuncta(n).trajectory)
        for k = 2:size(condition(d).allpuncta(n).trajectory(i).x,2)
            xtrajstart = condition(d).allpuncta(n).trajectory(i).x(k-1);
            xtrajend = condition(d).allpuncta(n).trajectory(i).x(k);
            lenx(k) = xtrajstart-xtrajend;
            ytrajstart = condition(d).allpuncta(n).trajectory(i).y(k-1);
            ytrajend = condition(d).allpuncta(n).trajectory(i).y(k);
            leny(k) = ytrajstart-ytrajend;
        end
        allx(i) = sum(lenx);
        ally(i) = sum(leny);
        clear leany leanx
    end
    meanx(n) = mean(allx);
    meany(n) = mean(ally);
    clear allx ally
end