function[genuine, imposter] = extract_genuine_imposter_score
    [S, Id] = get_scores_from_file;
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

    figure();
    bins=350 
    histogram(genuine, bins, 'Facecolor', 'b', 'Normalization', 'probability', 'EdgeColor', 'none');
    hold on;
    histogram(imposter, bins, 'Facecolor', 'r', 'Normalization', 'probability', 'EdgeColor', 'none'); 
    hold off;
    title('Genuine and Imposter score histogram, Binsize:',bins);
    legend('Genuine scores', 'Imposter scores', 'Location', 'southwest');
    xlabel('Scores');
    ylabel('Probability');
end
                