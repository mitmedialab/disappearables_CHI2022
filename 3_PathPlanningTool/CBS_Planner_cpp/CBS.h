// This file is part of the CBS planner code for the disappearables_CHI2022 project.
// See file <filename> or go to <url> for full license details.
// 
// A license file for the C++ planner code will be added soon. Please do not modify or distribute the code until the license file is added.
// 
// Author: Yi Zheng
// Email: yzheng63@usc.edu
//


#include <boost/heap/fibonacci_heap.hpp>
#include <vector>

#include <cmath>
#include <map>
#include <vector>
#include <unordered_map>
#include "map_load.h"

using namespace std;

typedef vector < tuple <int, int,int>> Path;
typedef tuple<int, int, int, int> Config;

// a_id, a_id2, locx, locy, locz, collision type ,locx2, locy2, locz2, timestep
typedef tuple<int, int, int, int, int, int, int, int, int, int> Collision;


// constraint, a1, x1,y1, z1, x2, y2 ,z2, t, t_ranged
typedef tuple<int, int, int, int, int, int, int, int, int> Constraint;

struct pair_hash {
    template <class T1, class T2>
    size_t operator()(const pair<T1, T2>& p) const
    {
        auto hash1 = hash<T1>{}(p.first);
        auto hash2 = hash<T2>{}(p.second);
        return hash1 ^ hash2;
    }
};

class CBS_node {
public:
	int id;
	int cost;
	int num_conflict;
	int parent_id;
    bool root;

	vector<Path> paths;
    const CBS_node& ptrparent;

	//map<int, vector<Config>> constraint_list;
    list<Constraint> constraint_list;

    struct compare_node {
        bool operator()(const CBS_node* n1, const CBS_node* n2) const {
//            if (n1->cost == n2->cost) {
//                return n1->num_conflict >= n2->num_conflict;
//            }
            return n1->cost >= n2->cost;
        }
    };
    struct compare_node_focal {
        bool operator()(const CBS_node* n1, const CBS_node* n2) const {

            return n1->num_conflict >= n2->num_conflict;

        }
    };

    list<Constraint> getAllConstraints() {
        list<Constraint> temp;

        for (const auto& constraint : constraint_list) {
            temp.push_back(constraint);
        }

        const CBS_node* curr = this;
        while (!curr->root) {
            for (const auto& constraint : curr->constraint_list) {
                temp.push_back(constraint);
            }
            curr = &curr->ptrparent;
        }

        return temp;
    }

    boost::heap::fibonacci_heap<CBS_node*, boost::heap::compare<CBS_node::compare_node>>::handle_type open_handle;
    boost::heap::fibonacci_heap<CBS_node*, boost::heap::compare<CBS_node::compare_node_focal>>::handle_type focal_handle;

    CBS_node() : ptrparent(*this), root(true), cost(0), id(0), num_conflict(0) {}
    CBS_node(const CBS_node& parent) : ptrparent(parent), root(false), parent_id(parent.id), paths(parent.paths), cost(0), id(parent.id + 1), num_conflict(0), open_handle(nullptr), focal_handle(nullptr){} // inherit constraints, paths and cost.
};


class A_node {
public: 
    Config config;    // x,y,r,t.
    A_node* parent = nullptr;

    int id;
    int g;
    int h;
    int f;
    int num_conflict;

    struct compare_node {
        bool operator()(const A_node* n1, const A_node* n2) const {
            return n1->f >= n2->f;
        }
    };

    struct compare_node_conflict {
        bool operator()(const A_node* n1, const A_node* n2) const {
            if (n1->f == n2->f) {
                return n1->num_conflict >= n2->num_conflict;
            }
            return n1->f >= n2->f;
        }
    };

    struct compare_conflict {
        bool operator()(const A_node* n1, const A_node* n2) const {

            return n1->num_conflict >= n2->num_conflict;

        }
    };

    struct compare_node_id {
        bool operator()(const A_node* n1, const A_node* n2) const {
            return n1->id >= n2->id;
        }
    };
    boost::heap::fibonacci_heap<A_node*, boost::heap::compare<A_node::compare_node>>::handle_type open_handle;
    boost::heap::fibonacci_heap<A_node*, boost::heap::compare<A_node::compare_conflict>>::handle_type focal_handle;
};



class CBS {
public:

    
    int expanded_count = 0;
    StageMap * map;
    int step_size = STEP_SIZE;
    int toio_size = 23;
    // precompute heuristic table.
    // from goals to every location.
    vector<std::map<tuple<int, int, int>, int>> h_table;

    vector<Path> find_solution(float w);
    int real_dist_heuristic(int agent_id, int x, int y, int z);
    void make_path(A_node* goal, Path& path);

    CBS(StageMap * plan_map) {map = plan_map;};

private:
    void precompute_h_table();
    int count_conflicts(const CBS_node& curr);
    bool find_conflicts_exact_goal_check(Collision& collision, vector<Path>& paths);
    vector<tuple<int, int, int>> get_exact_goal_blocked_locations(int x, int y, int z);
    bool find_conflicts(Collision& collision, vector<Path>& paths);
    int get_earliest_goal_timestep(int agent_id, int goal_x, int goal_y, int goal_z, const list<Constraint>& constraints);
    int get_latest_constraint(int agent_id, const list<Constraint>& constraints) const;
    bool is_constrained(int agent_id, int curr_loc_x, int curr_loc_y, int curr_loc_z, int next_loc_x, int next_loc_y, int next_loc_z, int next_t, const list<Constraint>& constraints) const;
   
    Path find_path(int agent_id, tuple<int, int, int>& start, tuple<int, int, int>& goal, vector<Path> & paths, const list<Constraint>& constraint_list);
    vector<Config> get_loc_neighbors(Config& location);
    vector<Config> get_neighbors(Config & location);
    bool next_to_tp_point(int x0, int y0, int x1, int y1, int step_size);
    bool check_body_collision(int x0, int y0, int x1, int y1);
    bool check_blocked_location(int x_loc, int y_loc, vector<vector<int>>& used_map);
};