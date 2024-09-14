import subprocess
import re

def extract_info(line):
    bracket_substrings = []
    start = line.find('[')
    while start != -1:
        end = line.find(']', start)  # Include the closing bracket
        bracket_substrings.append(line[start+1:end])
        start = line.find('[', end)

    # Find the substring that starts with '='
    equal_substring = line.split('=')[-1].strip()  # Extracts everything after '=' and removes leading/trailing spaces

    # Combine the results
    result = bracket_substrings + [equal_substring]
    return result

result = subprocess.run(['spin', '-w', '-n1234', '-u500', 'resource_allocation.pml'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)

# Access the standard output and error
output = result.stdout
error = result.stderr

pattern = r"uniform\[\d+\]\.aa\[\d+\] = \d+"

uniform_array_string = re.findall(pattern, output)

# Join the extracted strings with newlines
result = "\n".join(uniform_array_string)

# Print the extracted result
print(result)

rows, cols = (16, 2)

uniform_strategy = [[0]*cols]*rows

lines = []
for line in result.splitlines():
    results = extract_info(line)
    x = int(results[0])
    y = int(results[1])
    action = int(results[2])
    print(f'x: {x}, y: {y}, action: {action}')
    uniform_strategy[x][y] = action
    lines.append(results)

print(uniform_strategy)


# print("Output:")
# print(output)
# print("Error:")
# print(error)