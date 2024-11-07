# SSMA-Resource-Allocation

## Resource allocation Promela Program

In this promela program, there are 2 agents and 4 resources to be allocated. 
Agent one needs resource 1, resource 2 and resource 3. Agent two needs resource 2, resource 3 and resource 4.

![agent_resource drawio](https://github.com/user-attachments/assets/12b7f7c9-2f01-4f55-aad5-3355b565a708)


The number of resources that each agents needs to allocate is as follows:
	d(A1) = 2 and d(A2) = 2
	
	
Mappings of Actions:
request = 10
release = 20
idle = 30

Mapping example:
	if Agent 2 requests for resource 1 then Act(A2) = 11 (10 + 1)
	if Agent 1 releases Resource 2 then Act(A1) = 22 (20 + 2)
	if Agent 1 releases all resources then Act(A1) = 20


### Before running..
Before running the program please ensure that the following python libraries are installed:
1. `numpy`
2. `seaborn`
3. `matplotlib`

### How to run the code
1. The script can be executed by running `python resource_allocation.py` in the terminal

### Expected Outputs
- A GUI is expected to appear with information about the state observations and the variables of the MRA.
- Output of verification can be found in a text file `output.txt`

