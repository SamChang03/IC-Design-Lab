# set testing file name
set testing_file_name "mod_add"

# set report file
set report_file "spyglass_${testing_file_name}.rpt"

# read file list
read_file -type sourcelist "${testing_file_name}.list"

# for sram module
set_option mthresh 10000

# goal setup [lint_rtl]
current_goal lint/lint_rtl -alltop
# run goal
run_goal
# create a report file and write report message to the file
capture spyglass_${testing_file_name}.rpt {write_report moresimple}

# setup another goal
current_goal lint/lint_turbo_rtl -alltop
# run goal
run_goal
# append the report message to the same file created above
capture -append spyglass_${testing_file_name}.rpt {write_report moresimple}

current_goal lint/lint_functional_rtl -alltop
run_goal
capture -append spyglass_${testing_file_name}.rpt {write_report moresimple}

current_goal lint/lint_abstract -alltop
run_goal
capture -append spyglass_${testing_file_name}.rpt {write_report moresimple}

# advance
# current_goal adv_lint/adv_lint_struct -alltop
# run_goal
# capture -append $report_file {write_report moresimple}

# current_goal adv_lint/adv_lint_verify -alltop
# run_goal
# capture -append $report_file {write_report moresimple}

# USAGE:
# $ sg_shell < part1.tcl