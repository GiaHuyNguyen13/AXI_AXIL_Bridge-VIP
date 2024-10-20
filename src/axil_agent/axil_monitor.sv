class axil_monitor extends uvm_monitor;
   `uvm_component_utils (axil_monitor)
   function new (string name="axil_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

   uvm_analysis_port #(axil_item)  axil_mon_ap;
   virtual axil_interface          axil_vif;

  virtual function void build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual axil_interface)::get(this, "", "axil_interface", axil_vif))
      `uvm_fatal("MON", "Could not get axil_vif")
    axil_mon_ap = new ("axil_mon_ap", this); // create analysis port
  endfunction

  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
    // This task monitors the interface for a complete 
    // transaction and writes into analysis port when complete
    forever begin
        axil_item m_item;
        @(axil_vif.clk);
        m_item = axil_item::type_id::create("m_item");
        // Write address line
        m_item.m_axil_awaddr  = axil_vif.m_axil_awaddr;
        m_item.m_axil_awprot  = axil_vif.m_axil_awprot;
        m_item.m_axil_awvalid = axil_vif.m_axil_awvalid;
        m_item.m_axil_awready = axil_vif.m_axil_awready;

        // Write data line
        m_item.m_axil_wdata   = axil_vif.m_axil_wdata;
        m_item.m_axil_wstrb   = axil_vif.m_axil_wstrb;
        m_item.m_axil_wvalid  = axil_vif.m_axil_wvalid;
        m_item.m_axil_wready  = axil_vif.m_axil_wready;

        // Write response line
        m_item.m_axil_bresp   = axil_vif.m_axil_bresp;
        m_item.m_axil_bvalid  = axil_vif.m_axil_bvalid;
        m_item.m_axil_bready  = axil_vif.m_axil_bready;

        // Read address line
        m_item.m_axil_araddr  = axil_vif.m_axil_araddr;
        m_item.m_axil_arprot  = axil_vif.m_axil_arprot;
        m_item.m_axil_arvalid = axil_vif.m_axil_arvalid;
        m_item.m_axil_arready = axil_vif.m_axil_arready;

        // Read data line
        m_item.m_axil_rdata   = axil_vif.m_axil_rdata;
        m_item.m_axil_rresp   = axil_vif.m_axil_rresp;
        m_item.m_axil_rvalid  = axil_vif.m_axil_rvalid;
        m_item.m_axil_rready  = axil_vif.m_axil_rready;


			  // axil_mon_ap.write(m_item); // send tempo item to analysis port, which will be sent to scoreboard
		end
    
  endtask
endclass
