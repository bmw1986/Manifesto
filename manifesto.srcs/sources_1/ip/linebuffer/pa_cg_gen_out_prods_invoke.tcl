# Tcl script generated by PlanAhead

set reloadAllCoreGenRepositories true

set tclUtilsPath "c:/Xilinx/14.7/ISE_DS/PlanAhead/scripts/pa_cg_utils.tcl"

set repoPaths ""

set cgIndexMapPath "C:/Users/Ben Petroski/Documents/manifesto/manifesto.srcs/sources_1/ip/cg_nt_index_map.xml"

set cgProjectPath "c:/Users/Ben Petroski/Documents/manifesto/manifesto.srcs/sources_1/ip/linebuffer/coregen.cgc"

set ipFile "c:/Users/Ben Petroski/Documents/manifesto/manifesto.srcs/sources_1/ip/linebuffer/linebuffer.xco"

set ipName "linebuffer"

set hdlType "Verilog"

set cgPartSpec "xc6slx25-3csg324"

set chains "GENERATE_CURRENT_CHAIN"

set params ""

set bomFilePath "c:/Users/Ben Petroski/Documents/manifesto/manifesto.srcs/sources_1/ip/linebuffer/pa_cg_bom.xml"

# generate the IP
set result [source "c:/Xilinx/14.7/ISE_DS/PlanAhead/scripts/pa_cg_gen_out_prods.tcl"]

exit $result

