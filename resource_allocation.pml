/* Version 1.0 */

/* Constants */
#define R 4

/** Actions Encoding */
int req_1 = 11;
int req_2 = 12;
int req_3 = 13;
int req_4 = 14;

int rel_1 = 21;
int rel_2 = 22;
int rel_3 = 23;
int rel_4 = 24;
int rel_all = 20;

int idle = 30;


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
	int aa[6]
}

array uniform[32];

bool hasGoalAchieved = false;

int rounds = 0;

int A1_goal_achieved = 0;
int A2_goal_achieved = 0;


proctype Env() {
	int action_1 = 0;
	int action_2 = 0;

	int row = 0;

	int state = 0;
	bool state_found = false;
	
	Loop:
		state = -1;
		
		/** New way of getting index */
		row = 0;
		bool row_found = false;
		do
		:: row < 32 -> atomic{
			int column = 0;
			do
			:: column < 4 -> {
				if
				:: (uniform[row].aa[column] != resources[column]) -> {
					state_found = false;
					break;
				}
				:: else -> {
					state_found = true;
					column = column + 1;
				}
				fi
			}
			:: else -> break;
			od;

			if
			:: (state_found == true) -> {
				state = row;
				break;
			}
			:: else -> {
				row = row + 1;
			}
			fi
		}
		:: else -> break;
		od;

		EnvA1!state;
		EnvA2!state;

		if
		:: (state_found == false) -> {
			row = 0;
			do
			:: row < 32 -> atomic{
				int column = 0;
				if
				:: (uniform[row].aa[0] == -1) -> {
					state = row;
					do
					:: column < 4 -> {
						uniform[row].aa[column] = resources[column];
						column = column + 1;
					}
					:: else -> break;
					od
					break;
				}
				:: else -> skip;
				fi
				row = row + 1;
			}
			:: else -> break;
			od;
		}
		:: else -> { 
			skip;
		}
		fi
		

		A1Env?action_1;
		A2Env?action_2;
		
		int resource = -1;

		if
		:: (action_1 == action_2 && action_1 / 10 == 1 && action_2 / 10 == 1) -> atomic {
			printf("Same resource (%u) requested by agent 1 and agent 2! Doing nothing...", resource);
			EnvA1!0;
			EnvA2!0;

			goto Loop;
		}
		:: else -> skip;
		fi

		uniform[state].aa[4] = action_1;
		uniform[state].aa[5] = action_2;
		
		if /* request resource */
		:: (action_1 / 10 == 1 || action_2 / 10 == 1) ->
			if
			:: (action_1 != action_2) ->
				if
				:: ( action_1/10 == 1) -> 
					resource = action_1 % 10;
					printf("Env: Resource requested by agent 1: %u\n", resource);
					if 
					:: (resources[resource-1] == 0) -> resources[resource-1] = 1; d1 = d1 - 1;
					:: else -> skip;
					fi
					printf("Resource granted to agent 1: %u\n", resource);
				:: else -> skip;
				fi
				
				if
				:: ( action_2/10 == 1) ->
					resource = action_2 % 10;
					printf("Env: Resource requested by agent 2: %u\n", resource);
					if 
					:: (resources[resource-1] == 0) -> resources[resource-1] = 2; d2 = d2 -1;
					:: else -> skip;
					fi
					printf("Resource granted to agent 2: %u\n", resource);
				:: else -> skip;
				fi
				
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		if /* release resource */
		:: (action_1 / 10 == 2) -> {
			resource = action_1 % 10;
			if
			:: (resource == 0) -> { /* release all */
				printf("Agent 2 releases all assigned resources\n")
				int i = 0;
				do
				:: i < R ->
					if
					:: resources[i] == 1 -> resources[i] = 0;
					:: else -> skip;
					fi;
					i = i+1;
				:: else -> break;
				od;

				hasGoalAchieved = true;
				A1_goal_achieved++;
A1GoalAchieved:	d1 = 2; 
			}
			:: else -> atomic {
				printf("Resource released by agent 1: %u\n", resource);
				resources[resource-1] = 0; 
				d1 = d1 + 1;
			}
			fi
		}
		:: else -> skip;
		fi
		
		if /* release resource */
		:: (action_2 / 10 == 2) ->
			resource = action_2 % 10;
			if
			:: (resource == 0) -> { /* release all */
				printf("Agent 2 releases all assigned resources\n")
				int i = 0;
				do
				:: i < R ->
					if
					:: resources[i] == 2 -> resources[i] = 0;
					:: else -> skip;
					fi;
					i = i+1;
				:: else -> break;
				od;
				
				A2_goal_achieved++;
				hasGoalAchieved = true;
A2GoalAchieved:	d2 = 2;
			}
			:: else -> {
				printf("Resource released by agent 2: %u\n", resource);
				resources[resource-1] = 0; d2 = d2 + 1;
			}
			fi
		:: else -> skip;
		fi

		if
		:: (hasGoalAchieved) -> rounds++;
		:: else -> skip;
		fi
		
		EnvA1!action_1;
end:	EnvA2!action_2;
	
	goto Loop;
}


