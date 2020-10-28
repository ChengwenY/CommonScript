#!/bin/bash
########### git 提交 ############
git add *

echo "请输入当前要提交的内容"
read commitText

git commit -m ${commitText}

################spec信息 start################
RootPath=`pwd`
PodSpecName="HaloSlim.podspec"

PodSpecPath=$RootPath/$PodSpecName
RepoName="HaloSlim"

##### git 校验tag #####

echo "请输入pod tag 版本号"
read Tag_Version
if [ -z $Tag_Version ];then
	#输入的是空
	echo "\n输入格式错误，请重新运行脚本，输入正确格式的sdk tag版本号\n"
else
	#不是空
		# release的正则
		reg='^[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}$'

		echo "Tag_Version》》》》》》 "$Tag_Version

		if [[ "$Tag_Version" =~ $reg ]];then
			echo "恭喜你，输入的版本号，格式验证通过"
		else
			echo "\n输入格式错误，请重新运行脚本，输入正确格式的sdk tag版本号\n"
			exit 1
		fi
fi

## 更新版本号 ##
function changeVersion() {
	echo ${PodSpecPath}
	
	while read line 
	do 
		regex="^s.version"
		if [[ $line =~ $regex ]];then 
			echo "File:$line"
			sed -i "" "s/$line/s.version    = \'$Tag_Version\'/g" $PodSpecPath
		fi
	done < $PodSpecPath
}

function podLibLint() {
	pod lib lint --use-libraries --allow-warnings 
}
function podPushRepo() {
	pod repo push iOSSpecs $PodSpecName --use-libraries --allow-warnings 
}

## 版本号比对 ##
TempTagList=$RootPath/taglist.txt
echo "TempTagListFile:" $TempTagList
git fetch --tags
git tag -l |sort -r >$TempTagList

Have_tag="0"
while read line
do
	tagNumber=$line
	echo "tagNumber:"$tagNumber
	
	if [ $tagNumber == $Tag_Version ]; then
		Have_tag="1"
	fi
done < $TempTagList

if [[ $Have_tag == "1" ]];then 
	echo "tag $Tag_Version 已经存在，请重新输入！"
else
	echo "tag $Tag_Version 符合要求。请继续操作"
	changeVersion
fi

## 提交git ##
git add .
git pull
git add .
git commit -m "new Version $PodSpecName in $Date"
git push 
git tag $Tag_Version
git push --tags 

## 验证podspec ##
while read -p "请输入接下来的操作 1.验证podspec 2.提交私有库 3.退出> " input
do 
	if [ "$input" == "1" ]; then 
		podLibLint
	elif [ "$input" == "2" ]; then
		podPushRepo 
	else 
		exit 1
	fi
done 

pod search $RepoName

