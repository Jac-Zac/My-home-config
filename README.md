# My-home-config

## Synopsis
this configuration repo contain everything to set up my termianal from scrach in a single script
###### (It is made for mac)

## Motivation
I mainly craeted this to always have my config with me, but I would really be happy if anybody wanted to try it. And also If I can help someone with this I think it is worth to share it. 

## Example of what my terminal look like

![showcase](https://github.com/Jac-Zac/My-home-config/blob/master/my_terminal.png)

# Installation (Noob proof)

###### you have to be in zsh shell for this installation

###### clone the reposiotry
```
git clone https://github.com/Jac-Zac/My-home-config.git
```
###### change in to the correct directory
```
cd My-home-config
```
###### this command give excecute permission to the script
```
chmod +x installer.sh 
```
###### run the first script
```
bash installer.sh 
```
###### run the second script
```
sudo bash root_script.sh
```

**I suggest to install also** [anaconda](https://docs.anaconda.com/anaconda/install/mac-os/)

**Other thing I suggest to have the same terminla style and look:**

- If you want my same color theme go to -> https://github.com/arcticicestudio/nord-terminal-app
- If you want gotop you can run ```brew install gotop ```

## Customizations

- If you want neofetch just run ```brew install neofetch ```
- You can change the .zshrc and I suggest to follow the commnets
- You can change the .vimrc file
- You can delete the .hushlogin (to decide see info when the terminal start, I think theat if you enable neofetch that is enough)
- You can also ```brew install lolcat``` -> you can pipe comnads and make them look rainbow-like
- To have my font ```brew tap homebrew/cask-font``` and then ```brew cask install font-hack-nerd-font```
- I suggest to uncomment some stuff in the .zshrc -> but do not forget to ```brew install lsd```
- I also suggest to use iTerm2, there is a file with my theme -> you also shuold use it in minimal mode 
- Beautiful dynamic wallpapers [first](https://dynamicwallpaper.club/wallpaper/6df38eo4nym) [second](https://dynamicwallpaper.club/wallpaper/jculsb683ok)
