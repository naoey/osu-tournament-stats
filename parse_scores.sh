
#!/bin/bash
while IFS=, read -r col1 col2
do
    rails "osustats:add_match[$col2,$col1]"
done < ~/Desktop/match_list.csv
