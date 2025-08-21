#!/bin/bash

# Check if the first argument is "combine"
if [ "$1" == "combine" ]; then
    # Get a list of all CSV files in the current directory except main.csv
	all_csvs=($(ls | grep -v main.csv | grep -E '\.csv$'))
	# If no CSV files found, exit with an error message
	if [ ${#all_csvs[@]} -eq 0 ]; then
	    echo "No csv files found"
	    exit 1
	fi
	# Set the first CSV file as focus
	focus=${all_csvs[0]}
	# Create the header line in main.csv
	echo "Roll_Number,Name,$(echo ${all_csvs[@]}|sed 's/ /,/g' | sed 's/.csv//g')" >  main.csv
	# Initialize count
	count=0
	# Loop through each CSV file
	for csv_file in "${all_csvs[@]}"; do
		# Initialize header flag
		header=true
		# Read each line of the CSV file
		while IFS=',' read -r roll name marks || [ -n "$roll" ]; do
			# Skip the header line
			if $header; then
				header=false
				continue
			fi
			# If roll number not found in main.csv, add a new row
			if ! awk -v roll="$roll" -F ',' '$1 == roll {found=1; exit} END {exit !found}' main.csv; then
				x=""
				# Add 'a' for each CSV file as placeholder for marks
				for ((i = 0; i < ${#all_csvs[@]}; i++)); do
				    x+="a,"
				done
				echo "${roll},${name},${x}" >> main.csv
			fi
			# Get the line with the corresponding roll number in main.csv
			line=$(awk -v roll="$roll" -F ',' '$1 == roll {print}' "main.csv")
			# Calculate the column index for marks
			column_index=$((count+3))
			# Split the line into an array
			IFS=',' read -r -a array <<< "$line"
			# Update the marks for the current CSV file
			array[$(($column_index - 1))]=$marks
			# Join the array elements into a string
			modified_string=$(IFS=','; echo "${array[*]}")
			# Replace the line with the updated string in main.csv
			sed -i "/^$roll,/c$modified_string" main.csv
		done < "$csv_file"
		# Increment count
		count=$((count+1))
	done
	
# Check if the first argument is "upload"
elif [ "$1" == "upload" ]; then
	# Copy the specified file to the current directory
	cp $2 .
	
# Check if the first argument is "total"
elif [ "$1" == "total" ]; then
	# Combine all CSV files into main.csv
	./$0 combine
	# Read each line of main.csv
	while IFS=',' read -r -a array; do
	
		if [ "${array[0]}" = "Roll_Number" ]; then
			sum="Total"
			
		else
			sum=0
			for ((i = 2; i < ${#array[@]}; i++)); do
				if [[ "${array[i]}" =~ ^[0-9]+$ ]]; then
					sum=$((sum + ${array[i]}))
				fi
			done
		fi

		# Modify the line to append the total marks
		modified_string=""
		for ((i = 0; i < ${#array[@]}; i++)); do
			if [ "${array[i]}" != $'\n' ]; then
				modified_string+="${array[i]}"
				modified_string+=','
			fi
		done
		IFS=','
		# Append the total marks to the line and write to temp.csv
		printf "%s,%s\n" "${array[*]}" "$sum" >> temp.csv
	done < main.csv
	# Remove main.csv and replace it with temp.csv
	rm main.csv
	mv temp.csv main.csv



# Check if the first argument is "git_init"
elif [ "$1" == "git_init" ]; then
	# Initialize a Git repository
	remote_repository=$2
	# Remove trailing slash if exists
	if [[ $remote_repository == */ ]]; then
		remote_repository=${remote_repository%/}
	fi
	# Create the repository directory if not exists
	if [ ! -e "$remote_repository" ]; then
		mkdir $remote_repository
	fi
	# Create .git_log file if not exists
	if [ ! -e "$remote_repository/.git_log" ]; then
		touch $remote_repository/.git_log
	fi
	# Store the repository path in .my_git file
	echo $remote_repository> .my_git


# Check if the first argument is "git_commit"
elif [ "$1" == "git_commit" ]; then
	# Check if .my_git file exists
	if [ ! -e "./.my_git" ]; then
		echo "no git repo found"
		exit 1
	fi
	# Get the remote repository path from .my_git
	if [ -s .my_git ]; then
	    remote_repository=$(cat .my_git)
	else
	    echo ".my_git is empty"
	    exit 1
	fi
	# Generate a random hash for the commit
	hash=$(printf "%04d%04d%04d%04d" $((RANDOM%10000)) $((RANDOM%10000)) $((RANDOM%10000)) $((RANDOM%10000)))
	# Create a directory with the hash as its name in the remote repository
	mkdir $remote_repository/$hash
	# Copy all files to the newly created directory
	cp -r * $remote_repository/$hash/
	# Check if commit message provided
	if [ "$2" == "-m" ]; then
		message=$3
	else
		echo -e "please enter message \n"
		read message
	fi
	# Display commit hash
	echo "commited hash:$hash"
	# Compare changes with the previous commit
	prev_commit=$(tail -n 1 $remote_repository/.git_log | awk -F ',' '{print $1}')
	if [ -z "$prev_commit" ]; then
    		echo "no previous commit found"
	else
    		diff $remote_repository/$hash $remote_repository/$prev_commit
	fi
	# Append commit hash and message to .git_log
	echo $hash,$message >> $remote_repository/.git_log
	#commit done
	
	
# Check if the first argument is "git_checkout"
elif [ "$1" == "git_checkout" ]; then
	# Check if .my_git file exists
	if [ ! -e "./.my_git" ]; then
		echo "no git repo found"
		exit 1
	fi
	# Get the remote repository path from .my_git
	if [ -s .my_git ]; then
	    remote_repository=$(cat .my_git)
	else
	    echo ".my_git is empty"
	    exit 1
	fi
	# If "-m" option is provided
	if [ "$2" = "-m" ]; then
		# Get commit hash from .git_log using the message
		string=$3
		line=$(awk -v msg="$string" -F ',' '$2 == msg {print}' "$remote_repository/.git_log")
		IFS=',' read -r -a array <<< "$line"
		hash=${array[0]}
		# Copy files from the commit directory to current directory
		cp "$remote_repository/$hash/"* .
	else
		# If prefix provided, find matching directories
		matches=("$remote_repository/$2"*/)
		num_matches=${#matches[@]}
		# If only one match found, copy files from it to current directory
		if [ $num_matches -eq 1 ]; then
			cp "${matches[0]}"/* .
		elif [ $num_matches -gt 1 ]; then
			# If multiple matches found, display error
			echo "Error: Multiple directories match the prefix '$prefix'"
			IFS=$'\n'
			echo "${matches[*]}"
			exit 1
		else
			# If no match found, display error
			echo "Error: No directories match the prefix '$prefix'"
			exit 1
		fi
	fi


elif [ "$1" == "git_log" ]; then
	# Check if .my_git file exists
	if [ ! -e "./.my_git" ]; then
		echo "no git repo found"
		exit 1
	fi
	# Get the remote repository path from .my_git
	if [ -s .my_git ]; then
	    remote_repository=$(cat .my_git)
	else
	    echo ".my_git is empty"
	    exit 1
	fi
    echo "Hash, message"
    cat $remote_repository/.git_log

# Check if the first argument is "update"
elif [ "$1" == "update" ]; then
    # Prompt user to enter roll number, name, exam, and marks
    echo -e "enter input in 4 separate lines \n <roll_number> \n <name> \n <exam> \n <marks>"
	read roll
	read name
	read exam
	read marks
    row=$(awk -v roll="$roll" -F, '$1==roll {print NR}' main.csv)

    if [ -z "$row" ]; then
        echo "Roll number not found"
        exit 1
    fi

    # Using awk to find the column number
    column_number=$(head -1 main.csv | awk -v exam="$exam" 'BEGIN{FS=","} {for (i=1; i<=NF; i++) if ($i == exam) print i}') 
    line=$(awk -v roll="$roll" -F ',' '$1 == roll {print}' "main.csv")
	IFS=',' read -r -a array <<< "$line"
	# Update the marks for the specified exam
	array[$(($column_number - 1))]=$marks
	name_in_list=${array[1]}
    if [ "$name_in_list" != "$name" ]; then
	echo "Error: $name_in_list is the correct name, updating regardless"
    fi
    modified_string=$(IFS=','; echo "${array[*]}")
    sed -i "/^$roll,/c$modified_string" main.csv

	# Append ".csv" to exam to match the filename
	exam+=.csv
	# Using awk to find the column number in the specified exam file
	column_number=$(head -1 $exam | awk 'BEGIN{FS=","} {for (i=1; i<=NF; i++) if ($i == "Marks") print i}') 
	# Get the line with the corresponding roll number in the exam file
	line=$(awk -v roll="$roll" -F ',' '$1 == roll {print}' "$exam")
	IFS=',' read -r -a array <<< "$line"
	# Update the marks for the specified exam in the exam file
	array[$(($column_number - 1))]=$marks
    modified_string=$(IFS=','; echo "${array[*]}")
    sed -i "/^$roll,/c$modified_string" $exam
    #to re calculate total marks in main after update
    if head -1 main.csv | grep -q "Total"; then
        ./$0 total
    fi

elif [ "$1" == "mean" ]; then
    python3 customizations.py mean
elif [ "$1" == "median" ]; then
    python3 customizations.py median
elif [ "$1" == "mode" ]; then
    python3 customizations.py mode
elif [ "$1" == "stdev" ]; then
    python3 customizations.py stdev
elif [ "$1" == "maximum" ]; then
    python3 customizations.py maximum
elif [ "$1" == "minimum" ]; then
    python3 customizations.py minimum
elif [ "$1" == "completestat" ]; then
    python3 customizations.py completestat
elif [ "$1" == "stat" ]; then
    python3 customizations.py stat $2
elif [ "$1" == "student" ]; then
    python3 customizations.py student $2 $3
fi
