class monitor extends uvm_monitor;
   `uvm_component_utils (monitor)
   function new (string name="monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

   uvm_analysis_port #(item)  mon_ap;
   virtual vir_interface          vif;

  virtual function void build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual vir_interface)::get(this, "", "vir_interface", vif))
      `uvm_fatal("MON", "Could not get vif")
    mon_ap = new ("mon_ap", this); // create analysis port
  endfunction

  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
    // This task monitors the interface for a complete 
    // transaction and writes into analysis port when complete
    forever begin
				mon_ap.write(m_item); // send tempo item to analysis port, which will be sent to scoreboard
			end
    end
  endtask
endclass
