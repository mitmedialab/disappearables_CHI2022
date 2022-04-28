// This file is part of the CBS planner code for the disappearables_CHI2022 project.
// See file <filename> or go to <url> for full license details.
// 
// A license file for the C++ planner code will be added soon. Please do not modify or distribute the code until the license file is added.
// 
// Author: Yi Zheng
// Email: yzheng63@usc.edu
//


#include "CBS.h"

void print_paths(const vector<Path>& paths) {
	for (Path p : paths) {
		int t = 0;
		for (auto a : p) {
			cout << get<0>(a) << "," << get<1>(a) << ", " << t << " ";
			t++;
		}
		cout << endl;
	}
}

void print_single_path(const Path& path) {
	int t = 0;
	for (auto a : path) {
		cout << get<0>(a) << "," << get<1>(a) << ", " << t << " ";
		t++;
	}
	cout << endl;
}

inline int compute_sum_of_cost(const vector<Path>& paths) {
	int sum_of_cost = 0;
	for (auto a : paths) {
		sum_of_cost += (a.size()-1) * STEP_SIZE;

	}
	return sum_of_cost;
}

vector<Path> CBS::find_solution(float w)
{
	boost::heap::fibonacci_heap<CBS_node*, boost::heap::compare<CBS_node::compare_node_focal>> FOCAL;
	boost::heap::fibonacci_heap<CBS_node*, boost::heap::compare<CBS_node::compare_node>> OPEN;
	vector<CBS_node*> node_track; // for memory release
	
	CBS_node* root = new CBS_node();
	root->id = 0;
	
	
	int agent_num = map->agent_start.size();

	precompute_h_table();

	for (int i = 0; i < agent_num; i++) {
		tuple<int, int, int> start = map->agent_converted_start[i];
		tuple<int, int, int> goal = map->agent_converted_goal[i];

		cout << "finding inital path for agent: " << i << endl;
		Path p = find_path(i, start, goal, root->paths, list<Constraint>());
		root->paths.push_back(p);
		// print_single_path(p);
		if (p.size() == 0) {
			cout << "Agent " << i << " has no valid path from its start to its goal." << endl;
			return vector<Path>();
		}
	}
	// print_paths(root->paths);

	root->cost = compute_sum_of_cost(root->paths);

	root->num_conflict = count_conflicts(*root);

	root->open_handle = OPEN.push(root);
	root->focal_handle = FOCAL.push(root);

	while (!FOCAL.empty()) {
		int cost_old = OPEN.top()->cost;
		CBS_node* top = FOCAL.top();
		
		cout << "Expanding CBS node, id: " << top->id << " cost: " << top->cost << endl;

		
		FOCAL.pop();

		OPEN.erase(top->open_handle);

		expanded_count++;

		Collision collision;
		

		if (!find_conflicts_exact_goal_check(collision, top->paths)) {
			return top->paths;
		}

		Constraint constraints[2];
		

		int a1, a2, x1,y1,z1, c_type ,x2, y2, z2, t;
		
		tie(a1, a2, x1, y1, z1, c_type, x2, y2, z2, t) = collision;

		if (c_type == -1) { // a vertex conflict.
			constraints[0] = make_tuple(a1, x1, y1, z1, x2, y2, z2, t, -1);
			constraints[1] = make_tuple(a2, x1, y1, z1, x2, y2, z2, t, -1);
		}
		else if (c_type == -2) { // conflict with a stay-at-goal agent.
			// constriant for a1.
			constraints[0] = make_tuple(a1, get<0>(top->paths[a1][top->paths[a1].size()-2]), get<1>(top->paths[a1][top->paths[a1].size() - 2]), get<2>(top->paths[a1][top->paths[a1].size() - 2]), 
				x2, y2, z2, t-1, -1);

			// a2 can't be at the blocked location.
			constraints[1] = make_tuple(a2, x1, y1, z1, x2, y2, z2, t, 1);
		}
		else if (c_type == -3) { // edge collision
			constraints[0] = make_tuple(a1, x1, y1, z1, x2, y2, z2, t,-1);
			constraints[1] = make_tuple(a2, x2, y2, z2, x1, y1, z1, t,-1);
		}
		else if (c_type == -5) {
			constraints[0] = make_tuple(a1, x1, y1, z1, -1, -1, -1, t, -1);
			constraints[1] = make_tuple(a2, x2, y2, z2, -1, -1, -1, t - 1, -1);
		}
		else { // conflicts with teleport points.
			constraints[0] = make_tuple(a1, x1, y1, z1, -1, -1,-1, t, -1);
			constraints[1] = make_tuple(a2, x2, y2, z2, -1, -1, -1, t, -1);
		}

		// generate child nodes
		for (const auto& constraint : constraints) {
			CBS_node* child = new CBS_node(*top);
			child->constraint_list.push_back(constraint);

			int agent_id = get<0>(constraint);

			tuple<int, int, int> start = map->agent_converted_start[agent_id];
			tuple<int, int, int> goal = map->agent_converted_goal[agent_id];


			child->paths[agent_id] = find_path(agent_id, start, goal, child->paths, child->getAllConstraints());


			if (child->paths[agent_id].empty()) {
				delete child;
				continue;
			}

			child->cost = compute_sum_of_cost(child->paths);

			child->num_conflict = count_conflicts(*child);

			child->open_handle = OPEN.push(child);
			node_track.push_back(child);
			if (child->cost <= w * OPEN.top()->cost) {
				child->focal_handle = FOCAL.push(child);
			}
		}
		
		int cost_new = OPEN.top()->cost;
		for (auto node : OPEN) {
			if (w * cost_old < node->cost && w * cost_new >= node->cost) {
				node->focal_handle = FOCAL.push(node);
			}
		}
	}


	

	return vector<Path>();
}



