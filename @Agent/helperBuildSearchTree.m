function searchNode = helperBuildSearchTree(obj, map, neighbours)
%HELPERBUILDSEARCHTREE 
    
    rrt = RRT(obj, map, neighbours);
    searchNode = rrt.search();
    rrt.show();
end
