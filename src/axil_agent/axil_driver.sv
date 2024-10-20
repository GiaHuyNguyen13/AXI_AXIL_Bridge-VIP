class axil_driver extends uvm_driver #(axil_item);              
  `uvm_component_utils(axil_driver)
  function new(string name = "axil_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual axil_interface axil_vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axil_interface)::get(this, "", "axil_interface", axil_vif))
      `uvm_fatal("DRV", "Could not get axil_vif")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      axil_item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item); // get next item
      drive_item(m_item); // forward item to DUT through interface
      seq_item_port.item_done(); // item get done
    end
  endtask
  
  virtual task resp_r_addr (axil_item m_item);
      if (!m_item.operation) begin // Read operation
          wait (axil_vif.m_axil_arvalid);
          //@(posedge axil_vif.clk);
          axil_vif.m_axil_arready <= m_item.m_axil_arready;
          repeat (2) @(posedge axil_vif.clk);
          axil_vif.m_axil_arready <= 1'b0;
      end
  endtask

  virtual task resp_r_data (axil_item m_item);
      if (!m_item.operation) begin // Read operation
          @(negedge axil_vif.m_axil_arready);
          axil_vif.m_axil_rdata  <= m_item.m_axil_rdata;
          axil_vif.m_axil_rresp  <= m_item.m_axil_rresp;
          axil_vif.m_axil_rvalid <= m_item.m_axil_rvalid;
          @(negedge axil_vif.m_axil_rready);
          axil_vif.m_axil_rvalid <= 1'b0;
      end
  endtask

  virtual task resp_w_addr (axil_item m_item);
      if (m_item.operation) begin // Write operation
          wait (axil_vif.m_axil_awvalid);
          //@(posedge axil_vif.clk);
          axil_vif.m_axil_awready <= m_item.m_axil_awready;
          repeat (2) @(posedge axil_vif.clk);
          axil_vif.m_axil_awready <= 1'b0;
      end
  endtask

  virtual task resp_w_data (axil_item m_item);
      if (m_item.operation) begin // Write operation
          wait (axil_vif.m_axil_wvalid);
          //@(posedge axil_vif.clk);
          axil_vif.m_axil_wready <= m_item.m_axil_wready;
          repeat (2) @(posedge axil_vif.clk);
          axil_vif.m_axil_wready <= 1'b0;

          axil_vif.m_axil_bresp  <= m_item.m_axil_bresp;
          axil_vif.m_axil_bvalid <= m_item.m_axil_bvalid;
          repeat (2) @(posedge axil_vif.clk);
          axil_vif.m_axil_bvalid <= 1'b0;
      end
  endtask

  virtual task response_item(axil_item m_item);
      resp_r_addr(m_item);
      resp_r_data(m_item);
      resp_w_addr(m_item);
      resp_w_data(m_item);
  endtask

endclass