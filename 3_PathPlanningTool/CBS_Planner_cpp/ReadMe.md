This is the CBS-based planner code for the disappearables_CHI2022 project. The code was tested on Ubuntu.

A license file for this c++ planner code will be added soon.

Author: Yi Zheng, Email: yzheng63@usc.edu

**Required Libraries**:

- cmake
- boost library for cpp

If you are using a Linux machine, run the following commands to install the two libraries. 

> apt-get install build-essential 
>
> apt-get install cmake 

**Installation**:

1. Compile and make the code by entering the following command lines in the CBS_Planner_cpp folder: 

   > cmake .  
   >
   > make

2. Copy the file "planner" to the Control UI folder "ControlUI_v1_1\CBS_planner".
3. The planner will be called when the "PLAN PATHS" button in the control UI is clicked.



