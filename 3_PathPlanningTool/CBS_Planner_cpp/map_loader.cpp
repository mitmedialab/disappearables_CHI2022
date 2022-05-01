// This file is part of the CBS planner code for the disappearables_CHI2022 project.
// See file <filename> or go to <url> for full license details.
// 
// A license file for the C++ planner code will be added soon. Please do not modify or distribute the code until the license file is added.
// 
// Author: Yi Zheng
// Email: yzheng63@usc.edu
//

#include "map_load.h"


void StageMap::print_converted_map() {
	ofstream f;
	f.open("./test.txt");
	for (auto vec : converted_map) {
		for (int v : vec) {
			f << v;
		}
		f << endl;
	}
	f << endl;
}

void StageMap::print_understage_converted_map() {
	ofstream f;
	f.open("./test_understage.txt");
	for (auto vec : understage_converted_map) {
		for (int v : vec) {
			f << v;
		}
		f << endl;
	}
	f << endl;
}

void StageMap::load_agents() {
	ifstream myfile(agent_path.c_str());

	int agent_count = 0;
	if (myfile.is_open()){
		string line;
		int header_skipped = false;
		while (getline(myfile, line)) {
			if (!header_skipped) {
				header_skipped=true;
				continue;
			}

			vector<string> values;
			boost::split(values, line, boost::is_any_of(","));
			int start_x = stoi(values[0]);
			int start_y = stoi(values[1]);
			int start_z = -1;
			if (start_y > height) {
				start_y -= height;
				start_z = 0;   // the point is on the lower stage
			}
			else {
				start_z = 1;   // the point is on the upper stage
			}
			

			agent_start.push_back(make_tuple(start_x, start_y, start_z));
			agent_converted_start.push_back(make_tuple((int)ceil(start_x/STEP_SIZE)* STEP_SIZE, (int)ceil(start_y/ STEP_SIZE)* STEP_SIZE, start_z));

			int goal_x = stoi(values[2]);
			int goal_y = stoi(values[3]);
			int goal_z = -1;
			if (goal_y > height) {
				goal_y -= height;
				goal_z = 0;   // the point is on the lower stage
			}
			else {
				goal_z = 1;   // the point is on the upper stage
			}


			agent_goal.push_back(make_tuple(goal_x, goal_y, goal_z));
			agent_converted_goal.push_back(make_tuple((int)ceil(goal_x/ STEP_SIZE)* STEP_SIZE, (int)ceil(goal_y/ STEP_SIZE)* STEP_SIZE, goal_z));
			agent_count++;
		}
	}
	num_agents = agent_count;
}

void StageMap::load_init_map() {
	
	ifstream myfile(file_path.c_str());

	if (myfile.is_open()){
		string line;
		int line_idx = 0;
		while (getline(myfile, line)) {

			
			vector<string> values;
			boost::split(values, line, boost::is_any_of(","));

			if (line_idx == 0) {
				width = stoi(values[0]);
				height = stoi(values[1]);
				num_walls = max(0,stoi(values[2])-1);
				num_wall_portals = stoi(values[3]);
				understage = stoi(values[4]);
				num_understage_walls = max(0,stoi(values[5])-1);
				num_stage_portals = stoi(values[6]);
			}
			else if (line_idx > 0 && line_idx <= num_walls) {
				wall_points.push_back(make_pair(make_pair(stoi(values[0]), stoi(values[1])), 
										make_pair(stoi(values[2]), stoi(values[3]))));
			}
			else if (line_idx > num_walls && line_idx <= num_walls + num_wall_portals) {
				portal_mid_points.push_back(make_pair(stoi(values[0]), stoi(values[1])));
				portal_left_points.push_back(make_pair(stoi(values[2]), stoi(values[3])));
				portal_right_points.push_back(make_pair(stoi(values[4]), stoi(values[5])));
			}
			else if (line_idx > num_walls && line_idx <= num_walls + num_wall_portals + num_understage_walls) {
				understage_wall_points.push_back(make_pair(make_pair(stoi(values[0]), stoi(values[1])),
					make_pair(stoi(values[2]), stoi(values[3]))));
			}
			else if (line_idx > num_walls && line_idx <= num_walls + num_wall_portals + num_understage_walls + num_stage_portals) {

				stage_portal_points.push_back(make_pair(stoi(values[0]), stoi(values[1])));
				stage_portal_front_points.push_back(make_pair(stoi(values[2]), stoi(values[3])));
				stage_portal_back_points.push_back(make_pair(stoi(values[4]), stoi(values[5])));
				stage_portal_slope_dir.push_back(stoi(values[6]));
			}

			line_idx++;
		}
	}

}

