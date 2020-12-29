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
Xtr = extract_dataset(training, 0);
Xte = extract_dataset(testing, 1);


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
% plot_eigenfaces(mean_face, 'images/mean_face.png', 55);
% mean_face = uint8(mean_face * 255);

for k=1:m
    face = reshape(Phi(:,k), 56,46);
    filename = strcat(strcat('images/eigenface_',int2str(k)),'.png');
    % plot_eigenfaces(face, filename, 55);
end


%% Computing the dissimilarity scores
m = 90;
Phi_m = PC(:, 1:m);
a = zeros(m, size(Xte,2));
for i=1:size(Xte,2)
    a(:,i) = Phi_m'*(Xte(:,i) - sample_mean);
end
dissimilarity_matrix = pdist2(a',a'); % default is euclidean


%% Function definitions
function [result_dataset] = extract_dataset(dataset, if_testing)
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
    
    
    
















