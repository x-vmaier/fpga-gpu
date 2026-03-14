# Vivado project recreation script for fpga-gpu
# Target: xc7a35tcpg236-1 (Artix-7)
#
# Usage (batch mode):
#   vivado -mode batch -source build.tcl
#   vivado -mode batch -source build.tcl -tclargs --origin_dir <path>
#   vivado -mode batch -source build.tcl -tclargs --project_name <name>
#   vivado -mode batch -source build.tcl -tclargs --help

# Project Name
set PROJECT_NAME "build"
if { [info exists ::user_project_name] } {
    set PROJECT_NAME $::user_project_name
}

# Origin Directory
set ORIGIN_DIR [file dirname [file normalize [info script]]]
if { [info exists ::origin_dir_loc] } {
    set ORIGIN_DIR $::origin_dir_loc
}

# CLI argument parser
variable script_file
set script_file "build.tcl"

proc print_help {} {
    variable script_file
    puts "\nDescription:"
    puts "  Recreate the fpga-gpu Vivado project from this script.\n"
    puts "Syntax:"
    puts "  $script_file"
    puts "  $script_file -tclargs \[--origin_dir <path>\]"
    puts "  $script_file -tclargs \[--project_name <name>\]"
    puts "  $script_file -tclargs \[--help\]\n"
    puts "Options:"
    puts "  --origin_dir <path>     Source file root. Defaults to script directory."
    puts "  --project_name <name>   Override project name. Defaults to 'fpga-gpu'."
    puts "  --help                  Print this message."
    puts "-------------------------------------------------------------------------\n"
    exit 0
}

if { $::argc > 0 } {
    for { set i 0 } { $i < $::argc } { incr i } {
        set option [string trim [lindex $::argv $i]]
        switch -regexp -- $option {
            "--origin_dir"   { incr i; set ORIGIN_DIR   [lindex $::argv $i] }
            "--project_name" { incr i; set PROJECT_NAME [lindex $::argv $i] }
            "--help"         { print_help }
            default {
                if { [regexp {^-} $option] } {
                    puts "ERROR: Unknown option '$option'. Use --help for usage info."
                    return 1
                }
            }
        }
    }
}

set PART "xc7a35tcpg236-1"

# Create a fileset if it doesn't already exist
proc ensure_fileset { name type } {
    if { [string equal [get_filesets -quiet $name] ""] } {
        create_fileset $type $name
    }
}

# Create Project
create_project $PROJECT_NAME ${ORIGIN_DIR}/${PROJECT_NAME} -part $PART

set PROJ_DIR [get_property directory [current_project]]

set_property -dict {
    default_lib                      xil_defaultlib
    enable_vhdl_2008                 1
    ip_cache_permissions             {read write}
    mem.enable_memory_map_generation 1
    revised_directory_structure      1
    sim.ip.auto_export_scripts       1
    sim_compile_state                1
    simulator_language               Mixed
    source_mgmt_mode                 DisplayOnly
    use_inline_hdl_ip                1
    xpm_libraries                    {XPM_CDC XPM_MEMORY}
} [current_project]

set_property ip_output_repo     "${PROJ_DIR}/${PROJECT_NAME}.cache/ip" [current_project]
set_property sim.central_dir    "${PROJ_DIR}/${PROJECT_NAME}.ip_user_files" [current_project]

# Sources Fileset
ensure_fileset sources_1 -srcset

set SRC_OBJ [get_filesets sources_1]

