set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# define a lib path here
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Read Design File (add your files here)
set HDL_DIR "../../hdl"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/$TOPLEVEL.v
                                            $HDL_DIR/sha256_top.v
                                            $HDL_DIR/sha256_padding.v
                                            $HDL_DIR/sha256_extending.v
                                            $HDL_DIR/sha256_compress.v
                                            $HDL_DIR/ECC_top.v
                                            $HDL_DIR/ECPA.v
                                            $HDL_DIR/ECPD.v
                                            $HDL_DIR/signing.v
                                            $HDL_DIR/CSA_mod_inv.v
                                            $HDL_DIR/CSA_mod_add.v
                                            $HDL_DIR/CSA_mod_mul.v
                                            $HDL_DIR/CSA_mod_sub.v"


# elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# link the design
current_design $TOPLEVEL
link
