	.. -*- mode: rst -*-
  
RobLob Volume Extraction
========================

Shell routines segmenting the brain in different volumes, 
according to a anatomic atlas, and computing volumes
statistic, in the subject native space for the grey
and white matter.

For a in depth explaination we invite to consult the following reference from 
`Toro et al <https://link.springer.com/article/10.1007/s00429-009-0203-y>`_.

Prerequisites
=============

Files Architecture
~~~~~~~~~~~~~~~~~~

Those scripts are optimize for a `BrainVisa <https://github.com/brainvisa/>`_ files
architecture. If you don't use this architecture, please modify the variable `common_path`
accordingly to yours.

Brain Atlas
~~~~~~~~~~~

You will a brain atlas in the .nii format, in the normalized
space. You will also need a lobar atlas, in the fixed (normalized)
space. 

Software
~~~~~~~~

You will need to have on your machine the following software:

* Matlab, at least the R2014a release with the toolbox SPM12.
* The AIMS functions from the BrainVisa environment need to be available.
* Python, at least the 3.5 Release.

Launch the pipeline
===================

The only script to execute is the `pipeline_launcher.sh` scripts. 
In this scripts, you will have to changes the data access path, 
to your image database, lobar atlas, and anatomical atlas. You'll
have to change the path to the `scripts` folder too.
The results will be created in a **Roblob** folder inside each
subject folder with all the sub-folder corresponding to each
step of the pipelines. I encourage you to check each step.

Contributors
============

`Dhaif BEKHA`_

.. _Dhaif BEKHA: dhaif@dhaifbekha.com
