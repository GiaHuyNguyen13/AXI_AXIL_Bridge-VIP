class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  centralized_memory_model mem;
  uvm_analysis_imp #(axi_item, scoreboard) axi_analysis_imp;
  uvm_analysis_imp #(axil_item, scoreboard) axil_analysis_imp;
  axi_axil_adapter_rd_ref_model rd_ref_model;

  axil_item expected_axil_tx_q[$];
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_analysis_imp = new("axi_analysis_imp", this);
    axil_analysis_imp = new("axil_analysis_imp", this);
    rd_ref_model = axi_axil_adapter_rd_ref_model::new();
    if (!uvm_config_db#(centralized_memory_model)::get(this, "", "central_memory", mem)) begin
      `uvm_fatal("CONFIG_ERR", "Could not get centralized memory from config DB.");
    rd_ref_model.set_memory(mem);
  endfunction
  
  virtual function write(axi_item axi_item);
    process_axi_rd_transaction(axi_item); // Pass the argument to ref model
  endfunction

  virtual function write(axil_item axil_item);
    
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

    // Check if the transaction is a write transaction
    else if (axi_item.operation) begin  // Assuming 1 means write
      `uvm_info("AXI_TO_AXIL_CHECK", "Processing AXI write transaction...", UVM_LOW);

    end
  endfunction
endclass
