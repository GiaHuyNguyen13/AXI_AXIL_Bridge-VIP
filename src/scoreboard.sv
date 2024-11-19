class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  `uvm_analysis_imp_decl(_axi)
  `uvm_analysis_imp_decl(_axil)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  bit [0:0] rwop;
  bit [7:0] blen;
  centralized_memory_model mem;
  uvm_analysis_imp_axi  #(axi_item, scoreboard) axi_analysis_imp;
  uvm_analysis_imp_axil #(axil_item, scoreboard) axil_analysis_imp;
  axi_axil_adapter_rd_ref_model rd_ref_model;
  axi_axil_adapter_wr_ref_model wr_ref_model;

  axil_item expected_axil_tx_q[$];
  axil_item actual_axil_tx_q[$];
  
  axi_item expected_axi_tx_q[$];
  axi_item actual_axi_tx_q[$];

  axil_item temp_axil_item;
  axi_item temp_axi_item; // add

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    blen = 0;
    rwop = 0;
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

    if (axi_item.s_axi_rvalid && axi_item.s_axi_rready) begin
      `uvm_info("SCBD", $sformatf("Process axi read transaction"), UVM_LOW);

      if (blen == 0) begin
        process_axi_rd_transaction(axi_item);
        process_actual_axi_transaction(axi_item);
        blen++;
      end else begin
        process_actual_axi_transaction(axi_item);
        blen++;
      end

      if (blen == axi_item.s_axi_arlen + 1) begin
        `uvm_info("SCBD", $sformatf("Blen reset here"), UVM_LOW);
        blen = 0;
      end 
      // Write transaction
    end else if (axi_item.s_axi_wvalid && axi_item.s_axi_wready) begin
      `uvm_info("SCBD", $sformatf("Process axi write transaction"), UVM_LOW);
      if (blen == 0) process_axi_wr_transaction(axi_item);
      blen = (blen == axi_item.s_axi_awlen) ? 0 : blen + 1;
    end else if (axi_item.s_axi_bvalid && axi_item.s_axi_bready) begin

        actual_axi_tx_q.push_back(axi_item);
    end

  endfunction

  function void process_axi_wr_transaction(axi_item axi_tr);//axi_item axi_item);
    `uvm_info("SCBD", $sformatf("Generating expected axil write transaction"), UVM_LOW);
    wr_ref_model.create_expected_axil_sequence(axi_tr);
    // Access the populated axil_sequence as needed
    foreach (wr_ref_model.axil_sequence[i]) begin
          expected_axil_tx_q.push_back(wr_ref_model.axil_sequence[i]);
    end
  endfunction

    virtual function write_axil(axil_item axil_item);
      if (axil_item.m_axil_awvalid && axil_item.m_axil_awready)
          process_actual_axil_transaction(axil_item);
      if (axil_item.m_axil_arvalid && axil_item.m_axil_arready)
          process_actual_axil_transaction(axil_item);
      if (axil_item.m_axil_bvalid && axil_item.m_axil_bready)
          expected_axi_tx_q.push_back(wr_ref_model.create_expected_axi_bchan(axil_item));
    endfunction

    function void process_actual_axil_transaction(axil_item axil_tr);//axi_item axi_item);
      `uvm_info("SCBD", $sformatf("Receiving actual axil transaction"), UVM_LOW);
        actual_axil_tx_q.push_back(axil_tr);
    endfunction

  function void process_axi_rd_transaction(axi_item axi_tr);
    `uvm_info("SCBD", $sformatf("Generating expected axi read transaction"), UVM_LOW);
    rd_ref_model.create_expected_rd_sequence(axi_tr);
    // Access the populated axil_sequence as needed
    foreach (rd_ref_model.axi_sequence[i]) begin
          expected_axi_tx_q.push_back(rd_ref_model.axi_sequence[i]);
    end
    foreach (rd_ref_model.axil_sequence[i]) begin
          expected_axil_tx_q.push_back(rd_ref_model.axil_sequence[i]);
    end
  endfunction

  function void process_actual_axi_transaction(axi_item axi_item);
    `uvm_info("SCBD", $sformatf("Receiving actual axi transaction"), UVM_LOW);
        actual_axi_tx_q.push_back(axi_item);
  endfunction


     // Check phase to compare expected and actual AXI-Lite transactions
 function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    // for (int h = 0; h < actual_axi_tx_q.size(); h++)
    //   $display("AXI actual: %0d\n",actual_axi_tx_q[h].s_axi_rdata);
    `uvm_info("SCBD", "Starting check phase for transactions", UVM_LOW);

    // axi_item expected_axi_tr;
    // axi_item actual_axi_tr;
    // Compare expected and actual transactions
    if (expected_axil_tx_q.size() != actual_axil_tx_q.size()) begin
      `uvm_error("SCBD", $sformatf("Mismatch in WRITE transaction count: Expected %0d, Actual %0d",
                                   expected_axil_tx_q.size(), actual_axil_tx_q.size()))
      return;
    end

    // Compare expected and actual READ transactions
    if (expected_axi_tx_q.size() != actual_axi_tx_q.size()) begin
      `uvm_error("SCBD", $sformatf("Mismatch in READ transaction count: Expected %0d, Actual %0d",
                                   expected_axi_tx_q.size(), actual_axi_tx_q.size()))
      return;
    end
    for (int i = 0; i < expected_axil_tx_q.size(); i++) begin
      axil_item expected_tr = expected_axil_tx_q[i];
      axil_item actual_tr = actual_axil_tx_q[i];


      if (expected_tr.m_axil_awaddr != actual_tr.m_axil_awaddr) begin
        `uvm_error("SCBD", $sformatf("Address mismatch at transaction %0d: Expected awaddr=%0h, Actual awaddr=%0h", 
                                     i, expected_tr.m_axil_awaddr, actual_tr.m_axil_awaddr));
      end else begin
        `uvm_info("SCBD", $sformatf("\nAddress match at transaction %0d:\n Expected awaddr=0x%0h, Actual awaddr=0x%0h", 
                                     i, expected_tr.m_axil_awaddr, actual_tr.m_axil_awaddr),UVM_LOW);
      end

      if (expected_tr.m_axil_awprot != actual_tr.m_axil_awprot) begin
        `uvm_error("SCBD", $sformatf("Write protection mismatch at transaction %0d: Expected awprot=%0b, Actual awprot=%0b", 
                                     i, expected_tr.m_axil_awprot, actual_tr.m_axil_awprot));
      end else begin
        `uvm_info("SCBD", $sformatf("\nWrite protection match at transaction %0d:\n Expected awprot=%0b, Actual awprot=%0b", 
                                     i, expected_tr.m_axil_awprot, actual_tr.m_axil_awprot),UVM_LOW);
      end

      if (expected_tr.m_axil_wdata != actual_tr.m_axil_wdata) begin
        `uvm_error("SCBD", $sformatf("Data mismatch at transaction %0d: Expected wdata=0x%0h, Actual wdata=0x%0h", 
                                     i, expected_tr.m_axil_wdata, actual_tr.m_axil_wdata));
      end else begin
        `uvm_info("SCBD", $sformatf("\nData match at transaction %0d:\n Expected wdata=%0h, Actual wdata=%0h", 
                                     i, expected_tr.m_axil_wdata, actual_tr.m_axil_wdata),UVM_LOW);
      end

      if (expected_tr.m_axil_wstrb != actual_tr.m_axil_wstrb) begin
        `uvm_error("SCBD", $sformatf("Write strobe mismatch at transaction %0d: Expected wstrb=%b, Actual wstrb=%b", 
                                     i, expected_tr.m_axil_wstrb, actual_tr.m_axil_wstrb));
      end else begin
        `uvm_info("SCBD", $sformatf("\nWrite strobe match at transaction %0d:\n Expected wstrb=%b, Actual wstrb=%b\n\n", 
                                     i, expected_tr.m_axil_wstrb, actual_tr.m_axil_wstrb),UVM_LOW);
      end
      
    end


      `uvm_info("SCBD", $sformatf("\nSize of exp_axi :%0d \n Size of act_axi :%0d", 
                                     expected_axi_tx_q.size(), actual_axi_tx_q.size()),UVM_LOW);
      // axi_item expected_axi_tr;
      // axi_item actual_axi_tr;
      for (int k = 0; k < expected_axi_tx_q.size(); k++) begin
       
          //`uvm_info("SCBD", $sformatf("AXI I'm in"), UVM_HIGH);
          axi_item expected_axi_tr = expected_axi_tx_q[k];//.pop_front();
          axi_item actual_axi_tr = actual_axi_tx_q[k];//.pop_front();

          if (expected_axi_tr.s_axi_bresp != actual_axi_tr.s_axi_bresp) begin
            `uvm_error("SCBD", $sformatf("Write response mismatch at transaction %0d: Expected bresp=%b, Actual bresp=%b", 
                                       k, expected_axi_tr.s_axi_bresp, actual_axi_tr.s_axi_bresp));
          end else begin
            `uvm_info("SCBD", $sformatf("\nWrite response match at transaction %0d:\n Expected bresp=%b, Actual bresp=%b\n\n", 
                                       k, expected_axi_tr.s_axi_bresp, actual_axi_tr.s_axi_bresp),UVM_LOW);
          end

        
      end
    
    for (int j = 0; j < expected_axi_tx_q.size(); j++) begin
      axi_item expected_rd_tr = expected_axi_tx_q[j];
      axi_item actual_rd_tr = actual_axi_tx_q[j];

      if (expected_rd_tr.s_axi_rdata != actual_rd_tr.s_axi_rdata) begin
        `uvm_error("SCBD", $sformatf("Data mismatch at transaction %0d: Expected rdata=0x%0h, Actual rdata=0x%0h", 
                                     j, expected_rd_tr.s_axi_rdata, actual_rd_tr.s_axi_rdata));
      end else begin
        `uvm_info("SCBD", $sformatf("\nData match at transaction %0d:\n Expected rdata=%0h, Actual rdata=%0h", 
                                     j, expected_rd_tr.s_axi_rdata, actual_rd_tr.s_axi_rdata),UVM_LOW);
      end

      if (expected_rd_tr.s_axi_rid != actual_rd_tr.s_axi_rid) begin
        `uvm_error("SCBD", $sformatf("Read ID mismatch at transaction %0d: Expected rid=%b, Actual rid=%b", 
                                     j, expected_rd_tr.s_axi_rid, actual_rd_tr.s_axi_rid));
      end else begin
        `uvm_info("SCBD", $sformatf("\nRead ID match at transaction %0d:\n Expected rid=%b, Actual rid=%b\n\n", 
                                     j, expected_rd_tr.s_axi_rid, actual_rd_tr.s_axi_rid),UVM_LOW);
      end
      
    end

    for (int l = 0; l < expected_axil_tx_q.size(); l++) begin
      axil_item expected_rd_axil_tr = expected_axil_tx_q[l];
      axil_item actual_rd_axil_tr = actual_axil_tx_q[l];

          if (expected_rd_axil_tr.m_axil_araddr != actual_rd_axil_tr.m_axil_araddr) begin
        `uvm_error("SCBD", $sformatf("Address mismatch at transaction %0d: Expected araddr=%0h, Actual araddr=%0h", 
                                     l, expected_rd_axil_tr.m_axil_araddr, actual_rd_axil_tr.m_axil_araddr));
      end else begin
        `uvm_info("SCBD", $sformatf("\nAddress match at transaction %0d:\n Expected araddr=0x%0h, Actual araddr=0x%0h", 
                                     l, expected_rd_axil_tr.m_axil_araddr, actual_rd_axil_tr.m_axil_araddr),UVM_LOW);
      end

      if (expected_rd_axil_tr.m_axil_arprot != actual_rd_axil_tr.m_axil_arprot) begin
        `uvm_error("SCBD", $sformatf("Read protection mismatch at transaction %0d: Expected arprot=%0b, Actual arprot=%0b", 
                                     l, expected_rd_axil_tr.m_axil_arprot, actual_rd_axil_tr.m_axil_arprot));
      end else begin
        `uvm_info("SCBD", $sformatf("\nRead protection match at transaction %0d:\n Expected arprot=%0b, Actual arprot=%0b\n", 
                                     l, expected_rd_axil_tr.m_axil_arprot, actual_rd_axil_tr.m_axil_arprot),UVM_LOW);
      end

    end

    `uvm_info("SCBD", "Check phase completed successfully", UVM_LOW);
  endfunction
endclass
