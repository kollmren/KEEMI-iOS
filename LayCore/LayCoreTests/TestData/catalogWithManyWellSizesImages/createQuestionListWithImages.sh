#! /bin/bash
COUNTER=1
MAX_QUESTIONS=500
mkdir catalogWithManyWellSizedImages
echo "<questionList>" >> catalogWithManyWellSizedImages/questionList.xml
while [ "$COUNTER" -lt "$MAX_QUESTIONS" ]
do
	cp RibbonImage.png "catalogWithManyWellSizedImages/RibbonImage$COUNTER.png"
	cp ButtonImageColumn.png "catalogWithManyWellSizedImages/ButtonImageColumn$COUNTER.png"
     echo "<question type=\"singleChoice\" name=\"question$COUNTER\">\
            <text>Thats a question$COUNTER which shows each possible answer as a button with an image?</text>\
            <answer style=\"column\">\
            <mediaList>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                </mediaList>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImageColumn$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImageColumn$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImageColumn$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"yes\">\
                    <media type=\"image\" ref=\"ButtonImageColumn$COUNTER.png\"/>\
                </answerItem>\
            </answer>\
        </question>" >> catalogWithManyWellSizedImages/questionList.xml
        COUNTER=$[$COUNTER +1]
        # style:row
        cp RibbonImage.png "catalogWithManyWellSizedImages/RibbonImage$COUNTER.png"
		cp ButtonImage.png "catalogWithManyWellSizedImages/ButtonImage$COUNTER.png"
        echo "<question type=\"singleChoice\" name=\"question$COUNTER\">\
            <text>Thats a question$COUNTER which shows each possible answer as a button with an image?</text>\
            <answer>\
            <mediaList>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                    <media type=\"image\" ref=\"RibbonImage$COUNTER.png\"/>\
                </mediaList>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImage$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImage$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"no\">\
                    <media type=\"image\" ref=\"ButtonImage$COUNTER.png\"/>\
                </answerItem>\
                <answerItem correct=\"yes\">\
                    <media type=\"image\" ref=\"ButtonImage$COUNTER.png\"/>\
                </answerItem>\
            </answer>\
        </question>" >> catalogWithManyWellSizedImages/questionList.xml
     COUNTER=$[$COUNTER +1]
done
echo "</questionList>" >> catalogWithManyWellSizedImages/questionList.xml
