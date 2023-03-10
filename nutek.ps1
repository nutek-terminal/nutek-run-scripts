#!/usr/bin/env pwsh

<#
.Synopsis
Wheter you want to break things, or make them and test their defenses, Nutek is here to help.
Join your forces with friends and fellow hackers, on the way to gold and glory. Nutek will connect
all the dots with it's streamlined workflow, role playing, information gathering, automation and
a lot of flexibility and extendability.
.Example
PS> .\nutek -default
roughly translates to 'docker run -it -p [ports] $HOME/nutek:/root/nutek neosb/nutek-core:latest
.Description
Nutek is the only h@xor tool you will ever need. You can take a deep dive into the ocean of bug bounty
programs solo or with friends to get recognition and get payed in many programs offered on the web.
Nutek is the way to go. Create, break, restore, exploit, communicate, report, do it better and faster.
.Parameter default
Use nutek as container name, nutek-core as container image and latest version of it
.Parameter podman
Instead of Docker, use Podman as container engine
.Parameter powershell
Start Nutek's Powershell as a system shell
.Parameter bash
Use bash as system shell
.Parameter ad_hoc
Create Nutek container with random name, nutek-core image, latest version, all default ports and remove it after exit.
Optionally run with Powershell or bash. Zsh is default
.Parameter stop
Stop running Nutek's Docker container
.Parameter delete
Delete Nutek's Docker container
.Parameter help
Find where the help is
.Parameter h
Find where the help is
.INPUTS
None. You cannot pipe objects to Nutek.
.OUTPUTS
None. Nutek does not generate any output.
.Link
Nutek blog https://nutek.neosb.net
#> 
param (
    [switch]$default=$false,
    [switch]$podman=$false,
    [switch]$powershell=$false,
    [switch]$bash=$false,
    [switch]$ad_hoc=$false,
    [switch]$stop=$false,
    [switch]$delete=$false,
    [switch]$help=$false,
    [switch]$h=$false
    # [Parameter(Mandatory=$true)][string]$username,
)

if ($help -Or $h) {
    Write-Output "This is Nutek, it will help you strenghten security of your IT system, or break it. Get more help 'get-help .\nutek.ps1 -Full'"
    Exit
}

if ($podman) {
    $engine = "podman"
    $docker_prefix = "docker.io/"
} else {
    $engine = "docker"
    $docker_prefix = ""
}

Write-Output "Welcome to Nutek, the only h@xor tool you will ever need!"
if (-Not (Test-Path "${HOME}/nutek")) {
    Write-Output "Creating Nutek home folder"
    mkdir "${HOME}/nutek"
    mkdir "${HOME}/nutek/feroxbuster"
    mkdir "${HOME}/nutek/gobuster"
    Write-Output "Nutek home folder created"
}

Write-Output "nutek home folder is present, proceeding..."

if (-Not (Get-Command $engine -errorAction SilentlyContinue))
{
    if ($engine -eq "docker") {
        Write-Output "You don't have Docker installed,"
        Write-Output "Please visit https://docs.docker.com/get-docker/"
        Exit
    } else {
        Write-Output "You don't have Podman installed,"
        Write-Output "Please visit https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md"
        Exit
    }
}

$default_ports = "-p 7746:7746 -p 8066:8066 -p 8077:8077 -p 8080:8080 -p 8081:8081 -p 8888:8888 -p 8889:8889"

if ($ad_hoc) {
    if ($powershell) {
        Write-Output "Starting ad hoc Nutek container with Powershell..."
        Invoke-Expression "${engine} run --rm -it -h nutek-terminal -e SHELL=powershell ${default_ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/nutek-core:latest"
    } elseif ($bash) {
        Write-Output "Starting ad hoc Nutek container with bash..."
        Invoke-Expression "${engine} run --rm -it -h nutek-terminal -e SHELL=bash ${default_ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/nutek-core:latest"
    } else {
        Write-Output "Starting ad hoc Nutek container with zsh..."
        Invoke-Expression "${engine} run --rm -it -h nutek-terminal ${default_ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/nutek-core:latest"
    }
    Exit
}

if (-not $default) {
    $container_name = Read-Host -Prompt "What's the name of your Nutek container? (nutek)"
    if ($container_name -eq "") {
        $container_name = "nutek"
    }
    $container_flavor = Read-Host -Prompt "What flavor of Nutek image do you want [nutek-core, nutek-dev, nutek-base]? (nutek-core)"
    if ($container_flavor -eq "") {
        $container_flavor = "nutek-core"
    }
    $container_version = Read-Host -Prompt "What version of ${container_flavor} image do you want? (latest)"
    if ($container_version -eq "") {
        $container_version = "latest"
    }
    $ports = Read-Host -Prompt "Which ports do you want to use? 8080 is used for mitmproxy (occupied when mitmproxy is running), 8081 for mitmweb (the same as mitmproxy - occupied if running), 7746 for sshd, 8077 is for nginx server, 8066 stands for postgresql and others are optional. [0 for none] or (7746,8066,8077,8080,8081,8888,8889)"
    if ($ports -eq "") {
        $ports = $default_ports
    } elseif ($ports -eq "0") {
        $ports = ""
    } else {
        $ports = $ports.Split(",")
        $new_ports = ""
        foreach ($port in $ports) {
            $new_ports = "${new_ports} -p ${port}:${port}"
        }
        $ports = $new_ports
    }
} else {
    $container_name = "nutek"
    $container_flavor = "nutek-core"
    $container_version = "latest"
    $ports = $default_ports
}

