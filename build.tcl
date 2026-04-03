open_project ./build/build.xpr

puts "INFO: Launching synthesis..."
set num_jobs [get_param general.maxThreads]
launch_runs synth_1 -jobs $num_jobs
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "ERROR: Synthesis failed."
}

puts "INFO: Launching implementation..."
launch_runs impl_1 -to_step write_bitstream -jobs $num_jobs
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "ERROR: Implementation failed."
}

puts "INFO: Done. Bitstream: ${PROJ_DIR}/${PROJECT_NAME}.runs/impl_1/gpu.bit"
