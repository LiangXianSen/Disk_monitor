#!/bin/bash
#encoding:UTF-8
#检测硬盘硬件情况脚本
#2015/8/24
#lianglian8866@163.com

#	$1	传入一个参数指定发现什么类型的设备(SAS/SATA/SSD)


#脚本命令支持检测
MegaCli="sudo /usr/sbin/MegaCli"
smartctl="sudo /usr/sbin/smartctl"
#======================================================发现硬件===================================================================#
#判断硬盘类型，做硬RAID得硬盘和没做硬RAID检测方式不一样
#$1  区分两种硬盘形式进行探索

json(){
#将发现的数据以JSON形式打印
         printf '{\n'
            printf '\t"data":[\n'
               for key in ${!dev[@]}
                   do
                       if [[ "${#dev[@]}" -gt 1 && "${key}" -ne "$((${#dev[@]}-1))" ]];then
                          printf '\t {\n'
                          printf "\t\t\t\"{#DISK}\":\"${dev[${key}]}\"},\n"
                       else [[ "${key}" -eq "((${#dev[@]}-1))" ]]
                          printf '\t {\n'
                          printf "\t\t\t\"{#DISK}\":\"${dev[${key}]}\"}\n"
                       fi
                   done
                          printf '\t ]\n'
                          printf '}\n'
}


#=========================================================================================================================#
#       $1      传入一个参数指定发现什么类型的设备(SAS/SATA/SSD)
case $1 in
        SATA)
                discovery_disk=($($smartctl --scan |awk '{print $1}' | awk -F "/" '{print $3}'))
                num=0
                for notraid_disk in ${discovery_disk[@]}
                do      if=$($smartctl -a -d auto "/dev/$notraid_disk" |wc -l)
                        structure=$($smartctl -a -d auto "/dev/$notraid_disk" | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})
            	if [ -n "$structure" ];then
                            if [ $if -gt 20 ] && [ $structure -ge 10 ]
                       	    then    dev[$num]=$notraid_disk
                           	    let num++
                	    fi
            	fi
                done

                raid_disk=($($MegaCli -LdPdInfo -aALL | grep "Device Id:" | awk -F ": " '{print $2}'))
                for disk in ${raid_disk[@]}
                do
                line_num=$($smartctl -a -d sat+megaraid,$disk /dev/sda | wc -l)
                type=$($smartctl -a -d sat+megaraid,$disk /dev/sda | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})
            	if [ -n "$type" ];then
                        if [ $line_num -gt 20 ] && [ $type -ge 10 ];then
                        dev[$num]=$disk
                        let num++
                        fi
            	fi
                done
                json
                ;;



        SAS)
                discovery_disk=($($smartctl --scan |awk '{print $1}' | awk -F "/" '{print $3}'))
                num=0
                for notraid_disk in ${discovery_disk[@]}
                do      if=$($smartctl -a -d auto "/dev/$notraid_disk" |wc -l)
                        disk_type=$($smartctl -a -d auto "/dev/$notraid_disk" | egrep -o "Transport protocol:   SAS" &> /dev/null && echo $?)
            	if [ -n "$disk_type" ];then
                            if [ $if -gt 20 ] && [ $disk_type -eq 0 ]
                	    then    dev[$num]=$notraid_disk
                                    let num++
                            fi  
            	fi  
                done

                raid_disk=($($MegaCli -LdPdInfo -aALL | grep "Device Id:" | awk -F ": " '{print $2}'))
                for disk in ${raid_disk[@]}
                do    
                        line_num=$($smartctl -a -d megaraid,$disk /dev/sda | wc -l)
                        type=$($smartctl -a -d megaraid,$disk /dev/sda | egrep -o "Transport protocol:   SAS" &> /dev/null && echo $?) 
            	if [ -n "$type" ];then
                        if [ $line_num -gt 20 ] && [ $type -eq 0 ];then
                        dev[$num]=$disk
                        let num++
                        fi  
            	fi  
                done
                json
                ;;  



        SSD)
                discovery_disk=($($smartctl --scan |awk '{print $1}' | awk -F "/" '{print $3}'))
                num=0
                for notraid_disk in ${discovery_disk[@]}
                do      if=$($smartctl -a -d auto "/dev/$notraid_disk" |wc -l)
                        structure=$($smartctl -a -d auto "/dev/$notraid_disk" | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})
            	if [ -n "$structure" ];then
                        if [ $if -gt 20 ] && [ $structure -eq 1 ] 
                        then    dev[$num]=$notraid_disk
                                let num++
                        fi  
            	fi  
                done

                raid_disk=($($MegaCli -LdPdInfo -aALL | grep "Device Id:" | awk -F ": " '{print $2}'))
                for disk in ${raid_disk[@]}
                do
                        line_num=$($smartctl -a -d sat+megaraid,$disk /dev/sda | wc -l)
                        type=$($smartctl -a -d sat+megaraid,$disk /dev/sda | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})
            	if [ -n "$type" ];then
                        if [ $line_num -gt 20 ] && [ $type -eq 1 ];then
                        dev[$num]=$disk
                        let num++
                        fi
            	fi
                done
                json
                ;;

esac

