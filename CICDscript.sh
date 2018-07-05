#!/bin/sh

while getopts k:s:d:e:c:a:j: option
do
        case "${option}"
        in
				k) key=${OPTARG};;
                s) sum=${OPTARG};;
                d) des=${OPTARG};;
                e) env=${OPTARG};;
                c) comp=${OPTARG};;
                a) attach=${OPTARG};;
                j) jira=${OPTARG};;
        esac
done

echo "Checking CICD Dashboard for existing tickets"
STR1=$sum
STR=`echo ${STR1// /%20}`
empty="\"\""
contentType='"Content-Type:application/json"'
curl -u shagun.jain:Shubh@123 -X GET -H "Content-Type:application/json" "http://localhost:8081/rest/agile/1.0/board/1/issue?fields=summary&jql=project=$key+AND+status!=Closed+AND+summary~%22$STR%22+ORDER+BY+key+DESC" > "/tmp/splunk/input_solr.json"
findSummary=`jq .issues[0].fields.summary '/tmp/splunk/input_solr.json'`
if [ "$findSummary" != "null"  ]
        then
                        findTicket=`jq .issues[0].key '/tmp/splunk/input_solr.json'`
                        jiranumber=`echo $findTicket | cut -d "\"" -f2`
                        echo "Adding comment to $jiranumber"
                        commentData="'"{"\"update\"":{"\"comment\"":[{"\"add\"":{"\"body\"":"\"$sum\""}}]}}"'"
                        url="http://localhost:8081/rest/api/2/issue/$jiranumber"
                        var=`echo curl -D- -u shagun.jain:Shubh@123 -X PUT --data "$commentData" -H "$contentType" "$url"`
                        eval $var
else
                echo "Creating ticket under CICD Board"
                url="http://localhost:8081/rest/api/2/issue/"
				summaryData="'"{"\"fields\"":{"\"project\"":{"\"key\"":"\"$key\""},"\"summary\"":"\"$sum\"","\"description\"":"\"$des\"","\"issuetype\"":{"\"name\"":"\"Change\""}}}"'"
                #summaryData="'"{"\"fields\"":{"\"project\"":{"\"key\"":"\"$key\""},"\"summary\"":"\"$sum\"","\"description\"":"\"$des\"","\"customfield_10108\"":{"\"value\"":"\"06/Jul/18 4:10 PM\""},"\"customfield_10107\"":{"\"value\"":"\"06/Jul/18 5:10 PM\""},"\"issuetype\"":{"\"name\"":"\"Change\""}}}"'"
                result=`eval curl -D- -u shagun.jain:Shubh@123 -X POST --data "$summaryData" -H "$contentType" "$url"`
                jiranumber=`echo $result | awk -F '"' '{print $8}'`
                echo $jiranumber
fi
if [ -z $attach ] || [ $attach = $empty ]
        then
                echo "No Attachments."
else
        curl -D- -u shagun.jain:Shubh@123 -X POST -H "X-Atlassian-Token: no-check" -F "file=@$attach" --url http://localhost:8081/rest/api/2/issue/$jiranumber/attachments
fi

if [ -z $jira ] || [ $jira = $empty ]
        then
                echo "No JIRA to LINK."
else
        STR2=$jira
        STR3=`echo ${STR2// /%20}`
        curl -u shagun.jain:Shubh@123 -X GET -H "Content-Type:application/json" "http://localhost:8081/rest/agile/1.0/board/715/issue?fields=summary&jql=project=$key+ORDER+BY+key+DESC" > "/tmp/splunk/input_cicd2.json"
        totaljira=`jq .total '/tmp/splunk/input_cicd2.json'`
        if [ $totaljira!='0' ]
                then
                        i=0
                        while [ $i -lt $totaljira ]
                                do
                                        linkfindTicket=`jq .issues[$i].key '/tmp/splunk/input_cicd2.json'`
                                        linkjiranumber=`echo $linkfindTicket | cut -d "\"" -f2`
                                        linkurl="http://localhost:8081/rest/api/2/issueLink"
                                        linksummaryData="'"{"\"inwardIssue\"":{"\"key\"":"\"$jiranumber\""},"\"outwardIssue\"":{"\"key\"":"\"$linkjiranumber\""},"\"type\"":{"\"id\"":"\"10003\"","\"name\"":"\"Relates\"","\"inward\"":"\"relates to\"","\"outward\"":"\"relates to\""}}"'"
                                        eval curl -D- -u shagun.jain:Shubh@123 -X POST --data "$linksummaryData" -H "$contentType" "$linkurl"
                                        i=$((i+1))
                        done
        fi
fi