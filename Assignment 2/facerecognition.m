% loading the Face data
load('FaceData.mat');

% I = FaceData(39,3).Image;
% x = I(:);
% xy = FaceData(39,:);


%% Creating training and testing datasets
% 20 subjects each for training and testing.

training = FaceData(1:20,:);
testing = FaceData(21:40,:);

% Initializing the datasets with the appropriate dimensions. 
[Xtr, ~] = extract_dataset(training, 0);
[Xte, id] = extract_dataset(testing, 1);


%% Computing the Mean, Covariance matrices, Eigenvectors and Eigenvalues.
% test_matrix = [1 2 3; 7 8 6; 3 9 6];
sample_mean = mean(Xtr,2);
X0 = Xtr - sample_mean;

% covariance of the transpose matrix, since the `cov` function takes rows
% as observations (subjects) and not the columns. 
C = cov(X0');

% Computing the Eigenvectors/values and then sorting in desc order.
[V, D] = eig(C);
[d, ind] = sort(diag(D),'descend');
eigenvalues = diag(D(ind,ind));
PC = V(:,ind);


%% Plotting the contribution of the `m` largest Eigenvalues
m = (10:10:100);
total = sum(eigenvalues);
v_m = zeros(size(m));

for i=1:size(m,2)
    subset = sum(eigenvalues(1:m(i)));
    v_m(i) = subset;
end

plot(m, v_m)
exportgraphics(gcf,'images/vplot.png','Resolution',100);


%% Working with Eigenfaces and printing them
m = 10;
Phi = PC(:, 1:m);
mean_face = reshape(sample_mean, 56, 46);
plot_eigenfaces(mean_face, 'images/mean_face.png', 55);
% mean_face = uint8(mean_face * 255);

for k=1:m
    face = reshape(Phi(:,k), 56,46);
    filename = strcat(strcat('images/eigenface_',int2str(k)),'.png');
    plot_eigenfaces(face, filename, 55);
end


%% Computing the dissimilarity scores
m_values = 10:10:100;
% m_values = 10:10:10;
for k=1:size(m_values,2)
    m = m_values(k);
    fprintf("m = %d\n", m);
    Phi_m = PC(:, 1:m);
    a = zeros(m, size(Xte,2));
    for i=1:size(Xte,2)
        a(:,i) = Phi_m'*(Xte(:,i) - sample_mean);
    end
    dissimilarity_matrix = pdist2(a',a'); % default is euclidean
    [genuine, imposter] = extract_genuine_imposter_score(dissimilarity_matrix, id);
    [fmr, tmr] = calculate_match_rates(genuine, imposter, m);
end


%% Function definitions
function [result_dataset,id] = extract_dataset(dataset, if_testing)
    count = 1;
    id = zeros(1,size(dataset,2));
    result_dataset = zeros(2576, 200);
    for row=1:size(dataset,1)
        for col=1:size(dataset,2)
            I = dataset(row,col).Image;
            I = double(I)/255;
            x = I(:);
            result_dataset(:,count) = x;
            if if_testing == 1
                id(count) = row;
            end
            count = count+1;
        end     
    end
end

function [] = plot_eigenfaces(face, filename, resolution)
    figure, imagesc(face)
    set(gca,'XTick',[]) % Remove the ticks in the x axis!
    set(gca,'YTick',[]) % Remove the ticks in the y axis
    set(gca,'Position',[0 0 1 1]) % Make the axes occupy the hole figure
    exportgraphics(gcf,filename,'Resolution', resolution);
end  
    
function[genuine, imposter] = extract_genuine_imposter_score(dissimilarity_scores, Id)
    S = dissimilarity_scores;
%     max_value = max(dissimilarity_scores(:));
%     S = max_value - dissimilarity_scores;
    [np, nt] = size(S);
    genuine = zeros(1, np*nt);
    imposter = zeros(1, np*nt);
    genuine_count = 1;
    imposter_count = 1;
    for i=1:np
        j=1;
        while j<i
            if Id(i)==Id(j)
                genuine(genuine_count) = S(i,j);
                genuine_count = genuine_count + 1;
            else
                imposter(imposter_count) = S(i,j);
                imposter_count = imposter_count + 1;
            end
            j=j+1;
        end
    end
    genuine = genuine(1:genuine_count-1);
    imposter = imposter(1:imposter_count-1);
    
    
%     figure();
%     bins=350; 
%     histogram(genuine, bins, 'Facecolor', 'b', 'Normalization', 'probability', 'EdgeColor', 'none');
%     hold on;
%     histogram(imposter, bins, 'Facecolor', 'r', 'Normalization', 'probability', 'EdgeColor', 'none'); 
%     hold off;
%     title(strcat('Genuine and Imposter score histogram, Binsize:', int2str(bins)));
%     legend('Genuine scores', 'Imposter scores', 'Location', 'southwest');
%     xlabel('Scores');
%     ylabel('Probability');
end
    
function [false_match_rate, true_match_rate] = calculate_match_rates(genuine_scores, imposter_scores, m_val)
%     [genuine_scores, imposter_scores] = extract_genuine_imposter_scores;
    
    genuine_scores_sorted = sort(int32(genuine_scores), 'ascend');
    imposter_scores_sorted = sort(int32(imposter_scores), 'ascend');
    
    minimum_threshold = floor(min(genuine_scores));
    maximum_threshold = ceil(max(imposter_scores));
    
    total_number_of_scores = abs(maximum_threshold - minimum_threshold) + 1;
    
    false_match_rate = zeros(1, total_number_of_scores);
    true_match_rate = zeros(1, total_number_of_scores);
     threshold = 0;
     for j = 1:size(false_match_rate,2)
         count=0;
         for i = 1:size(imposter_scores_sorted, 2)
             value = imposter_scores_sorted(1, i);
             if value <= threshold
                 count = count+1;
             end
         end
         false_match_rate(threshold+1) = count/size(imposter_scores_sorted, 2);
         count=0;
         for i = 1:size(genuine_scores_sorted, 2)
             value = genuine_scores_sorted(1, i);
             if value <= threshold
                 count = count+1;
             end
         end
         true_match_rate(threshold+1) = count/size(genuine_scores_sorted, 2);
         threshold = threshold + 1;
     end
    
%     max_value = maximum_threshold;
%     for i = 1:size(imposter_scores_sorted, 2)
%         threshold = imposter_scores_sorted(1, i);
%         if threshold < max_value
%             false_match_rate(maximum_threshold - max_value + 1: maximum_threshold - threshold + 1) = (i-1)/size(imposter_scores_sorted, 2);
%             max_value = threshold;
%         end
%     end
%     false_match_rate(maximum_threshold - max_value + 1 : end)= 1;
     %disp(false_match_rate);
%     
%     max_value = maximum_threshold;
%     for i = 1:size(genuine_scores_sorted, 2)
%         threshold = genuine_scores_sorted(1, i);
%         if threshold < max_value
%             true_match_rate(maximum_threshold - max_value + 1: maximum_threshold - threshold + 1) = (i-1)/size(genuine_scores_sorted, 2);
%             max_value = threshold;
%         end
%     end
%     true_match_rate(maximum_threshold - max_value + 1 : end)= 1;
%     true_match_rate = true_match_rate(1:total_number_of_scores);
     %disp(true_match_rate);
%     
    
%     frpintf("%0.4f", eer);
    % FMR vs FNMR curve , plotting both on the same curve
    false_non_match_rate = 1 - true_match_rate;
%     eers = abs(false_match_rate - false_non_match_rate);
%     eer_pos = find(eers == min(eers));
%     eer = 0.5* (false_match_rate(eer_pos) + false_non_match_rate(eer_pos));
%     fprintf("EER = %0.4f\n", eer);
%     eer_coords = find(false_non_match_rate - false_match_rate < eps, 1) ;
    figure()
    x = 0:0.1:1;
    y = x;
    [x(i), y(i)] = polyxpoly(x, y, false_non_match_rate, false_match_rate);
    hold on;
    plot(false_match_rate, false_non_match_rate);
%     plot(false_match_rate(eer_coords), false_non_match_rate(eer_coords), 'b.' , 'MarkerSize', 18);
    plot(x(i), y(i),'b.' , 'MarkerSize', 18);
    plot(x, y, '--');
    hold off;
%     legend('FMR vs FNMR', 'EER line', 'Location', 'southwest');
    graph_title = strcat('DET curve for m=',int2str(m_val));
    title(graph_title);
    xlabel('False match rate');
    ylabel('False non-match rate');
    filename = strcat(strcat('images/performance_plots/DET_plots/DET_', int2str(m_val)),'.png');
    exportgraphics(gcf,filename,'Resolution', 55);
    
    figure();
    hold on;
    plot(minimum_threshold:1:maximum_threshold, false_match_rate);
    plot(minimum_threshold:1:maximum_threshold, 1 - true_match_rate);
    hold off
    legend('FMR', 'FNMR', 'Location', 'southwest');
    title('False Match Rates and False Non-Match rates');
    xlabel('Threshold value');
    ylabel('Score percentage');
    filename = strcat(strcat('images/performance_plots/FMR_FNMR_plots/FMR_FNMR_', int2str(m_val)),'.png');
    exportgraphics(gcf,filename,'Resolution', 55);
    
    % ROC - FMR vs TMR normal scale
    figure();
    plot(false_match_rate, true_match_rate);
    title('Receiver Operating Characteristic curve');
    xlabel('False Match Rate');
    ylabel('True Match Rate');
    filename = strcat(strcat('images/performance_plots/ROC_plots/ROC_', int2str(m_val)),'.png');
    exportgraphics(gcf,filename,'Resolution', 55);
    
end
