# Add sources
set src_sv_files  [glob -nocomplain ${ORIGIN_DIR}/src/*.sv]
set src_coe_files [glob -nocomplain ${ORIGIN_DIR}/resources/*.coe]
set all_src_files [concat $src_sv_files $src_coe_files]

if { [llength $all_src_files] > 0 } {
    add_files -norecurse -fileset $SRC_OBJ $all_src_files
}

# Stamp every .sv source as SystemVerilog
foreach f $src_sv_files {
    set fobj [get_files -of_objects $SRC_OBJ [list "*[file tail $f]"]]
    if { $fobj ne "" } {
        set_property file_type SystemVerilog $fobj
    }
}

set_property -dict {
    dataflow_viewer_settings {min_width=16}
    top                      dut
    top_auto_set             0
} $SRC_OBJ

# IP: Clock Wizard (clk_wiz_0)
create_ip \
    -name        clk_wiz \
    -vendor      xilinx.com \
    -library     ip \
    -version     6.0 \
    -module_name clk_wiz_0

set_property -dict {
    CONFIG.PRIM_IN_FREQ                 {100.000}
    CONFIG.PRIM_SOURCE                  {Single_ended_clock_capable_pin}
    CONFIG.PRIMITIVE                    {MMCM}
    CONFIG.USE_FREQ_SYNTH               {true}
    CONFIG.USE_PHASE_ALIGNMENT          {true}
    CONFIG.USE_SAFE_CLOCK_STARTUP       {true}
    CONFIG.NUM_OUT_CLKS                 {1}
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ   {25.175}
    CONFIG.CLKOUT1_REQUESTED_PHASE      {0.000}
    CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {50.000}
    CONFIG.CLKOUT1_DRIVES               {BUFGCE}
    CONFIG.USE_RESET                    {true}
    CONFIG.RESET_TYPE                   {ACTIVE_LOW}
    CONFIG.RESET_PORT                   {resetn}
    CONFIG.USE_LOCKED                   {true}
    CONFIG.LOCKED_PORT                  {locked}
    CONFIG.FEEDBACK_SOURCE              {FDBK_AUTO}
    CONFIG.MMCM_DIVCLK_DIVIDE           {4}
    CONFIG.MMCM_CLKFBOUT_MULT_F         {36.375}
    CONFIG.MMCM_CLKOUT0_DIVIDE_F        {36.125}
    CONFIG.JITTER_SEL                   {No_Jitter}
} [get_ips clk_wiz_0]

generate_target all [get_ips clk_wiz_0]
set_msg_config -id {Netlist 29-345} -new_severity INFO

# IP: Block Memory Generator (blk_mem_gen_0)
create_ip \
    -name        blk_mem_gen \
    -vendor      xilinx.com \
    -library     ip \
    -version     8.4 \
    -module_name blk_mem_gen_0

set coe_path [file normalize "${ORIGIN_DIR}/resources/image.coe"]

set_property -dict [list \
    CONFIG.Memory_Type                                {Single_Port_ROM} \
    CONFIG.Write_Width_A                              {12} \
    CONFIG.Write_Depth_A                              {76800} \
    CONFIG.Read_Width_A                               {12} \
    CONFIG.Enable_A                                   {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File                             {true} \
    CONFIG.Coe_File                                   $coe_path \
    CONFIG.Use_RSTA_Pin                               {false} \
    CONFIG.Algorithm                                  {Minimum_Area} \
] [get_ips blk_mem_gen_0]

generate_target all [get_ips blk_mem_gen_0]

# Constraints Fileset
ensure_fileset constrs_1 -constrset

set CONSTR_OBJ [get_filesets constrs_1]

set_property target_part $PART $CONSTR_OBJ

add_files -fileset $CONSTR_OBJ ${ORIGIN_DIR}/constrs/Basys3_Master.xdc
add_files -fileset $CONSTR_OBJ ${ORIGIN_DIR}/constrs/Timings.xdc
set_property used_in_synthesis false [get_files ${ORIGIN_DIR}/constrs/Timings.xdc]

# Simulation Fileset
ensure_fileset sim_1 -simset

set SIM_OBJ [get_filesets sim_1]

# Add sim files via glob
set sim_sv_files   [glob -nocomplain ${ORIGIN_DIR}/sim/*.sv]
set sim_vh_files   [glob -nocomplain ${ORIGIN_DIR}/sim/*.vh]
set sim_wcfg_files [glob -nocomplain ${ORIGIN_DIR}/sim/*.wcfg]
set all_sim_files  [concat $sim_sv_files $sim_vh_files $sim_wcfg_files]

if { [llength $all_sim_files] > 0 } {
    add_files -norecurse -fileset $SIM_OBJ $all_sim_files
}

# Stamp file types
foreach f $sim_sv_files {
    set fobj [get_files -of_objects $SIM_OBJ [list "*[file tail $f]"]]
    if { $fobj ne "" } { set_property file_type SystemVerilog    $fobj }
}
foreach f $sim_vh_files {
    set fobj [get_files -of_objects $SIM_OBJ [list "*[file tail $f]"]]
    if { $fobj ne "" } { set_property file_type {Verilog Header} $fobj }
}

set_property -dict {
    top          TB
    top_auto_set 0
    top_lib      xil_defaultlib
} $SIM_OBJ

# Synthesis Run
# Disable IDR flow property constraints temporarily (required for run creation)
set _idr_constraint ""
catch { set _idr_constraint [get_param runs.disableIDRFlowPropertyConstraints] }
catch { set_param runs.disableIDRFlowPropertyConstraints 1 }

if { [string equal [get_runs -quiet synth_1] ""] } {
    create_run \
        -name     synth_1 \
        -part     $PART \
        -flow     {Vivado Synthesis 2025} \
        -strategy "Vivado Synthesis Defaults" \
        -report_strategy {No Reports} \
        -constrset constrs_1
} else {
    set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
    set_property flow     "Vivado Synthesis 2025"     [get_runs synth_1]
}

set SYNTH_OBJ [get_runs synth_1]
set_property -dict {
    part                       xc7a35tcpg236-1
    strategy                   {Vivado Synthesis Defaults}
    auto_incremental_checkpoint 1
} $SYNTH_OBJ

# Utilisation report after synthesis
set_property set_report_strategy_name 1 $SYNTH_OBJ
set_property report_strategy {Vivado Synthesis Default Reports} $SYNTH_OBJ
set_property set_report_strategy_name 0 $SYNTH_OBJ

if { [string equal [get_report_configs -of_objects $SYNTH_OBJ synth_1_synth_report_utilization_0] ""] } {
    create_report_config \
        -report_name synth_1_synth_report_utilization_0 \
        -report_type report_utilization:1.0 \
        -steps       synth_design \
        -runs        synth_1
}

current_run -synthesis $SYNTH_OBJ

# Implementation Run
if { [string equal [get_runs -quiet impl_1] ""] } {
    create_run \
        -name         impl_1 \
        -part         $PART \
        -flow         {Vivado Implementation 2025} \
        -strategy     "Vivado Implementation Defaults" \
        -report_strategy {No Reports} \
        -constrset    constrs_1 \
        -parent_run   synth_1
} else {
    set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
    set_property flow     "Vivado Implementation 2025"     [get_runs impl_1]
}

set IMPL_OBJ [get_runs impl_1]
set_property -dict {
    part                                     xc7a35tcpg236-1
    strategy                                 {Vivado Implementation Defaults}
    steps.write_bitstream.args.bin_file      1
    steps.write_bitstream.args.readback_file 0
    steps.write_bitstream.args.verbose       0
} $IMPL_OBJ

set_property set_report_strategy_name 1 $IMPL_OBJ
set_property report_strategy {Vivado Implementation Default Reports} $IMPL_OBJ
set_property set_report_strategy_name 0 $IMPL_OBJ

# Create an impl report config if it doesn't already exist
proc add_impl_report { name type step {props {}} } {
    if { [string equal [get_report_configs -of_objects [get_runs impl_1] $name] ""] } {
        create_report_config \
            -report_name $name \
            -report_type $type \
            -steps       $step \
            -runs        impl_1
    }
    if { [llength $props] > 0 } {
        set obj [get_report_configs -of_objects [get_runs impl_1] $name]
        if { $obj ne "" } { set_property -dict $props $obj }
    }
}

# Disabled timing reports (kept for completeness / easy re-enable)
set DISABLED_TIMING { is_enabled 0  options.max_paths 10  options.report_unconstrained 1 }

add_impl_report impl_1_init_report_timing_summary_0             report_timing_summary:1.0    init_design              $DISABLED_TIMING
add_impl_report impl_1_opt_report_drc_0                         report_drc:1.0               opt_design
add_impl_report impl_1_opt_report_timing_summary_0              report_timing_summary:1.0    opt_design               $DISABLED_TIMING
add_impl_report impl_1_power_opt_report_timing_summary_0        report_timing_summary:1.0    power_opt_design         $DISABLED_TIMING
add_impl_report impl_1_place_report_io_0                        report_io:1.0                place_design
add_impl_report impl_1_place_report_utilization_0               report_utilization:1.0       place_design
add_impl_report impl_1_place_report_control_sets_0              report_control_sets:1.0      place_design             { options.verbose 1 }
add_impl_report impl_1_place_report_incremental_reuse_0         report_incremental_reuse:1.0 place_design             { is_enabled 0 }
add_impl_report impl_1_place_report_incremental_reuse_1         report_incremental_reuse:1.0 place_design             { is_enabled 0 }
add_impl_report impl_1_place_report_timing_summary_0            report_timing_summary:1.0    place_design             $DISABLED_TIMING
add_impl_report impl_1_post_place_power_opt_report_timing_summary_0 report_timing_summary:1.0 post_place_power_opt_design $DISABLED_TIMING
add_impl_report impl_1_phys_opt_report_timing_summary_0         report_timing_summary:1.0    phys_opt_design          $DISABLED_TIMING
add_impl_report impl_1_route_report_drc_0                       report_drc:1.0               route_design
add_impl_report impl_1_route_report_methodology_0               report_methodology:1.0       route_design
add_impl_report impl_1_route_report_power_0                     report_power:1.0             route_design
add_impl_report impl_1_route_report_route_status_0              report_route_status:1.0      route_design
add_impl_report impl_1_route_report_incremental_reuse_0         report_incremental_reuse:1.0 route_design
add_impl_report impl_1_route_report_clock_utilization_0         report_clock_utilization:1.0 route_design
add_impl_report impl_1_route_report_timing_summary_0            report_timing_summary:1.0    route_design             { options.max_paths 10  options.routable_nets 1  options.report_unconstrained 1 }
add_impl_report impl_1_route_report_bus_skew_0                  report_bus_skew:1.1          route_design             { options.warn_on_violation 1 }
add_impl_report impl_1_post_route_phys_opt_report_timing_summary_0 report_timing_summary:1.0 post_route_phys_opt_design { options.max_paths 10  options.report_unconstrained 1  options.warn_on_violation 1 }
add_impl_report impl_1_post_route_phys_opt_report_bus_skew_0    report_bus_skew:1.1          post_route_phys_opt_design { options.warn_on_violation 1 }

current_run -implementation $IMPL_OBJ

# Restore IDR constraint
catch {
    if { $_idr_constraint ne "" } {
        set_param runs.disableIDRFlowPropertyConstraints $_idr_constraint
    }
}

# Dashboard Gadgets
proc ensure_gadget { name type } {
    if { [string equal [get_dashboard_gadgets [list $name]] ""] } {
        create_dashboard_gadget -name $name -type $type
    }
}

ensure_gadget utilization_1 utilization
ensure_gadget utilization_2 utilization
ensure_gadget timing_1      timing
ensure_gadget power_1       power
ensure_gadget drc_1         drc
ensure_gadget methodology_1 methodology

set_property -dict { reports synth_1#synth_1_synth_report_utilization_0  run.step synth_design  run.type synthesis } \
    [get_dashboard_gadgets [list utilization_1]]
set_property reports impl_1#impl_1_place_report_utilization_0    [get_dashboard_gadgets [list utilization_2]]
set_property reports impl_1#impl_1_route_report_timing_summary_0 [get_dashboard_gadgets [list timing_1]]
set_property reports impl_1#impl_1_route_report_power_0          [get_dashboard_gadgets [list power_1]]
set_property reports impl_1#impl_1_route_report_drc_0            [get_dashboard_gadgets [list drc_1]]
set_property reports impl_1#impl_1_route_report_methodology_0    [get_dashboard_gadgets [list methodology_1]]

move_dashboard_gadget -name utilization_1 -row 0 -col 0
move_dashboard_gadget -name power_1       -row 1 -col 0
move_dashboard_gadget -name drc_1         -row 2 -col 0
move_dashboard_gadget -name timing_1      -row 0 -col 1
move_dashboard_gadget -name utilization_2 -row 1 -col 1
move_dashboard_gadget -name methodology_1 -row 2 -col 1

puts "INFO: Project created: ${PROJECT_NAME}"
puts "INFO: Project directory: ${PROJ_DIR}"
