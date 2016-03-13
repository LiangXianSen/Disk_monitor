#!/bin/bash
#encoding:UTF-8
#检测硬盘硬件情况脚本
#2015/9/9
#lianglian8866@163.com

smartctl="sudo /usr/sbin/smartctl"

#$1     硬盘标识
#$2     健康检查项

#####用函数定义通道####
item=$2
SSD(){
case $item in
        SSD_Reallocated_Sector) #剩余备用扇区数百分比(表示缺陷表已满或备用扇区已用尽，已经失去了重映射功能，再出现不良扇区就会显现出来并直接导致数据丢失。#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Reallocated_Sector" |awk '{print $4}')
        echo ${value#0}
	;;
        SSD_Power_On_Hours) #硬盘的使用时间百分比#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Power_On_Hours" |awk '{print $4}')
        expr 100 - ${value#0}
        ;;
        SSD_Power_Cycle_Count) #硬盘通电次数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Power_Cycle_Count" |awk '{print $10}'
	;;
        SSD_Wear_Leveling_Count) #硬盘元件擦写寿命百分比#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Wear" |awk '{print $4}')
        echo ${value#0}
	;;
        SSD_Used_Rsvd_Blk) #使用备用块剩余数量百分比#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Used_Rsvd_Blk" |awk '{print $4}')
	expr 100 - ${value#0}
        ;;
        SSD_Program_Fail) #编程错误块计数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Program_Fail" |awk '{print $10}'
        ;;
        SSD_Temperature) #硬盘温度#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Temperature" |awk '{print $10}'
        ;;
        SSD_Hardware_ECC_Recovered) #硬盘错误检查和纠正（ECC）次数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Hardware_ECC_Recovered" |awk '{print $10}'
        ;;
esac
}

RAID_SSD(){
case $item in
        SSD_Reallocated_Sector) #剩余备用扇区数百分比(表示缺陷表已满或备用扇区已用尽，已经失去了重映射功能，再出现不良扇区就会显现出来并直接导致数据丢失。#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Reallocated_Sector" |awk '{print $4}')
        echo ${value#0}
	;;
        SSD_Power_On_Hours) #硬盘的使用时间百分比#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Power_On_Hours" |awk '{print $4}')
	expr 100 - ${value#0}
	;;
        SSD_Power_Cycle_Count) #硬盘通电次数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Power_Cycle_Count" |awk '{print $10}'
	;;
        SSD_Wear_Leveling_Count) #硬盘元件擦写寿命百分比#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Wear" |awk '{print $4}')
        echo ${value#0}
	;;
        SSD_Used_Rsvd_Blk) #使用备用块剩余数量百分比#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Used_Rsvd_Blk" |awk '{print $4}')
	expr 100 - ${value#0}
        ;;
        SSD_Program_Fail) #编程错误块计数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Program_Fail" |awk '{print $10}'
        ;;
        SSD_Temperature) #硬盘温度#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Temperature" |awk '{print $10}'
        ;;
        SSD_Hardware_ECC_Recovered) #硬盘错误检查和纠正(ECC)次数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Hardware_ECC_Recovered" |awk '{print $10}'
        ;;
esac
}

SATA(){
case $item in 
	SATA_Raw_Read_Error_Rate) #底层数据读取错误百分比#
	value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Raw_Read_Error_Rate" |awk '{print $4}')
	echo ${value#0}
	;;
	SATA_Spin_Up_Time) #主轴起旋时间健康状态#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Spin_Up_Time" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Start_Stop_Count) #硬盘主轴电机启动/停止的次数,轴电机寿命#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Start_Stop_Count" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Reallocated_Sector) #剩余备用扇区数百分比(表示缺陷表已满或备用扇区已用尽，已经失去了重映射功能，再出现不良扇区就会显现出来并直接导致数据丢失。#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Reallocated_Sector" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Seek_Error_Rate) #寻道错误#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Seek_Error_Rate" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Power_On_Hours) #硬盘的使用时间百分比#
        value=$($smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Power_On_Hours" |awk '{print $4}')
        expr 100 - ${value#0}
        ;;
        SATA_Spin_Retry_Count) #主轴起旋重试次数#
	$smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Spin_Retry_Count" |awk '{print $10}'
        ;;
        SATA_Power_Cycle_Count) #硬盘通电次数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Power_Cycle_Count" |awk '{print $10}'
        ;;
        SATA_Power-Off_Retract) #硬盘意外断电次数#
	$smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Power-Off_Retract" |awk '{print $10}'
        ;;
        SATA_Load_Cycle_Count) #磁头加载次数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Load_Cycle_Count" |awk '{print $10}'
        ;; 
        SATA_Temperature) #硬盘温度#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep " Temperature" |awk '{print $10}'
        ;;
        SATA_Current_Pending_Sector) #被挂起的扇区数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Current_Pending_Sector" |awk '{print $10}'
        ;;
        SATA_Offline_Uncorrectable) #脱机无法校正的扇区计数#
        $smartctl -a -d auto /dev/$disk |egrep -A 25 "^ID#"| grep "Offline_Uncorrectable" |awk '{print $10}'
        ;;
