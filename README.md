# nutek-run-scripts
Run Nutek Terminal

![Nutek Terminal ready to use](https://storage.googleapis.com/neosb/static/nutek-terminal.png)

## What is this?

Here I wrote you a shell script that makes using Nutek Terminal a lot easier. With few taps on keyboard you can
have all the goodies from the internet.

### What is Nutek Terminal?

My take on hacking tools is here, Nutek, Docker container image that is the only h@xor tool you will ever need.

#### What do I need?

* Docker or Podman to run Nutek Terminal
* PowerShell to run this script

## Important

if you see this line in your terminal output:

```shel
docker: Error response from daemon: user declined directory sharing C:\Users\username\.nutek.
```

Add this folder to your sharing list in Docker settings under `Resources/File sharing`

## Usage

Start your terminal app with PowerShell as your shell, or (for Windows) right click and `Run with PowerShell`.

```shell
pwsh nutek.ps1
```

```shell
# using PowerShell
nutek.ps1
```

### Options

* `-default` use default settings (still you can set shell and container engine)
* `-podman` run with podman
* `-powershell` start with shell set to PowerShell
* `-bash` use Bash shell
* `-ad_hoc` run with random name, nutek-core image, latest version, all default ports and remove it after exit.
(still you can set shell and container engine)
* `-stop` stop running container
* `-delete` delete container