inline int CBS::real_dist_heuristic(int agent_id, int x, int y, int z) {
	return h_table[agent_id][make_tuple(x,y,z)];
}

inline int simple_heuristic(int x0, int y0, int x1, int y1) {
	return abs(x1 - x0) + abs(y1 - y0);
}

void CBS::make_path(A_node* goal, Path& path)
{
	A_node* curr = goal;
	while (curr != nullptr) {
		path.push_back(make_tuple(get<0>(curr->config), get<1>(curr->config), get<2>(curr->config)));
		curr = curr->parent;
	}
}

// Precompute true distance heuristic table.
void CBS::precompute_h_table()
{

	for (int i = 0; i < map->num_agents; i++) {
		
		cout << "precomputing for agent: " << i << endl;

		tuple<int,int,int> goal = map->agent_converted_goal[i];

		A_node* root = new A_node();
		root->config = make_tuple(get<0>(goal), get<1>(goal), get<2>(goal),0);
		root->g = 0;
		root->id = 0;

		boost::heap::fibonacci_heap<A_node*, boost::heap::compare<A_node::compare_node_id>> OPEN;
		vector<A_node*> track;

		int node_count = 0;

		h_table.push_back(std::map<tuple<int, int, int>, int>());
		h_table[i][make_tuple(get<0>(root->config), get<1>(root->config), get<2>(root->config))] = root->g;

		OPEN.push(root);
		track.push_back(root);

		while (!OPEN.empty()) {
			A_node* top = OPEN.top();
			OPEN.pop();
			
			node_count++;

			vector<Config> neighbors = get_loc_neighbors(top->config);
			for (auto n : neighbors) {
				auto it = h_table[i].find( make_tuple(get<0>(n),get<1>(n), get<2>(n)));
				if (it != h_table[i].end()) {
					continue;
				}

				A_node* child = new A_node();
				child->config = n;
				child->g = top->g + step_size;
				child->id = top->id + 1;

				OPEN.push(child);
				track.push_back(child);

				h_table[i][make_tuple(get<0>(child->config), get<1>(child->config), get<2>(child->config))] = child->g;
			}

		}

		for (auto node : track) {
			delete node;
		}

 	}
}

