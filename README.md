# STEAMScout

This is the scouting app made by FIRST Team 525 for the FIRST Steamworks game. 

## Setting up the environment
This project uses [Cocoapods](https://cocoapods.org) to manage packages.

### Cocoapods Setup
In order to import the necessary packages, cocoapods must be installed on your
local system.  To do this, run the following command in the terminal:
```bash
$ sudo gem install cocoapods
```

Once this completes, navigate to the root directory of this project and run:
```bash
$ pod install
```

Cocoapods might require an update of its repository version references. This 
can be resolved by running the following:
```bash
$ pod repo update
$ pod install
```

Once Cocoapods has installed the necessary pods, you should be ready to open
the generated workspace in Xcode.

> You might want to run `pod update` from time to time to fetch new 
> dependencies if they exist


Cocoapods requires using the `.xcworkspace` to open the project in Xcode 
instead of the `.xcodeproj` file! 
> If your project is not building, make sure you are opening the `.xcworkspace`
> file instead of the `.xcodeproj` file.


More details will come soon!

