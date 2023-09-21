#!/usr/bin/env bash
#20230921_13:16_est--EJR
#
###########################################################
#>>>-DEPS/->>>
if ! command -v xclip &> /dev/null; then echo "xclip is not installed."; echo "Please run the following command to install it:"; echo "sudo apt-get install -y xclip"; exit 1; fi
if ! command -v oathtool &> /dev/null; then echo "oathtool is not installed."; echo "Please run the following command to install it:"; echo "sudo apt-get install -y oathtool"; exit 1; fi
#<<<-DEPS/-<<<
###########################################################
#>>>-FUNCS/->>>
control_loop() { while true; do read -n 1 input < /dev/tty; if [[ "${input,,}" == 'q' ]]; then kill $(jobs -p); break; fi; done; }
background_loop() { while true; do clear; zotp=$(oathtool --base32 --totp "$zseed"); echo -e "\e[32m\e[2m$zinfo\e[0m"; echo -e "\nOTP FOR \e[36m\e[1m$zname\e[0m (Copied To Clipboard):\n\e[33m$(figlet $zotp)\e[0m"; echo -e "\n**Press \e[5m( Q )\e[0m To Leave**"; if [ "$zotp" != "$last_otp" ]; then echo -n "$zotp" | xclip -selection clipboard; last_otp="$zotp"; fi; sleep 1; done; }
#<<<-FUNCS/-<<<
###########################################################
#>>>-VARS/->>>
keys="1234567890qwertyuiopasdfghjklzxcvbnm"
IFS=',' # Set the field separator to comma
line_num=0 # Counter for line number in CSV file
declare -A menu_options # Associative array to store menu options
#<<<-VARS/-<<<
###########################################################
#>>>-CSV/->>>
#>>>-CSV/VAR/FILE->>>🛑️
csv="$HOME/🛑️MODIFY/THIS/AREA/auth.csv🛑️" #🛑️FORMAT OF CSV= NAME,SEED,USER,PASS,URL
#📌️>>>-CSV/VAR/HEREDOC/->>>📌️OPTIONALO
#USING A HEREDOC IS AN OPTION (REQUIRES A LITTLE MODIFICATION)
#>>>-CSV/VAR/HEREDOC/CODE->>>
csv=$(cat << H3R3C5V
NAME,SEED,USER,PASS,URL
Gmail,1234567890,myusername,mypassword,gmail.com
H3R3C5V
#<<<-CSV/VAR/HEREDOC/CODE-<<<
# **Also Modify Program**
# FILE:    done < "$csv"
# HEREDOC: done <<< "$csv"
#📌️<<<-CSV/VAR/HEREDOC/-<<<📌️OPTIONAL
###########################################################
#>>>-MAINMENU/->>>
#>>>-MAINMENU/LOOP/->>>
clear; while read -r line; do
  if [ $line_num -gt 0 ]; then
    IFS=',' read -r -a fields <<< "$line"
    name="${fields[0]}"; seed="${fields[1]}"; user="${fields[2]}"; pass="${fields[3]}"; url="${fields[4]}"
    key="${keys:0:1}"; keys="${keys:1}"; menu_options["$key"]="$name"
    echo "$key - $name"
  fi
  ((line_num++))
# 📌️  -IF- -USING_HEREDOC- -THEN-   done <<< "$csv"   -ELSE-   done < "$csv"   📌️
done < "$csv"
#<<<-MAINMENU/LOOP/-<<<
###########################################################
#>>>-MAINMENU/INPUTS/->>>
echo 'Esc - Exit'; echo "Hit Key For Option:"; read -rsn1 key; key=${key,,}
#>>>-MAINMENU/INPUTS/LOGIC/->>>
case "$key" in
  $'\e') clear; exit 0 ;;
  *) if [ -n "${menu_options[$key]}" ]; then zinfo="USER: $user\nPASS: $pass\nURL: $url"; zname="${menu_options[$key]}"; zseed="$seed"; last_otp=""; background_loop & control_loop; clear; else clear; exit 0; fi ;;
esac
#<<<-MAINMENU/INPUTS/LOGIC/-<<<
#<<<-MAINMENU/INPUTS/-<<<
###########################################################
#<<<-MAINMENU/-<<<
###########################################################