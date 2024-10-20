class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  centralized_memory_model mem;
  uvm_analysis_imp #(axi_item, scoreboard) axi_analysis_imp;
  uvm_analysis_imp #(axil_item, scoreboard) axil_analysis_imp;
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_analysis_imp = new("axi_analysis_imp", this);
    axil_analysis_imp = new("axil_analysis_imp", this);
    if (!uvm_config_db#(centralized_memory_model)::get(this, "", "central_memory", mem)) begin
      `uvm_fatal("CONFIG_ERR", "Could not get centralized memory from config DB.");
  endfunction
  
  virtual function write(axi_item axi_item);
    
  endfunction

  virtual function write(axil_item axil_item);
  
  endfunction
endclass
