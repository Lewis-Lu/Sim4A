#include "mex.h"

#ifndef RVO_OUTPUT_TIME_AND_POSITIONS
#define RVO_OUTPUT_TIME_AND_POSITIONS 0
#endif

#ifndef RVO_SEED_RANDOM_NUMBER_GENERATOR
#define RVO_SEED_RANDOM_NUMBER_GENERATOR 1
#endif

#include <cmath>
#include <cstdlib>

#include <vector>

#if RVO_OUTPUT_TIME_AND_POSITIONS
#include <iostream>
#endif

#if RVO_SEED_RANDOM_NUMBER_GENERATOR
#include <ctime>
#endif

#if _OPENMP
#include <omp.h>
#endif

#include <RVO.h>

#ifndef M_PI
const float M_PI = 3.14159265358979323846f;
#endif
// goals
std::vector<RVO::Vector2> goals;
// agents
std::vector<RVO::Vector2> agents;
// obstacles
std::vector<std::vector<RVO::Vector2> > obstacles;

void setupAgents(RVO::RVOSimulator *sim)
{
    int nAgent = agents.size();
	for (size_t i = 0; i < nAgent; i++)
	{
		sim->addAgent(agents[i]);
	}
}

void setupObstacles(RVO::RVOSimulator *sim)
{
	int nObs = obstacles.size();
	for (size_t i = 0; i < nObs; i++)
	{
		sim->addObstacle(obstacles[i]);
	}
	sim->processObstacles();
}

void setupScenarioMex(RVO::RVOSimulator *sim)
{
	/* Specify the global time step of the simulation. */
	sim->setTimeStep(0.25f);

	/* Specify the default parameters for agents that are subsequently added. */
	sim->setAgentDefaults(15.0f, 10, 5.0f, 5.0f, 2.0f, 2.0f);

	setupAgents(sim);

	setupObstacles(sim);
}

#if RVO_OUTPUT_TIME_AND_POSITIONS
void updateVisualization(RVO::RVOSimulator *sim)
{
	/* Output the current global time. */
	std::cout << sim->getGlobalTime();

	/* Output the current position of all the agents. */
	for (size_t i = 0; i < sim->getNumAgents(); ++i) {
		std::cout << " " << sim->getAgentPosition(i);
	}

	std::cout << std::endl;
}
#endif

// store the timestep and trajectory
std::vector<float> timeStep;
std::vector<std::vector<RVO::Vector2>> traj;

void mexGetData(RVO::RVOSimulator *sim)
{
	timeStep.push_back(sim->getGlobalTime());
	std::vector<RVO::Vector2> tmp;
	for (size_t i = 0; i < sim->getNumAgents(); i++)
	{
		tmp.push_back(sim->getAgentPosition(i));
	}
	traj.push_back(tmp);
}

void setPreferredVelocities(RVO::RVOSimulator *sim)
{
	/*
	 * Set the preferred velocity to be a vector of unit magnitude (speed) in the
	 * direction of the goal.
	 */
#ifdef _OPENMP
#pragma omp parallel for
#endif
	for (int i = 0; i < static_cast<int>(sim->getNumAgents()); ++i) {
		RVO::Vector2 goalVector = goals[i] - sim->getAgentPosition(i);

		if (RVO::absSq(goalVector) > 1.0f) {
			goalVector = RVO::normalize(goalVector);
		}

		sim->setAgentPrefVelocity(i, goalVector);

		/*
		 * Perturb a little to avoid deadlocks due to perfect symmetry.
		 */
		float angle = std::rand() * 2.0f * M_PI / RAND_MAX;
		float dist = std::rand() * 0.0001f / RAND_MAX;

		sim->setAgentPrefVelocity(i, sim->getAgentPrefVelocity(i) +
		                          dist * RVO::Vector2(std::cos(angle), std::sin(angle)));
	}
}

bool reachedGoal(RVO::RVOSimulator *sim)
{
	/* Check if all agents have reached their goals. */
	for (size_t i = 0; i < sim->getNumAgents(); ++i) {
		if (RVO::absSq(sim->getAgentPosition(i) - goals[i]) > 4.0f * 4.0f) {
			return false;
		}
	}
	return true;
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    mexPrintf("mexFunction begins\n");
	
	// Right hand processing
	// prhs[0]
    double* posAgents = mxGetPr(prhs[0]);
    int posAgentsM = mxGetM(prhs[0]);
    int posAgentsN = mxGetN(prhs[0]);
    if (posAgentsM > 4 || posAgentsM == 1)
    {
        mexErrMsgTxt("Agent dimension error.");
    }    
    for (size_t i = 0; i < posAgentsN; i++)
    {
        agents.push_back(RVO::Vector2(posAgents[i*posAgentsM], posAgents[i*posAgentsM + 1]));
    }
	
    // prhs[1]
    double* posObstacles = mxGetPr(prhs[1]);
    int posObsM = mxGetM(prhs[1]);
    int posObsN = mxGetN(prhs[1]);
    for (size_t i = 0; i < posObsN; i++)
    {
        std::vector<RVO::Vector2> tmp;
        for (size_t j = 0; j < posObsM; j+=2)
        {
            tmp.push_back(RVO::Vector2(posObstacles[i*posObsM + j], posObstacles[i*posObsM + j + 1]));
        }
        obstacles.push_back(tmp);
    }
    
	// prhs[2]
	// initialize goals
	double* posGoals = mxGetPr(prhs[2]);
	int posGoalM = mxGetM(prhs[2]);
	int posGoalN = mxGetN(prhs[2]);
	if (posGoalM > 4 || posGoalM == 1)
	{
		mexErrMsgTxt("Goal dimension error.");
	}
	else if (posGoalN != posAgentsN)
	{
		mexErrMsgTxt("Goal quantity error (should be equal with agents').");
	}
	for (size_t i = 0; i < posGoalN; i++)
	{
		goals.push_back(RVO::Vector2(posGoals[i*posGoalM], posGoals[i*posGoalM + 1]));	
	}
	
	// simulation

    RVO::RVOSimulator *sim = new RVO::RVOSimulator();
    setupScenarioMex(sim);
    do {

#if RVO_OUTPUT_TIME_AND_POSITIONS
		// output information on command line
		updateVisualization(sim); 
#endif
		mexGetData(sim);
		setPreferredVelocities(sim);
		sim->doStep();
	}
	while (!reachedGoal(sim));

	// add left-hand processing
	int mTime = timeStep.size();
	plhs[0] = mxCreateDoubleMatrix(1 , mTime, mxREAL);
	double *outTime = mxGetPr(plhs[0]);
	for (size_t i = 0; i < mTime; i++)
	{
		outTime[i] = timeStep[i];
	}

	int nIter = traj.size();
	int nAgent = traj[0].size();
	plhs[1] = mxCreateDoubleMatrix(nAgent*2, nIter, mxREAL);
	double *outTraj = mxGetPr(plhs[1]);
	for (size_t i = 0; i < nIter; i++)
	{
		std::vector<RVO::Vector2> tmp = traj[i];
		std::vector<float> coordCache;
		for (size_t j = 0; j < tmp.size(); j++)
		{
			coordCache.push_back(tmp[j].x_);
			coordCache.push_back(tmp[j].y_);
		}
		
		for (size_t k = 0; k < coordCache.size(); k++)
		{
			outTraj[i*nAgent*2 + k] = coordCache[k];
		}
	}
	
	plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
	double *outRadius = mxGetPr(plhs[2]);
	outRadius[0] = sim->getAgentRadius(0);
	
    delete sim;

	mexPrintf("mexFunction ended\n");
}