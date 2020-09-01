
function allVO = calVO(obj, nnp, patMethod, nno, obsMethod, nnpoly, polyMethod)
    % calculate velocity obstacle for every agent
    % we did not use nargin method to deal with default inputs 

    allVO = [];
    if ~isempty(nnp)
        for i = 1:size(nnp,2) 
            allVO = [allVO obj.helperCalVelocityObstacle(nnp(i), patMethod)];
        end
    end
    if ~isempty(nno)
        for i = 1:size(nno,2) 
            allVO = [allVO obj.helperCalVelocityObstacle(nno(i), obsMethod)];
        end
    end
    if ~isempty(nnpoly)
        for i = 1:size(nnpoly,2) 
            allVO = [allVO obj.helperCalVelocityObstacle(nnpoly(i), polyMethod)];
        end
    end
end