esac	
}

RAID_SATA(){
case $item in 
	SATA_Raw_Read_Error_Rate) #底层数据读取错误百分比#
	value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Raw_Read_Error_Rate" |awk '{print $4}')
	echo ${value#0}
	;;
	SATA_Spin_Up_Time) #主轴起旋时间健康状态#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Spin_Up_Time" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Start_Stop_Count) #硬盘主轴电机启动/停止的次数,轴电机寿命#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Start_Stop_Count" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Reallocated_Sector) #剩余备用扇区数百分比(表示缺陷表已满或备用扇区已用尽，已经失去了重映射功能，再出现不良扇区就会显现出来并直接导致数据丢失。#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Reallocated_Sector" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Seek_Error_Rate) #寻道错误#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Seek_Error_Rate" |awk '{print $4}')
	echo ${value#0}
        ;;
        SATA_Power_On_Hours) #硬盘的使用时间百分比#
        value=$($smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Power_On_Hours" |awk '{print $4}')
        expr 100 - ${value#0}
        ;;
        SATA_Spin_Retry_Count) #主轴起旋重试次数#
	$smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Spin_Retry_Count" |awk '{print $10}'
        ;;
        SATA_Power_Cycle_Count) #硬盘通电次数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Power_Cycle_Count" |awk '{print $10}'
        ;;
        SATA_Power-Off_Retract) #硬盘意外断电次数#
	$smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Power-Off_Retract" |awk '{print $10}'
        ;;
        SATA_Load_Cycle_Count) #磁头加载次数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Load_Cycle_Count" |awk '{print $10}'
        ;; 
        SATA_Temperature) #硬盘温度#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep " Temperature" |awk '{print $10}'
        ;;
        SATA_Current_Pending_Sector) #被挂起的扇区数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Current_Pending_Sector" |awk '{print $10}'
        ;;
        SATA_Offline_Uncorrectable) #脱机无法校正的扇区计数#
        $smartctl -a -d sat+megaraid,$disk /dev/sda |egrep -A 25 "^ID#"| grep "Offline_Uncorrectable" |awk '{print $10}'
        ;;
esac	
}

SAS(){
case $item in
        1) #底层数据读取错误率#
        value=$($smartctl -a -d auto /dev/sda |egrep -A 25 "^ID#"| grep "^  1 " |awk '{print $4}')
        echo ${value#0}
        ;;
esac
}





######区分硬盘类型####
#RAID
raid(){
sas_type=$($smartctl -a -d megaraid,$disk /dev/sda | egrep -o "Transport protocol:   SAS" && echo $?)
structure=$($smartctl -a -d sat+megaraid,$disk /dev/sda | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})

if [ -n "$sas_type" ] && [ $sas_type -eq 0 ];then
        type=SAS
elif [ -n "$structure" ] && [ $structure -eq 1 ];then
        type=SSD
elif [ -n "$structure" ] && [ $structure -ge 10 ];then
        type=SATA
fi

case $type in
        SSD)
                RAID_SSD
                ;;
        SATA)
                RAID_SATA
                ;;
        SAS)
                RAID_SAS
                ;;
esac
}


#NO RAID
access(){
sas_type=$($smartctl -a -d auto "/dev/$disk" | egrep -o "Transport protocol:   SAS" &> /dev/null && echo $?)
structure=$($smartctl -a -d auto "/dev/$disk" | grep "SMART Attributes Data Structure revision number: "| egrep -o [0-9]\{1,2\})

if [ -n "$sas_type" ] && [ $sas_type -eq 0 ];then
        type=SAS
elif [ -n "$structure" ] && [ $structure -eq 1 ];then
        type=SSD
elif [ -n "$structure" ] && [ $structure -ge 10 ];then
        type=SATA
fi

case $type in
        SSD)
                SSD
                ;;
        SATA)
                SATA
                ;;
        SAS)
                SAS
                ;;
esac
}




###入口####
#通过discovery定义得名称判断选择进入哪个接口检测##
disk=$1
if [[ $disk =~ [0-9] || $disk =~ [0-9][0-9] ]];then
	raid #RAID
elif [[ $disk =~ sd[a-z] ]];then
	access #NO RAID
fi

