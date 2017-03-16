# STEAMScout

This is the scouting app made by FIRST Team 525 for the FIRST Steamworks game. 

## Setting up the environment
This project can be checked out using Git commands.  Git clients can also be
used, but command line instructions are given below.  

This project uses [Cocoapods](https://cocoapods.org) to manage packages.
Instructions for setting up Cocoapods are given below.

### Git Setup

#### Checking out the repository
Open an instance of the terminal app.  On Macs, this is a utility app that is
found in the `Applications/Utilities/` folder.  You can also search for 
`Terminal` through spotlight (cmd+space is a quick shortcut) and lauch it form
there.

Once in the terminal, navigate to a safe directory.  I recommend having one
folder that contains all your Repositories, but if you have a specific location
in mind, you can use that.

> The rest of the instructions will assume you want to create a new folder

Create a new folder called `Repositories` in your Home folder and navigate to 
that folder within the Terminal:
```bash
$ mkdir ~/Repositories
$ cd ~/Repositories
```

Clone the Repository from Github using the following command:
```bash
$ git clone https://github.com/Swartdogs/STEAMScout.git
```

> You will be prompted for your github user name and password.

Once this completes, you will have a folder within your Repositories folder
called `STEAMScout/`.  Enter this folder:

```bash
$ cd ./STEAMScout
```

You will now be in you local repository of the app.  Check to make sure
you have the latest updates:
```bash
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
```

The master branch is the most stable build, so this should be used for 
usability testing, or when loading the app on a device.  To view other
branches, use the following command:
```bash
$ git branch -a
```

You will see a list of your local branches and the remote branches that
you can checkout.  

Each branch represents a different state of the app.
The master branch will be the most stable, but in order to see progress
of features in development, you can checkout a work in progress (wip)
branch.  These branches will have the form `wip_<version>`.  The latest
version will probably be the one you want to choose.  

There are also many branches that are of the form `issue_<num>`.  These
branches are the progress towards a specific issue that has been added
to Github.  You can view the progress on that specific issue by checking
out its branch.  

To checkout a specific branch, use the following commands:
```bash
$ git checkout <branch_name>
$ git pull origin <branch_name>
```
where "branch_name" is the name of the branch you want.  Remote 
branches only need last part of the path in the branch list.  This is
everything after the `remotes/origin/`.  

If you want to create your own branch for development, first checkout
the branch you want to be the \"Base\" of your branch.  Then run:
```bash
$ git checkout -b <new_branch>
```
where "new_branch" is the new name of your branch

#### Making commits

If you are in your branch for development and have modified/new files
you want to add to version control, you have to make a `commit` these
are group of changes that are tied to a unique id and a commit message.
You must first add the files you want to the commit, then make the 
commit:
```bash
$ git add path/to/specific/file
$ git commit -m "Commit Message (must be in quotes!)"
```

For ease of use, you can simply use `$ git add .` to add all changed
files in the current directory and all sub directories. Once you have
made a commit, you must push your commit to the remote repository.

#### Syncing your local repository

From time to time, you will have new commits that you have made and
others will also have made commits that you may want.  In order to
sync you local repository, you can "push" your commits to the remote
repository and "pull" others' commits to your local repository.  

These commands can be used as follows:
```bash
$ git pull origin <branch_name>
$ git push origin <branch_name>
```
where "branch_name" is the name of your current branch

The pull command in particular should be run somewhat frequently to stay 
to date with the progress of others.

### Cocoapods Setup
In order to import the necessary packages, cocoapods must be installed on your
local system.  To do this, run the following command in the terminal:
```bash
$ sudo gem install cocoapods
```

Once this completes, navigate to the root directory of this project and run:
```bash
$ cd ~/Repositories/STEAMScout
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