vector<pair<int,int>> StageMap::points_between(int x0, int y0, int x1, int y1, int wall_width) {
	vector<pair<int, int>> points;
	int half_width = wall_width / 2;
	if (abs(x0-x1) <= 5) {
		int ymin = min(y0, y1);
		int ymax = max(y0, y1);

		for (int i = ymin; i <= ymax; i++) {
			points.push_back(make_pair(x0, i));
			for (int j = 1; j <= half_width; j++) {
				points.push_back(make_pair(max(x0-j,0), i));
				points.push_back(make_pair(min(x0+j,width), i));
			}
		}

	}
	else if (abs(y0-y1)<=5) {
		int xmin = min(x0, x1);
		int xmax = max(x0, x1);

		for (int i = xmin; i <= xmax; i++) {
			points.push_back(make_pair(i, y0));
			for (int j = 1; j <= half_width; j++) {
				points.push_back(make_pair(i, max(y0-j,0)));
				points.push_back(make_pair(i, min(y0+j,height)));
			}
		}
	}
	else {
		float slope = ((float)y1 - (float)y0) / ((float)x1 - (float)x0);
		float b = y1 - slope * x1;

		int xmin = min(x0,x1);
		int xmax = max(x0,x1);
		for (int i = xmin; i<=xmax; i++) {
            int new_y = slope * i + b;
            points.push_back(make_pair(i, new_y));
            for (int j = 1; j <= half_width; j++) {
                points.push_back(make_pair(i, max(new_y - j, 0)));
                points.push_back(make_pair(i, min(new_y + j, width)));
            }
        }

	}
	return points;
}

