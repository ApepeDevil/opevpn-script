#!/bin/bash
#скрипт запускается, и устанавливается vpn соединение
#описание:
#0. create directory vpn-book
#1. Download from vpn-book archive of .ovpn files
#2. установка значения пароля
#3. проверка наличия указателя файл с юзером и пасом в  конфиге, если нет - создает, если есть - пропуск. Проверка актуальности пароля в файле auth.txt
#4. сравнение значения passord переменной полученной из wget, и значения из локального файла
#5. проверка vpn-файла
#добавить возможность указания сайта откуда скачивать. download in temporary directory
#wget http://www.vpnbook.com
#var0 - getten value of password
#var1 - local value of password
#var3 - files ovpn
#var4 - проверка ovpn file на наличие auth.txt 

#create directory if not exist

if [ -d vpn-book ];
then
        echo "directory already exist"
else
        echo "now directory was created"
        mkdir $HOME/vpn-book
fi

#
if [ -f $HOME/vpn-book/Euro1.zip ];
then
        echo "archive already exist"
else
        echo "now archive was downloaded."
        wget -nv -O $HOME/vpn-book/Euro1.zip http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip

fi

#
var3=( $HOME/vpn-book/vpnbook* )

if [ -f $var3 ];
then
        echo "ovpn files already exist"
else
        echo "now files was unziped"
        unzip -o $HOME/vpn-book/Euro1.zip -d $HOME/vpn-book
fi


#get web page vpnbook
wget -nv -O /tmp/index.html http://www.vpnbook.com

#convert html to normal tex and grep password
var0=$(awk '{gsub("<[^>]*>", "")}1' /tmp/index.html | grep  'Password: ' | cut -d: -f2 | awk '{ print $1; exit}')

#
var1=$(cat $HOME/vpn-book/auth.txt | grep -v "vpnbook")
if [[ $var0 == $var1 ]];
then
      echo "auth.txt is ok. Yeah!"
else
#clear auth.txt
      cat /dev/null > $HOME/vpn-book/auth.txt
      echo "vpnbook" > $HOME/vpn-book/auth.txt
      echo $var0 >> $HOME/vpn-book/auth.txt
      echo "now auth.txt is ok."

fi

#
files=( $HOME/vpn-book/vpnbook* )
shopt -s extglob

string="@(${files[0]}"
for((i=1;i<${#files[@]};i++))
do
    string+="|${files[$i]}"
done
string+=")"

select file in "${files[@]}" "quit"
do
    case $file in
    $string)
         break;
        ;;

    "quit")
        exit;;
    *)
        file=""
        echo "Please choose a number from 1 to $((${#files[@]}+1))";;
    esac
done

var4=$(cat $file | grep "auth-user-pass auth.txt")

if [[ $var4 > 0 ]];
then
        echo "ovpn is ok."
else
        sed -i 's/auth-user-pass/auth-user-pass auth.txt/g' $file
        echo "now ovpn file ok."
fi

cd $HOME/vpn-book

sudo openvpn --config $file

exit 0
