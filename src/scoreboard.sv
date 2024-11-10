class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  `uvm_analysis_imp_decl(_axi)
  `uvm_analysis_imp_decl(_axil)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  bit [7:0] blen;
  centralized_memory_model mem;
  uvm_analysis_imp_axi  #(axi_item, scoreboard) axi_analysis_imp;
  uvm_analysis_imp_axil #(axil_item, scoreboard) axil_analysis_imp;
  axi_axil_adapter_rd_ref_model rd_ref_model;
  axi_axil_adapter_wr_ref_model wr_ref_model;

  axil_item expected_axil_tx_q[$];
  axil_item actual_axil_tx_q[$];
  axil_item temp_axil_item;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    blen = 0;
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
      process_axi_rd_transaction(axi_item); // Pass the argument to ref model
    end else if (axi_item.s_axi_rvalid && axi_item.s_axi_rready) begin
      
      if (expected_axil_tx_q.size()) temp_axil_item = expected_axil_tx_q.pop_front();
      // if (axi_item.s_axi_rdata != temp_axil_item.m_axil_rdata) `uvm_info("SB", $sformatf("Read data mismatched"), UVM_HIGH)
      // else begin `uvm_info("SB", $sformatf("Read data is correct"), UVM_HIGH) end
    // Write transaction
    end else if (axi_item.s_axi_wvalid && axi_item.s_axi_wready) begin
      `uvm_info("SCBD", $sformatf("Process axi write transaction"), UVM_LOW);
      if (blen == 0) begin
        process_axi_wr_transaction(axi_item);
        blen++;
      end else if (blen == axi_item.s_axi_awlen)
        blen = 0;
      else
        blen++;
    end
  endfunction

  function void process_axi_wr_transaction(axi_item axi_tr);//axi_item axi_item);
    `uvm_info("SCBD", $sformatf("Generating expected axil write transaction"), UVM_LOW);
    wr_ref_model.create_expected_axil_sequence(axi_tr);
    // Access the populated axil_sequence as needed
    foreach (wr_ref_model.axil_sequence[i]) begin
          expected_axil_tx_q.push_back(wr_ref_model.axil_sequence[i]);
    end

 
    // axil_item expected_axil_tx[];  // Temporary storage for the expected transactions

    //  // Generate the expected sequence of AXI-Lite transactions
    // //axil_item[] expected_axil_sequence = ref_model.create_expected_axil_sequence(axi_tr);

    // // Compare each expected transaction with the actual transaction
    // if (expected_axil_sequence.size() != actual_axil_sequence.size()) begin
    //   `uvm_error("AXI_AXIL_SB", "Size mismatch between expected and actual AXI-Lite transaction sequences")
    //   return;
    // end

    // for (int i = 0; i < expected_axil_sequence.size(); i++) begin
    //   axil_item expected_tr = expected_axil_sequence[i];
    //   axil_item actual_tr = actual_axil_sequence[i];

    //   if (expected_tr.awaddr !== actual_tr.awaddr) begin
    //     `uvm_error("AXI_AXIL_SB", $sformatf("Address mismatch: Expected awaddr=%0h, Actual awaddr=%0h", expected_tr.awaddr, actual_tr.awaddr))
    //   end

    //   if (expected_tr.wdata !== actual_tr.wdata) begin
    //     `uvm_error("AXI_AXIL_SB", $sformatf("Data mismatch: Expected wdata=%0h, Actual wdata=%0h", expected_tr.wdata, actual_tr.wdata))
    //   end

    //   if (expected_tr.wstrb !== actual_tr.wstrb) begin
    //     `uvm_error("AXI_AXIL_SB", $sformatf("Write strobe mismatch: Expected wstrb=%0b, Actual wstrb=%0b", expected_tr.wstrb, actual_tr.wstrb))
    //   end
    //end
    // // Check if the transaction is a write transaction
    // if (axi_item.operation) begin  // Assuming 1 means write
    //   `uvm_info("AXI_TO_AXIL_CHECK", "Processing AXI write transaction...", UVM_LOW);
      
    //   // Process the write request using the reference model
    //   wr_ref_model.axi_write_request(axi_item);
      
      
    //   /*
    //   // Convert the AXI burst into expected AXI-Lite transactions
    //   wr_ref_model.convert_burst_to_axil_write(expected_axil_tx);*/

    //   // Store the expected AXI-Lite transactions in the queue for later comparison
    //   foreach (expected_axil_tx[i]) begin
    //     expected_axil_tx_q.push_back(expected_axil_tx[i]);
    //   end
    //   `uvm_info("AXI_TO_AXIL_CHECK", $sformatf("Stored %0d expected AXI-Lite transactions for write", expected_axil_tx.size()), UVM_LOW);
    // end
  endfunction



    virtual function write_axil(axil_item axil_item);
       if (axil_item.m_axil_awvalid && axil_item.m_axil_awready)
          process_axil_wr_transaction(axil_item);
    //   `uvm_info("AXI_SCOREBOARD", $sformatf("\nReceived item from monitor:\n%s", axil_item.conv2str(2'b00)), UVM_LOW);

    //   if (axil_item.m_axil_wvalid && axil_item.m_axil_wready)
    //   `uvm_info("AXI_SCOREBOARD", $sformatf("\nReceived item from monitor:\n%s", axil_item.conv2str(2'b01)), UVM_LOW);

    //   if (axil_item.m_axil_bvalid && axil_item.m_axil_bready)
    //   `uvm_info("AXI_SCOREBOARD", $sformatf("\nReceived item from monitor:\n%s", axil_item.conv2str(2'b10)), UVM_LOW);
     
    //   /*if (axil_item.m_axil_wvalid && axil_item.m_axil_wready) begin
    //     if (expected_axil_tx_q.size()) temp_axil_item = expected_axil_tx_q.pop_front(); begin
    //       // if (axil_item.m_axil_wdata != temp_axil_item.m_axil_wdata) `uvm_info("SB", $sformatf("Write data mismatched"), UVM_HIGH)
    //       // else begin `uvm_info("SB", $sformatf("Write data is correct"), UVM_HIGH) end
    //     end
    //   end*/
    endfunction

    function void process_axil_wr_transaction(axil_item axil_tr);//axi_item axi_item);
      `uvm_info("SCBD", $sformatf("Receiving actual axil transaction"), UVM_LOW);
        actual_axil_tx_q.push_back(axil_tr);

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


     // Check phase to compare expected and actual AXI-Lite transactions
 function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    `uvm_info("SCBD", "Starting check phase for AXI write transactions", UVM_LOW);

    // Compare expected and actual transactions
    if (expected_axil_tx_q.size() != actual_axil_tx_q.size()) begin
      `uvm_error("SCBD", $sformatf("Mismatch in transaction count: Expected %0d, Actual %0d",
                                   expected_axil_tx_q.size(), actual_axil_tx_q.size()))
      return;
    end

    for (int i = 0; i < expected_axil_tx_q.size(); i++) begin
      axil_item expected_tr = expected_axil_tx_q[i];
      axil_item actual_tr = actual_axil_tx_q[i];

      if (expected_tr.m_axil_awaddr !== actual_tr.m_axil_awaddr) begin
        `uvm_error("SCBD", $sformatf("Address mismatch at transaction %0d: Expected awaddr=%0h, Actual awaddr=%0h", 
                                     i, expected_tr.m_axil_awaddr, actual_tr.m_axil_awaddr));
      end else begin
        `uvm_info("SCBD", $sformatf("\nAddress match at transaction %0d:\n Expected awaddr=0x%0h, Actual awaddr=0x%0h", 
                                     i, expected_tr.m_axil_awaddr, actual_tr.m_axil_awaddr),UVM_LOW);
      end

      if (expected_tr.m_axil_awprot !== actual_tr.m_axil_awprot) begin
        `uvm_error("SCBD", $sformatf("Write protection mismatch at transaction %0d: Expected awprot=%0b, Actual awprot=%0b", 
                                     i, expected_tr.m_axil_awprot, actual_tr.m_axil_awprot));
      end else begin
        `uvm_info("SCBD", $sformatf("\nWrite protection match at transaction %0d:\n Expected awprot=%0b, Actual awprot=%0b", 
                                     i, expected_tr.m_axil_awprot, actual_tr.m_axil_awprot),UVM_LOW);
      end

      if (expected_tr.m_axil_wdata !== actual_tr.m_axil_wdata) begin
        `uvm_error("SCBD", $sformatf("Data mismatch at transaction %0d: Expected wdata=0x%0h, Actual wdata=0x%0h", 
                                     i, expected_tr.m_axil_wdata, actual_tr.m_axil_wdata));
      end else begin
        `uvm_info("SCBD", $sformatf("\nData match at transaction %0d:\n Expected wdata=%0h, Actual wdata=%0h", 
                                     i, expected_tr.m_axil_wdata, actual_tr.m_axil_wdata),UVM_LOW);
      end

      if (expected_tr.m_axil_wstrb !== actual_tr.m_axil_wstrb) begin
        `uvm_error("SCBD", $sformatf("Write strobe mismatch at transaction %0d: Expected wstrb=%b, Actual wstrb=%b", 
                                     i, expected_tr.m_axil_wstrb, actual_tr.m_axil_wstrb));
      end else begin
        `uvm_info("SCBD", $sformatf("\nWrite strobe match at transaction %0d:\n Expected wstrb=%b, Actual wstrb=%b\n\n", 
                                     i, expected_tr.m_axil_wstrb, actual_tr.m_axil_wstrb),UVM_LOW);
      end
      
    end
    `uvm_info("SCBD", "Check phase completed successfully", UVM_LOW);
  endfunction

  


endclass
