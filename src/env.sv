class env extends uvm_env;
  `uvm_component_utils(env)
  function new(string name="env", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  axi_agent 		axi_a0; 		// Agent handle
  axil_agent    axil_a0;
  scoreboard	sb0; 		// Scoreboard handle
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_a0 = axi_agent::type_id::create("axi_a0", this);
    axil_a0 = axil_agent::type_id::create("axil_a0", this);
    sb0 = scoreboard::type_id::create("sb0", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    axi_a0.m0.axi_mon_ap.connect(sb0.axi_analysis_imp);
    axil_a0.m0.axil_mon_ap.connect(sb0.axil_analysis_imp);
  endfunction
endclass