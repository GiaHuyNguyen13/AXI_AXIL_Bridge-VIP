class axi_monitor extends uvm_monitor;
   `uvm_component_utils (axi_monitor)
   function new (string name="axi_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

   uvm_analysis_port #(axi_item)  axi_mon_ap;
   virtual axi_interface          axi_vif;

  virtual function void build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual axi_interface)::get(this, "", "axi_interface", axi_vif))
      `uvm_fatal("MON", "Could not get axi_vif")
    axi_mon_ap = new ("axi_mon_ap", this); // create analysis port
  endfunction

  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
    // This task monitors the interface for a complete 
    // transaction and writes into analysis port when complete
    forever begin
        // @(axi_vif.clk);
        axi_item m_item_beat;
        axi_item m_item = axi_item::type_id::create("m_item");
        wait ((axi_vif.s_axi_awvalid && axi_vif.s_axi_awready) || (axi_vif.s_axi_arvalid && axi_vif.s_axi_arready));
        // `uvm_info("MNT", $sformatf("Read data is correct"), UVM_HIGH)
        if (axi_vif.s_axi_awvalid && axi_vif.s_axi_awready) begin
            // Write address line
            m_item.s_axi_awid    = axi_vif.s_axi_awid;
            m_item.s_axi_awaddr  = axi_vif.s_axi_awaddr;
            m_item.s_axi_awlen   = axi_vif.s_axi_awlen;
            m_item.s_axi_awsize  = axi_vif.s_axi_awsize;
            m_item.s_axi_awburst = axi_vif.s_axi_awburst;
            m_item.s_axi_awlock  = axi_vif.s_axi_awlock;
            m_item.s_axi_awcache = axi_vif.s_axi_awcache;
            m_item.s_axi_awprot  = axi_vif.s_axi_awprot;
            m_item.s_axi_awvalid = axi_vif.s_axi_awvalid;
            m_item.s_axi_awready = axi_vif.s_axi_awready;
            //axi_mon_ap.write(m_item);

            for (int i = 0; i <= axi_vif.s_axi_awlen; i++) begin
              wait (axi_vif.s_axi_wvalid && axi_vif.s_axi_wready);
              m_item_beat = axi_item::type_id::create("m_item_beat");
              m_item_beat.s_axi_awid    = m_item.s_axi_awid;
              m_item_beat.s_axi_awaddr  = m_item.s_axi_awaddr;
              m_item_beat.s_axi_awlen   = m_item.s_axi_awlen;
              m_item_beat.s_axi_awsize  = m_item.s_axi_awsize;
              m_item_beat.s_axi_awburst = m_item.s_axi_awburst;
              m_item_beat.s_axi_awlock  = m_item.s_axi_awlock;
              m_item_beat.s_axi_awcache = m_item.s_axi_awcache;
              m_item_beat.s_axi_awprot  = m_item.s_axi_awprot;
              m_item_beat.s_axi_awvalid = m_item.s_axi_awvalid;
              m_item_beat.s_axi_awready = m_item.s_axi_awready;
              // Write data line
              m_item_beat.s_axi_wdata   = axi_vif.s_axi_wdata;
              m_item_beat.s_axi_wstrb   = axi_vif.s_axi_wstrb;
              m_item_beat.s_axi_wlast   = axi_vif.s_axi_wlast;
              m_item_beat.s_axi_wvalid  = axi_vif.s_axi_wvalid;
              m_item_beat.s_axi_wready  = axi_vif.s_axi_wready;
              axi_mon_ap.write(m_item_beat);
              
              if (i == axi_vif.s_axi_awlen) begin
              
              wait (axi_vif.s_axi_bvalid && axi_vif.s_axi_bready);
              //`uvm_info("AXI_MON", $sformatf("AXI I'm in"), UVM_HIGH)
                  // Write response line
                  m_item.s_axi_bid     = axi_vif.s_axi_bid;
                  m_item.s_axi_bresp   = axi_vif.s_axi_bresp;
                  m_item.s_axi_bvalid  = axi_vif.s_axi_bvalid;
                  m_item.s_axi_bready  = axi_vif.s_axi_bready;     
                  `uvm_info("AXI_MON", $sformatf("m_item_beat.s_axi_bready: %0d",axi_vif.s_axi_bready), UVM_HIGH)
                  axi_mon_ap.write(m_item);
              end
              if (axi_vif.s_axi_wlast) begin
                break;  // Exit the loop after the last data beat
              end
            end
        end

        if (axi_vif.s_axi_arvalid && axi_vif.s_axi_arready) begin
            // Read address line
            m_item.s_axi_arid    = axi_vif.s_axi_arid;
            m_item.s_axi_araddr  = axi_vif.s_axi_araddr;
            m_item.s_axi_arlen   = axi_vif.s_axi_arlen;
            m_item.s_axi_arsize  = axi_vif.s_axi_arsize;
            m_item.s_axi_arburst = axi_vif.s_axi_arburst;
            m_item.s_axi_arlock  = axi_vif.s_axi_arlock;
            m_item.s_axi_arcache = axi_vif.s_axi_arcache;
            m_item.s_axi_arprot  = axi_vif.s_axi_arprot;
            m_item.s_axi_arvalid = axi_vif.s_axi_arvalid;
            m_item.s_axi_arready = axi_vif.s_axi_arready;
            // axi_mon_ap.write(m_item);   

            for (int i = 0; i <= axi_vif.s_axi_arlen; i++) begin
              wait (axi_vif.s_axi_rvalid && axi_vif.s_axi_rready);
              m_item_beat = axi_item::type_id::create("m_item_beat");
              // Read address line
              m_item_beat.s_axi_arid    = m_item.s_axi_arid;
              m_item_beat.s_axi_araddr  = m_item.s_axi_araddr;
              m_item_beat.s_axi_arlen   = m_item.s_axi_arlen;
              m_item_beat.s_axi_arsize  = m_item.s_axi_arsize;
              m_item_beat.s_axi_arburst = m_item.s_axi_arburst;
              m_item_beat.s_axi_arlock  = m_item.s_axi_arlock;
              m_item_beat.s_axi_arcache = m_item.s_axi_arcache;
              m_item_beat.s_axi_arprot  = m_item.s_axi_arprot;
              m_item_beat.s_axi_arvalid = m_item.s_axi_arvalid;
              m_item_beat.s_axi_arready = m_item.s_axi_arready; 
              // Read data line
              m_item_beat.s_axi_rid     = axi_vif.s_axi_rid;
              m_item_beat.s_axi_rdata   = axi_vif.s_axi_rdata;
              m_item_beat.s_axi_rresp   = axi_vif.s_axi_rresp;
              m_item_beat.s_axi_rlast   = axi_vif.s_axi_rlast;
              m_item_beat.s_axi_rvalid  = axi_vif.s_axi_rvalid;
              m_item_beat.s_axi_rready  = axi_vif.s_axi_rready;    
              axi_mon_ap.write(m_item_beat);
              if (axi_vif.s_axi_rlast) begin
                break;  // Exit the loop after the last data beat
              end
            end
        end
    end
  endtask
endclass
