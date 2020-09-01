# README

This framework supports multi-agent simulation in MATLAB using object-oriented fashion. This framework is now under conversion to C/C++ implementation for higher performance. Currently, agent adopts the basic collision avoidance maneuvers and cooperative algorithms. The framework also implements a CoppeliaSim remote API wrapper for simulation using physical engine.

Author:  [Lu, Hong](http://www.lewissoft.com)

For questions regarding the project, drop me by email at: luhong@westlake.edu or luh.lewis@gmail.com.
## Table of Contents

- [Structure](#structure)
  - [Map Initialization](#Map-Initialization)
  - [Outlier APIs wrapper](#Outlier-APIs-wrapper)
  - [Agent](#Agent)
  - [Obstacle](#Obstacle)
  - [Random Searcher](#Random-Searcher)
- [Slices](#Slices)
- Maintainers
- License

## Structure

<div align="center">
    <img src="assets/structure.png" width="600" />
</div>



- Vertically, the simulator configuration is initialized by maps outside according to certain predefined regulation. Map initialization has been shown in [Map Initialization](#map-initialization).
- Horizontally, the framework has various types of plug-in usages through MATLAB tools. Framework can use .MEX files to load RVO2 library for some certain purposes. CoppeliaSim Simulator remote-API has also been wrapped.

### Map Initialization

<div align=center>
    <img src="assets/envInit.png" alt="init" width="375" />
</div>

### Outlier APIs wrapper

### Agent

### Obstacle

### Random Searcher

## Slices

<div>
    <img src="assets/single.gif" alt="single" width="375" /><img src="assets/single2.gif" width="375" />
    <img src="assets/circle.gif" width="375" /><img src="assets/giveTheWay.gif" width="375" />
    <img src="assets/easyWU.gif" width="375" />
</div>

## Reference

