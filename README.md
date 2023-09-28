# ontra

## Developing

```bash
# install homebrew (https://brew.sh/) to manage packages on macOS
# note that yeeting a bash script from the internet isn't always the best idea, 
# but we're going to assume we trust nothing here has been compromised for now
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# now, let's install pyenv (https://github.com/pyenv/pyenv)to manage our local python instance
$ brew install pyenv

# now, you'll need to setup the shell environment for pyenv, so 
# follow the instructions here: https://github.com/pyenv/pyenv#set-up-your-shell-environment-for-pyenv
$ eval "$(pyenv init -)"

# let's install python3.11.5
$ pyenv install 3.11.5

# let's install a virtualenv manager (https://github.com/pyenv/pyenv-virtualenv) that works well with pyenv
$ brew install pyenv-virtualenv

# setup the shell for virtualenv
$ eval "$(pyenv virtualenv-init -)"

# let's create a virtualenv for this project. 
$ pyenv virtualenv 3.11.5 ontra

# we're going to use poetry (https://python-poetry.org/) to manage our python dependencies, so let's start by installing it
$ curl -sSL https://install.python-poetry.org | python3 -

# now, let's add poetry to our shell
$ export PATH="/Users/coronado/.local/bin:$PATH"

```


For package management, we use [poetry](https://python-poetry.org/).

