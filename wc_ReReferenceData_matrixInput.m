

function [ecog_preprocessReref,lfp_preprocessReref] = wc_ReReferenceData_matrixInput(ecog,lfp,ref_method,bad,name)
    
% common average or common median re-ref
if ref_method <2 
    length_CAR = size(ecog,1);

    % exclude bad chan
    good = setdiff(1:size(ecog,1), bad);
    
    % define common reference
    if ref_method == 0 %  use common  mean
        ref=nanmean(ecog(good,:));
    elseif ref_method ==1 % use common median 
        ref=nanmedian(ecog(good,:));
    end
    
    % subtract common reference
    for i = 1:length_CAR
        if ~isempty(ecog(i,:) & sum(ecog(i,:)~=0))
            ecog_preprocessReref(i,:)= ecog(i,:)-ref;
        end
    end
end

% bipolar re-ref ecog
if ref_method == 2
    for i = 1:(size(ecog,1)-1)
        if ~isempty(ecog(i,:)) & ~isempty(ecog(i+1,:))
            ecog_preprocessReref= ecog(i,:)-ecog(i+1,:);
        end
    end
end

% bipolar re-ref lfp
if ~isempty(lfp)
    for i = 1:size(lfp,1)-1
        lfp_preprocessReref(i,:)=lfp(i,:)-lfp(i+1,:);
    end
else
    lfp_preprocessReref=[];
end

