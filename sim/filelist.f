
// Import UVM classes
+incdir+../../uvm-1.2/src
../../uvm-1.2/src/uvm_pkg.sv

+incldir+../src

// Design
../src/axi_axil_adapter.v
../src/axi_axil_adapter_wr.v 
../src/axi_axil_adapter_rd.v

// Interface
../src/axi_interface.sv
../src/axil_interface.sv

// Top tb
../src/tb.sv

// Central memory
../src/central_mem.sv

// AXI Agent
../src/axi_agent/axi_item.sv
../src/axi_agent/axi_gen_item_seq.sv
../src/axi_agent/axi_monitor.sv
../src/axi_agent/axi_driver.sv
../src/axi_agent/axi_agent.sv

// AXIL Agent
../src/axil_agent/axil_item.sv
../src/axil_agent/axil_gen_item_seq.sv
../src/axil_agent/axil_monitor.sv
../src/axil_agent/axil_driver.sv
../src/axil_agent/axil_agent.sv

//Reference models
../src/rd_ref_model.sv
../src/wr_ref_model.sv

// Remaining UVM components
../src/scoreboard.sv
../src/env.sv
../src/base_test.sv
../src/burst_test.sv
 
            


            