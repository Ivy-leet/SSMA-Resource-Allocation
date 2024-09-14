/* Version 0.2.0 */

/* Constants */
#define R 4

/* Channels */
chan A1Env = [1] of {int};
chan A2Env = [1] of {int};
chan EnvA1 = [1] of {int};
chan EnvA2 = [1] of {int};

/* Demand */
int d1 = 2;
int d2 = 2;

/* Arrays */
byte resources[R];

typedef array {
	byte aa[2]
}

array uniform[16];

int helper = 0;

bool A1_written = false;
bool A2_written = false;


proctype Env() {
	int action_1 = 0;
	int action_2 = 0;
	
	Loop:
		
		do
		:: (A1_written == true && A2_written == true) -> break;
		od

		// do
		// :: (A2_written == true) -> break;
		// od
		// if
		// :: (helper == 2) -> {
		// 	A1Env?action_1;
		// 	A2Env?action_2;
		// }
		// :: else -> goto Loop;
		// fi
		

		A1Env?action_1;
		A2Env?action_2;
		
		int resource = -1;

		if
		:: (action_1 == action_2 && action_1 / 10 == 1 && action_2 / 10 == 1) -> atomic {
			EnvA1!0;
			EnvA2!0;

			A1_written = false;
			A2_written = false;

			goto Loop;
		}
		:: else -> skip;
		fi
		
		if /* request resource */
		:: (action_1 / 10 == 1 || action_2 / 10 == 1) ->
			if
			:: (action_1 != action_2) ->
				if
				:: ( action_1/10 == 1) -> 
					resource = action_1 % 10;
					printf("Resource requested by agent 1: %u\n", resource);
					if 
					:: (resource == 1 && resources[resource-1] == 0) -> resources[resource-1] = 1; d1 = d1 - 1;
					:: (resource == 2 && resources[resource-1] == 0) -> resources[resource-1] = 1; d1 = d1 - 1;
					:: (resource == 3 && resources[resource-1] == 0) -> resources[resource-1] = 1; d1 = d1 - 1;
					:: (resource == 4 && resources[resource-1] == 0) -> resources[resource-1] = 1; d1 = d1 - 1;
					:: else -> skip;
					fi
				:: else -> skip;
				fi
				
				if
				:: ( action_2/10 == 1) ->
					resource = action_2 % 10;
					printf("Resource requested by agent 2: %u\n", resource);
					if 
					:: (resource == 1 && resources[resource-1] == 0) -> resources[resource-1] = 2; d2 = d2 -1;
					:: (resource == 2 && resources[resource-1] == 0) -> resources[resource-1] = 2; d2 = d2 -1;
					:: (resource == 3 && resources[resource-1] == 0) -> resources[resource-1] = 2; d2 = d2 -1;
					:: (resource == 4 && resources[resource-1] == 0) -> resources[resource-1] = 2; d2 = d2 -1;
					:: else -> skip;
					fi
				:: else -> skip;
				fi
				
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		if /* release resource */
		:: (action_1 / 10 == 2) ->
			resource = action_1 % 10;
			printf("Resource released by agent 1: %u\n", resource);
			if
			:: (resource == 1) -> resources[resource-1] = 0; d1 = d1 + 1;
			:: (resource == 2) -> resources[resource-1] = 0; d1 = d1 + 1;
			:: (resource == 3) -> resources[resource-1] = 0; d1 = d1 + 1;
			:: (resource == 4) -> resources[resource-1] = 0; d1 = d1 + 1;
			:: (resource == 0) -> atomic{ /* release all */
				int i = 0;
				do
				:: i < R ->
					if
					:: resources[i] == 1 -> resources[i] = 0
					fi;
					i = i+1;
				:: else -> break;
				od;
				
				d1 = 2; 
			}
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		if /* release resource */
		:: (action_2 / 10 == 2) ->
			resource = action_2 % 10;
			printf("Resource released by agent 2: %u\n", resource);
			if
			:: (resource == 1) -> resources[resource-1] = 0; d2 = d2 + 1;
			:: (resource == 2) -> resources[resource-1] = 0; d2 = d2 + 1;
			:: (resource == 3) -> resources[resource-1] = 0; d2 = d2 + 1;
			:: (resource == 0) -> atomic{ /* release all */
				int i = 0;
				do
				:: i < R ->
					if
					:: resources[i] == 2 -> resources[i] = 0
					fi;
					i = i+1;
				:: else -> break;
				od;
				
				d2 = 2;
			}
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		// rounds = rounds + 1;
		
		EnvA1!action_1;
		EnvA2!action_2;

		A1_written = false;
		A2_written = false;
	
	goto Loop;
}


