#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
                                                                                
                            .:^7J5PGGBBBBBBGP5Y?!^:.                            
                       .~JPB####BGG55YYYJYY5PGB#####B5?^.                       
                   .~YB###G5?~:.                .:~?5B###GJ^.                   
                .!P###P?^.          .:^~!7777!^:.     .~YB###5~                 
              :Y###P!.          ^75B#############G7.      :7G###J:              
            ~P##B?.          .JB###################5         :J###5:            
          ^P##G~    .::     7####################G7.           .?B##5.          
        .Y##B!   .JG###G   .B#################P7:    :~!~^.      .?###7         
       ^B##Y.  .Y#######~   5##############P~.     7G######GJ~     :G##P.       
      !###~   :B########7   .B###########G^      7B###########B?.    J##B:      
     7##B^   ^##########?    :B##########!     .P################J.   !###^     
    !##B:   .G##########5     .5#########!    .G##################B~   !###:    
   :B##!    ?############:      !B#######G.   G#####################?   ?##G    
   5##Y    .G############B7.     .5#######G?~J#######################~  .G##?   
  ^B#B:    .################G5J77P##GY?!7?PB##########G5YPG##########B   !##G.  
  ?##P     .G#####################Y.  ...   :P#####P~.     .^?PB#####B   .B##~  
  5##?      ^####################^  7G###BP~  7###~             :7YP5:    P##?  
 .P##!       .?PB###########B###?  5########!  5##. .::^^~^^:.            ?##Y  
 .P##!           .:^~~!~^^:. ~##?  P########!  Y###B###########B5!        ?##Y  
  5##7    ~YY?~.             7##B^  ?B####G!  7###################G.      P##J  
  ?##P   .######BY!.      .~G#####?.  ....  :5#####################J      B##~  
  ^##B:  .##########BPY?YG##########GJ7~!7YG##5?JYPB###############5     !##G.  
   P##Y   Y#######################?!5########?      ^5#############Y     G##J   
   :B##~   5#####################J   ^B#######G^      7############!    7##B.   
    !##B:   ?###################P     J#########J      ###########P    !###:    
     ?##B:   :5################Y      J##########P     B#########G.   ~###^     
      7###~    ^5############B~      ~B###########P    P########P.   ?##B^      
       ^B##J     .75B######G!     .!P##############7   Y#######?   .P##G.       
        .5##B~       :~!!~:    :7P#################P   :####G?.   7###?         
          ^G##P^            .7G###################B~    .^^.    7B##P:          
            ~G##G7.        .G###################B?.          :?B##P^            
              ^5###5~.      :YB#############B57:          .!P###Y:              
                .7G###P?:.     .^!7???7!~^:.          .^JG###5!.                
                   .!5####GY7^.                 .:~75G###BY~.                   
                       :!YG#####BGP5YYJ??JYY5PGB####BPJ~.                       
                            .:~?Y5GBBBBBBBBBGP5J7~:.                            
                                                                                
-------------------------------------------------------------------------
                    Automated TurbineOS Installer
                        SCRIPTHOME: TurbineOS
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/ArchTitus/configs/setup.conf

  cd ~
  mkdir "/home/$USERNAME/.cache"
  touch "/home/$USERNAME/.cache/zshhistory"
  git clone "https://github.com/ChrisTitusTech/zsh"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  ln -s "~/zsh/.zshrc" ~/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchTitus/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchTitus/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    cp -r ~/ArchTitus/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/ArchTitus/configs/kde.knsv
    sleep 1
    konsave -a kde
 fi
fi

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
