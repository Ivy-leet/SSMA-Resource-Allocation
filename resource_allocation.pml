/* Version 0.1 */

/* Channels */
chan A1Env = [0] of {int};
chan A2Env = [0] of {int};
chan EnvA1 = [0] of {int};
chan EnvA2 = [0] of {int};

/* Resources */
int r1 = 0;
int r2 = 0;
int r3 = 0;

/* Demand */
int d1 = 2;
int d2 = 2;


proctype Env() {
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
			:: (action_1 % 10 == 0) -> /* release all */
				if 
				:: (r1 == 1) -> r1 = 0;
				:: (r2 == 1) -> r2 = 0;
				:: (r3 == 1) -> r3 = 0;
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
			:: (action_2 % 10 == 1) -> 
					r1 = 0; d2 = d2 + 1;
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
				
				d2 = 2;
			:: else -> skip;
			fi
		:: else -> skip;
		fi
		
		EnvA1!action_1;
		EnvA2!action_2;
	
	goto Loop;
}


proctype A1() {
	int req_1 = 11;
	int req_2 = 12;
	
	int rel_1 = 21;
	int rel_2 = 22;
	int rel_all = 20;
	
	int idle = 30;
	
	
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:
	
		if 
		:: (d1 == 0) -> 
			atomic {
				A1Env!rel_all;
				prinf("Agent 1 action: release all");
			}
		:: (r1 == 0) -> 
			atomic {
				A1Env!req_1;
				prinf("Agent 1 action: request resource 1");
			}
		:: (r2 == 0) -> 
			atomic {
				A1Env!req_2;
				prinf("Agent 1 action: request resource 2");
			}
		:: (r1 == 1) -> 
			atomic {
				A1Env!rel_1;
				prinf("Agent 1 action: release resource 1");
			}
		:: (r2 == 1) -> 
			atomic {
				A1Env!rel_2;
				prinf("Agent 1 action: release resource 2");
			}
		:: (d1 > 0) -> 
			atomic {
				A1Env!idle;
				prinf("Agent 1 action: idle");
			}
		fi
		
		int action = 0;
		EnvA1?action;
		
	goto Loop;
}


proctype A2() {
	int req_2 = 12;
	int req_3 = 13;
	
	int rel_2 = 22;
	int rel_3 = 23;
	int rel_all = 20;
	
	int idle = 30;
	
	/* Need to wait for Env to complete one round before going for another */
	Loop:		
		if 
		:: (d2 == 0) -> 
			atomic {
				A2Env!rel_all;
				prinf("Agent 2 action: release all");
			}
		:: (r2 == 0) -> 
			atomic {
				A2Env!req_2;
				prinf("Agent 2 action: request resource 2");
			}
		:: (r3 == 0) -> 
			atomic {
				A2Env!req_3;
				prinf("Agent 2 action: request resource 3");
			}
		:: (r2 == 1) -> 
			atomic {
				A2Env!rel_2;
				prinf("Agent 2 action: release resource 2");
			}
		:: (r3 == 1) -> 
			atomic {
				A2Env!rel_3;
				prinf("Agent 2 action: release resource 3");
			}
		:: (d2 > 0) -> 
			atomic {
				A2Env!idle;
				prinf("Agent 2 action: idle");
			}
		fi
		
		int action = 0;
		EnvA2?action;
		
	goto Loop;
}

init {
	run Env();
	run A1();
	run A2();
}