void StageMap::convert_init_map() {
	
	// init converted map
	for (int i = 0; i < width; i++) {
		vector<int> col(height);
		fill(col.begin(), col.end(), 0);
		converted_map.push_back(col);
	}
	converted_max_width = ceil(width / STEP_SIZE) * STEP_SIZE;
	converted_max_height = ceil(height / STEP_SIZE) * STEP_SIZE;

	if (understage) {
		for (int i = 0; i < width; i++) {
			vector<int> col(height);
			fill(col.begin(), col.end(), 0);
			understage_converted_map.push_back(col);
		}
	}

	// add walls
	for (auto ptr_pair : wall_points) {
		auto p0 = ptr_pair.first;
		auto p1 = ptr_pair.second;
		int x0 = p0.first;
		int y0 = p0.second;
		int x1 = p1.first;
		int y1 = p1.second;

		vector<pair<int, int>> blocked = points_between(x0, y0, x1, y1, wall_width);
		for (auto ptr : blocked) {
			int ptr_x = ptr.first;
			int ptr_y = ptr.second;
			if(0<=ptr_x && ptr_x<width && 0<=ptr_y && ptr_y<height){
                converted_map[ptr_x][ptr_y] = 1;
			}

		}
	}

	// add understage walls
	for (auto ptr_pair : understage_wall_points) {
		auto p0 = ptr_pair.first;
		auto p1 = ptr_pair.second;
		int x0 = p0.first;
		int y0 = p0.second;
		int x1 = p1.first;
		int y1 = p1.second;

		vector<pair<int, int>> blocked = points_between(x0, y0, x1, y1, wall_width);
		for (auto ptr : blocked) {
			int ptr_x = ptr.first;
			int ptr_y = ptr.second;
			understage_converted_map[ptr_x][ptr_y] = 1;
		}
	}



	// add portals
	for (int i = 0; i < portal_mid_points.size(); i++) {
		int x0 = portal_left_points[i].first;
		int y0 = portal_left_points[i].second;

		int x1 = portal_right_points[i].first;
		int y1 = portal_right_points[i].second;

		vector<pair<int, int>> unblock = points_between(x0, y0, x1, y1, wall_width + 15);
		for (auto ptr : unblock) {
			int ptr_x = ptr.first;
			int ptr_y = ptr.second;
			converted_map[ptr_x][ptr_y] = 0;
		}
		
	}

	// add cells blocked by slopes
	for (int i = 0; i < num_stage_portals; i++) {
		auto p0 = stage_portal_front_points[i];
		auto p1 = stage_portal_back_points[i];
		int x0 = p0.first;
		int y0 = p0.second;
		int x1 = p1.first;
		int y1 = p1.second;

		vector<pair<int, int>> blocked = points_between(x0, y0, x1, y1, SLOPE_WIDTH);
		for (auto ptr : blocked) {
			int ptr_x = ptr.first;
			int ptr_y = ptr.second;
			understage_converted_map[ptr_x][ptr_y] = 1;
		}
	}




	// add stage portals
	for (int i = 0; i < num_stage_portals; i++) {
		// add blocked upper stage locations.
		int half_portal_size = SLOPE_WIDTH / 2;
		int portal_x0 = stage_portal_points[i].first;
		int portal_y0 = stage_portal_points[i].second;

		for (int xb = max(0, portal_x0 - half_portal_size); xb <= min(width, portal_x0 + half_portal_size); xb++) {
			for (int yb = max(0, portal_y0 - half_portal_size); yb <= min(height, portal_y0 + half_portal_size); yb++) {
				converted_map[xb][yb] = 1;
			}
		}
		
		// create neighbors for each tp point

		int back_tp_x = stage_portal_back_points[i].first;
		int back_tp_y = stage_portal_back_points[i].second;
		int front_tp_x = stage_portal_front_points[i].first;
		int front_tp_y = stage_portal_front_points[i].second;

		stage_portal_back_point_neighbors[make_pair(back_tp_x, back_tp_y)] = get_tp_point_neighbors(back_tp_x, back_tp_y, 0);
		stage_portal_front_point_neighbors[make_pair(front_tp_x, front_tp_y)] = get_tp_point_neighbors(front_tp_x, front_tp_y, 1);
		
	}



	print_understage_converted_map();
	print_converted_map();
}

bool check_blocked_location(int x_loc, int y_loc, vector<vector<int>> map, int width, int height)
{

	for (int x = -11; x < 11; x++) {
		if (x_loc + x < 0 || x_loc + x >width - 1) {
			break;
		}
		for (int y = -11; y < 11; y++) {
			if (y_loc + y < 0 || y_loc + y >height - 1) {
				break;
			}

			if (map[x_loc + x][y_loc + y] == 1) {
				return true;
			}

		}
	}
	return false;
}

vector<tuple<int, int, int>> StageMap::get_tp_point_neighbors(int x, int y, int z) {
	
	vector<tuple<int, int, int>> neighbors;

	vector<vector<int>> used_map;
	if (z == 0) {
		used_map = understage_converted_map;
	}
	else {
		used_map = converted_map;
	}

	for (int x_s = 0; x_s <= converted_max_width; x_s++) {
		for (int y_s = 0; y_s <= converted_max_height; y_s++) {
			int xv = x_s * STEP_SIZE;
			int yv = y_s * STEP_SIZE;
			if (abs(xv - x) < STEP_SIZE && abs(yv - y) < STEP_SIZE) {
				if (check_blocked_location(xv, yv, used_map, width, height)) {
					continue;
				}
				else {
					neighbors.push_back(make_tuple(xv, yv, z));
				}
				
			}
		}
	}

	return neighbors;
}


