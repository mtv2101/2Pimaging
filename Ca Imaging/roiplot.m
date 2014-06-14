function roiplot(ALLDAYS, ALLBLOCKS, allblocks_parsed, odor1, odor2, beh1,...
    beh2, beh3, beh4)

roi = 31;
alpha = 0.01;
colors = [1 0 0; 1 0.5 0.2; 0, .8, 1; 0.2, 0.2, 0.2]; % for b1, b2, b3, b4
title_vector = {beh1, beh2, beh3, beh4, odor2};
alldat = [];
fields = fieldnames(allblocks_parsed);
hasdata = zeros(1,numel(fields));
for n = 1:numel(fields) % for each odor/bnehavior pair
    if size(allblocks_parsed.(fields{n}), 1) > 3 %only consider those with more than 3 trials
        hasdata(n) = 1;
    end
    alldat = cat(1, alldat, allblocks_parsed.(fields{n}));
end


%
% dat = [];
% for b = 1:length(ALLBLOCKS)
%     dat = cat(1, dat, ALLBLOCKS(b).dff(:,:,roi));
% end

% sig_tuned = zeros(1,size(ALLBLOCKS(b).tune_sigs(roi,:),2));
% sig_o1 = zeros(1,size(ALLBLOCKS(b).tune_sigs(roi,:),2));
% sig_o2 = zeros(1,size(ALLBLOCKS(b).tune_sigs(roi,:),2));
%     temp = ALLBLOCKS(b).tune_sigs(roi,:);
% sig_tuned(temp<alpha) = 1;
%     temp = ALLBLOCKS(b).o1response_sigs(roi,:);
% sig_o1(temp<alpha) = 1;
%     temp = ALLBLOCKS(b).o2response_sigs(roi,:);
% sig_o2(temp<alpha) = 1;
%
% t_chunks = ones(1,size(dat,2));
% tuned = t_chunks; o1_response = t_chunks; o2_response = t_chunks;
%     chunk = length(t_chunks)/size(sig_tuned,2);
%     if ~isint(chunk)
%         fprintf 'data chunk is not an interger factor of dff length, check data';
%         break
%     end
%     for n = 1:size(sig_tuned,2);
%         vec = [1:length(t_chunks)];
%         indx = vec(((n*chunk)-chunk+1):(n*chunk));
%         tuned(indx) = sig_tuned(n)*t_chunks(indx);
%         o1_response(indx) = sig_o1(n)*t_chunks(indx);
%         o2_response(indx) = sig_o2(n)*t_chunks(indx);
%     end



for n = 1:numel(fields)
    subplot(2,4,n)
    if hasdata(n) == 1;
        dat = allblocks_parsed.(fields{n});
        imagesc(dat(:,:,roi));colormap(redblue);
    end
    if n <= 4
        if n == 1
            ylabel(odor1)
        end
        title(title_vector{n});
    end
    if n == 5
        ylabel(odor2)
    end
end
suplabel(['ROI ' num2str(roi)], 't', [.1 .1 .84 .84]);
% subplot(2,4,1);
%     imagesc(dat); %colormap(c);
%
% subplot(2,4,2);
%     num_b(1)=sum(b1);num_b(2)=sum(b2);num_b(3)=sum(b3);num_b(4)=sum(b4);
%     bar(num_b', 'stacked');
%     colormap(colors);legend
% subplot(2,4,3);

% for n = 1:length(ALLBLOCKS)
%     shadedErrorBar([], b1_mean(:,n), b1_std/sqrt(size(allblock_b1,3)),...
%         {'color', colors(1,:)}, 1);hold on;
%     shadedErrorBar([], b2_mean(:,n), b2_std/sqrt(size(allblock_b2,3)),...
%         {'color', colors(2,:)}, 1);hold on;
%     shadedErrorBar([], b3_mean(:,n), b3_std/sqrt(size(allblock_b3,3)),...
%         {'color', colors(3,:)}, 1);hold on;
%     shadedErrorBar([], b4_mean(:,n), b4_std/sqrt(size(allblock_b4,3)),...
%         {'color', colors(4,:)}, 1);hold on;
%     hlegend = legend('HIT',  'CR', 'FA', 'MISS');
%         hkids = get(hlegend,'Children');    %# Get the legend children
%         htext = hkids(strcmp(get(hkids,'Type'),'text')); %# Select the legend children of type 'text'
%         set(htext,{'Color'},{colors(4,:); colors(3,:); colors(2,:); colors(1,:)});
% end
end

function [c] = redblue
%figure(h);
m=256;
n = fix(0.5*m);
r = [(0:1:n-1)/n,ones(1,n)];
g = [(0:n-1)/n, (n-1:-1:0)/n];
b = [ones(1,n),(n-1:-1:0)/n];
c = [r(:), g(:), b(:)];
%colormap(c);
end

