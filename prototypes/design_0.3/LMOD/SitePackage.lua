-- LUMI Lmod customizations

require("strict")
local dbg  = require("Dbg"):dbg()
local hook = require("Hook")

--
-- SiteName hook, used by Lmod in variable names.
-- We don't chose LUMI but take LUMI_LMOD to avoid conflicts as there
-- will likely be more LUMI_ environment variables on the system.
--

local function site_name_hook()
    -- set the SiteName
    return "LUMI_LMOD"
end


--
-- Code to rename directories in module avail
-- Based on "Providing Custom Labels for Avail" in the Lmod manual
-- Note that this requires the use of LMOD_AVAIL_STYLE, and in this case,
-- LMOD_AVAIL_STYLE=labeled:system to make the labeled style the default.
--

local mapT =
{
    sp_labeled = {
        ['/testview$']                     = 'Activate environments',
        ['modules/SoftwareStack$']         = 'Software stacks',
        ['modules/SystemPartition/']       = 'LUMI partitions for the loaded stack',
        ['modules/easybuild/']             = 'EasyBuild managed software for the loaded stack/partition',
        ['modules/spack/']                 = 'Spack managed software for the loaded stack/partition',
        ['modules/manual/']                = 'Manually installed software for the loaded stack/partition',
        ['cray/pe/.*/core']                = 'HPE-Cray PE core modules',
        ['cray/pe/.*/craype-targets']      = 'HPE-Cray PE target modules',
        ['cray/pe/.*/perftools']           = 'HPE-Cray PE performance analysis tools',
        ['cray/pe/.*/compiler/crayclang']  = 'HPE-Cray PE libraries for Cray clang (cce)',
        ['cray/pe/.*/compiler/gnu']        = 'HPE-Cray PE libraries for GNU compilers',
        ['cray/pe/.*/hdf5/']               = 'HPE-Cray PE libraries that use cray-hdf5',
        ['cray/pe/.*/hdf5-parallel/']      = 'HPE-Cray PE libraries that use cray-hdf5-parallel',
        ['cray/pe/.*/comnet']              = 'HPE-Cray PE MPI libraries',
        ['cray/pe/.*/mpi']                 = 'HPE-Cray PE MPI-dependent libraries',
        -- The next one doesn't seem to be implemented on the Grenoble nodes
        ['cray/pe/craype']                 = 'HPE-Cray PE compiler wrappers',
        -- Likely only on the Grenoble system?
        ['/usr/share/Modules/modulefiles'] = 'Non-PE HPE-Cray modules',
        ['/usr/share/modulefiles']         = 'Non-PE HPE-Cray modules',
     },
    ps_labeled = {
        ['/testview$']                     = 'Activate environments',
        ['modules/SystemPartition$']       = 'LUMI partitions',
        ['modules/SoftwareStack/']         = 'Software stacks or the loaded partition',
        ['modules/easybuild/']             = 'EasyBuild managed software for the loaded partition/stack',
        ['modules/spack/']                 = 'Spack managed software for the loaded partition/stack',
        ['modules/manual/']                = 'Manually installed software for the loaded partition/stack',
        ['cray/pe/.*/core']                = 'HPE-Cray PE core modules',
        ['cray/pe/.*/craype-targets']      = 'HPE-Cray PE target modules',
        ['cray/pe/.*/perftools']           = 'HPE-Cray PE performance analysis tools',
        ['cray/pe/.*/compiler/crayclang']  = 'HPE-Cray PE libraries for Cray clang (cce)',
        ['cray/pe/.*/compiler/gnu']        = 'HPE-Cray PE libraries for GNU compilers',
        ['cray/pe/.*/hdf5/']               = 'HPE-Cray PE libraries that use cray-hdf5',
        ['cray/pe/.*/hdf5-parallel/']      = 'HPE-Cray PE libraries that use cray-hdf5-parallel',
        ['cray/pe/.*/comnet']              = 'HPE-Cray PE MPI libraries',
        ['cray/pe/.*/mpi']                 = 'HPE-Cray PE MPI-dependent libraries',
        -- The next one doesn't seem to be implemented on the Grenoble nodes
        ['cray/pe/craype']                 = 'HPE-Cray PE compiler wrappers',
        -- Likely only on the Grenoble system?
        ['/usr/share/Modules/modulefiles'] = 'Non-PE HPE-Cray modules',
        ['/usr/share/modulefiles']         = 'Non-PE HPE-Cray modules',
     },
}


local function avail_hook(t)
    dbg.start( 'avail_hook' )

    local availStyle = masterTbl().availStyle
    local styleT     = mapT[availStyle]
    if (not availStyle or availStyle == "system" or styleT == nil) then
        io.stderr:write('Avail hook: style not found\n')
        return
    end

    for k,v in pairs(t) do
        for pat,label in pairs(styleT) do
            if (k:find(pat)) then
                t[k] = label
                break
            end
        end
    end

    dbg.fini()

end

--
-- Message hook
-- - Adds a reference to LUMI support at the end of the module avail output
--

local function msg_hook(mode, output)
    -- mode is avail, list or spider
    -- output is a table with the current output

    dbg.start{"msg_hook"}

    dbg.print{"Mode is ", mode, "\n"}

    if mode == "avail" then
        local spiderdoc_url = 'https://docs.lumi-supercomputer.eu/LMOD_TODO'
        local request_url   = 'https://lumi-supercomputer.eu/support'
        output[#output+1]   = '\nAdditional ways to search for software:\n'
        output[#output+1]   = '* Use "module spider" to find all possible modules and extensions.\n'
        output[#output+1]   = '* Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".\n'
        output[#output+1]   = 'See the LUMI documentation at ' .. spiderdoc_url .. ' for more information on searching modules.\n'
        output[#output+1]   = "If then you still miss software, contact LUMI User Support via "..request_url..".\n\n"
    end

    dbg.fini()

    return output
end


--
-- Register the hooks
--

hook.register( "SiteName", site_name_hook )
hook.register( "avail",    avail_hook )
hook.register( "msgHook",  msg_hook )
