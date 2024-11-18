class axi_axil_adapter_wr_ref_model;

  // Class member to store the AXI-Lite sequence
  axil_item axil_sequence[$];  // Declare as a queue to use push_back

  // Centralized memory model instance
  centralized_memory_model memory;

  // Constructor with centralized memory model instance
  function new();
    
  endfunction

  // Function to set the centralized memory model
  function void set_memory(centralized_memory_model memory);
    this.memory = memory;  // Store the reference to the centralized memory
  endfunction

  // Function to create a single expected AXI-Lite transaction for each beat of an AXI write burst
  function axil_item create_expected_axil_tr(axi_item axi_tr, int beat);
    axil_item expected_axil_tr = axil_item::type_id::create("expected_axil_tr");

    // Calculate the address for each beat in the burst
    int address = axi_tr.s_axi_awaddr + (beat * (1 << axi_tr.s_axi_awsize));
    expected_axil_tr.m_axil_awaddr = address;
    expected_axil_tr.m_axil_awprot = axi_tr.s_axi_awprot;

    // Retrieve WDATA from centralized memory model instead of directly from AXI item
    expected_axil_tr.m_axil_wdata   = memory.read(address);  // Assuming 32-bit word addressing
    expected_axil_tr.m_axil_wstrb   = axi_tr.s_axi_wstrb;
    expected_axil_tr.m_axil_awvalid = 1'b1;
    expected_axil_tr.m_axil_wvalid  = 1'b1;


    //`uvm_info("Write_Transaction_Reference_Model", $sformatf("\nExpected AW Channel AXIL item:\n%s", expected_axil_tr.conv2str(2'b00)), UVM_LOW);
    //`uvm_info("Write_Transaction_Reference_Model", $sformatf("\nExpected W  Channel AXIL item:\n%s", expected_axil_tr.conv2str(2'b01)), UVM_LOW);
    
    return expected_axil_tr;
  endfunction

  // Function to populate the axil_sequence queue with the expected AXI-Lite transactions
  function void create_expected_axil_sequence(axi_item axi_tr);
    axil_sequence.delete();  // Clear the queue before starting

    // Loop over each beat in the burst, generating an AXI-Lite transaction for each
    for (int i = 0; i <= axi_tr.s_axi_awlen; i++) begin
      axil_item expected_axil_tr_seq = axil_item::type_id::create("expected_axil_tr_seq");
      expected_axil_tr_seq = create_expected_axil_tr(axi_tr, i);
      axil_sequence.push_back(expected_axil_tr_seq);  // Use push_back with the queue
    end
  endfunction

  function axi_item create_expected_axi_bchan(axil_item axil_tr);
    axi_item expected_axi_bchannel = axi_item::type_id::create("expected_axi_bchannel");

    expected_axi_bchannel.s_axi_bresp = axil_tr.m_axil_bresp;
    expected_axi_bchannel.s_axi_bvalid = axil_tr.m_axil_bvalid;
    expected_axi_bchannel.s_axi_bready = axil_tr.m_axil_bready;

    return expected_axi_bchannel;
  endfunction
  // // Handle for the centralized memory model
  // centralized_memory_model mem;

  // // Constructor with centralized memory model instance
  // function new(centralized_memory_model memory);
  //   this.mem = memory;  // Store the reference to the centralized memory
  // endfunction

  // // Method to generate the expected AXI-Lite transaction for each beat of an AXI write burst transaction
  // function axil_item create_expected_axil_tr(axi_item axi_tr, int beat);
  //   axil_item expected_axil_tr = axil_item::type_id::create("expected_axil_tr");

  //   // Calculate the address for each beat in the burst
  //   int address = axi_tr.s_axi_awaddr + (beat * (1 << axi_tr.s_axi_awsize));
  //   expected_axil_tr.m_axil_awaddr = address;
  //   expected_axil_tr.m_axil_awprot = axi_tr.s_axi_awprot;

  //   // Retrieve WDATA from centralized memory model instead of directly from AXI item
  //   //expected_axil_tr.m_axil_wdata  = memory.read(address >> 2);  // Assuming 32-bit word addressing
  //   expected_axil_tr.m_axil_wstrb  = axi_tr.s_axi_wstrb;
  //   expected_axil_tr.m_axil_awvalid = 1'b1;
  //   expected_axil_tr.m_axil_wvalid  = 1'b1;

  //   return expected_axil_tr;
  // endfunction

  // // Method to generate a sequence of expected AXI-Lite transactions based on an AXI write burst
  // function void create_expected_axil_sequence(input axi_item axi_tr, output axil_item axil_sequence[]);
  //   // axil_item axil_sequence[$]; // Array to hold each beat's AXI-Lite transaction

  //   // // Loop over each beat in the burst, generating an AXI-Lite transaction for each
  //   // for (int i = 0; i <= axi_tr.s_axi_awlen; i++) begin
  //   //   axil_item expected_axil_tr = create_expected_axil_tr(axi_tr, i);
  //   //   axil_sequence.push_back(expected_axil_tr);
  //   // end

  //   // return axil_sequence;

  //   axil_item expected_axil_tr;

  // // Loop over each beat in the burst, generating an AXI-Lite transaction for each
  // for (int i = 0; i <= axi_tr.s_axi_awlen; i++) begin
  //   expected_axil_tr = create_expected_axil_tr(axi_tr, i);
  //   //axil_sequence.push_back(expected_axil_tr);
  //   axil_sequence = {axil_sequence, expected_axil_tr};

  // end
  // endfunction
