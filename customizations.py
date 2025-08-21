import pandas as pd
import numpy as np
import sys
import matplotlib.pyplot as plt

def convert_to_int(arr):
    # Convert the array to Unicode strings
    arr = arr.astype(str)
    
    # Replace non-numeric values with '0'
    arr[~np.char.isdigit(arr)] = '0'
    
    # Convert the array to integer data type
    arr = arr.astype(int)
    
    return arr


def plot_bar_graph(data,xlabel,ylabel,title):
    
    # Extract keys and values from the dictionary
    keys = list(data.keys())
    values = list(data.values())

    plt.clf()

    # Create bar graph
    plt.bar(keys, values)

    # Add labels and title
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)

    # Show plot
    
    plt.savefig(ylabel + '.png')
    plt.show()
    
    
def calc(arrays,argument) :
    
    all_calc = {}
    
    for name, array in arrays.items():
        
        if name == 'Name' or name == 'Roll_Number' :
            continue
        
        single_calc = None
        
        if argument == 'mean' :
            single_calc = np.round(np.mean(array),2)
        elif argument == 'median' :
            single_calc = np.round(np.median(array),2)
        elif argument == 'mode' :
            unique, counts = np.unique(array, return_counts=True)
            single_calc = unique[np.argmax(counts)]
        elif argument == 'stdev' :
            single_calc = np.round(np.std(array),2)
        elif argument == 'maximum' :
            single_calc = np.round(max(array),2)
        elif argument == 'minimum' :
            single_calc = np.round(min(array),2)
        
        all_calc[name] = single_calc
        
        print(f"{argument} in {name} is : {single_calc}")
        
    plot_bar_graph(all_calc,'Exams',argument,argument + ' bar graph')
    
    
def find(arrays) :
    
    name = sys.argv[2]
    roll_no = sys.argv[3]
    
    temp = list(roll_no)
    temp[2] = 'b'
    roll_no = ''.join(temp)
    
    if roll_no in arrays['Roll_Number'] :
        index = np.where(arrays['Roll_Number'] == roll_no)[0][0]
        
        if arrays['Name'][index] != name :
            print(f"Roll number is present in array but the name hasn't matched and his name is {arrays['Name'][index]}")
            return
        
        print(f'name of the student is : {name}')
        print(f'roll number of the student : {roll_no}')
        
        for name , array in arrays.items() :
            
            if name == 'Name' or name == 'Roll_Number' :
                continue
            
            print(f'score in {name} is : {array[index]}')
            
        return
            
    temp = list(roll_no)
    temp[2] = 'B'
    roll_no = ''.join(temp)
            
    if roll_no in arrays['Roll_Number'] :
        index = np.where(arrays['Roll_Number'] == roll_no)[0][0]
        
        if arrays['Name'][index] != name :
            print("Roll number is present in array but the name hasn't matched")
            return
        
        print(f'name of the student is : {name}')
        print(f'roll number of the student : {roll_no}')
        
        for name , array in arrays.items() :
            
            if name == 'Name' or name == 'Roll_Number' :
                continue
            
            print(f'score in {name} is : {array[index]}')   
    else :
        print("given roll number is not present in the list")         


def stat(arrays,exam) :
    
    stats = {}
    
    if exam in arrays :
        temp = np.round(np.mean(arrays[exam]),2)
        stats['mean'] = temp
        print(f"mean in {exam} is : {temp}")   
         
        temp = np.round(np.median(arrays[exam]),2)
        stats['median'] = temp
        print(f"median in {exam} is : {temp}") 
        
        unique, counts = np.unique(arrays[exam], return_counts=True)  
        temp = unique[np.argmax(counts)]
        stats['mode'] = temp          
        print(f"mode in {exam} is : {temp}")
        
        temp = np.round(np.std(arrays[exam]),2)
        stats['stdev'] = temp
        print(f"standard deviation in {exam} is : {temp}")  
        
        temp = np.round(max(arrays[exam]),2)
        stats['maximum'] = temp
        print(f"maximum in {exam} is : {temp}") 
        
        temp = np.round(min(arrays[exam]),2)
        stats['minimum'] = temp
        print(f"minimum in {exam} is : {temp}")   
        
        plot_bar_graph(stats,'Exams','score','stats bar graph')
    else :
        print("Given exam is not in the list of exams")           
    
 
def completestat(arrays) :
    
    calc(arrays,'mean')
    print()
    calc(arrays,'median')
    print()
    calc(arrays,'mode')
    print()
    calc(arrays,'stdev')
    print()
    calc(arrays,'maximum')
    print()
    calc(arrays,'minimum')


def main():
    
    # Check if the correct number of arguments is provided
    if len(sys.argv) < 2:
        print("Usage: python script_name.py arguments")
        return
    
    # Get the argument from the command line
    argument = sys.argv[1]

    # Use pandas to read the CSV file
    file_path = 'main.csv'
    df = pd.read_csv(file_path)
    
    if argument == 'student' :
        if len(sys.argv) < 4:
            print("Usage: python script_name.py student <name> <roll_no> ")
            return 
        
        arrays = {}
        for column in df.columns:
            arrays[column] = np.array(df[column]) 
            
        find(arrays)
        
        return
                   
    # Convert each column into a NumPy array with row index as the array name
    arrays = {}
    for column in df.columns:
        arrays[column] = np.array(df[column])

        if (column != 'Name' and column != 'Roll_Number')  and isinstance(arrays[column][0], str):
            arrays[column] = convert_to_int(arrays[column])
        

    if argument == 'mean'  or argument == 'median' or argument == 'mode' or argument == 'stdev' or argument == 'maximum' or argument == 'minimum' :
        calc(arrays,argument)
    elif argument == 'completestat' :
        completestat(arrays)
    elif argument == 'stat' :
        if len(sys.argv) != 3:
            print("Usage: python script_name.py argument <test_name>")
            return
        stat(arrays,sys.argv[2])
    else :
        print("given command is not present")
        
    
if __name__ == "__main__":
    main()