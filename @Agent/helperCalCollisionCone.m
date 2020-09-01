function [ccLeftUpperBoundVertice, ccRightUpperBoundVertice, ccRightLowerBoundVertice, ccLeftLowerBoundVertice] = helperCalCollisionCone(obj, that, sigmaLength, leftSigma, rightSigma, alpha, tau)
    if nargin == 7
        tau_prime = tau;
    else
        tau_prime = obj.tau;
    end
    tauLength =  ((norm(obj.position - that.position) - obj.radius - that.radius)*cos(alpha))/tau_prime;
    ccLeftUpperBoundVertice  = [sigmaLength*cos(leftSigma),  sigmaLength*sin(leftSigma)];
    ccRightUpperBoundVertice = [sigmaLength*cos(rightSigma), sigmaLength*sin(rightSigma)];
    ccLeftLowerBoundVertice  = [tauLength*cos(leftSigma),    tauLength*sin(leftSigma)];
    ccRightLowerBoundVertice = [tauLength*cos(rightSigma),   tauLength*sin(rightSigma)];
end
