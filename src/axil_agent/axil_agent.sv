class axil_agent extends uvm_agent;
  `uvm_component_utils(axil_agent)
  function new(string name="axil_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  axil_driver 		d0; 		// Driver handle
  axil_monitor 		m0; 		// Monitor handle
  uvm_sequencer #(axil_item)	s1; 		// Sequencer Handle

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    s1 = uvm_sequencer#(axil_item)::type_id::create("s1", this);
    d0 = axil_driver::type_id::create("d0", this);
    m0 = axil_monitor::type_id::create("m0", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d0.seq_item_port.connect(s1.seq_item_export);
  endfunction

endclass