int CBS::count_conflicts(const CBS_node & curr)
{
	int retVal = 0;

	for (int i = 0; i < (int)curr.paths.size(); i++) {   // for every path
		for (int j = i + 1; j < (int)curr.paths.size(); j++) { // for every another path
			int a1 = curr.paths[i].size() < curr.paths[j].size() ? i : j;
			int a2 = curr.paths[i].size() < curr.paths[j].size() ? j : i;
			for (int t = 0; t < (int)curr.paths[a1].size(); t++) {
				if (curr.paths[a1][t] == curr.paths[a2][t] || curr.paths[a1][t] == curr.paths[a2][t-1] || curr.paths[a1][t-1] == curr.paths[a2][t]) {
					retVal++;
				}
				else if (t > 0 && curr.paths[a1][t] != curr.paths[a1][t - 1] &&
					curr.paths[a1][t] == curr.paths[a2][t - 1] && curr.paths[a1][t - 1] == curr.paths[a2][t]) {
					retVal++;
				}
				else if (get<2>(curr.paths[a1][t]) == get<2>(curr.paths[a2][t])) {
					int z = get<2>(curr.paths[a1][t]);

					vector<pair<int, int>> tp_points;
					if (z == 0) {
						tp_points = map->stage_portal_back_points;
					}
					else {
						tp_points = map->stage_portal_front_points;
					}

					auto it = find(tp_points.begin(), tp_points.end(), make_pair(get<0>(curr.paths[a1][t]), get<1>(curr.paths[a1][t])));
					auto it2 = find(tp_points.begin(), tp_points.end(), make_pair(get<0>(curr.paths[a2][t]), get<1>(curr.paths[a2][t])));
					if (it == tp_points.end() && it2 == tp_points.end()) {
						continue;
					}

					if (it != tp_points.end()) {

						if (check_body_collision(get<0>(curr.paths[a1][t]), get<1>(curr.paths[a1][t]), get<0>(curr.paths[a2][t]), get<1>(curr.paths[a2][t]))) {
							retVal++;
							continue;
						}
					}

					if (it2 != tp_points.end()) {
						if (check_body_collision(get<0>(curr.paths[a1][t]), get<1>(curr.paths[a1][t]), get<0>(curr.paths[a2][t]), get<1>(curr.paths[a2][t]))) {
							retVal++;
						}
					}

				}
			}
			for (int t = (int)curr.paths[a1].size(); t < (int)curr.paths[a2].size(); t++) {
				auto cells_blocked_by_exact_goal = get_exact_goal_blocked_locations(get<0>(curr.paths[a1].back()), get<1>(curr.paths[a1].back()), get<2>(curr.paths[a1].back()));

				for (auto blocked : cells_blocked_by_exact_goal) {
					vector<pair<int, int>> a1_collision;
					if (blocked == curr.paths[a2][t]) {
						retVal++;
						break;
					}
				}
			}
		}
	}
	return retVal;
}