proctype A1() {
	int agent = 4;
	
	int next_observation = 0;
	int row_access;
	
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:
		row_access = 0;

		EnvA1?row_access;
		
		int prev_action = 0;
		if
		:: (row_access != -1) -> {
			prev_action = uniform[row_access].aa[agent];
		}
		:: else -> skip;
		fi

		if 
		:: (prev_action == 0) -> {
			if 
			:: (d1 == 0) -> 
				atomic {
					printf("Agent 1 action: release all\n");
					A1Env!rel_all;
				}
			:: else -> { 
				if
				:: (resources[0] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 1\n");
						A1Env!req_1;
					}
				:: (resources[1] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 2\n");
						A1Env!req_2;
					}
				:: (resources[2] == 0) -> 
					atomic {
						printf("Agent 1 action: request resource 3\n");
						A1Env!req_3;
					}
				:: (resources[0] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 1\n");
						A1Env!rel_1;
					}
				:: (resources[1] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 2\n");
						A1Env!rel_2;
					}
				:: (resources[2] == 1) -> 
					atomic {
						printf("Agent 1 action: release resource 3\n");
						A1Env!rel_3;
					}
				:: (d1 > 0) -> 
					atomic {
						printf("Agent 1 action: idle\n");
						A1Env!idle;
					}
				fi
			}
			fi
		}
		:: else -> atomic {
			printf("Agent 1 State observation at state %u: %u\n", row_access, prev_action);
			A1Env!(prev_action);
		}
		fi
		
		EnvA1?next_observation;

	goto Loop;
}


proctype A2() {
	int agent = 5;
	
	int next_observation = 0;
	int row_access;
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:

		row_access = 0;

		EnvA2?row_access;

		int prev_action = 0;
		if
		:: (row_access != -1) -> {
			prev_action = uniform[row_access].aa[agent];
		}
		:: else -> skip;
		fi
		
		if
		:: (prev_action == 0) -> {
			if 
			:: (d2 == 0) -> 
				atomic {
					printf("Agent 2 action: release all\n");
					A2Env!rel_all;
				}
			:: else -> {
				if
				:: (resources[1] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 2\n");
						A2Env!req_2;
					}
				:: (resources[2] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 3\n");
						A2Env!req_3;
					}
				:: (resources[3] == 0) -> 
					atomic {
						printf("Agent 2 action: request resource 4\n");
						A2Env!req_4;
					}
				:: (resources[1] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 2\n");
						A2Env!rel_2;
					}
				:: (resources[2] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 3\n");
						A2Env!rel_3;
					}
				:: (resources[3] == 2) -> 
					atomic {
						printf("Agent 2 action: release resource 4\n");
						A2Env!rel_4;
					}
				:: (d2 > 0) -> 
					atomic {
						printf("Agent 2 action: idle\n");
						A2Env!idle;
				}
				fi
			}
			fi
		}
		:: else -> atomic {
			printf("Agent 2 State observation at state %u: %u\n", row_access, prev_action);
			A2Env!(prev_action);
		}
		fi
		
		EnvA2?next_observation;

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
	:: row < 32 -> atomic{
		int column = 0;
		do
		:: column < 6 -> {
			uniform[row].aa[column] = -1;
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

#define s1 (Env@A1GoalAchieved)
#define s2 (Env@A2GoalAchieved)

// Properties for verification - Liveness (non-progress cycle)
