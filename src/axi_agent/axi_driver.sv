class axi_driver extends uvm_driver #(axi_item);              
  `uvm_component_utils(axi_driver)
  function new(string name = "axi_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual axi_interface axi_vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", axi_vif))
      `uvm_fatal("DRV", "Could not get axi_vif")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      axi_item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item); // get next item
      drive_item(m_item); // forward item to DUT through interface
      `uvm_info("DRV", $sformatf("AXI item done"), UVM_HIGH)
      seq_item_port.item_done(); // item get done
    end
  endtask
  

  virtual task r_addr (axi_item m_item);
      @(posedge axi_vif.clk);
      if (!m_item.operation) begin // Read operation
          axi_vif.s_axi_arid    <= m_item.s_axi_arid;
          axi_vif.s_axi_araddr  <= m_item.s_axi_araddr;
          axi_vif.s_axi_arlen   <= m_item.s_axi_arlen;
          axi_vif.s_axi_arsize  <= m_item.s_axi_arsize;
          axi_vif.s_axi_arburst <= m_item.s_axi_arburst;
          axi_vif.s_axi_arlock  <= m_item.s_axi_arlock;
          axi_vif.s_axi_arcache <= m_item.s_axi_arcache;
          axi_vif.s_axi_arprot  <= m_item.s_axi_arprot;
          axi_vif.s_axi_arvalid <= m_item.s_axi_arvalid;
          @(posedge axi_vif.s_axi_arready);
          axi_vif.s_axi_arvalid <= 1'b0;
      end
  endtask

  virtual task r_data (axi_item m_item);
      @(posedge axi_vif.clk);
      if (!m_item.operation) begin // Read operation
          axi_vif.s_axi_rready <= m_item.s_axi_rready;
          @(negedge axi_vif.s_axi_rlast);
          axi_vif.s_axi_rready <= 1'b0;
      end
  endtask

  virtual task w_addr (axi_item m_item);
    @(posedge axi_vif.clk);
    if (m_item.operation) begin // Write operation
        axi_vif.s_axi_awid    <= m_item.s_axi_awid;
        axi_vif.s_axi_awaddr  <= m_item.s_axi_awaddr;
        axi_vif.s_axi_awlen   <= m_item.s_axi_awlen;
        axi_vif.s_axi_awsize  <= m_item.s_axi_awsize;
        axi_vif.s_axi_awburst <= m_item.s_axi_awburst;
        axi_vif.s_axi_awlock  <= m_item.s_axi_awlock;
        axi_vif.s_axi_awcache <= m_item.s_axi_awcache;
        axi_vif.s_axi_awprot  <= m_item.s_axi_awprot;
        axi_vif.s_axi_awvalid <= m_item.s_axi_awvalid;
        @(posedge axi_vif.s_axi_awready);
        axi_vif.s_axi_awvalid <= 1'b0;
    end
endtask

virtual task w_data (axi_item m_item);
    @(posedge axi_vif.clk);
    if (m_item.operation) begin // Write operation
        axi_vif.s_axi_wdata   <= m_item.s_axi_wdata;
        axi_vif.s_axi_wstrb   <= m_item.s_axi_wstrb;
        axi_vif.s_axi_wlast   <= m_item.s_axi_wlast;
        axi_vif.s_axi_wvalid  <= m_item.s_axi_wvalid;
        @(posedge axi_vif.s_axi_wready);
        axi_vif.s_axi_wvalid  <= 1'b0;
        @(posedge axi_vif.s_axi_bvalid);
        axi_vif.s_axi_bready  <= 1'b1; // Ready to accept write response
        @(posedge axi_vif.clk);
        axi_vif.s_axi_bready  <= 1'b0;
    end
endtask

virtual task drive_item (axi_item m_item);
    r_addr(m_item);
    r_data(m_item);
    w_addr(m_item);
    w_data(m_item);
endtask

endclass