bool CBS::find_conflicts_exact_goal_check(Collision& collision, vector<Path>& paths)
{
	for (int i = 0; i < (int)paths.size(); i++) {   // for every path
		for (int j = i + 1; j < (int)paths.size(); j++) { // for every another path
			int a1 = paths[i].size() < paths[j].size() ? i : j;
			int a2 = paths[i].size() < paths[j].size() ? j : i;
			for (int t = 0; t < (int)paths[a1].size(); t++) {
				if (paths[a1][t] == paths[a2][t]) {
					
					collision = make_tuple(a1, a2, get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]), -1, -1, -1, -1, t);
					return true;
				}
				else if (paths[a1][t] == paths[a2][t - 1]) {
					collision = make_tuple(a1, a2, get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]), -5, get<0>(paths[a2][t - 1]), get<1>(paths[a2][t - 1]), get<2>(paths[a2][t - 1]), t);
					return true;
				}
				else if (paths[a1][t-1] == paths[a2][t]) {
					
					collision = make_tuple(a2, a1, get<0>(paths[a2][t]), get<1>(paths[a2][t]), get<2>(paths[a2][t]), -5, get<0>(paths[a1][t - 1]), get<1>(paths[a1][t - 1]), get<2>(paths[a1][t - 1]), t);
					return true;
				}
				else if (t > 0 && paths[a1][t] != paths[a1][t - 1] &&
					paths[a1][t] == paths[a2][t - 1] && paths[a1][t - 1] == paths[a2][t]) {
					collision = make_tuple(a1, a2, get<0>(paths[a1][t - 1]), get<1>(paths[a1][t - 1]), get<2>(paths[a1][t - 1]), 
						-3, get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]), t);
					return true;
				}
				else if (get<2>(paths[a1][t]) == get<2>(paths[a2][t])) {
					int z = get<2>(paths[a1][t]);

					vector<pair<int, int>> tp_points;
					if (z == 0) {
						tp_points = map->stage_portal_back_points;
					}
					else {
						tp_points = map->stage_portal_front_points;
					}
					
					auto it = find(tp_points.begin(), tp_points.end(), make_pair(get<0>(paths[a1][t]), get<1>(paths[a1][t])));
					auto it2 = find(tp_points.begin(), tp_points.end(), make_pair(get<0>(paths[a2][t]), get<1>(paths[a2][t])));
					if (it == tp_points.end() && it2 == tp_points.end()) {
						continue;
					}
						
					if (it != tp_points.end()) {
						auto cells_blocked_by_tp_point = get_exact_goal_blocked_locations(get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]));
						for (auto blocked : cells_blocked_by_tp_point) {
							
							if (blocked == paths[a2][t]) {
								collision = (make_tuple(a1, a2, get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]), -4, get<0>(blocked), get<1>(blocked), get<2>(blocked), t));
								return true;
							}
						}
					}
						
					if (it2 != tp_points.end()) {
						auto cells_blocked_by_tp_point = get_exact_goal_blocked_locations(get<0>(paths[a2][t]), get<1>(paths[a2][t]), get<2>(paths[a2][t]));
						
						for (auto blocked : cells_blocked_by_tp_point) {
							if (blocked == paths[a1][t]) {
								collision = (make_tuple(a2, a1, get<0>(paths[a2][t]), get<1>(paths[a2][t]), get<2>(paths[a2][t]), -4, get<0>(blocked), get<1>(blocked), get<2>(blocked), t));
								return true;
							}
						}
					}
					
				}


			}
			for (int t = (int)paths[a1].size(); t < (int)paths[a2].size(); t++) {	// a1 arrives before a2.

				auto cells_blocked_by_exact_goal = get_exact_goal_blocked_locations(get<0>(paths[a1].back()), get<1>(paths[a1].back()), get<2>(paths[a1].back()));
				vector<tuple<int, int, int>> a1_collision;
				for (auto blocked : cells_blocked_by_exact_goal) {
					if (blocked == paths[a2][t]) {
						collision = (make_tuple(a1, a2, get<0>(blocked), get<1>(blocked), get<2>(blocked), -2, -2, -2, -2, t));
						return true;
					}
                    if (blocked == paths[a2][t-1]) {
                        collision = (make_tuple(a1, a2, get<0>(blocked), get<1>(blocked), get<2>(blocked), -2, -2, -2, -2, t-1));
                        return true;
                    }
				}
			}
		}
	}
	return false;

}




vector<tuple<int, int, int>> CBS::get_exact_goal_blocked_locations(int x, int y, int z) {
	// get the 3x3 cells around the exact goal location
	int x_0 = ceil(x / step_size) * step_size;
	int y_0 = ceil(y / step_size) * step_size;
	
	vector<tuple<int, int, int>> blocked_by_exact_goal;
	
	for (int x_change = -step_size; x_change <= step_size; x_change += step_size) {
		for (int y_change = -step_size; y_change <= step_size; y_change += step_size) {
			int neighbor_x = x_0 + x_change;
			int neighbor_y = y_0 + y_change;

			if (abs(neighbor_x - x) < step_size && abs(neighbor_y - y) < step_size) {
				blocked_by_exact_goal.push_back(make_tuple(neighbor_x, neighbor_y,z));
			}
			else {
				continue;
			}
			
		}
	}

	return blocked_by_exact_goal;
}


int CBS::get_earliest_goal_timestep(int agent_id, int goal_x, int goal_y, int goal_z, const list<Constraint>& constraints) {
	int a, x1, y1, z1, x2, y2, z2, t, t_r;
	int output = -1;
	
	for (const auto& c : constraints) {
		tie(a, x1, y1, z1, x2, y2, z2, t, t_r) = c;
		if (a == agent_id && x1 == goal_x && y1 == goal_y && z1 == goal_z && x2 <0 && t > output) {
			output = t;
		}
	}
	return output;
}

