function polyset = array2polyshape(array, numVertice)
    N = size(array,1)/numVertice;
    polyset = polyshape();
    for i = 1:N
        index = (i-1)*numVertice + 1;
        tmp = polyshape(array(index:index+numVertice-1,:));
        polyset = union(polyset, tmp);
    end
end