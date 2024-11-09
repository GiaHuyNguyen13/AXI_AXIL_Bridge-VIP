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
        m_item = axil_item::type_id::create("m_item");
        //@(axil_vif.clk);
        wait ((axil_vif.m_axil_awvalid && axil_vif.m_axil_awready) || (axil_vif.m_axil_arvalid && axil_vif.m_axil_arready));
        //@(axil_vif.clk);
        if (axil_vif.m_axil_awvalid && axil_vif.m_axil_awready) begin
            // Write address line
            m_item.m_axil_awaddr  = axil_vif.m_axil_awaddr;
            m_item.m_axil_awprot  = axil_vif.m_axil_awprot;
            m_item.m_axil_awvalid = axil_vif.m_axil_awvalid;
            m_item.m_axil_awready = axil_vif.m_axil_awready;
            //m_item.disp_aw(2'b00);
            //axil_mon_ap.write(m_item);

            wait (axil_vif.m_axil_wvalid && axil_vif.m_axil_wready);
            //m_item = axil_item::type_id::create("m_item");
            // Write data line
            m_item.m_axil_wdata   = axil_vif.m_axil_wdata;
            m_item.m_axil_wstrb   = axil_vif.m_axil_wstrb;
            m_item.m_axil_wvalid  = axil_vif.m_axil_wvalid;
            m_item.m_axil_wready  = axil_vif.m_axil_wready;
            //m_item.disp_aw(2'b01);
            axil_mon_ap.write(m_item);

            // wait (axil_vif.m_axil_bvalid && axil_vif.m_axil_bready);
            // m_item = axil_item::type_id::create("m_item");
            // // Write response line
            // m_item.m_axil_bresp   = axil_vif.m_axil_bresp;
            // m_item.m_axil_bvalid  = axil_vif.m_axil_bvalid;
            // m_item.m_axil_bready  = axil_vif.m_axil_bready;
            // m_item.disp_aw(2'b10);
            // axil_mon_ap.write(m_item);
        end
/*
        if (axil_vif.m_axil_arvalid && axil_vif.m_axil_arready) begin

            // Read address line
            m_item.m_axil_araddr  = axil_vif.m_axil_araddr;
            m_item.m_axil_arprot  = axil_vif.m_axil_arprot;
            m_item.m_axil_arvalid = axil_vif.m_axil_arvalid;
            m_item.m_axil_arready = axil_vif.m_axil_arready;
            axil_mon_ap.write(m_item);

            wait (axil_vif.m_axil_rvalid && axil_vif.m_axil_rready);
            m_item = axil_item::type_id::create("m_item");
            // Read data line
            m_item.m_axil_rdata   = axil_vif.m_axil_rdata;
            m_item.m_axil_rresp   = axil_vif.m_axil_rresp;
            m_item.m_axil_rvalid  = axil_vif.m_axil_rvalid;
            m_item.m_axil_rready  = axil_vif.m_axil_rready;
            axil_mon_ap.write(m_item);
			  // axil_mon_ap.write(m_item); // send tempo item to analysis port, which will be sent to scoreboard
		end*/
    end
    
  endtask
endclass
