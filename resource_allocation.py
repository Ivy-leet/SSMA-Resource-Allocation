import platform
import subprocess
import re
import math
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from gui import create_gui


class StrategySynthesis:
    Payload: float = 1
    NumRounds = 0
    A1GoalsAchieved: int = 0
    A2GoalsAchieved: int = 0
    
    Claims = {
        'safe': '([] (!s1) || [] (!s2))',
        'live': '(<>[] (!s1) || <>[] (!s2))',
        'payload': '[] (A1_goal_achieved + A2_goal_achieved <= alpha )'
    }
    
    def run_promela_program(self, claim: str, payload = 0):
        self.construct_ltl(claim)
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
        
        self.remove_ltl()
        
        return output
    
    @staticmethod
    def extract_output(output):
        # Define the patterns for the line immediately before and the line immediately after the target section
        before_pattern = r"pan: rate\s+\d+\.?\d+\s+states/second"
        after_pattern = r"spin: trail ends after\s+\d+\s+steps"

        # Use regular expression to find the section between the 'before' and 'after' lines
        match = re.search(f"{before_pattern}(.+?){after_pattern}", output, re.DOTALL)

        # Extract and print the result if the section is found
        if match:
            extracted_text = match.group(1)  # The text between before and after patterns
            print(extracted_text)
            
        
    @staticmethod
    def extract_variables(lines):
        goal_pattern = r'A\d+_goal_achieved = \d+'
        
        goals = re.findall(goal_pattern, lines)
        
        a1_goals_achieved = 0
        a2_goals_achieved = 0
        for goal_var in goals:
            goal = int(goal_var.split('=')[-1].strip())
            if 'A1' in goal_var:
                a1_goals_achieved = goal
            else:
                a2_goals_achieved = goal
                
        rounds_pattern = r'rounds = \d+'
        
        rounds = re.findall(rounds_pattern, lines)
        
        num_of_rounds = int(rounds[0].split('=')[-1].strip())
        
        return a1_goals_achieved, a2_goals_achieved, num_of_rounds
        
    
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
    
    
    def construct_ltl(self, claim):
        alpha = math.ceil(self.NumRounds * self.Payload)
        
        ltl = f'ltl {claim} {{ {self.Claims[claim]} }}'
        ltl = ltl.replace('alpha', str(alpha))
            
        f = open("resource_allocation.pml", "a")
        f.write(f'\n{ltl}\n')
        f.close()
        
        return ltl
    
    def define_ltl(self, claim):
        ltl = self.construct_ltl(claim)
        
        
        
    def remove_ltl(self):
        with open("resource_allocation.pml", "r+") as f:
            d = f.readlines()
            f.seek(0)
            for i in d:
                if 'ltl' not in i.strip('\n'):
                    f.write(i)
            f.truncate()
    
    def iterative_step(self):
        best_payload = self.run('safe')
        
        # payload = self.run('payload')
        # # i=0
        
        # best_scores = [best_payload]
        # while payload >= best_payload:
        #     if payload > best_payload:
        #         best_payload = payload
        #         best_scores.append(best_payload)
                
        #     payload = self.run('payload')
            
        # print(f'Best payload = {best_payload}, Best Scores: {best_scores}')
            
            
    def run(self, claim, should_create_gui: bool = True):
        output = self.run_promela_program(claim)
        
        model_output = StrategySynthesis.extract_output(output)
        
        a1_goals_achieved, a2_goals_achieved, num_of_rounds = StrategySynthesis.extract_variables(output)
        
        payoff = round( 1 / num_of_rounds * (a1_goals_achieved + a2_goals_achieved), 3)
        
        self.NumRounds, self.Payload = num_of_rounds, payoff
        
        uniform_strategy = StrategySynthesis.extract_state_info(output)
        
        if should_create_gui:
            create_gui(uniform_strategy, (a1_goals_achieved, a2_goals_achieved, num_of_rounds, payoff))
        
        return payoff
   
    def execute(self):
        self.iterative_step()
     
def main():
    try:
        SS = StrategySynthesis()
        SS.execute()
    except Exception:
        raise
     

if __name__ == '__main__':
    main()
    
