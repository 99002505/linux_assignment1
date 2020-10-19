#! /bin/bash

FILE_PATH='Input.csv'
RESULT_PATH='Results.csv'

while IFS=',' read -r t1 t2 REPO
do
   [[ $t1 != 'Name' ]] && echo "$t1"
   [[ $t2 != 'Email ID' ]] && echo "$t2"
   if [ "$REPO" != 'Repo link' ]; then 
        repo=$REPO
        git clone "$REPO"
        if [ "$?" -eq 0 ]; then
            clone-="clone success"
        else
            clone = "clone failure"
        fi
        REPO=`echo "$REPO" | cut -d'/' -f5`
        echo "REPO = $REPO"
        make -C "$REPO"
        if [ $? -eq 0 ]; then
            bu="Build success"
        else
            bu="Build Failure"
        fi
        ERR=`cppcheck "$REPO" | grep 'error' | wc -l`
        if [ $? -eq 0 ]; then
            er="$ERR"
        fi
        make test -C $REPO
        EXE=`find "$REPO" -name "TEST*.out"`
        valgrind "./$EXE" 2>log.txt
        STR=$( tail -n 1 log.txt )
        val=$(echo ${STR:24:3})
        verr="$val"
        printf "$t1,$t2,$repo,$clone,$clone,$bu,$er,$verr\n" >> $RESULT_PATH
    fi
done < "${FILE_PATH}"