int CBS::get_latest_constraint(int agent_id, const list<Constraint>& constraints) const {
	int a, x1, y1, z1, x2, y2, z2, t, t_r;
	int output = -1;
	for (const auto& c : constraints) {
		tie(a, x1, y1, z1, x2, y2, z2, t, t_r) = c;
		if (a == agent_id && t > output)
			output = t;
	}
	return output;
}

bool CBS::is_constrained(int agent_id, int curr_loc_x, int curr_loc_y, int curr_loc_z, int next_loc_x, int next_loc_y, int next_loc_z, int next_t,
	const list<Constraint>& constraints) const {
	int a, x1, y1, z1, x2, y2, z2, t, t_r;
	for (const auto& c : constraints) {
		tie(a, x1, y1, z1, x2, y2, z2, t, t_r) = c;
		if (a != agent_id)
			continue;
		else if (x2 == -2 && t_r == 1) {  // goal constraint
			if (x1 == next_loc_x && y1 == next_loc_y && z1 == next_loc_z)
				return true;
		}
		else if (x2 == -1) {  // vertex constraint
			if (x1 == next_loc_x && y1 == next_loc_y && z1 == next_loc_z && t == next_t)
				return true;
		}
		else { // edge constraint
			if (curr_loc_x == x1 && curr_loc_y == y1 && curr_loc_z == z1 && next_loc_x == x2 && next_loc_y == y2 && next_loc_z == z2 && t == next_t)
				return true;
		}
	}
	return false;
}

Path CBS::find_path(int agent_id, tuple<int, int, int>& start, tuple<int, int, int>& goal, vector<Path>& paths, const list<Constraint>& constraint_list)
{
	A_node* root = new A_node();
	root->config = make_tuple(get<0>(start), get<1>(start), get<2>(start), 0); // x,y,z,t
	root->g = 0;
	root->h = real_dist_heuristic(agent_id, get<0>(start),get<1>(start),get<2>(start));
	
	root->f = root->g + root->h;


	int earliest_goal_timestep = get_earliest_goal_timestep(agent_id, get<0>(goal), get<1>(goal), get<2>(goal), constraint_list);
	int latest_constraint = get_latest_constraint(agent_id, constraint_list);

	boost::heap::fibonacci_heap<A_node*, boost::heap::compare<A_node::compare_node>> OPEN;
	

	vector<Config> CLOSE;
	vector<A_node*> track;
	Path path; 

	root->open_handle = OPEN.push(root);
	
	track.push_back(root);

	int low_level_node_count = 0;

	while (!OPEN.empty()) {
		
		A_node* top = OPEN.top();

		OPEN.pop();
		
		low_level_node_count++;

		//cout << get<0>(top->config) << "," << get<1>(top->config) << "," <<  get<3>(top->config) << endl;
		
		if (get<0>(top->config) == get<0>(goal) && get<1>(top->config) == get<1>(goal) && get<2>(top->config) == get<2>(goal) && get<3>(top->config) > earliest_goal_timestep) {
			make_path(top, path);
			reverse(path.begin(), path.end());

			auto exact_start = map->agent_start[agent_id];
			auto exact_goal = map->agent_goal[agent_id];
			path.push_back(make_tuple(get<0>(exact_goal), get<1>(exact_goal), get<2>(exact_goal)));

			for (auto node : track) {
				delete node;
			}

			return path;
		}

		if (get<3>(top->config) > get_latest_constraint(agent_id, constraint_list) + 2 * (map->converted_max_width / step_size) * (map->converted_max_height / step_size)) {
			continue;
		}

		vector<Config> neighbors = get_neighbors(top->config);
		for (auto n : neighbors) {

			if (is_constrained(agent_id, get<0>(top->config), get<1>(top->config), get<2>(top->config), get<0>(n), get<1>(n), get<2>(n), get<3>(n), constraint_list))
				continue;

			auto it = find(CLOSE.begin(), CLOSE.end(), n);
			if (it != CLOSE.end()) {
				continue;
			}

			A_node* child = new A_node();
			child->config = n;
			child->g = top->g + step_size;
			child->h = real_dist_heuristic(agent_id, get<0>(child->config), get<1>(child->config), get<2>(child->config));
			child->f = child->g + child->h;
			child->parent = top;

			// compute the number of conflict would caused by this child node.
			int current_p = 0;
			int num_conflicts_with_other_paths = 0;
			for (auto path : paths) {
				if (current_p == agent_id) {
					continue;
				}

				if (path.size() == 0) {
					continue;
				}
				
				int timestep = get<3>(child->config);

				if (get<3>(child->config) >= path.size()) {
					timestep = path.size() - 1;
				}

				if (get<2>(path[timestep]) == get<2>(child->config) && check_body_collision(get<0>(path[timestep]), get<1>(path[timestep]), get<0>(child->config), get<1>(child->config))) {
					num_conflicts_with_other_paths++;
				}

				if (make_tuple(get<0>(child->config), get<1>(child->config), get<2>(child->config)) == path[timestep]) {
					
					num_conflicts_with_other_paths++;
				}

				current_p++;
			}
			child->num_conflict = num_conflicts_with_other_paths;
			/*if (child->num_conflict > 0) {
				cout << child->num_conflict << endl;
			}*/

			OPEN.push(child);
			track.push_back(child);
			CLOSE.push_back(child->config);
		}

		
		
	}

	return Path();
}



