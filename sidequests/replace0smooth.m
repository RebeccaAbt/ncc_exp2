function data = replace0smooth(data)
% remove the zeros in the ECG signal; replace it with the man of the two
% neighbouring data points
for i = 1:size(data,1)
    for j = 1:size(data,2)
        if data(i,j) == 0
            v1 = data(i,j-1);
            v2 = 0;
            inx = 1;
            while v2 == 0 && (j+inx) < size(data,2)
                v2 = data(i,j+inx);
                inx = inx+1;
            end
            if v2 == 0
                v2 = v1;
            end
            data(i,j) = (v1+v2)/2;
        end
    end
end
end