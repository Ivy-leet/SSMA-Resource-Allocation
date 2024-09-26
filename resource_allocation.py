import platform
import subprocess
import re
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns


def run_promela_program():
    file_extension = 'sh'
    
    if platform.system() == 'Windows':
        file_extension = 'bat'
        
    result = subprocess.run(['sh', f'resource_allocation.{file_extension}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)

    # Access the standard output and error
    output = result.stdout
    error = result.stderr
    
    if error:
        raise Exception(error)

    f = open('output.txt', 'w')
    f.write(output)
    f.close()
    
    return output
    
def extract_info(line):
    bracket_substrings = []
    start = line.find('[')
    while start != -1:
        end = line.find(']', start)
        bracket_substrings.append(line[start+1:end])
        start = line.find('[', end)
        
    equal_substring = line.split('=')[-1].strip()

    result = bracket_substrings + [equal_substring]
    return result
   
def create_heatmap(uniform_strategies):
    max_x = max([d[0] for d in uniform_strategies]) + 1
    max_y = max([d[1] for d in uniform_strategies]) + 1

    matrix = np.zeros((max_x, max_y))

    for item in uniform_strategies:
        x, y, value = item
        matrix[x, y] = value

    # Plotting the heatmap
    plt.figure(figsize=(10, 8))
    sns.heatmap(matrix, annot=True, cmap='coolwarm', cbar=True, linewidths=0.5)

    plt.title("Resource Allocation Uniform Strategy")
    plt.xlabel("Values")
    plt.ylabel("State")
    plt.show()
     
def main():
    try:
        output = run_promela_program()
        
        # get uniform strategy 2D array
        pattern = r"uniform\[\d+\]\.aa\[\d+\] = [+-]?\d+"

        uniform_array_string = re.findall(pattern, output)

        result = "\n".join(uniform_array_string)
        
        uniform_strategy = []
        for line in result.splitlines():
            results = extract_info(line)
            uniform_strategy.append([int(i) for i in results])
        
        create_heatmap(uniform_strategy)
    except Exception:
        raise
    

if __name__ == '__main__':
    main()
    
