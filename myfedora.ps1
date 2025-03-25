Invoke-WebRequest https://github.com/VSWSL/Fedora-WSL-RootFS/releases/download/v41.0.1/rootfs.amd64.tar.gz -OutFile rootfs.amd64.tar.gz
wsl --install MyFedora --from-file .\rootfs.amd64.tar.gz --location $HOME\MyFedora --name MyFedora
wsl -d MyFedora useradd -G adm,wheel,cdrom $Env:UserName.ToLower()
wsl -d MyFedora passwd $Env:UserName.ToLower()
wsl --manage MyFedora --set-default-user $Env:UserName.ToLower()