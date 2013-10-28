#! /bin/bash
COUNTER=1
MAX_QUESTIONS=30
echo "<questionList>" >> questionList.txt
while [ "$COUNTER" -lt "$MAX_QUESTIONS" ]
do
     echo "<question name=\"question$COUNTER\" type=\"singleChoice\" topic=\"topic$COUNTER\"><text>Thats a question ...</text>\
     		<answer>\
            	<answerItem correct=\"yes\"><text>answer1</text></answerItem>\
            	<answerItem correct=\"no\"><text>answer2</text></answerItem>\
            </answer>\
     </question>" >> questionList.txt
     COUNTER=$[$COUNTER +1]
done
echo "</questionList>" >> questionList.txt
# ---
COUNTER=1
echo "<topicList>" >> questionList.txt
while [ "$COUNTER" -lt "$MAX_QUESTIONS" ]
do
     echo "<topic name=\"topic$COUNTER\">\
            <title>Title of topic $COUNTER</title>\
        </topic>" >> questionList.txt
     COUNTER=$[$COUNTER +1]
done
echo "</topicList>" >> questionList.txt