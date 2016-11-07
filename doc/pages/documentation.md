# Documentation

The documentation is generated automatically. In order to do so a number of steps are taken.

- Set of output directories is created
- Any gnuplot files are plotted and results stored in `doc/img/bld`
- All VHDL files are parsed and for every entity definition found a dot file is created.
- For every WaveDrom file a timing diagram is created in png format using WaveDromTikZ.
- All test input and output images are converted to png in the doc/img/bld folder
- All documentation is generated using Doxygen.

## Deploying documentation

The doc/html folder is a separate git repo. Follow these steps to deploy:

    cd <PROJECT_ROOT>
    make clean
    make test
    make docs
    cd doc/html
    git commit -A -m "Doc update"
    git push
