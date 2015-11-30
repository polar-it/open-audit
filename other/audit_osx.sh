#!/bin/bash
#
#  Copyright 2003-2015 Opmantek Limited (www.opmantek.com)
#
#  ALL CODE MODIFICATIONS MUST BE SENT TO CODE@OPMANTEK.COM
#
#  This file is part of Open-AudIT.
#
#  Open-AudIT is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Open-AudIT is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with Open-AudIT (most likely in a file named LICENSE).
#  If not, see <http://www.gnu.org/licenses/>
#
#  For further information on Open-AudIT or for a license other than AGPL please see
#  www.opmantek.com or email contact@opmantek.com
#
# *****************************************************************************

# @package Open-AudIT
# @author Mark Unwin <marku@opmantek.com>
# @version 1.8.4
# @copyright Copyright (c) 2014, Opmantek
# @license http://www.gnu.org/licenses/agpl-3.0.html aGPL v3

O=$IFS
IFS=$'\n'

export PATH=$PATH:/usr/sbin

url="http://localhost/open-audit/index.php/system/add_system"
submit_online="n"
create_file="y"
org_id=""
terminal_print="n"
debugging="3"
system_id=""

# import the command line arguements
for arg in "$@"; do
	parameter=${arg%%=*}
	value=${arg##*=}
	if [ "$parameter" == "--help" ]; then parameter="help"; value="y"; fi
	if [ "$parameter" == "-h" ]; then parameter="help"; value="y"; fi
	eval "$parameter"=\""$value\""
done

if [  "$debugging" -gt 0 ]; then
	echo "OPTIONS"
	echo "-------"
	echo "url: $url"
	echo "submit_online: $submit_online"
	echo "create_file: $create_file"
	echo "debugging: $debugging"
	echo "-------"
fi

if [ "$help" = "y" ]; then
	echo ""
	echo "---------------------------"
	echo "Open-AudIT OSX Audit script"
	echo "(c) Opmantek, 2014.        "
	echo "---------------------------"
	echo "This script should be run on a Mac OSX based computer using root or sudo access rights."
	echo ""
	echo "Valid command line options are below (items containing * are the defaults) and should take the format name=value (eg: debugging=1)."
	echo ""
	echo "  create_file"
	echo "     y - Create an XML file containing the audit result."
	echo "    *n - Do not create an XML result file."
	echo ""
	echo "  debugging"
	echo "     0 - No output."
	echo "     1 - Minimal Output."
	echo "     2 - Verbose output."
	echo "    *3 - Very Verbose output."
	echo ""
	echo "  -h or --help or help=y"
	echo "      y - Display this help output."
	echo "     *n - Do not display this output."
	echo ""
	echo "  org_id"
	echo "       - The org_id (an integer) taken from Open-AudIT. If set all devices found will be associated to that Organisation."
	echo ""
	echo "  submit_online"
	echo "    *y - Submit the audit result to the Open-AudIT Server defined by the 'url' variable."
	echo "     n - Do not submit the audit result"
	echo ""
	echo "  url"
	echo "    *http://localhost/open-audit/index.php/discovery/process_subnet - The http url of the Open-AudIT Server used to submit the result to."
	echo ""
	echo ""
	echo "The name of the resulting XML file will be in the format HOSTNAME-YYMMDDHHIISS.xml, as in the hostname of the machine the the complete timestamp the audit was started."
	exit
fi


if [ "$debugging" -gt "0" ]; then
	echo "System Info"
fi
system_timestamp=`date +'%F %T'`
system_uuid=`system_profiler SPHardwareDataType | grep "Hardware UUID:" | cut -d":" -f2 | sed 's/^ *//g'`
system_hostname=`networksetup -getcomputername | cut -f1 -d.`
system_domain=`more /etc/resolv.conf | grep domain | cut -d" " -f2`
system_os_version=`sw_vers | grep "ProductVersion:" | cut -f2`
system_os_name="OSX $system_os_version"
system_serial=`system_profiler SPHardwareDataType | grep "Serial Number (system):" | cut -d":" -f2 | sed 's/^ *//g'`
system_model=`system_profiler SPHardwareDataType | grep "Model Identifier:" | cut -d":" -f2 | sed 's/^ *//g'`
# todo - below displays days and stops at hours
# system_uptime=`system_profiler SPSoftwareDataType | grep "Time since boot:" | cut -d":" -f2 | sed 's/^ *//g'`
system_uptime=""
system_form_factor=""
system_pc_os_bit="64"
system_pc_memory=`system_profiler SPHardwareDataType | grep "Memory:" | cut -d":" -f2 | sed 's/^ *//g' | cut -d" " -f1`
system_pc_memory=`expr $system_pc_memory \* 1024 \* 1024`
processor_count=`system_profiler SPHardwareDataType | grep "Number of Processors" | cut -d: -f2`
system_pc_date_os_installation=`date -r $(stat -f "%B" /private/var/db/.AppleSetupDone) "+%Y-%m-%d %H:%M:%S"`
man_class=""
if [[ "$system_model" == *"MacBook"* ]]; then
	system_form_factor="laptop"
	man_class="laptop"
fi

xml_file="$system_hostname"-`date +%Y%m%d%H%M%S`.xml
echo  "<?xml version="\"1.0\"" encoding="\"UTF-8\""?>" > $xml_file
echo  "<system>" >> $xml_file
echo  "	<sys>" >> $xml_file
echo  "		<timestamp>$system_timestamp</timestamp>" >> $xml_file
echo  "     <system_id>$system_id</system_id>" >> $xml_file
echo  "     <uuid>$system_uuid</uuid>" >> $xml_file
echo  "		<hostname>$system_hostname</hostname>" >> $xml_file
echo  "		<domain>$system_domain</domain>" >> $xml_file
echo  "		<description></description>" >> $xml_file
echo  "		<man_class>$man_class</man_class>" >> $xml_file
echo  "		<type>computer</type>" >> $xml_file
echo  "		<os_icon>apple</os_icon>" >> $xml_file
echo  "		<os_group>Apple</os_group>" >> $xml_file
echo  "		<os_family>Apple OSX</os_family>" >> $xml_file
echo  "		<os_name>$system_os_name</os_name>" >> $xml_file
echo  "		<os_version>$system_os_version</os_version>" >> $xml_file
echo  "		<serial>$system_serial</serial>" >> $xml_file
echo  "		<model>$system_model</model>" >> $xml_file
echo  "		<manufacturer>Apple Inc</manufacturer>" >> $xml_file
echo  "		<uptime>$system_uptime</uptime>" >> $xml_file
echo  "		<form_factor>$system_form_factor</form_factor>" >> $xml_file
echo  "		<pc_os_bit>$system_pc_os_bit</pc_os_bit>" >> $xml_file
echo  "		<pc_memory>$system_pc_memory</pc_memory>" >> $xml_file
echo  "		<pc_num_processor>$processor_count</pc_num_processor>" >> $xml_file
echo  "		<pc_date_os_installation>$system_pc_date_os_installation</pc_date_os_installation>" >> $xml_file
echo  "		<man_org_id>$org_id</man_org_id>" >> $xml_file
echo  "	</sys>" >> $xml_file



if [ "$debugging" -gt "0" ]; then
	echo "Network Cards Info"
fi
ip_info=""
echo "	<network>" >> $xml_file
for line in $(system_profiler SPNetworkDataType | grep "BSD Device Name: en" | cut -d":" -f2); do
	line=`echo "${line}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`
	net_mac_address=`ifconfig $line 2>/dev/null | grep "ether" | awk '{print $2}'`
	i=`system_profiler SPNetworkDataType | grep "BSD Device Name: $line" -B 4 | grep ":" | grep -v "      " | cut -d":" -f1`
	i=`echo "${i}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`
	j=`system_profiler SPNetworkDataType | grep "BSD Device Name: $line" -B 3 | grep ":" | grep "Type" | cut -d":" -f2`
	j=`echo "${j}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`
	net_index="$line"
	net_manufacturer="Apple"
	net_model="$i"
	net_description="$i $j"
	net_ip_enabled=`system_profiler SPNetworkDataType | grep "BSD Device Name: $line" -A 1 | grep ":" | grep "Has IP Assigned" | cut -d":" -f2 | cut -d" " -f2`
	net_connection_id="$line"
	net_speed=""
	net_adapter_type="$j"
	if [[ "$net_mac_address" > "" ]]; then
		echo "		<item>" >> $xml_file
		echo "			<net_index>$net_index</net_index>" >> $xml_file
		echo "			<mac>$net_mac_address</mac>" >> $xml_file
		echo "			<manufacturer>$net_manufacturer</manufacturer>" >> $xml_file
		echo "			<model>$net_model</model>" >> $xml_file
		echo "			<description>$net_description</description>" >> $xml_file
		echo "			<ip_enabled>$net_ip_enabled</ip_enabled>" >> $xml_file
		echo "			<connection>$net_connection_id</connection>" >> $xml_file
		echo "			<type>$net_adapter_type</type>" >> $xml_file
		echo "		</item>" >> $xml_file
	fi
done
echo "	</network>" >> $xml_file
echo "	<addresses>" >> $xml_file
for line in $(system_profiler SPNetworkDataType | grep "BSD Device Name: en" | cut -d":" -f2); do
	line=`echo "${line}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`
	net_mac_address=`ifconfig $line 2>/dev/null | grep "ether" | awk '{print $2}'`
	if [[ "$net_mac_address" > "" ]]; then
		ip_address_v4=`ipconfig getifaddr $line`
		if [[ "$ip_address_v4" > "" ]]; then
			net_index="$line"
			ip_subnet=`ipconfig getpacket $line | grep "subnet_mask" | cut -d" " -f3`
			echo "		<ip_address>" >> $xml_file
			echo "			<net_index>$net_index</net_index>" >> $xml_file
			echo "			<net_mac_address>$net_mac_address</net_mac_address>" >> $xml_file
			echo "			<ip_address_v4>$ip_address_v4</ip_address_v4>" >> $xml_file
			echo "			<ip_address_v6></ip_address_v6>" >> $xml_file
			echo "			<ip_subnet>$ip_subnet</ip_subnet>" >> $xml_file
			echo "			<ip_address_version>4</ip_address_version>" >> $xml_file
			echo "		</ip_address>" >> $xml_file
		fi
	fi
done
echo "	</addresses>" >> $xml_file


if [ "$debugging" -gt "0" ]; then
	echo "Processor Info"
fi

processor_cores=`system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk '{print $5}'`
processor_logical=`sysctl hw.ncpu | awk '{print $2}'`
processor_socket=""
processor_description=`sysctl -n machdep.cpu.brand_string`
processor_speed=`system_profiler SPHardwareDataType | grep "Processor Speed:" | cut -d":" -f2 | sed 's/^ *//g' | cut -d" " -f1 | sed 's/,/./g'`
processor_speed=`echo "scale = 0; $processor_speed*1000" | bc`
processor_manufacturer="GenuineIntel"

echo  "	<processor>" >> $xml_file
echo  "		<item>" >> $xml_file
echo  "			<physical_count>$processor_count</physical_count>" >> $xml_file
echo  "			<core_count>$processor_cores</core_count>" >> $xml_file
echo  "			<logical_count>$processor_logical</logical_count>" >> $xml_file
echo  "			<socket>$processor_socket</socket>" >> $xml_file
echo  "			<description>$processor_description</description>" >> $xml_file
echo  "			<speed>$processor_speed</speed>" >> $xml_file
echo  "			<manufacturer>$processor_manufacturer</manufacturer>" >> $xml_file
echo "			<architecture>x64</architecture>" >> $xml_file
echo  "		</item>" >> $xml_file
echo  "	</processor>" >> $xml_file




if [ "$debugging" -gt "0" ]; then
	echo "Memory Info"
fi
echo "	<memory>" >> $xml_file
for line in $(system_profiler SPMemoryDataType | grep "BANK" -A 8); do

	if [[ "$line" == *"BANK"* ]]; then
		memory_tag=`echo "$line" | cut -d"/" -f1 | sed 's/^ *//'`
		memory_bank=`echo "$memory_tag" | sed 's/BANK/DIMM/g'`
	fi

	if [[ "$line" == *"Size"* ]]; then
		memory_capacity=`echo "$line" | grep "Size:" | cut -d":" -f2 | sed 's/^ *//g' | cut -d" " -f1 | sed 's/,/./g'`
		memory_capacity=`echo "scale = 0; $memory_capacity * 1024" | bc`
	fi

	if [[ "$line" == *"Type"* ]]; then
		memory_detail=`echo "$line" | grep "Type:" | cut -d":" -f2 | sed 's/^ *//g'`
	fi

	if [[ "$line" == *"Speed"* ]]; then
		memory_speed=`echo "$line" | grep "Speed:" | cut -d":" -f2 | sed 's/^ *//g'`
	fi

	if [[ "$line" == *"Serial Number"* ]]; then
		memory_serial=`echo "$line" | grep "Serial Number:" | cut -d":" -f2 | sed 's/^ *//g'`

		echo "		<item>" >> $xml_file
		echo "			<bank>$memory_bank</bank>" >> $xml_file
		echo "			<type></type>" >> $xml_file
		echo "			<form_factor></form_factor>" >> $xml_file
		echo "			<detail>$memory_detail</detail>" >> $xml_file
		echo "			<size>$memory_capacity</size>" >> $xml_file
		echo "			<speed>$memory_speed</speed>" >> $xml_file
		echo "			<tag>$memory_tag</tag>" >> $xml_file
		echo "			<serial>$memory_serial</serial>" >> $xml_file
		echo "		</item>" >> $xml_file
	fi
done
#unset IFS
echo "	</memory>" >> $xml_file

if [ "$debugging" -gt "0" ]; then
	echo "Hard Disks"
fi
# NOTES -
# manufacturer not available on SATA conntected disks
# model not available on USB connected disks
# partition count not available
# scsi logical unit not available

echo "  <disk>" >> $xml_file
partition_each=""
for disk in $(diskutil list | grep "^/" | cut -d/ -f3); do
    hard_drive_index=$disk
    hard_drive_caption=$(diskutil info "$disk" | grep "^ " | grep "Device / Media Name:" | cut -d":" -f2- | sed 's/^ *//g')
    hard_drive_interface_type=$(diskutil info "$disk" | grep "^ " | grep "Protocol:" | cut -d":" -f2- | sed 's/^ *//g')
    hard_drive_size=$(diskutil info "$disk" | grep "^ " | grep "Total Size:" | cut -d":" -f2- | sed 's/^ *//g' | cut -d" " -f3 | cut -d"(" -f2)
    hard_drive_size=$(echo "$hard_drive_size / 1000 / 1000 " | bc | cut -d"." -f1)
    hard_drive_device_id=$(diskutil info "$disk" | grep "^ " | grep "Device Node:" | cut -d":" -f2- | sed 's/^ *//g')
    hard_drive_status=$(diskutil info "$disk" | grep "^ " | grep "SMART Status:" | cut -d":" -f2- | sed 's/^ *//g')
    hard_drive_manufacturer=""
    hard_drive_model=""
    if [[ "$hard_drive_interface_type" == "SATA" ]]; then
        hard_drive_model=$(system_profiler SPSerialATADataType | grep "BSD Name: $disk$" -B8 | grep "Model:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
        hard_drive_serial=$(system_profiler SPSerialATADataType | grep "BSD Name: $disk$" -B8 | grep "Serial Number:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
        hard_drive_firmware=$(system_profiler SPSerialATADataType | grep "BSD Name: $disk$" -B8 | grep "Revision:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
    fi
    if [[ "$hard_drive_interface_type" == "USB" ]]; then
        hard_drive_serial=$(system_profiler SPUSBDataType | grep "BSD Name: $disk$" -B12 | grep "Serial Number:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
        hard_drive_firmware=$(system_profiler SPUSBDataType | grep "BSD Name: $disk$" -B12 | grep "Version:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
        hard_drive_manufacturer=$(system_profiler SPUSBDataType | grep "BSD Name: $disk$" -B12 | grep "Manufacturer:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
    fi
    if [[ "$hard_drive_model" == *"APPLE"* ]]; then
        hard_drive_manufacturer="Apple"
    fi
    test=""
    test=$(diskutil info "$disk" | grep "^ "| grep "This disk is a Core Storage Logical Volume")
    if [ -n "$test" ]; then
        # we have a LVM - likely the data partition used on the main disk
        # get some extra info we would normally only get for a partition
        partition_device_id=$(diskutil info "$disk" | grep "^ " | grep "Volume UUID:" | cut -d":" -f2- | sed 's/^ *//g')
        hard_drive_index=$(system_profiler SPStorageDataType | grep "Volume UUID: $partition_device_id" -A20 | grep "Physical Volumes:" -A1 | grep -v "Physical" | cut -d":" -f1 | cut -d"s" -f2 | sed 's/^ *//g')
        hard_drive_index="dis$hard_drive_index"
        partition_mount_point=$(diskutil info "$disk" | grep "^ " | grep "Mount Point:" | cut -d":" -f2- | sed 's/^ *//g')
        partition_name=$(diskutil info "$disk" | grep "^ " | grep "Volume Name:" | cut -d":" -f2- | sed 's/^ *//g')
        partition_size="$hard_drive_size"
        partition_free_space=$(diskutil info "$disk" | grep "^ " | grep "Volume Free Space:" | cut -d":" -f2- | sed 's/^ *//g' | cut -d" " -f3 | cut -d"(" -f2)
        partition_free_space=$(echo "$partition_free_space / 1000 / 1000 " | bc | cut -d"." -f1)
        partition_format=$(diskutil info "$disk" | grep "^ " | grep "File System Personality:" | cut -d":" -f2- | sed 's/^ *//g')
        partition_caption=$(diskutil info "$disk" | grep "^ " | grep "Volume Name:" | cut -d":" -f2- | sed 's/^ *//g')
        partition_disk_index=$(system_profiler SPStorageDataType | grep "Volume UUID: $partition_device_id" -A20 | grep "Physical Volumes:" -A1 | grep -v "Physical" | cut -d":" -f1 | sed 's/^ *//g')
        partition_used_space=$(echo "$partition_size - $partition_free_space" | bc | cut -d"." -f1)
        partition_each="$partition_each       <partition>"$'\n'
        partition_each="$partition_each           <hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
        partition_each="$partition_each           <partition_mount_type>partition</partition_mount_type>"$'\n'
        partition_each="$partition_each           <partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
        partition_each="$partition_each           <partition_name>$partition_name</partition_name>"$'\n'
        partition_each="$partition_each           <partition_size>$partition_size</partition_size>"$'\n'
        partition_each="$partition_each           <partition_free_space>$partition_free_space</partition_free_space>"$'\n'
        partition_each="$partition_each           <partition_used_space>$partition_used_space</partition_used_space>"$'\n'
        partition_each="$partition_each           <partition_format>$partition_format</partition_format>"$'\n'
        partition_each="$partition_each           <partition_caption>$partition_caption</partition_caption>"$'\n'
        partition_each="$partition_each           <partition_device_id>$partition_device_id</partition_device_id>"$'\n'
        partition_each="$partition_each           <partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
        partition_each="$partition_each           <partition_bootable></partition_bootable>"$'\n'
        partition_each="$partition_each           <partition_type>local hard disk</partition_type>"$'\n'
        partition_each="$partition_each           <partition_quotas_supported></partition_quotas_supported>"$'\n'
        partition_each="$partition_each           <partition_quotas_enabled></partition_quotas_enabled>"$'\n'
        partition_each="$partition_each           <partition_serial>$partition_serial</partition_serial>"$'\n'
        partition_each="$partition_each       </partition>"$'\n'
    else
        echo "      <item>" >> $xml_file
        echo "          <caption>$hard_drive_caption</caption>" >> $xml_file
        echo "          <hard_drive_index>$hard_drive_index</hard_drive_index>" >> $xml_file
        echo "          <interface_type>$hard_drive_interface_type</interface_type>" >> $xml_file
        echo "          <manufacturer>$hard_drive_manufacturer</manufacturer>" >> $xml_file
        echo "          <model>$hard_drive_model</model>" >> $xml_file
        echo "          <serial>$hard_drive_serial</serial>" >> $xml_file
        echo "          <size>$hard_drive_size</size>" >> $xml_file
        echo "          <device>$hard_drive_device_id</device>" >> $xml_file
        echo "          <status>$hard_drive_status</status>" >> $xml_file
        echo "          <firmware>$hard_drive_firmware</firmware>" >> $xml_file
        echo "      </item>" >> $xml_file
        # partitions on this disk
        for partition in $(diskutil list | grep "  $disk"s.\$ | awk 'NF>1{print $NF}'); do
            partition_mount_point=$(diskutil info "$partition" | grep "^ " | grep "Mount Point:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
            partition_name=$(diskutil info "$partition" | grep "^ " | grep "Volume Name:" | cut -d":" -f2- | sed 's/^ *//g' | sed 's/ *$//g')
            if [ "$partition_name" == "Not applicable (no file system)" ]; then
                partition_name=$(diskutil info "$partition" | grep "^ " | grep "Device / Media Name:" | cut -d":" -f2- | sed 's/^ *//g' | sed 's/ *$//g')
            fi
            partition_size=$(diskutil info "$partition" | grep "^ " | grep "Total Size:" | cut -d":" -f2- | sed 's/^ *//g' | cut -d" " -f3 | cut -d"(" -f2)
            partition_size=$(echo "$partition_size / 1000 / 1000" | bc | cut -d"." -f1)
            partition_free_space=$(diskutil info "$partition" | grep "^ " | grep "Volume Free Space:" | cut -d":" -f2- | sed 's/^ *//g' | cut -d" " -f3 | cut -d"(" -f2)
            partition_free_space=$(echo "$partition_free_space / 1000 / 1000" | bc | cut -d"." -f1)
            partition_format=$(diskutil info "$partition" | grep "^ " | grep "File System Personality:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
            partition_caption=$(diskutil info "$partition" | grep "^ " | grep "Volume Name:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
            partition_device_id=$(diskutil info "$partition" | grep "^ " | grep "Volume UUID:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
            partition_disk_index=$(diskutil info "$partition" | grep "^ " | grep "Device Identifier:" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g')
            partition_used_space=$(echo "$partition_size - $partition_free_space" | bc | cut -d"." -f1)
            partition_each="$partition_each       <partition>"$'\n'
            partition_each="$partition_each           <hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
            partition_each="$partition_each           <partition_mount_type>partition</partition_mount_type>"$'\n'
            partition_each="$partition_each           <partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
            partition_each="$partition_each           <partition_name>$partition_name</partition_name>"$'\n'
            partition_each="$partition_each           <partition_size>$partition_size</partition_size>"$'\n'
            partition_each="$partition_each           <partition_free_space>$partition_free_space</partition_free_space>"$'\n'
            partition_each="$partition_each           <partition_used_space>$partition_used_space</partition_used_space>"$'\n'
            partition_each="$partition_each           <partition_format>$partition_format</partition_format>"$'\n'
            partition_each="$partition_each           <partition_caption>$partition_caption</partition_caption>"$'\n'
            partition_each="$partition_each           <partition_device_id>$partition_device_id</partition_device_id>"$'\n'
            partition_each="$partition_each           <partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
            partition_each="$partition_each           <partition_bootable></partition_bootable>"$'\n'
            partition_each="$partition_each           <partition_type>local hard disk</partition_type>"$'\n'
            partition_each="$partition_each           <partition_quotas_supported></partition_quotas_supported>"$'\n'
            partition_each="$partition_each           <partition_quotas_enabled></partition_quotas_enabled>"$'\n'
            partition_each="$partition_each           <partition_serial>$partition_serial</partition_serial>"$'\n'
            partition_each="$partition_each       </partition>"$'\n'
        done
    fi
done
echo "  </disk>" >> $xml_file
echo "   <partitions>" >> $xml_file
echo "$partition_each</partitions>" >> $xml_file







# partition=""
# partition_name=""
# partition_mount_point=""
# partition_disk_index=""
# partition_size=""
# partition_free_space=""
# partition_used_space=""
# partition_format=""
# partition_caption=""
# partition_device_id=""
# media_name=""
# temp_partition=""
# temp_disk=""
# echo "	<hard_disks>" >> $xml_file
# for line in $(system_profiler SPStorageDataType | grep "Available" -B2 -A13); do
# 	if [[ "$line" == *"Media Name"* ]]; then
# 		hard_drive_caption=$(echo "$line" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ Media//g')
# 		media_name="$media_name $hard_drive_caption "
# 	fi
# 	if [[ "$line" == *"BSD Name"* ]]; then
# 		hard_drive_index=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | cut -dk -f2 | cut -ds -f1 | sed 's/^ *//g' | sed 's/ *$//g'`
# 	fi
# 	volumes="0"
# 	if [[ "$line" == *"Protocol"* ]]; then
# 		hard_drive_interface_type=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g'`
# 		if [[ "$hard_drive_interface_type" == "SATA" ]]; then
# 			for each in $(system_profiler SPSerialATADataType | grep "$hard_drive_caption" -A15); do
# 				if [[ "$each" == *"Model"* ]]; then
# 					hard_drive_model=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 					if [[ "$hard_drive_model" == *"APPLE"* ]]; then
# 						hard_drive_manufacturer="Apple"
# 					fi
# 				fi
# 				if [[ "$each" == *"Serial Number"* ]]; then
# 					hard_drive_serial=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"S.M.A.R.T. status"* ]]; then
# 					hard_drive_status=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"Revision"* ]]; then
# 					hard_drive_firmware=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"Volumes:"* ]] && [[ "$volumes" == "0" ]]; then
# 					volumes="1"
# 					for vol in $(system_profiler SPSerialATADataType | grep "$hard_drive_caption" -A100 | grep "Volumes:" -A 30 | egrep "^$" -B30 | grep -v "Volumes:"); do
# 						partition_mount_type="mount point"
# 						if [[ "$vol" == *"Mount Point"* ]]; then
# 							partition_mount_point=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 						fi
# 						if [[ "$vol" == *"BSD Name"* ]]; then
# 							partition_disk_index=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | cut -dk -f2 | cut -ds -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 						fi
# 						if [[ "$vol" == *"Capacity"* ]]; then
# 							partition_size=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/,/./g'`
# 							if [[ "$vol" == *"GB"* ]]; then
# 								partition_size=`echo "$partition_size * 1024" | bc | cut -d"." -f1`
# 							fi
# 							if [[ "$vol" == *"TB"* ]]; then
# 								partition_size=`echo "$partition_size * 1024 * 1024" | bc | cut -d"." -f1`
# 							fi
# 						fi
# 						if [[ "$vol" == *"Available"* ]]; then
# 							partition_free_space=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/,/./g'`
# 							if [[ "$vol" == *"GB"* ]]; then
# 								partition_free_space=`echo "$partition_free_space * 1024" | bc | cut -d"." -f1`
# 							fi
# 							if [[ "$vol" == *"TB"* ]]; then
# 								partition_free_space=`echo "$partition_free_space * 1024 * 1024" | bc | cut -d"." -f1`
# 							fi
# 							partition_used_space=`echo "$partition_size - $partition_free_space" | bc`
# 						fi
# 						if [[ "$vol" == *"File System"* ]]; then
# 							partition_format=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 						fi
# 						if [[ "$vol" == *"Content"* ]]; then
# 							partition_caption=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 						fi
# 						if [[ "$vol" == *"Volume UUID"* ]]; then
# 							partition_device_id=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 						fi
# 						partition_type="volume"
# 						partition_quotas_supported=""
# 						partition_quotas_enabled=""
# 						partition_serial=""
# 						# test if we have a blank line
# 						test=$(echo "$vol" | cut -d":" -f2)
# 						if [[ "$test" == "" ]] ; then
# 							if [[ "$partition_size" != "" ]]; then
# 								#echo "TEMP PART: $temp_partition"
# 								#echo "PART INDEX: d$hard_drive_index p$partition_disk_index "
# 								if [[ "$temp_partition" != *" d$hard_drive_index p$partition_disk_index "* ]]; then
# 									#echo "in sata 2, writing partition info to XML for $partition_name on $hard_drive_caption"
# 									partition="$partition		<partition>"$'\n'
# 									partition="$partition			<hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
# 									partition="$partition			<partition_mount_type>partition</partition_mount_type>"$'\n'
# 									partition="$partition			<partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
# 									partition="$partition			<partition_name>$partition_name</partition_name>"$'\n'
# 									partition="$partition			<partition_size>$partition_size</partition_size>"$'\n'
# 									partition="$partition			<partition_free_space>$partition_free_space</partition_free_space>"$'\n'
# 									partition="$partition			<partition_used_space>$partition_used_space</partition_used_space>"$'\n'
# 									partition="$partition			<partition_format>$partition_format</partition_format>"$'\n'
# 									partition="$partition			<partition_caption>$partition_caption</partition_caption>"$'\n'
# 									partition="$partition			<partition_device_id>$partition_device_id</partition_device_id>"$'\n'
# 									partition="$partition			<partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
# 									partition="$partition			<partition_bootable></partition_bootable>"$'\n'
# 									partition="$partition			<partition_type>local hard disk</partition_type>"$'\n'
# 									partition="$partition			<partition_quotas_supported></partition_quotas_supported>"$'\n'
# 									partition="$partition			<partition_quotas_enabled></partition_quotas_enabled>"$'\n'
# 									partition="$partition			<partition_serial>$partition_serial</partition_serial>"$'\n'
# 									partition="$partition		</partition>"$'\n'
# 									temp_partition="$temp_partition d$hard_drive_index p$partition_disk_index "
# 									partition_name=$(echo "$vol" | cut -d":" -f1 | sed 's/^ *//g' | sed 's/ *$//g')
# 									partition_mount_point=""
# 									partition_disk_index=""
# 									partition_size=""
# 									partition_free_space=""
# 									partition_used_space=""
# 									partition_format=""
# 									partition_caption=""
# 									partition_device_id=""
# 								fi
# 							else
# 								partition_name=$(echo "$vol" | cut -d":" -f1 | sed 's/^ *//g' | sed 's/ *$//g')
# 							fi
# 						fi
# 						if [[ "$vol" == *"Volume UUID"* ]] && [[ "$partition_size" != "" ]]; then
# 							#echo "TEMP PART: $temp_partition"
# 							#echo "PART INDEX: d$hard_drive_index p$partition_disk_index "
# 							if [[ "$temp_partition" != *" d$hard_drive_index p$partition_disk_index "* ]]; then
# 								#echo "in sata 4, writing partition info to XML for $partition_name on $hard_drive_caption"
# 								partition="$partition		<partition>"$'\n'
# 								partition="$partition			<hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
# 								partition="$partition			<partition_mount_type>partition</partition_mount_type>"$'\n'
# 								partition="$partition			<partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
# 								partition="$partition			<partition_name>$partition_name</partition_name>"$'\n'
# 								partition="$partition			<partition_size>$partition_size</partition_size>"$'\n'
# 								partition="$partition			<partition_free_space>$partition_free_space</partition_free_space>"$'\n'
# 								partition="$partition			<partition_used_space>$partition_used_space</partition_used_space>"$'\n'
# 								partition="$partition			<partition_format>$partition_format</partition_format>"$'\n'
# 								partition="$partition			<partition_caption>$partition_caption</partition_caption>"$'\n'
# 								partition="$partition			<partition_device_id>$partition_device_id</partition_device_id>"$'\n'
# 								partition="$partition			<partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
# 								partition="$partition			<partition_bootable></partition_bootable>"$'\n'
# 								partition="$partition			<partition_type>local hard disk</partition_type>"$'\n'
# 								partition="$partition			<partition_quotas_supported></partition_quotas_supported>"$'\n'
# 								partition="$partition			<partition_quotas_enabled></partition_quotas_enabled>"$'\n'
# 								partition="$partition			<partition_serial>$partition_serial</partition_serial>"$'\n'
# 								partition="$partition		</partition>"$'\n'
# 								temp_partition="$temp_partition d$hard_drive_index p$partition_disk_index "
# 								partition_mount_point=""
# 								partition_disk_index=""
# 								partition_size=""
# 								partition_free_space=""
# 								partition_used_space=""
# 								partition_format=""
# 								partition_caption=""
# 								partition_device_id=""
# 							fi
# 						fi
# 					done
# 				fi
# 			done
# 		fi # end of linterface == SATA
# 		if [[ "$hard_drive_interface_type" == "USB" ]]; then
# 			for each in $(system_profiler SPUSBDataType | grep "BSD Name: disk$hard_drive_index\$" -B12 -A4); do
# 				if [[ "$each" == *"Serial Number"* ]]; then
# 					hard_drive_serial=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"Manufacturer"* ]]; then
# 					hard_drive_manufacturer=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"Version"* ]]; then
# 					hard_drive_firmware=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$each" == *"S.M.A.R.T. status"* ]]; then
# 					hard_drive_status=`echo "$each" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 			done
# 			for vol in $(system_profiler SPUSBDataType | grep "BSD Name: disk$hard_drive_index\$" -A30 | grep "Volumes:" -A20 | grep -v "Volumes:"); do
# 				partition_mount_type="mount point"
# 				if [[ "$vol" == *"Mount Point"* ]]; then
# 					partition_mount_point=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$vol" == *"BSD Name"* ]]; then
# 					partition_disk_index=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | cut -dk -f2 | cut -ds -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$vol" == *"Capacity"* ]]; then
# 					partition_size=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/,/./g'`
# 					if [[ "$vol" == *"GB"* ]]; then
# 						partition_size=`echo "$partition_size * 1024" | bc | cut -d"." -f1`
# 					fi
# 					if [[ "$vol" == *"TB"* ]]; then
# 						partition_size=`echo "$partition_size * 1024 * 1024" | bc | cut -d"." -f1`
# 					fi
# 				fi
# 				if [[ "$vol" == *"Available"* ]]; then
# 					partition_free_space=`echo "$vol" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/,/./g'`
# 					if [[ "$vol" == *"GB"* ]]; then
# 						partition_free_space=`echo "$partition_free_space * 1024" | bc | cut -d"." -f1`
# 					fi
# 					if [[ "$vol" == *"TB"* ]]; then
# 						partition_free_space=`echo "$partition_free_space * 1024 * 1024" | bc | cut -d"." -f1`
# 					fi
# 					partition_used_space=`echo "$partition_size - $partition_free_space" | bc`
# 				fi
# 				if [[ "$vol" == *"File System"* ]]; then
# 					partition_format=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$vol" == *"Content"* ]]; then
# 					partition_caption=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				if [[ "$vol" == *"Volume UUID"* ]]; then
# 					partition_device_id=`echo "$vol" | cut -d":" -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 				fi
# 				partition_type="volume"
# 				partition_quotas_supported=""
# 				partition_quotas_enabled=""
# 				partition_serial=""
# 				test=$(echo "$vol" | cut -d":" -f2)
# 				if [[ "$test" == "" ]] ; then
# 					if [[ "$partition_size" != "" ]]; then
# 						#echo "TEMP PART: $temp_partition"
# 						#echo "PART INDEX: d$hard_drive_index p$partition_disk_index "
# 						if [[ "$temp_partition" != *" d$hard_drive_index p$partition_disk_index "* ]]; then
# 							#echo "in usb 2, writing partition info to XML for $partition_name on $hard_drive_caption"
# 							partition="$partition		<partition>"$'\n'
# 							partition="$partition			<hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
# 							partition="$partition			<partition_mount_type>partition</partition_mount_type>"$'\n'
# 							partition="$partition			<partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
# 							partition="$partition			<partition_name>$partition_name</partition_name>"$'\n'
# 							partition="$partition			<partition_size>$partition_size</partition_size>"$'\n'
# 							partition="$partition			<partition_free_space>$partition_free_space</partition_free_space>"$'\n'
# 							partition="$partition			<partition_used_space>$partition_used_space</partition_used_space>"$'\n'
# 							partition="$partition			<partition_format>$partition_format</partition_format>"$'\n'
# 							partition="$partition			<partition_caption>$partition_caption</partition_caption>"$'\n'
# 							partition="$partition			<partition_device_id>$partition_device_id</partition_device_id>"$'\n'
# 							partition="$partition			<partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
# 							partition="$partition			<partition_bootable></partition_bootable>"$'\n'
# 							partition="$partition			<partition_type>local hard disk</partition_type>"$'\n'
# 							partition="$partition			<partition_quotas_supported></partition_quotas_supported>"$'\n'
# 							partition="$partition			<partition_quotas_enabled></partition_quotas_enabled>"$'\n'
# 							partition="$partition			<partition_serial>$partition_serial</partition_serial>"$'\n'
# 							partition="$partition		</partition>"$'\n'
# 							temp_partition="$temp_partition d$hard_drive_index p$partition_disk_index "
# 							partition_name=$(echo "$vol" | cut -d":" -f1 | sed 's/^ *//g' | sed 's/ *$//g')
# 							partition_mount_point=""
# 							partition_disk_index=""
# 							partition_size=""
# 							partition_free_space=""
# 							partition_used_space=""
# 							partition_format=""
# 							partition_caption=""
# 							partition_device_id=""
# 						fi
# 					else
# 						partition_name=$(echo "$vol" | cut -d":" -f1 | sed 's/^ *//g' | sed 's/ *$//g')
# 					fi
# 				fi
# 				if [[ "$vol" == *"Volume UUID"* ]] && [[ "$partition_size" != "" ]]; then
# 						#echo "TEMP PART: $temp_partition"
# 						#echo "PART INDEX: d$hard_drive_index p$partition_disk_index "
# 					if [[ "$temp_partition" != *" d$hard_drive_index p$partition_disk_index "* ]]; then
# 						#echo "in usb 4, writing partition ifo to XML for $partition_name on $hard_drive_caption"
# 						partition="$partition		<partition>"$'\n'
# 						partition="$partition			<hard_drive_index>$hard_drive_index</hard_drive_index>"$'\n'
# 						partition="$partition			<partition_mount_type>partition</partition_mount_type>"$'\n'
# 						partition="$partition			<partition_mount_point>$partition_mount_point</partition_mount_point>"$'\n'
# 						partition="$partition			<partition_name>$partition_name</partition_name>"$'\n'
# 						partition="$partition			<partition_size>$partition_size</partition_size>"$'\n'
# 						partition="$partition			<partition_free_space>$partition_free_space</partition_free_space>"$'\n'
# 						partition="$partition			<partition_used_space>$partition_used_space</partition_used_space>"$'\n'
# 						partition="$partition			<partition_format>$partition_format</partition_format>"$'\n'
# 						partition="$partition			<partition_caption>$partition_caption</partition_caption>"$'\n'
# 						partition="$partition			<partition_device_id>$partition_device_id</partition_device_id>"$'\n'
# 						partition="$partition			<partition_disk_index>$partition_disk_index</partition_disk_index>"$'\n'
# 						partition="$partition			<partition_bootable></partition_bootable>"$'\n'
# 						partition="$partition			<partition_type>local hard disk</partition_type>"$'\n'
# 						partition="$partition			<partition_quotas_supported></partition_quotas_supported>"$'\n'
# 						partition="$partition			<partition_quotas_enabled></partition_quotas_enabled>"$'\n'
# 						partition="$partition			<partition_serial>$partition_serial</partition_serial>"$'\n'
# 						partition="$partition		</partition>"$'\n'
# 						temp_partition="$temp_partition d$hard_drive_index p$partition_disk_index "
# 						partition_mount_point=""
# 						partition_disk_index=""
# 						partition_size=""
# 						partition_free_space=""
# 						partition_used_space=""
# 						partition_format=""
# 						partition_caption=""
# 						partition_device_id=""
# 					fi
# 				fi
# 			done
# 		fi # end of interface == USB
# 	fi # end of line == protocol
# 	if [[ "$line" == *"Medium Type"* ]]; then
# 		hard_drive_type=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 	fi
# 	if [[ "$line" == *"Capacity"* ]]; then
# 		hard_drive_size=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/,/./g'`
# 		if [[ "$line" == *"GB"* ]]; then
# 			hard_drive_size=`echo "$hard_drive_size * 1024" | bc | cut -d"." -f1`
# 		fi
# 		if [[ "$line" == *"TB"* ]]; then
# 			hard_drive_size=`echo "$hard_drive_size * 1024 * 1024" | bc | cut -d"." -f1`
# 		fi
# 	fi
# 	if [[ "$line" == *"Volume UUID"* ]]; then
# 		hard_drive_device_id=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 	fi
# 	if [[ "$line" == *"Mount Point"* ]]; then
# 		hard_drive_mount=`echo "$line" | cut -d":" -f2 | cut -d" " -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
# 	fi
# 	if [[ "$line" == *"Partition Map Type"* ]]; then
# 		#echo "TEMP DISK: $temp_disk"
# 		#echo "DISK INDEX: d$hard_drive_index "
# 		if [[ "$temp_disk" != *" d$hard_drive_index "* ]]; then
# 			echo "		<hard_disk>" >> $xml_file
# 			echo "			<hard_drive_caption>$hard_drive_caption</hard_drive_caption>" >> $xml_file
# 			echo "			<hard_drive_index>$hard_drive_index</hard_drive_index>" >> $xml_file
# 			echo "			<hard_drive_interface_type>$hard_drive_interface_type</hard_drive_interface_type>" >> $xml_file
# 			echo "			<hard_drive_manufacturer>$hard_drive_manufacturer</hard_drive_manufacturer>" >> $xml_file
# 			echo "			<hard_drive_model>$hard_drive_model</hard_drive_model>" >> $xml_file
# 			echo "			<hard_drive_serial>$hard_drive_serial</hard_drive_serial>" >> $xml_file
# 			echo "			<hard_drive_size>$hard_drive_size</hard_drive_size>" >> $xml_file
# 			echo "			<hard_drive_device_id>$hard_drive_device_id</hard_drive_device_id>" >> $xml_file
# 			echo "			<hard_drive_partitions>$hard_drive_partitions</hard_drive_partitions>" >> $xml_file
# 			echo "			<hard_drive_status>$hard_drive_status</hard_drive_status>" >> $xml_file
# 			echo "			<hard_drive_firmware>$hard_drive_firmware</hard_drive_firmware>" >> $xml_file
# 			echo "			<hard_drive_scsi_logical_unit></hard_drive_scsi_logical_unit>" >> $xml_file
# 			echo "		</hard_disk>" >> $xml_file
# 			temp_disk="$temp_disk d$hard_drive_index "
# 			hard_drive_caption=""
# 			hard_drive_index=""
# 			hard_drive_interface_type=""
# 			hard_drive_model=""
# 			hard_drive_serial=""
# 			hard_drive_size=""
# 			hard_drive_device_id=""
# 			hard_drive_partitions=""
# 			hard_drive_status=""
# 			hard_drive_firmware=""
# 		fi
# 	fi
# done
# echo "	</hard_disks>" >> $xml_file
# echo "	<partitions>" >> $xml_file
# echo "$partition" >> $xml_file
# echo "	</partitions>" >> $xml_file


if [ "$debugging" -gt "0" ]; then
	echo "Software Info"
fi
echo "	<software>" >> $xml_file
software_name=""
software_version=""
software_install_source=""
for line in $(system_profiler SPApplicationsDataType | grep "Location: " -B 8 -A 1 | grep -e '^$' -v); do

	if [[ "$software_name" == "" && "$line" != *"Get Info String: "* ]]; then
		#software_name=`echo "$line"`     # | cut -d":" -f0 | sed 's/^ *//'`
		software_name=`echo "$line" | sed 's/^ *//'`
	fi

	if [[ "$software_name" == "--" ]]; then
		software_name=""
	fi

	if [[ "$line" == *"Version: "* ]]; then
		software_version=`echo "$line" | cut -d":" -f2 | sed 's/^ *//'`
	fi

	if [[ "$line" == *"App Store: Yes"* ]]; then
		software_install_source="Mac App Store"
	fi

	if [[ "$line" == *"App Store: No"* ]]; then
		software_install_source="Unknown"
	fi

	if [[ "$line" == *"Obtained from: "* ]]; then
		software_install_source=`echo "$line" | cut -d":" -f2 | sed 's/^ *//'`
	fi

	if [[ "$line" == *"Signed by: Developer ID Application"* ]]; then
		software_publisher=`echo "$line" | cut -d":" -f3 | cut -d"," -f1 | sed 's/^ *//'`
	fi

	if [[ "$line" == *"Signed by: Microsoft Corporation"* ]]; then
		software_publisher="Microsoft"
	fi

	if [[ "$software_install_source" == "Apple" ]]; then
		software_publisher="Apple"
	fi

	if [[ "$line" == *"Get Info String: "* && "$software_publisher" == "" ]]; then
		software_publisher=`echo "$line" | sed 's/^ *//'`
		software_publisher=`echo "$software_publisher" | sed 's/^Get Info String: //'`
	fi

	if [[ "$line" == *"Location:"* ]]; then
		software_location=`echo "$line" | cut -d":" -f2 | sed 's/^ *//'`
		software_name=`echo $software_name | cut -d":" -f1`
		echo "		<item>" >> $xml_file
		echo "			<name><![CDATA[$software_name]]></name>" >> $xml_file
		echo "			<version><![CDATA[$software_version]]></version>" >> $xml_file
		echo "			<location><![CDATA[$software_location]]></location>" >> $xml_file
		echo "			<install_source>$software_install_source</install_source>" >> $xml_file
		echo "			<publisher><![CDATA[$software_publisher]]></publisher>" >> $xml_file
		echo "		</item>" >> $xml_file
		software_name=""
		software_version=""
		software_location=""
		software_install_source=""
		software_publisher=""
	fi
done
echo "	</software>" >> $xml_file



if [ "$debugging" -gt "0" ]; then
	echo "Software Keys"
fi
echo "	<software_keys>" >> $xml_file
key_name=""
key_release=""
key_text=""
# Adobe CS5 and later
if [ -d /Library/Application\ Support/regid.1986-12.com.adobe/ ] ; then
	# Read each each found file and add its product to a list
	for AFILE in /Library/Application\ Support/regid.1986-12.com.adobe/*
	do
		key_name=$( sed -n -e 's/.*<swid:product_title>\(.*\)<\/swid:product_title>.*/\1/p' "$AFILE" )
		key_release=$( sed -n -e 's/.*<swid:activation_status>\(.*\)<\/swid:activation_status>.*/\1/p' "$AFILE" )
		key_text=$( sed -n -e 's/.*<swid:serial_number>\(.*\)<\/swid:serial_number>.*/\1/p' "$AFILE" )
		echo "		<key>" >> $xml_file
		echo "			<key_name><![CDATA[$key_name]]></key_name>" >> $xml_file
		echo "			<key_text><![CDATA[$key_text]]></key_text>" >> $xml_file
		echo "			<key_release><![CDATA[$key_release]]></key_release>" >> $xml_file
		echo "			<key_edition>OSX</key_edition>" >> $xml_file
		echo "		</key>" >> $xml_file
		key_name=""
		key_release=""
		key_text=""
	done
fi

key_name=""
key_release=""
key_text=""

# Adobe CS4
if [ -d /Users/Shared/Adobe/ISO-19770/ ] ; then
	# Read each found file add its product to the list
	for AFILE in /Users/Shared/Adobe/ISO-19770/*
	do
		key_name=$( sed -n -e 's/.*<sat:product_title>\(.*\)<\/sat:product_title>.*/\1/p' "$AFILE" )
		# Some products use a different version of SWID Tag where "sat:product_title" isn't valid.
		# If "sat:product_title" isn't found in the tag then assume "product".
		if [ "$key_name" = "" ] ; then
			key_name=$( sed -n -e 's/.*<product>\(.*\)<\/product>.*/\1/p' "$AFILE" )
			key_suite=$( sed -n -e 's/.*<part_of_suite>\(.*\)<\/part_of_suite>.*/\1/p' "$AFILE" )

			# Some products such as Acrobat Pro may exist but this older version
			# of SWID Tag will only indicate that it was part of a suite or standalone.
			# Report if the product is part of a suite.

			if [ "$key_suite" = "true" ] ; then
				key_name="$key_name is part of an unknown CS4 suite"
			fi
		fi
		key_release=$( sed -n -e 's/.*<sat:activation_status>\(.*\)<\/sat:activation_status>.*/\1/p' "$AFILE" )
		echo "		<key>" >> $xml_file
		echo "			<key_name><![CDATA[$key_name]]></key_name>" >> $xml_file
		echo "			<key_text></key_text>" >> $xml_file
		echo "			<key_release><![CDATA[$key_release]]></key_release>" >> $xml_file
		echo "			<key_edition>OSX</key_edition>" >> $xml_file
		echo "		</key>" >> $xml_file
		key_name=""
		key_release=""
		key_text=""
	done
fi


echo "	</software_keys>" >> $xml_file




echo "</system>" >> $xml_file


if [ "$submit_online" = "y" ]; then
	echo "Submitting results to server"
	curl --data-urlencode form_systemXML@"$xml_file" $url
fi


if [ "$terminal_print" = "y" ]; then
	cat "$xml_file"
fi


if [ "$create_file" != "y" ]; then
	`rm -f $xml_file`
fi

IFS=$O

