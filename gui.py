import tkinter
import numpy as np
import seaborn as sns
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from PIL import ImageGrab

def init_gui(root, uniform_strategies):
    figure = create_heatmap(uniform_strategies)
    canvas = FigureCanvasTkAgg(figure, master=root)
    canvas.draw()    
    canvas.get_tk_widget().pack(side=tkinter.TOP, fill=tkinter.BOTH, expand=1)
    return canvas

def place_label(root, variables):
    text = f'''
        Goals achieved Agent 1:     {variables[0]}
        Goals achieved Agent 2:     {variables[1]}
        Number of Rounds:           {variables[2]}
        Payoff:                     {variables[3]}
    '''
    label = tkinter.Label(root, text=text, bg='white', justify=tkinter.LEFT, padx = 10, font=("Helvetica", 14))
    
    label.pack()

def create_heatmap(uniform_strategies):
    max_x = max([d[0] for d in uniform_strategies]) + 1
    max_y = max([d[1] for d in uniform_strategies]) + 1

    matrix = np.zeros((max_x, max_y))

    for item in uniform_strategies:
        x, y, value = item
        matrix[x, y] = value

    # Plotting the heatmap
    figure = Figure(figsize=(10, 8))
    ax = figure.subplots()
    sns.heatmap(matrix, annot=True, cmap='coolwarm', cbar=False, linewidths=0.5, ax=ax)
    ax.set_xlabel('Resources Allocation') 
    ax.set_ylabel('Number of Distinct Rounds')
    figure.savefig("out.png") 
    return figure

def capture_window(root):
    x = root.winfo_rootx()
    y = root.winfo_rooty()
    width = root.winfo_width()
    height = root.winfo_height()    #get details about window
    takescreenshot = ImageGrab.grab(bbox=(x, y, width, height))
    takescreenshot.save("screenshot.png")

def create_gui(uniform_strategies, variables):
    root = tkinter.Tk()
    
    root.configure(bg='white')
    
    place_label(root, variables)
    canvas = init_gui(root, uniform_strategies)
    
    tkinter.mainloop()
    