proctype A1() {
	int req_1 = 11;
	int req_2 = 12;
	int req_3 = 13;
	
	int rel_1 = 21;
	int rel_2 = 22;
	int rel_3 = 23;
	int rel_all = 20;
	
	int idle = 30;
	
	int observation = 0;
	int next_observation = 0;
	int row_access;
	
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:
		row_access = 0;
		int i = 0;

		/** Get row index */
		do
		:: i < R -> atomic {
			row_access = row_access + ((i+1)*resources[i]);
			i = i+1;
		}
		:: else -> break;
		od;
		
		int prev_action = uniform[row_access].aa[0];
		printf("previous action of agent 1: %u\n", prev_action);
		
		if 
		:: (prev_action == 0) -> {
			if 
			:: (d1 == 0) -> 
				atomic {
					printf("Agent 1 action: release all\n");
					helper = helper + 1;
					A1_written = true;
					A1Env!rel_all;
				}
			:: else -> { 
				if
				:: (resources[0] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 1\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!req_1;
					}
				:: (resources[1] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 2\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!req_2;
					}
				:: (resources[2] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 3\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!req_3;
					}
				:: (resources[0] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 1\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!rel_1;
					}
				:: (resources[1] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 2\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!rel_2;
					}
				:: (resources[2] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 3\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!rel_3;
					}
				:: (d1 > 0) -> 
					atomic {
						printf("Agent 1 action: idle\n");
						helper = helper + 1;
						A1_written = true;
						A1Env!idle;
					}
				fi
			}
			fi
		}
		:: else -> A1Env!(prev_action)
		fi
		
		EnvA1?next_observation;

		helper = helper - 1;
		A1_written = false;
			
		uniform[row_access].aa[0] = next_observation;
		
	goto Loop;
}


proctype A2() {
	int req_2 = 12;
	int req_3 = 13;
	int req_4 = 14;
	
	int rel_2 = 22;
	int rel_3 = 23;
	int rel_4 = 24;
	int rel_all = 20;
	
	int idle = 30;
	
	int observation = 0; // initial state - all resources are available
	int next_observation = 0;
	int row_access;
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:	
		do
		:: (A1_written == true) -> break;
		od

		row_access = 0;
		int i = 0;

		/** Get row index */
		do
		:: i < R -> atomic {
			row_access = row_access + ((i+1)*resources[i]);
			i = i+1;
		}
		:: else -> break;
		od;
		
		int prev_action = uniform[row_access].aa[1];
		printf("previous action of agent 2: %u\n", prev_action);
		
		if
		:: (prev_action == 0) -> {
			if 
			:: (d2 == 0) -> 
				atomic {
					printf("Agent 2 action: release all\n");
					helper = helper + 1;
					A2_written = true;
					A2Env!rel_all;
				}
			:: else -> {
				if
				:: (resources[1] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 2\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!req_2;
					}
				:: (resources[2] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 3\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!req_3;
					}
				:: (resources[3] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 4\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!req_4;
					}
				:: (resources[1] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 2\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!rel_2;
					}
				:: (resources[2] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 3\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!rel_3;
					}
				:: (resources[3] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 4\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!rel_4;
					}
				:: (d2 > 0) -> 
					atomic {
						printf("Agent 2 action: idle\n");
						helper = helper + 1;
						A2_written = true;
						A2Env!idle;
					}
				fi
			}
			fi
		}
		:: else -> A2Env!(prev_action)
		fi
		
		EnvA2?next_observation;

		helper = helper - 1;
		A2_written = false;
		
		uniform[row_access].aa[1] = next_observation;
		
	goto Loop;
}

init {
	/** initialise */
	int i=0;

	do
	:: i < R -> atomic{
		resources[i] = 0;
		i = i+1;
	}
	:: else -> break;
	od;

	int row = 0;
	

	do
	:: row < R*4 -> atomic{
		int column = 0;
		do
		:: column < 2 -> atomic{
			uniform[row].aa[column] = 0;
			column = column + 1;
		}
		:: else -> break;
		od;
		row = row + 1;
	}
	:: else -> break;
	od;

	atomic {
		run A1();
		run A2();
		run Env();
	}
}


// Properties for verification - Liveness (non-progress cycle)
ltl live { ([] d1 > 0) || ([] d2 > 0) }
