Resource allocation Promela Program

*****		Version 0.1		*****

In this promela program, there are 2 agents and 3 resources to be allocated. 
Agent one needs resource 1 and resource 2. Agent two needs resource 2 and resource 3.

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
	
	