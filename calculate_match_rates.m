function [false_match_rate, true_match_rate] = calculate_match_rates
    [genuine_scores, imposter_scores] = extract_genuine_imposter_scores;
    
    genuine_scores_sorted = sort(int32(genuine_scores), 'descend')
    imposter_scores_sorted = sort(int32(imposter_scores), 'descend')
    
    minimum_threshold = floor(min(imposter_scores));
    maximum_threshold = ceil(max(genuine_scores));
    
    total_number_of_scores = abs(maximum_threshold - minimum_threshold) + 1;
    
    false_match_rate = zeros(1, total_number_of_scores);
    true_match_rate = zeros(1, total_number_of_scores);
    
    max_value = maximum_threshold;
    for i = 1:size(imposter_scores_sorted, 2)
        threshold = imposter_scores_sorted(1, i);
        if threshold < max_value
            false_match_rate(maximum_threshold - max_value + 1: maximum_threshold - threshold + 1) = (i-1)/size(imposter_scores_sorted, 2);
            max_value = threshold;
        end
    end
    false_match_rate(maximum_threshold - max_value + 1 : end)= 1;
    
    max_value = maximum_threshold;
    for i = 1:size(genuine_scores_sorted, 2)
        threshold = genuine_scores_sorted(1, i);
        if threshold < max_value
            true_match_rate(maximum_threshold - max_value + 1: maximum_threshold - threshold + 1) = (i-1)/size(genuine_scores_sorted, 2);
            max_value = threshold;
        end
    end
    true_match_rate(maximum_threshold - max_value + 1 : end)= 1;
    
    % FMR vs FNMR curve , plotting both on the same curve
    figure();
    hold on;
    plot(maximum_threshold:-1:minimum_threshold, false_match_rate);
    plot(maximum_threshold:-1:minimum_threshold, 1 - true_match_rate);
    hold off
    legend('FMR', 'FNMR', 'Location', 'southwest');
    title('False Match Rates and False Non-Match rates');
    xlabel('Threshold value');
    ylabel('Score percentage');
    
    % ROC - FMR vs TMR normal scale
    figure();
    plot(false_match_rate, true_match_rate);
    title('Receiver Operating Characteristic curve');
    xlabel('False Match Rate');
    ylabel('True Match Rate');
    
    % ROC - FMR vs TMR - log FMR 
    figure();
    plot(false_match_rate, true_match_rate);
    title('Receiver Operating Characteristic curve - Log FMR');
    set(gca, 'xscale', 'log');
    xlabel('False Match Rate');
    ylabel('True Match Rate');
    
    % DET - -FMR vs FNMR normal scale
    figure();
    plot(false_match_rate, 1 - true_match_rate);
    title('Decision Error Tradeoff Curve');
    xlabel('False Match Rate');
    ylabel('False Non-Match Rate');
    
    % DET - -FMR vs FNMR - log FMR
    figure();
    plot(false_match_rate, 1 - true_match_rate);
    set(gca, 'xscale', 'log');
    title('Decision Error Tradeoff Curve - Log FMR');
    xlabel('False Match Rate');
    ylabel('False Non-Match Rate');
    
    % DET - -FMR vs FNMR - log FNMR
    figure();
    plot(false_match_rate, 1 - true_match_rate);
    set(gca, 'yscale', 'log');
    title('Decision Error Tradeoff Curve - Log FNMR');
    xlabel('False Match Rate');
    ylabel('False Non-Match Rate');
    
    % DET - -FMR vs FNMR - log FMR and FNMR
    figure();
    plot(false_match_rate, 1 - true_match_rate);
    set(gca, 'xscale', 'log', 'yscale', 'log');
    title('Decision Error Tradeoff Curve - Log FMR and FNMR');
    xlabel('False Match Rate');
    ylabel('False Non-Match Rate');
    
end