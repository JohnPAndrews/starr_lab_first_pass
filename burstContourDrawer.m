function burstContourDrawer()
[X,Y,Z] = hist3(; 
figure;
contourf(X,Y,abs(zscore(Z)),3,...
    'LevelList',3)
hold on; 

[X,Y,Z] = peaks; 
figure;
contourf(X,Y,abs(zscore(Z)),10);
end