#!/usr/bin/env bash
# This script is inspired from **scikit-learn** implementation of continous test
# integration. This is meant to "install" all the packages required for installing
# pgmpy.

# License: The MIT License (MIT)

set -e

sudo apt-get update -qq
sudo apt-get install build-essential -qq

if [[ "$DISTRIB" == "conda" ]]; then
	# Deactivate the travis-provided virtual environment and setup a
	# conda-based environment instead
	deactivate

	# Use the miniconda installer for faster download / install of conda
	# itself
	wget http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
		-O miniconda.sh
        chmod +x miniconda.sh && ./miniconda.sh -b
        export PATH=$HOME/miniconda3/bin:$PATH
	conda config --set always_yes yes --set changeps1 no
	conda update conda
	conda info -a

	conda create -n testenv python=$PYTHON_VERSION
        source activate testenv
	conda config --env --append channels conda-forge
	conda config --env --get channels

	conda install --file requirements-dev.txt
	# Possible workaround for pytorch installation issue
	conda uninstall pytorch
	pip uninstall torch -qqq
	conda install pytorch cuda80 -c soumith
	# End workaround
fi

if [[ "$COVERAGE" == "true" ]]; then
	pip install coverage codecov
fi

# Build pgmpy
python setup.py develop
black --diff .
black --check .
