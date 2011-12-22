#! /bin/sh 

project="[PhoneGap Build project number]";
username="[PhoneGap Build username]";
password="[PhoneGap Build password]";
appPath="[Path to source code]";
projectPath="[Path for holding compiled app]";

APIPATH="https://build.phonegap.com/api/v1/apps";
FILEPATH="https://build.phonegap.com/apps/";

APIcall="$APIPATH/$project"
creds="$username:$password";

##commit changes
echo "Forcing changes to github";
cd $appPath
null=$(git commit -m "auto commit as part of script");
null=$(git push origin master);
echo "Done";

cd $projectPath

##Request Phonegap data
echo "Requesting Project Data.";
package=$(curl -s -u $creds  $APIcall | grep -Po '"package":.*?[^\\],');
title=$(curl -s -u $creds  $APIcall | grep -Po '"title":.*?[^\\],');
title=${title##*:};
title=$(echo $title|sed 's/,//g');
title=$(echo $title|sed 's/"//g');
package=${package##*:};
package=$(echo $package|sed 's/,//g');
package=$(echo $package|sed 's/"//g');
echo "Done. ";

##Request Rebuild
echo "Requesting Rebuild.";
request=$(curl -s -u $creds -X PUT -d 'data={"pull":"true"}' $APIcall);
echo "Done. ";
donecheck="";


echo "\nWaiting for rebuild to be done.";
while [$donecheck -eq ""]
do
	echo ".";
	sleep 10;
	donecheck=$(curl -s -u $creds  $APIcall | grep -Po '"android":"complete"');	
done
echo "Done. Now downloading.\n";

##Download File
download=$(curl -L -s -u $creds -o $title-debug.apk $FILEPATH/$project/download/android);

##Install on Device
~/Downloads/android-sdk/platform-tools/adb uninstall $package
~/Downloads/android-sdk/platform-tools/adb install -r ./$title-debug.apk