if ($stop) {
    Write-Output "Stopping ${container_name}..."
    $result = Invoke-Expression "${engine} container stop ${container_name}"
    if ($result -eq $container_name) {
        Write-Output "Successfully stopped ${container_name} container"
    }
    Exit
}

if ($delete) {
    $delete_container = Read-Host -Prompt "Are you sure, you want to delete ${container_name} Nutek container? It won't delete the image, so you don't have to re-download anything again to run Nutek one more time and nutek folder is not deleted too. (no)"
    if ($delete_container.ToLower() -eq "yes" ) {
        $delete_container = $true
    } elseif ($delete_container.ToLower() -eq "force") {
        Write-Output "Deleting ${container_name} Nutek container using --force switch. I hope we will see soon..."
        $result = Invoke-Expression "${engine} container rm --force ${container_name}"
        if ($result -eq $container_name) {
            Write-Output "Successfully deleted ${container_name} container with help of *force*"
        }
        Exit
    } else {
        Write-Output "Nothing will be deleted"
        Exit
    }

    if ($delete_container) {
        Write-Output "Deleting ${container_name} Nutek container if it does not work, instead of yes write force. See you soon..."
        $result = Invoke-Expression "${engine} container rm ${container_name}"
        if ($result -eq $container_name) {
            Write-Output "Successfully deleted ${container_name} container"
        }
        Exit
    }
}

$nutek_image_present = Invoke-Expression "${engine} image ls | grep ${docker_prefix}neosb/${container_flavor}"
if ($null -eq $nutek_image_present) {
    $nutek_image_present = Invoke-Expression "${engine} image ls | grep ${docker_prefix}neosb/${container_flavor} | grep ${container_version}"
    if ($null -eq $nutek_image_present) {
        # $image_size = docker manifest inspect neosb/($container_flavor):($container_version) | grep size | awk -F ':' '{sum+=$NF} END {print sum}' | numfmt --to=iec-i -d "`r" [${image_size}]
        $pull = Read-Host -Prompt "You don't have ${container_flavor} image (version: ${container_version}), do you want to download it now? (yes)"
        if ($pull -eq "" -Or $pull.ToLower() -eq "yes" ) {
            $pull = $true
        } else {
            $pull = Read-Host -Prompt "Last chance! You don't have ${container_flavor} image (version: ${container_version}), do you want to download it now [${image_size}]? (yes)"
            if ($pull -eq "" -Or $pull.ToLower() -eq "yes" ) {
                $pull = $true
            } else {
                Exit
            }
        }
    } 
}

if ($pull) {
    Invoke-Expression "${engine} pull ${docker_prefix}neosb/${container_flavor}:${container_version}"
}

$container_down = Invoke-Expression "${engine}  ps -a -f name=${container_name} | grep ' ${container_name}$' | grep Exited"
$container_up = Invoke-Expression "${engine}  ps -f name=${container_name} | grep ' ${container_name}$' | grep Up"

if (-Not ($null -eq $container_down)) {
    if ($powershell) {
        Write-Output "If Powershell was the starting shell of this container it will be started with Powershell, otherwise not."
    }
    Write-Output "Starting previosly stopped Nutek in ${container_name} container"
    Invoke-Expression "${engine} start -i ${container_name}"
} elseif (-Not ($null -eq $container_up)) {
    if ($powershell) {
        Write-Output "Starting another Nutek Powershell shell in ${container_name} container"
        Invoke-Expression "${engine} exec -it ${container_name} /usr/bin/pwsh"    
    } elseif ($bash) {
        Write-Output "Starting another Nutek bash shell in ${container_name} container"
        Invoke-Expression "${engine} exec -it ${container_name} /bin/bash"    
    } else {
        Write-Output "Starting another Nutek zsh shell in ${container_name} container"
        Invoke-Expression "${engine} exec -it ${container_name} /bin/zsh"
    }
} else {
    $container_version = "${container_flavor}:${container_version}"
    if ($powershell) {
        Write-Output "Starting Nutek image ${container_version} in ${container_name} container with Powershell shell"
        Invoke-Expression "${engine} run --cap-add NET_ADMIN --name ${container_name} -it -h nutek-terminal -e SHELL=powershell ${ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/${container_version}"
        exit
    } if ($bash) {
        Write-Output "Starting Nutek image ${container_version} in ${container_name} container with Powershell shell"
        Invoke-Expression "${engine} run --cap-add NET_ADMIN --name ${container_name} -it -h nutek-terminal -e SHELL=bash ${ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/${container_version}"
        exit
    } else {
        Write-Output "Starting Nutek image ${container_version} in ${container_name} container with zsh shell"
        Invoke-Expression "${engine} run --cap-add NET_ADMIN --name ${container_name} -it -h nutek-terminal ${ports} -v ${HOME}/nutek:/root/nutek ${docker_prefix}neosb/${container_version}"
        exit
    }
}
