j=1;
for n = 1:size(allpuncta,2)
    for i = 1:size(allpuncta(n).puncta,2)
        for z = 2:size(allpuncta(n).puncta(i).xy,1)
            trajstart = allpuncta(n).puncta(i).xy(z-1,:);
            trajend = allpuncta(n).puncta(i).xy(z,:);
            len = trajstart-trajend;
            length(j) = sqrt(len(1)^2+len(2)^2);
            j = j+1;
        end
    end
end