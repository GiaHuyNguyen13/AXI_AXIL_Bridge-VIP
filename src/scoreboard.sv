class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  `uvm_analysis_imp_decl(_axi)
  `uvm_analysis_imp_decl(_axil)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  centralized_memory_model mem;
  uvm_analysis_imp_axi #(axi_item, scoreboard) axi_analysis_imp;
  uvm_analysis_imp_axil #(axil_item, scoreboard) axil_analysis_imp;
  axi_axil_adapter_rd_ref_model rd_ref_model;
  axi_axil_adapter_wr_ref_model wr_ref_model;

  axil_item expected_axil_tx_q[$];
  axil_item temp_axil_item;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_ref_model = new();
    wr_ref_model = new();
    axi_analysis_imp = new("axi_analysis_imp", this);
    axil_analysis_imp = new("axil_analysis_imp", this);
    if (!uvm_config_db#(centralized_memory_model)::get(this, "", "central_memory", mem))
      `uvm_fatal("CONFIG_ERR", "Could not get centralized memory from config DB.")
    rd_ref_model.set_memory(mem);
    wr_ref_model.set_memory(mem);
  endfunction

  virtual function write_axi(axi_item axi_item);
    
    // Read transaction
    if (axi_item.s_axi_arvalid && axi_item.s_axi_arready) begin
      // axi_item.print();
      process_axi_rd_transaction(axi_item); // Pass the argument to ref model
    end else if (axi_item.s_axi_rvalid && axi_item.s_axi_rready) begin
      if (expected_axil_tx_q.size()) temp_axil_item = expected_axil_tx_q.pop_front();
      // if (axi_item.s_axi_rdata != temp_axil_item.m_axil_rdata) `uvm_info("SB", $sformatf("Read data mismatched"), UVM_HIGH)
      // else begin `uvm_info("SB", $sformatf("Read data is correct"), UVM_HIGH) end
    // Write transaction
    end else if (axi_item.s_axi_awvalid && axi_item.s_axi_awready) begin
      process_axi_wr_transaction(axi_item);
    end
  endfunction

  virtual function write_axil(axil_item axil_item);
    
    if (axil_item.m_axil_wvalid && axil_item.m_axil_wready) begin
      if (expected_axil_tx_q.size()) temp_axil_item = expected_axil_tx_q.pop_front(); begin
        // if (axil_item.m_axil_wdata != temp_axil_item.m_axil_wdata) `uvm_info("SB", $sformatf("Write data mismatched"), UVM_HIGH)
        // else begin `uvm_info("SB", $sformatf("Write data is correct"), UVM_HIGH) end
      end
    end
  endfunction



  function void process_axi_rd_transaction(axi_item axi_item);
    axil_item expected_axil_tx[];  // Temporary storage for the expected transactions

    // Check if the transaction is a read transaction
    if (!axi_item.operation) begin  // Assuming 0 means read
      `uvm_info("AXI_TO_AXIL_CHECK", "Processing AXI read transaction...", UVM_LOW);
      
      // Process the read request using the reference model
      rd_ref_model.axi_read_request(axi_item);
      
      // Convert the AXI burst into expected AXI-Lite transactions
      rd_ref_model.convert_burst_to_axil(expected_axil_tx);

      // Store the expected AXI-Lite transactions in the queue for later comparison
      foreach (expected_axil_tx[i]) begin
        expected_axil_tx_q.push_back(expected_axil_tx[i]);
      end
      `uvm_info("AXI_TO_AXIL_CHECK", $sformatf("Stored %0d expected AXI-Lite transactions", expected_axil_tx.size()), UVM_LOW);
    end
  endfunction

  function void process_axi_wr_transaction(axi_item axi_item);
    axil_item expected_axil_tx[];  // Temporary storage for the expected transactions

    // Check if the transaction is a write transaction
    if (axi_item.operation) begin  // Assuming 1 means write
      `uvm_info("AXI_TO_AXIL_CHECK", "Processing AXI write transaction...", UVM_LOW);
      
      // Process the write request using the reference model
      wr_ref_model.axi_write_request(axi_item);
      
      // Convert the AXI burst into expected AXI-Lite transactions
      wr_ref_model.convert_burst_to_axil_write(expected_axil_tx);

      // Store the expected AXI-Lite transactions in the queue for later comparison
      foreach (expected_axil_tx[i]) begin
        expected_axil_tx_q.push_back(expected_axil_tx[i]);
      end
      `uvm_info("AXI_TO_AXIL_CHECK", $sformatf("Stored %0d expected AXI-Lite transactions for write", expected_axil_tx.size()), UVM_LOW);
    end
  endfunction


endclass