//---------------------------------------------------------------------------------------------------
  /*
     // Function to handle an AXI write request
  function void axi_write_request(input axi_item axi_tx);
    // AXI burst length, burst size, and starting address from the AXI transaction
    this.axi_burst_len = axi_tx.s_axi_awlen;    // AXI burst length for write
    this.axi_burst_size = axi_tx.s_axi_awsize;  // AXI burst size for write
    this.axi_addr = axi_tx.s_axi_awaddr;        // Starting address for write
    this.s_axi_awid     = axi_tx.s_axi_awid;         // Default ID
    this.s_axi_awaddr   = axi_tx.s_axi_awaddr; // Default address
    this.s_axi_awlen    = axi_tx.s_axi_awlen;         // Default burst length (single transfer)
    this.s_axi_awsize   = axi_tx.s_axi_awsize;       // Default size (4 bytes, 32-bit)
    this.s_axi_awburst  = axi_tx.s_axi_awburst;        // Default burst type (incremental)
    this.s_axi_awlock   = axi_tx.s_axi_awlock;         // Default lock (no lock)
    this.s_axi_awcache  = axi_tx.s_axi_awcache;      // Default cache type (e.g., normal, bufferable)
    this.s_axi_awprot   = axi_tx.s_axi_awprot;       // Default protection (non-secure, data access)
    this.s_axi_awvalid  = axi_tx.s_axi_awvalid;         // Default valid signal (inactive)
    this.s_axi_awready  = axi_tx.s_axi_awready;         // Default ready signal (inactive)
  endfunction

  // Function to convert AXI write transaction to AXI-Lite transaction
  function axil_item convert_axi_to_axil_write();
    axil_item axil_tx = axil_item::type_id::create("axil_tx_write");  // Create an AXI-Lite write item

    // Set the write address for the AXI-Lite transaction
    axil_tx.m_axil_awaddr = this.s_axi_awaddr;      // Address for AXI-Lite write

    // Fetch data from the centralized memory model to be written to the bridge
    axil_tx.m_axil_wdata = this.mem.read(this.s_axi_awaddr);  // Read data from memory to be written

    // Increment the AXI address for the next burst transfer
    this.axi_addr = this.axi_addr + (1 << this.axi_burst_size);
    this.axi_burst_len--;

    // Set other fields for the AXI-Lite write transaction
    axil_tx.m_axil_awprot = 3'b000;  // Assuming no special protection bits
    axil_tx.m_axil_awvalid = 1'b1;   // Valid write request
    axil_tx.m_axil_wvalid = 1'b1;    // Valid write data
    axil_tx.m_axil_bvalid = 1'b1;    // Valid write response
    axil_tx.m_axil_bresp = 2'b00;    // OKAY response 

    return axil_tx;
  endfunction

  // Task to convert an entire AXI write burst into AXI-Lite transactions
  function void convert_burst_to_axil_write(output axil_item axil_tx[]);
    int idx = 0;
    axil_tx = new[this.axi_burst_len];  // Initialize the array for AXI-Lite items
    while (this.axi_burst_len > 0) begin
      axil_tx[idx] = convert_axi_to_axil_write();  // Convert each part of the burst to AXI-Lite write
      idx++;
    end
  endfunction */

endclass
