
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name verily -dir "/home/ise/git/verily/planAhead_run_2" -part xc3s500evq100-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "constraints.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {display_logicwing.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {add.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {verily.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top verily $srcset
add_files [list {constraints.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s500evq100-4