vector<Config> CBS::get_loc_neighbors(Config& location)
{
	// timestep is not needed in this method. 
	// This is used for precomputing the real-distance heuristic table.
	int x = get<0>(location);
	int y = get<1>(location);
	int z = get<2>(location);

	int step_s = step_size;
	
	vector<pair<int, int>> tp_point_set;
	vector<pair<int, int>> other_tp_point_set;
	
	std::map<pair<int, int>, vector<tuple<int, int, int>>> tp_neighbors;
	vector<vector<int>> used_map;
	int other_z = -1;
	if (z == 0) {
		tp_point_set = map->stage_portal_back_points;
		other_tp_point_set = map->stage_portal_front_points;
		other_z = 1;
		tp_neighbors = map->stage_portal_back_point_neighbors;
		used_map = map->understage_converted_map;
	}
	else {
		tp_point_set = map->stage_portal_front_points;
		other_tp_point_set = map->stage_portal_back_points;
		other_z = 0;
		tp_neighbors = map->stage_portal_front_point_neighbors;
		used_map = map->converted_map;
	}


	vector<Config> neighbors{};

	// if it's a tp point, add the other end of the tp point. Then return.

	auto it = find(tp_point_set.begin(), tp_point_set.end(), make_pair(x, y));
	if (it != tp_point_set.end()) {
		// get the other end of tp_point.
		int index = it - tp_point_set.begin();
		auto other_end = other_tp_point_set[index];
		Config tp_end = make_tuple(other_end.first, other_end.second, other_z, 0);
		neighbors.push_back(tp_end);

		for (auto n : tp_neighbors[make_pair(x, y)]) {
			neighbors.push_back(make_tuple(get<0>(n), get<1>(n), get<2>(n),0));
		}

		return neighbors;
	}

	if (!check_blocked_location(x, min(y + step_s, map->converted_max_height), used_map)) {
		Config up = make_tuple(x, min(y + step_s, map->converted_max_height), z, 0);
		neighbors.push_back(up);
	}
	if (!check_blocked_location(x, max(y - step_s, 0), used_map)) {
		Config down = make_tuple(x, max(y - step_s, 0), z, 0);
		neighbors.push_back(down);
	}
	if (!check_blocked_location(max(x - step_s, 0), y, used_map)) {
		Config left = make_tuple(max(x - step_s, 0), y, z, 0);
		neighbors.push_back(left);
	}
	if (!check_blocked_location(min(x + step_s, map->converted_max_width), y, used_map)) {
		Config right = make_tuple(min(x + step_s, map->converted_max_width), y, z, 0);
		neighbors.push_back(right);
	}

	// add a tp point if the location is close to one.
	for (auto tp_point : tp_point_set) {
		if (next_to_tp_point(x, y, tp_point.first, tp_point.second, step_size)) {
			Config tp_start = make_tuple(tp_point.first, tp_point.second, z, 0);
			neighbors.push_back(tp_start);
		}
	}

	return neighbors;
}


