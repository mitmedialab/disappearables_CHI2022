// This file is part of the CBS planner code for the disappearables_CHI2022 project.
// See file <filename> or go to <url> for full license details.
// 
// A license file for the C++ planner code will be added soon. Please do not modify or distribute the code until the license file is added.
// 
// Author: Yi Zheng
// Email: yzheng63@usc.edu
//

#include <iostream>
#include "CBS.h"
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char* argv[])
{
	//string stage_file = argv[0];
	//string agent_file = argv[1];
	//float w = stof(argv[2]);
	
	StageMap * map = new StageMap("./current_stage.txt", "./current_agent.csv");
	// load stage map from file.
	map->load_init_map();
	// load control file (agent start and goal locations).
	map->load_agents();
	// convert map to the MAPF instance.
	map->convert_init_map();

	// Run planner. 
	CBS * planner = new CBS(map);

	vector<Path> plan = planner->find_solution(1.5);
	if (plan.empty()) {
		cout << "No solution." << endl;
		return 0;
	}
	int max_length = 0;

	for (int i = 0; i < map->num_agents; i++) {

		if (plan[i].size() >= max_length) {
			max_length = plan[i].size();
		}
	}

	for (int i = 0; i < map->num_agents; i++) {
		auto exact_start = map->agent_start[i];
		auto exact_goal = map->agent_goal[i];
		
		plan[i].insert(plan[i].begin(), make_tuple(get<0>(exact_start), get<1>(exact_start), get<2>(exact_start)));
		

	}

	ofstream paths_output;
	paths_output.open("paths.txt");
	for (int i = 0; i < map->num_agents; i++) {

		for (auto loc : plan[i]) {
			paths_output << get<0>(loc) << "," << get<1>(loc) << "," << get<2>(loc) << " ";
		}
		paths_output << endl;
	}
	paths_output.close();
	return 0;
}
