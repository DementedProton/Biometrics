function [S, Id] = get_score_from_file
    %
    % Loads score matrix and plots info.
    %
    S = load('scorematrix.txt', '-ascii');
    Id = load('id.txt', '-ascii');
    disp(Id);
    [np, nt] = size(S);
    nId = max(Id);
    %Entries = (1:np);

    fprintf(' Size of score matrix: %u x %u\n',np,nt);
    fprintf(' Number of identities: %u\n', nId);

    %figure(1); plot(Entries, Id); 
    %xlabel('Entry'); ylabel('Identity'); title('Mapping entry number to identity');

    %figure(2); imagesc(S); colormap('gray');
    %ylabel('test'); xlabel('reference'); title('Score matrix');
    
%     avg = int32(943)/int32(275);
%     disp(avg);
%     figure(3); histogram(Id,avg);
%     xlabel('Identities');title('Histogram plot');

end
% 
% function [] = extract_scores(Id)
%     reshape(Id,1,[]);
%     [GC,GR] = groupcounts(Id');
%     disp(GC);
% end


