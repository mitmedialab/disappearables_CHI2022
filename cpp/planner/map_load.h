
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include<boost/tokenizer.hpp>

using namespace std;

class StageMap {

public:
	void load_init_map(string filepath);
	void convert_init_map();
	vector<vector<int>> init_map; // linearized map. Int => location status, 0 = free, 1= blocked, 

	// converted map.
	StageMap() {};
};