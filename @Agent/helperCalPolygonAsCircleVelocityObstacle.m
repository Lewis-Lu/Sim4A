function vo = helperCalPolygonAsCircleVelocityObstacle(obj, that, method)
            %helperCalPolygonAsCircleVelocityObstacle
            that.radius = sqrt(that.width^2+that.height^2);
            that.type = 'circle';
            vo = obj.helperCalVelocityObstacle(that, method);
end