vector<Config> CBS::get_neighbors(Config & location)
{
	// up down left right stay
	int x = get<0>(location);
	int y = get<1>(location);
	int z = get<2>(location);
	int t = get<3>(location);
	
	Config stay = make_tuple(x, y, z, t + 1);

	int step_s = step_size;

	vector<Config> neighbors{stay};

	vector<pair<int, int>> tp_point_set;
	vector<pair<int, int>> other_tp_point_set;
	std::map<pair<int, int>, vector<tuple<int, int, int>>> tp_neighbors;
	vector<vector<int>> used_map;

	int other_z = -1;
	if (z == 0) {
		tp_point_set = map->stage_portal_back_points;
		other_tp_point_set = map->stage_portal_front_points;
		other_z = 1;
		tp_neighbors = map->stage_portal_back_point_neighbors;
		used_map = map->understage_converted_map;
	}
	else {
		tp_point_set = map->stage_portal_front_points;
		other_tp_point_set = map->stage_portal_back_points;
		other_z = 0;
		tp_neighbors = map->stage_portal_front_point_neighbors;
		used_map = map->converted_map;
	}


	// if it's a tp point, add the other end of the tp point. Then return.
	
	auto it = find(tp_point_set.begin(), tp_point_set.end(), make_pair(x, y));
	if (it != tp_point_set.end()) {
		// get the other end of tp_point.
		int index = distance(tp_point_set.begin(), it);
		auto other_end = other_tp_point_set[index];
		Config tp_end = make_tuple(other_end.first, other_end.second, other_z, t+1);
		neighbors.push_back(tp_end);

		for (auto n : tp_neighbors[make_pair(x, y)]) {
			neighbors.push_back(make_tuple(get<0>(n), get<1>(n), get<2>(n), t+1));
		}

		return neighbors;
	}

	if (!check_blocked_location(x, min(y + step_s, map->converted_max_height), used_map)) {
		Config up = make_tuple(x, min(y + step_s, map->converted_max_height), z, t + 1);
		neighbors.push_back(up);
	}
	if (!check_blocked_location(x, max(y - step_s, 0), used_map)){
		Config down = make_tuple(x, max(y - step_s, 0), z, t + 1);
		neighbors.push_back(down);
	}
	if (!check_blocked_location(max(x - step_s, 0), y, used_map)){
		Config left = make_tuple(max(x - step_s, 0), y, z, t + 1);
		neighbors.push_back(left);
	}
	if (!check_blocked_location(min(x + step_s, map->converted_max_width), y, used_map)){
		Config right = make_tuple(min(x + step_s, map->converted_max_width), y, z, t + 1);
		neighbors.push_back(right);
	}


	// add a tp point if the location is close to one.
	for (auto tp_point : tp_point_set) {
		if (next_to_tp_point(x, y, tp_point.first, tp_point.second, step_size)) {
			Config tp_start = make_tuple(tp_point.first,tp_point.second,z, t+1);
			neighbors.push_back(tp_start);
		}
	}
	

	return neighbors;
}

bool CBS::next_to_tp_point(int x0, int y0, int x1, int y1, int step_size) {
	if (abs(x0 - x1) < step_size && abs(y0 - y1) < step_size) {
		return true;
	}
	return false;
}

bool CBS::check_body_collision(int x0, int y0, int x1, int y1) {
	if (abs(x0 - x1) < 22 && abs(y0 - y1) < 22) {
		return true;
	}
	return false;
}

bool CBS::check_blocked_location(int x_loc, int y_loc, vector<vector<int>> & used_map)
{

	for (int x = -11; x < 11; x++) {
		if (x_loc + x < 0 || x_loc + x > map->width-1) {
			break;
		}
		for (int y = -11; y < 11; y++) {
			if (y_loc + y < 0 || y_loc + y >map->height-1) {
				break;
			}

			if (used_map[x_loc + x][y_loc + y] == 1) {
				return true;
			}

		}
	}
	return false;
}
