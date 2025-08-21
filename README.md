#Commands

Combine CSVs :- ./script.sh combine

Upload CSVs  :- ./script.sh upload path-to-file.csv

Total :- ./script.sh total

Update Marks :- ./script.sh update
                    Prompts for:
                    Roll_Number
                    Name
                    Exam (filename without .csv)
                    Marks

#Mini Git System

Initialize repository: ./script.sh git_init /path/to/repo

Commit changes: ./script.sh git_commit -m "your message"

Checkout commit:
./script.sh git_checkout <hash_prefix>
./script.sh git_checkout -m "commit message"

View log: ./script.sh git_log

#Statistics

./script.sh mean
./script.sh median
./script.sh mode
./script.sh stdev
./script.sh maximum
./script.sh minimum
./script.sh completestat
./script.sh stat <exam>
./script.sh student <roll> <exam>
