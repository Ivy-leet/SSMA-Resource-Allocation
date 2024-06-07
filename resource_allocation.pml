/* Version 0.1.1 */

/* Channels */
chan A1Env = [0] of {int};
chan A2Env = [0] of {int};
chan EnvA1 = [0] of {int};
chan EnvA2 = [0] of {int};

/* Resources */
int r1 = 0;
int r2 = 0;
int r3 = 0;
int r4 = 0;

/* Demand */
int d1 = 2;
int d2 = 2;


typedef array {
	byte aa[2]
}


active proctype Env() {
	int action_1 = 0;
	int action_2 = 0;
	
	Loop:
		
		
		A1Env?action_1;
		A2Env?action_2;
		
		
		if /* request resource */
		:: (action_1 / 10 == 1 || action_2 / 10 == 1) ->
			if
			:: (action_1 != action_2) ->
				if
				:: ( action_1/10 == 1) -> 
					if 
					:: (action_1 % 10 == 1 && r1 == 0) -> r1 = 1; d1 = d1 - 1;
					:: (action_1 % 10 == 2 && r2 == 0) -> r2 = 1; d1 = d1 - 1;
					:: (action_1 % 10 == 3 && r3 == 0) -> r3 = 1; d1 = d1 - 1;
					:: (action_1 % 10 == 4 && r4 == 0) -> r4 = 1; d1 = d1 - 1;
					:: else -> skip;
					fi
				:: else -> skip;
				fi
				
				if
				:: ( action_2/10 == 1) ->
					if 
					:: (action_2 % 10 == 1 && r1 == 0) -> r1 = 2; d2 = d2 -1;
					:: (action_2 % 10 == 2 && r2 == 0) -> r2 = 2; d2 = d2 -1;
					:: (action_2 % 10 == 3 && r3 == 0) -> r3 = 2; d2 = d2 -1;
					:: (action_2 % 10 == 4 && r4 == 0) -> r4 = 2; d2 = d2 -1;
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
			if
			:: (action_1 % 10 == 1) -> r1 = 0; d1 = d1 + 1;
			:: (action_1 % 10 == 2) -> r2 = 0; d1 = d1 + 1;
			:: (action_1 % 10 == 3) -> r3 = 0; d1 = d1 + 1;
			:: (action_1 % 10 == 4) -> r4 = 0; d1 = d1 + 1;
			:: (action_1 % 10 == 0) -> /* release all */
				if 
				:: (r1 == 1) -> r1 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r2 == 1) -> r2 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r3 == 1) -> r3 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r4 == 1) -> r4 = 0;
				:: else -> skip;
				fi
				d1 = 2; 
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		if /* release resource */
		:: (action_2 / 10 == 2) ->
			if
			:: (action_2 % 10 == 1) -> r1 = 0; d2 = d2 + 1;
			:: (action_2 % 10 == 2) -> r2 = 0; d2 = d2 + 1;
			:: (action_2 % 10 == 3) -> r3 = 0; d2 = d2 + 1;
			:: (action_2 % 10 == 0) -> /* release all */
				if 
				:: (r1 == 2) -> r1 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r2 == 2) -> r2 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r3 == 2) -> r3 = 0;
				:: else -> skip;
				fi
				
				if 
				:: (r4 == 2) -> r4 = 0;
				:: else -> skip;
				fi
				
				d2 = 2;
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		// rounds = rounds + 1;
		
		EnvA1!action_1;
		EnvA2!action_2;
	
	goto Loop;
}


active proctype A1() {
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
	int row = 0;
	
	
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:
		row = observation % 10;
		
		
		if 
		:: (uniform[row].aa[0] == 0) -> {
			if 
			:: (d1 == 0) -> 
				atomic {
					A1Env!rel_all;
					printf("Agent 1 action: release all\n");
				}
			:: (r1 == 0) -> 
				atomic {
					A1Env!req_1;
					printf("Agent 1 action: request resource 1\n");
				}
			:: (r2 == 0) -> 
				atomic {
					A1Env!req_2;
					printf("Agent 1 action: request resource 2\n");
				}
			:: (r3 == 0) -> 
				atomic {
					A1Env!req_3;
					printf("Agent 1 action: request resource 3\n");
				}
			:: (r1 == 1) -> 
				atomic {
					A1Env!rel_1;
					printf("Agent 1 action: release resource 1\n");
				}
			:: (r2 == 1) -> 
				atomic {
					A1Env!rel_2;
					printf("Agent 1 action: release resource 2\n");
				}
			:: (r3 == 1) -> 
				atomic {
					A1Env!rel_3;
					printf("Agent 1 action: release resource 3\n");
				}
			:: (d1 > 0) -> 
				atomic {
					A1Env!idle;
					printf("Agent 1 action: idle\n");
				}
			fi
		}
		:: else -> A1Env!(uniform[row].aa[0])
		fi
		
		EnvA1?next_observation;
		
		row = next_observation % 10;		
		uniform[row].aa[0] = next_observation;
		observation = next_observation;
		
	goto Loop;
}


active proctype A2() {
	int req_2 = 12;
	int req_3 = 13;
	int req_4 = 14;
	
	int rel_2 = 22;
	int rel_3 = 23;
	int rel_4 = 24;
	int rel_all = 20;
	
	int idle = 30;
	
	int observation = 0;
	int next_observation = 0;
	int row = 0;
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:	
		row = observation % 10;
		
		if
		:: (uniform[row].aa[1] == 0) -> {
			if 
			:: (d2 == 0) -> 
				atomic {
					A2Env!rel_all;
					printf("Agent 2 action: release all\n");
				}
			:: (r2 == 0) -> 
				atomic {
					A2Env!req_2;
					printf("Agent 2 action: request resource 2\n");
				}
			:: (r3 == 0) -> 
				atomic {
					A2Env!req_3;
					printf("Agent 2 action: request resource 3\n");
				}
			:: (r4 == 0) -> 
				atomic {
					A2Env!req_4;
					printf("Agent 2 action: request resource 4\n");
				}
			:: (r2 == 2) -> 
				atomic {
					A2Env!rel_2;
					printf("Agent 2 action: release resource 2\n");
				}
			:: (r3 == 2) -> 
				atomic {
					A2Env!rel_3;
					printf("Agent 2 action: release resource 3\n");
				}
			:: (r4 == 2) -> 
				atomic {
					A2Env!rel_4;
					printf("Agent 2 action: release resource 4\n");
				}
			:: (d2 > 0) -> 
				atomic {
					A2Env!idle;
					printf("Agent 2 action: idle\n");
				}
			fi
		}
		:: else -> A2Env!(uniform[row].aa[0])
		fi
		
		EnvA2?next_observation;
		
		row = next_observation % 10;		
		uniform[row].aa[1] = next_observation;
		observation = next_observation;
		
	goto Loop;
}

init {
	array uniform[5];
	
	uniform[0].aa[0] = 0;
	uniform[0].aa[1] = 0;
	uniform[1].aa[0] = 0;
	uniform[1].aa[1] = 0;
	uniform[2].aa[0] = 0;
	uniform[2].aa[1] = 0;
	uniform[3].aa[0] = 0;
	uniform[3].aa[1] = 0;
	uniform[4].aa[0] = 0;
	uniform[4].aa[1] = 0;
	
}


// Properties for verification - Liveness (non-progress cycle)
ltl live { (<>[] d1 > 0) || (<>[] d2 > 0) }
