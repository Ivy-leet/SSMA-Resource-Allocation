import platform
import subprocess
import re
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from gui import create_gui


class StrategySynthesis:
    Payload = 1
    
    
    @staticmethod
    def run_promela_program(claim: str):
        result = subprocess.run(['sh', 'resource_allocation.sh', claim], 
                                capture_output=True,
                                text=True, 
                                shell=False,
                                creationflags=subprocess.CREATE_NO_WINDOW)

        # Access the standard output and error
        output = result.stdout
        error = result.stderr
        code = result.check_returncode()
        
        if code:
            raise Exception(f'Return code: {code} \n{error}')

        f = open('output.txt', 'w')
        f.write(output)
        f.close()
        
        return output
    
    @staticmethod
    def extract_variables(lines):
        goal_pattern = r'A\d+_goal_achieved = \d+'
        
        goals = re.findall(goal_pattern, lines)
        
        a1_goals_achieved = 0
        a2_goals_achieved = 0
        for goal_var in goals:
            goal = goal_var.split('=')[-1]
            if 'A1' in goal_var:
                a1_goals_achieved = goal
            else:
                a2_goals_achieved = goal
        
        return (a1_goals_achieved, a2_goals_achieved)
        
    
    @staticmethod
    def extract_state_info(lines):
        # get uniform strategy 2D array
        pattern = r'uniform\[\d+\]\.aa\[\d+\] = \d+'

        uniform_array_string = re.findall(pattern, lines)

        result = '\n'.join(uniform_array_string)
        
        uniform_strategy = []
        for line in result.splitlines():
            bracket_substrings = []
            start = line.find('[')
            while start != -1:
                end = line.find(']', start)
                bracket_substrings.append(line[start+1:end])
                start = line.find('[', end)
                
            equal_substring = line.split('=')[-1].strip()

            result = bracket_substrings + [equal_substring]
            uniform_strategy.append([int(i) for i in result])
            
        
        return uniform_strategy

    def iterative_step(self, claim):
        
        
        for claim in claims:
            run(claim)
            
    def run(self, claim):
        output = StrategySynthesis.run_promela_program(claim)
        
        goals = StrategySynthesis.extract_variables(output)
        uniform_strategy = StrategySynthesis.extract_state_info(output)
        
        create_gui(uniform_strategy)
   
    def execute(self):
        claims = ['live']
        for claim in claims:
            self.run(claim)
        # iterative_step()
     
def main():
    try:
        SS = StrategySynthesis()
        SS.execute()
    except Exception:
        raise
     

if __name__ == '__main__':
    main()
    
