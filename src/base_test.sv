class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  env  				e0;
  gen_item_seq 		seq;
  virtual  	vir_interface 	vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create the environment
    e0 = env::type_id::create("e0", this);
    
    // Get virtual IF handle from top level and pass it to everything
    // in env level
    if (!uvm_config_db#(virtual vir_interface)::get(this, "", "vir_interface", vif))
      `uvm_fatal("TEST", "Did not get vif")      
    uvm_config_db#(virtual vir_interface)::set(this, "e0.a0.*", "vir_interface", vif);
    
    // Create sequence and randomize it
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
  endtask
  
endclass