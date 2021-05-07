whatis( 'Enforces showing descriptitve labels in the output of module avail rather than directories.' )

help( [[

Description
===========
Loading this module sets your environment to tell the module system to use
descriptitve labels rather than directories for the module categories.

With this module loaded, you can still show directories by using
$  module -s system avail
instead.

With no ]] .. myModuleName() .. [[ module loaded, you get the defailt behaviour of the
module tool as configured in the system.
]] )

pushenv( 'LMOD_AVAIL_STYLE', 'label,system' )
