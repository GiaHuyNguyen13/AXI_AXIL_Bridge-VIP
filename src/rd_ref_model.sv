class axi_axil_adapter_rd_ref_model;


  // Class member to store the AXI sequence
  axil_item axil_sequence[$];  // Declare as a queue to use push_back
  axi_item axi_sequence[$];  // Declare as a queue to use push_back

  // Handle for the centralized memory model
  centralized_memory_model memory;

  // Constructor with centralized memory model instance
  function new();
    
  endfunction

  // Function to set the centralized memory model
  function void set_memory(centralized_memory_model memory);
    this.memory = memory;  // Store the reference to the centralized memory
  endfunction

    // Function to populate the axil_sequence queue with the expected AXI-Lite transactions
  function void create_expected_rd_sequence(axi_item axi_tr);
    axil_sequence.delete();  // Clear the queue before starting
    axi_sequence.delete();  // Clear the queue before starting

    // Loop over each beat in the burst, generating an AXI-Lite transaction for each
    for (int i = 0; i <= axi_tr.s_axi_arlen; i++) begin
      axil_item expected_axil_tr = axil_item::type_id::create("expected_axil_tr_seq");
      axi_item expected_axi_tr = axi_item::type_id::create("expected_axi_tr_seq");

      // Calculate the address for each beat in the burst
    int address = axi_tr.s_axi_araddr + (i * (1 << axi_tr.s_axi_arsize));
    expected_axil_tr.m_axil_araddr = address;
    expected_axil_tr.m_axil_arprot = axi_tr.s_axi_arprot;

    // Retrieve WDATA from centralized memory model instead of directly from AXI item
    expected_axi_tr.s_axi_rdata   = memory.read(address);  // Assuming 32-bit word addressing
    expected_axi_tr.s_axi_rid   = axi_tr.s_axi_rid;

    expected_axil_tr.m_axil_arvalid = 1'b1;
    expected_axi_tr.s_axi_rvalid  = 1'b1;

      axil_sequence.push_back(expected_axil_tr);  // Use push_back with the queue
      axi_sequence.push_back(expected_axi_tr);  // Use push_back with the queue
    end
  endfunction

endclass
