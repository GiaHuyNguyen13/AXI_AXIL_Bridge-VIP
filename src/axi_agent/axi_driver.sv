class axi_driver extends uvm_driver #(axi_item);              
  `uvm_component_utils(axi_driver)
  function new(string name = "axi_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual axi_interface axi_vif;
  centralized_memory_model mem;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", axi_vif))
      `uvm_fatal("DRV", "Could not get axi_vif")
    if (!uvm_config_db#(centralized_memory_model)::get(this, "*", "central_memory", mem))
      `uvm_fatal("CONFIG_ERR", "Could not get centralized memory from config DB.");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      axi_item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item); // get next item
      // m_item.print();
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
          // axi_vif.s_axi_arlock  <= m_item.s_axi_arlock;
          // axi_vif.s_axi_arcache <= m_item.s_axi_arcache;
          // axi_vif.s_axi_arprot  <= m_item.s_axi_arprot;
          @(posedge axi_vif.clk);
          axi_vif.s_axi_arvalid <= m_item.s_axi_arvalid;
          wait(axi_vif.s_axi_arready);
          @(posedge axi_vif.clk);
          axi_vif.s_axi_arvalid <= 1'b0;
          wait(axi_vif.s_axi_rlast && axi_vif.s_axi_rvalid);
      end
  endtask

  virtual task r_data (axi_item m_item);
      @(posedge axi_vif.clk);
      if (!m_item.operation) begin // Read operation
          axi_vif.s_axi_rready <= m_item.s_axi_rready;
          // @(posedge axi_vif.s_axi_rlast);
          // @(posedge axi_vif.clk);
          // axi_vif.s_axi_rready <= 1'b0;
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
        // axi_vif.s_axi_awlock  <= m_item.s_axi_awlock;
        // axi_vif.s_axi_awcache <= m_item.s_axi_awcache;
        axi_vif.s_axi_awprot  <= m_item.s_axi_awprot;
        @(posedge axi_vif.clk);
        axi_vif.s_axi_awvalid <= m_item.s_axi_awvalid;
        wait(axi_vif.s_axi_awready);
        @(posedge axi_vif.clk);
        axi_vif.s_axi_awvalid <= 1'b0;
        wait(axi_vif.s_axi_bvalid);
    end
endtask

virtual task w_data (axi_item m_item);
    int len = m_item.s_axi_awlen + 1;
    @(posedge axi_vif.clk);
    if (m_item.operation) begin // Write operation
        wait (axi_vif.s_axi_awvalid && axi_vif.s_axi_awready);
        for (int i=0; i<len; i++) begin
          @(posedge axi_vif.clk);
          axi_vif.s_axi_wdata   <= mem.read(m_item.s_axi_awaddr + i*(m_item.s_axi_awsize + 1));
          axi_vif.s_axi_wstrb   <= m_item.s_axi_wstrb;
          axi_vif.s_axi_wlast   <= (i == len - 1) ? 1:0;

          @(posedge axi_vif.clk);
          axi_vif.s_axi_wvalid  <= m_item.s_axi_wvalid;

          wait(axi_vif.s_axi_wready);
          @(posedge axi_vif.clk);
          axi_vif.s_axi_wvalid  <= 1'b0;
          axi_vif.s_axi_wlast <= 0;
        end
          wait(axi_vif.s_axi_bvalid);
    end
endtask

virtual task drive_item (axi_item m_item);
  wait(!axi_vif.rst) begin
    fork
    r_addr(m_item);
    r_data(m_item);
    join

    fork
    axi_vif.s_axi_bready <= 1'b1; 
    w_addr(m_item);
    w_data(m_item);
    join
  end
endtask

endclass