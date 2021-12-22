#include "map_load.h"

void StageMap::load_init_map(string filepath) {
	string line;
	ifstream myfile(filepath.c_str());


	if (myfile.is_open())
	{
		getline(myfile, line);
		char_separator<char> sep(",");
		tokenizer< char_separator<char> > tok(line, sep);
		tokenizer< char_separator<char> >::iterator beg = tok.begin();

	}

}