#!/bin/sh

## usage:
# ./testingScript.sh board1 board2... etc
# run "chmod +x testingScript.sh" in shell if you haven't already
# don't include the file extensions and make sure both .h and .s files are present 
# in the current dir
# i don't do any error checking so use it correctly
# good luck!

for board in "$@"; do 

        # compile the c program with the give board
        echo "#include \"$board.h\"" | cat - life.c > temp.c 
        gcc temp.c

        cat "$board.s" "prog.s" > temp.s 

        
        if [ ! -d testOutput ]; then
                mkdir testOutput
        fi

        # testing nIterations 1..11
        i=1  
        while  [ $i -lt 11 ]; do 
                echo $i | ./a.out > "testOutput/c$i.out"
                echo $i | 1521 spim -file temp.s | sed 1d > "testOutput/mips$i.out"
                diff "testOutput/c$i.out" "testOutput/mips$i.out" > "testOutput/diff$i.txt"
                if [ ! $? ]; then 
                        echo "Test failed on $board."
                        echo "at nIterations == $i"
                        echo "use 'cat testOutput/diff$i.txt' to see difference"
                        exit 1
                fi
                i=$((i+1)) 
        done
done

exit 0 
