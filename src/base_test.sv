class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  env  				e0;
  axi_gen_item_seq 		axi_seq;
  virtual  	axi_interface 	axi_vif;
  virtual   axil_interface  axil_vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create the environment
    e0 = env::type_id::create("e0", this);
    
    // Get virtual IF handle from top level and pass it to everything
    // in env level
    if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", axi_vif))
      `uvm_fatal("TEST", "Did not get axi_vif")
    if (!uvm_config_db#(virtual axil_interface)::get(this, "", "axil_interface", axil_vif))
      `uvm_fatal("TEST", "Did not get axil_vif")

    uvm_config_db#(virtual axi_interface)::set(this, "e0.*", "axi_interface", axi_vif);
    uvm_config_db#(virtual axil_interface)::set(this, "e0.*", "axil_interface", axil_vif);
    
    // Create sequence and randomize it
    seq = axi_gen_item_seq::type_id::create("seq");
    seq.randomize();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apply_reset();
    seq.start(e0.axi_a0.s0);
    #2000;
    phase.drop_objection(this);
  endtask
  
  virtual task apply_reset();
    axi_vif.rst <= 1;
    repeat(5) @ (posedge axi_vif.clk);
    axi_vif.rst <= 0;
    repeat(10) @ (posedge axi_vif.clk);
  endtask

endclass