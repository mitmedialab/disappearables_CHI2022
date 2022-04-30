// This file is part of the CBS planner code for the disappearables_CHI2022 project.
// See file <filename> or go to <url> for full license details.
// 
// A license file for the C++ planner code will be added soon. Please do not modify or distribute the code until the license file is added.
// 
// Author: Yi Zheng
// Email: yzheng63@usc.edu
//


#include <cmath>
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp>
#include <map>

#define STEP_SIZE 25
#define SLOPE_WIDTH 46

using namespace std;

class StageMap {

public:
	int width;
	int height;
	int wall_width = 6;
	int num_walls;
	int num_wall_portals;
	bool understage;
	int num_understage_walls;
	int num_stage_portals;

	int converted_max_width;
	int converted_max_height;

	vector<pair<pair<int, int>, pair<int, int>>> wall_points;
	vector<pair<int, int>> portal_mid_points;
	vector<pair<int, int>> portal_left_points;
	vector<pair<int, int>> portal_right_points;

	vector<pair<pair<int, int>, pair<int, int>>> understage_wall_points;

	vector<pair<int, int>> stage_portal_points;
	vector<pair<int, int>> stage_portal_front_points;
	map<pair<int,int>,vector<tuple<int, int, int>>> stage_portal_front_point_neighbors;
	vector<pair<int, int>> stage_portal_back_points;
	map<pair<int, int>, vector<tuple<int, int, int>>> stage_portal_back_point_neighbors;
	vector<int> stage_portal_slope_dir;

	int num_agents;

	vector<tuple<int, int, int>> agent_start;
	vector<tuple<int, int, int>> agent_goal;

	vector<tuple<int, int, int>> agent_converted_start;
	vector<tuple<int, int, int>> agent_converted_goal;

	string file_path;
	string agent_path;

	void load_init_map();
	void convert_init_map();
	vector<tuple<int, int, int>> get_tp_point_neighbors(int x, int y, int z);
	
	void print_converted_map();
	void print_understage_converted_map();
	void load_agents();

	vector<vector<int>> converted_map; // (int,int) => location status, 0 = free, 1= blocked, 
	vector<vector<int>> understage_converted_map;

	
	StageMap(string path, string agent_file) { file_path = path; agent_path = agent_file; };
private:
	vector<pair<int, int>> points_between(int x0, int y0, int x1, int x2, int wall_width);
};
