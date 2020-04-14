#!/bin/bash

#旧文件名前缀
old_file_prefix="BG"
#新文件名前缀
new_file_prefix="TEST"

#旧方法名前缀
old_method_prefix="bg_"
#新方法名前缀
new_method_prefix="test_"

#旧资源名前缀
old_resources_prefix="bg"
#新资源名前缀
new_resources_prefix="test_"

#文件夹名旧前缀（不修改文件夹前缀传空）
old_folder_prefix=BG
#文件夹名新前缀
new_folder_prefix=TEST
#文件夹名旧前缀（同上，字符串类型）
old_folder_prefix_string="BG"
#文件夹名新前缀（同上，字符串类型）
new_folder_prefix_string="TEST"

#Assets.xcassets内旧图片资源前缀
old_assets_image_prefix=BG_
#Assets.xcassets内新图片资源前缀
new_assets_image_prefix=TEST_

#递归修改Assets.xcassets内图片名称
change_assets_image_prefix() {

    for image_folder in $1/*
    do
        
        #判断是否是目录
        if [ -d $image_folder ]
        then
            
            for image in $image_folder/*
            do
                
                #修改文件名称
                mv $image ${image/${old_assets_image_prefix}/${new_assets_image_prefix}}
                echo "✅修改""${image##*/}""图片名称成功"

            done

            #开始递归下一层
            change_assets_image_prefix $image_folder
        
        fi
    
    done
}

#递归项目中所有目录
foreachd() {
    
    #获取第一个参数（当前目录）
    for file in $1/*
    do
        
        #是目录
        if [ -d $file ]
        
        then
            
            #不处理Pods文件中的内容
            if [ $"${file##*/}" != $"Pods" ]
            then
                
                #不需要处理Assets.xcassets中内容
                if [ "${file##*/}"x != "Assets.xcassets"x ]
                then
                    #修改方法名
                    sed -i -e "s/$old_method_prefix/$new_method_prefix/g"  `grep ${old_method_prefix} -rl ${file}`
                    #修改文件中引用的类名
                    sed -i -e "s/$old_file_prefix/$new_file_prefix/g"  `grep ${old_file_prefix} -rl ${file}`

                    echo "✅修改""${file##*/}""文件下文件内文本成功"

                fi

                #修改文件夹前缀
                if test $"${old_folder_prefix}" != $""
                then

                    #递归修改项目中文件夹前缀
                    for folder in $file/*
                    do
                        mv $folder ${folder/${old_folder_prefix}/${new_folder_prefix}}
                    done

                fi
            
                #改名imageset后缀文件名（Assets.xcassets里的图片）
                if [ "${file##*.}"x = "xcassets"x ]
                then
                    
                    #调用方法
                    change_assets_image_prefix $file

                fi
                
                #开始递归下一层
                foreachd $file

            fi
                        
        elif [ -f $file ]
        #不是目录
        then
        
            #改名项目配置文件内容
            if [ "${file##*.}"x = "pbxproj"x ]
            then
            
                #修改配置文件里的项目名称前缀
                sed -i -e "s/$old_file_prefix/$new_file_prefix/g"  `grep ${old_file_prefix} -rl ${file}`
                #修改配置文件里的文件夹前缀
                sed -i -e "s/$old_folder_prefix_string/$new_folder_prefix_string/g"  `grep ${old_folder_prefix_string} -rl ${file}`

            fi
        
            #改名swift和xib后缀文件名
            if [ "${file##*.}"x = "h"x ] || [ "${file##*.}"x = "m"x ]
            then

                mv $file `echo $file|sed "s/"$old_file_prefix"/"$new_file_prefix"/g"`
                echo "✅修改""${file##*/}""文件名成功"

            fi
            
            #改名资源文件名
            if [ "${file##*.}"x = "png"x ] || [ "${file##*.}"x = "jpg"x ] || [ "${file##*.}"x = "gif"x ] || [ "${file##*.}"x = "html"x ]
            then

                mv $file `echo $file|sed "s/"$old_resources_prefix"/"$new_resources_prefix"/g"`
                echo "✅修改""${file##*/}""文件名成功"

            fi

        fi

    done
}

#获取当前目录
project_path=$(cd `dirname $0`; pwd)
#目录名称
project_name="${project_path##*/}"

#开始递归当前目录下的文件夹
foreachd $project_path

echo "✅✅✅修改完成✅✅✅"
