class axil_driver extends uvm_driver #(axil_item);              
  `uvm_component_utils(axil_driver)
  function new(string name = "axil_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual axil_interface axil_vif;
  centralized_memory_model mem;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axil_interface)::get(this, "*", "axil_interface", axil_vif))
      `uvm_fatal("DRV", "Could not get axil_vif");
    if (!uvm_config_db#(centralized_memory_model)::get(this, "*", "central_memory", mem))
      `uvm_fatal("CONFIG_ERR", "Could not get centralized memory from config DB.");
    mem = new();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // for (int i = 0; i < 10; i++) begin
    //   `uvm_info("DRV", $sformatf("Mem[%0d] = %0d",i, mem.read(i)), UVM_HIGH)
    // end
    forever begin
      axil_item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item); // get next item
      // m_item.print();
      response_item(m_item); // forward item to DUT through interface //ONLY RUN ONCE ???
      `uvm_info("DRV", $sformatf("AXIL item done"), UVM_HIGH)
      seq_item_port.item_done(); // item get done
    end
  endtask
  
  virtual task resp_r_addr (axil_item m_item);
   @(posedge axil_vif.clk);
      if (!m_item.operation) begin // Read operation
          //wait (axil_vif.m_axil_arvalid);
          // `uvm_info("DRV", $sformatf("r_addr_axil"), UVM_HIGH)
          //@(posedge axil_vif.clk);
          axil_vif.m_axil_arready <= m_item.m_axil_arready;
          // repeat (1) @(posedge axil_vif.clk);
          // axil_vif.m_axil_arready <= 1'b0;
      end
  endtask

  virtual task resp_r_data (axil_item m_item);
   @(posedge axil_vif.clk);
      if (!m_item.operation) begin // Read operation
          @(negedge axil_vif.m_axil_arvalid);
          axil_vif.m_axil_rdata  <= mem.read(axil_vif.m_axil_araddr);
          // `uvm_info("DRV", $sformatf("AXIL item done: %0d",axil_vif.m_axil_rdata), UVM_HIGH)
          axil_vif.m_axil_rresp  <= 1'b0; //m_item.m_axil_rresp;
          @(posedge axil_vif.clk);
          axil_vif.m_axil_rvalid <= 1'b1; //m_item.m_axil_rvalid;
          wait (axil_vif.m_axil_rready);
          @(posedge axil_vif.clk); // TREO
          axil_vif.m_axil_rvalid <= 1'b0;
      end
  endtask

  virtual task resp_w_addr (axil_item m_item);
   @(posedge axil_vif.clk);
      if (m_item.operation) begin // Write operation
          // wait (axil_vif.m_axil_awvalid);
          //@(posedge axil_vif.clk);
          axil_vif.m_axil_awready <= m_item.m_axil_awready;
          // repeat (2) @(posedge axil_vif.clk);
          // axil_vif.m_axil_awready <= 1'b0;
      end
  endtask

  virtual task resp_w_data (axil_item m_item);
   @(posedge axil_vif.clk);
      if (m_item.operation) begin // Write operation
        // `uvm_info("DRV", $sformatf("AXIL asadasdasdadfdasjkhlitem done"), UVM_HIGH)
          wait (axil_vif.m_axil_wvalid);
          //@(posedge axil_vif.clk);
          // axil_vif.m_axil_wready <= m_item.m_axil_wready;
          // repeat (2) @(posedge axil_vif.clk);
          // axil_vif.m_axil_wready <= 1'b0;
          axil_vif.m_axil_bresp  <= m_item.m_axil_bresp;
          axil_vif.m_axil_bvalid <= m_item.m_axil_bvalid;
          @(posedge axil_vif.clk);
          axil_vif.m_axil_bvalid <= 1'b0;
          axil_vif.m_axil_bresp  <= '0;
      end
  endtask

  virtual task response_item(axil_item m_item);
    wait(!axil_vif.rst)
    if (!m_item.operation) begin
      fork
        resp_r_addr(m_item);
        resp_r_data(m_item); // TREO
      join
    end

    else begin
      fork
        axil_vif.m_axil_wready = 1'b1;
        resp_w_addr(m_item);
        resp_w_data(m_item);
      join
    end
  endtask

endclass