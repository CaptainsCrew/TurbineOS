#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
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

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/ArchTitus/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
               Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing CyberRe Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME=CyberRe
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/ArchTitus
cp -a configs${THEME_DIR}/${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    echo [Theme] >>  /etc/sddm.conf
    echo Current=Nordic >> /etc/sddm.conf
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

if [[ "${FS}" == "luks" || "${FS}" == "btrfs" ]]; then
echo -ne "
-------------------------------------------------------------------------
                    Creating Snapper Config
-------------------------------------------------------------------------
"

SNAPPER_CONF="$HOME/ArchTitus/configs/etc/snapper/configs/root"
mkdir -p /etc/snapper/configs/
cp -rfv ${SNAPPER_CONF} /etc/snapper/configs/

SNAPPER_CONF_D="$HOME/ArchTitus/configs/etc/conf.d/snapper"
mkdir -p /etc/conf.d/
cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/

fi

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Plymouth Boot Splash
-------------------------------------------------------------------------
"
PLYMOUTH_THEMES_DIR="$HOME/ArchTitus/configs/usr/share/plymouth/themes"
PLYMOUTH_THEME="arch-glow" # can grab from config later if we allow selection
mkdir -p /usr/share/plymouth/themes
echo 'Installing Plymouth theme...'
cp -rf ${PLYMOUTH_THEMES_DIR}/${PLYMOUTH_THEME} /usr/share/plymouth/themes
if [[ $FS == "luks" ]]; then
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
  sed -i 's/HOOKS=(base udev \(.*block\) /&plymouth-/' /etc/mkinitcpio.conf # create plymouth-encrypt after block hook
else
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
fi
plymouth-set-default-theme -R arch-glow # sets the theme and runs mkinitcpio
echo 'Plymouth theme installed'

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/ArchTitus
rm -r /home/$USERNAME/ArchTitus

# Replace in the same state
cd $pwd
