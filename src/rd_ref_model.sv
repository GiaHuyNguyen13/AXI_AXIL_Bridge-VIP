class axi_axil_adapter_rd_ref_model;


  // Class member to store the AXI sequence
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

  // Function to create a single expected AXI transaction for each beat of an AXI read burst
  function axi_item create_expected_axi_tr(axi_item axi_tr, int beat);
    axi_item expected_axi_tr = axi_item::type_id::create("expected_axi_tr");

    // Calculate the address for each beat in the burst

    // int address = axi_tr.s_axi_araddr + (beat * (1 << axi_tr.s_axi_arsize)); // NEEDED ??????????????
   

    expected_axi_tr.s_axi_araddr = axi_tr.s_axi_araddr; 
   

    expected_axi_tr.s_axi_arprot = axi_tr.s_axi_arprot;

    // Retrieve WDATA from centralized memory model instead of directly from AXI item
    expected_axi_tr.s_axi_rdata   = memory.read(axi_tr.s_axi_araddr);  // Assuming 32-bit word addressing
    expected_axi_tr.s_axi_rid     = axi_tr.s_axi_rid;
    expected_axi_tr.s_axi_rvalid  = 1'b1;


    //`uvm_info("Write_Transaction_Reference_Model", $sformatf("\nExpected AW Channel AXIL item:\n%s", expected_axil_tr.conv2str(2'b00)), UVM_LOW);
    //`uvm_info("Write_Transaction_Reference_Model", $sformatf("\nExpected W  Channel AXIL item:\n%s", expected_axil_tr.conv2str(2'b01)), UVM_LOW);
    
    return expected_axi_tr;
  endfunction

  // Function to populate the axil_sequence queue with the expected AXI-Lite transactions
  function void create_expected_axi_sequence(axi_item axi_tr);
    axi_sequence.delete();  // Clear the queue before starting

    // Loop over each beat in the burst, generating an AXI transaction for each
    for (int i = 0; i <= axi_tr.s_axi_arlen; i++) begin
      axi_item expected_axi_tr_seq = axi_item::type_id::create("expected_axi_tr_seq");
      expected_axi_tr_seq = create_expected_axi_tr(axi_tr, i);
      axi_sequence.push_back(expected_axi_tr_seq);  // Use push_back with the queue
    end
  endfunction

  // // Internal state variables to track burst processing
  // int axi_burst_len;
  // int axi_burst_size;
  // logic [31:0] axi_addr;  // Assuming 32-bit addresses

  // // Constructor
  // function new();
  //   // Initialize internal states
  //   this.axi_burst_len = 0;
  //   this.axi_burst_size = 0;
  //   this.axi_addr = 0;
  // endfunction

  // // Function to set the centralized memory model
  // function void set_memory(centralized_memory_model memory);
  //   this.mem = memory;  // Store the reference to the centralized memory
  // endfunction

  // // Function to handle an AXI read request
  // function void axi_read_request(input axi_item axi_tx);
  //   // AXI burst length, burst size, and starting address from the AXI transaction
  //   this.axi_burst_len = axi_tx.s_axi_arlen;  // AXI burst length
  //   this.axi_burst_size = axi_tx.s_axi_arsize;  // AXI burst size
  //   this.axi_addr = axi_tx.s_axi_araddr;  // Starting address
  // endfunction

  // // Function to convert AXI transaction to AXI-Lite transaction
  // function axil_item convert_axi_to_axil();
  //   axil_item axil_tx = axil_item::type_id::create("axil_tx");  // Create an AXI-Lite item

  //   // Single AXI-Lite read transaction for the current AXI address
  //   axil_tx.m_axil_araddr = this.axi_addr;  // Pass the address to AXI-Lite

  //   // Fetch data from the centralized memory model
  //   axil_tx.m_axil_rdata = this.mem.read(this.axi_addr);  // Use the centralized memory for read data

  //   // Increment the AXI address for the next burst transfer
  //   this.axi_addr = this.axi_addr + (1 << this.axi_burst_size);  
  //   this.axi_burst_len--;

  //   // Set other fields for the AXI-Lite transaction
  //   axil_tx.m_axil_arprot = 3'b000;  // Assuming no special protection bits
  //   axil_tx.m_axil_arvalid = 1'b1;   // Valid read request
  //   axil_tx.m_axil_rvalid = 1'b1;    // Valid read response
  //   axil_tx.m_axil_rresp = 2'b00;    // OKAY response

  //   return axil_tx;
  // endfunction

  // // Task to convert an entire AXI burst into AXI-Lite transactions
  // function void convert_burst_to_axil(output axil_item axil_tx[]);
  //   int idx = 0;
  //   axil_tx = new[this.axi_burst_len];  // Initialize the array for AXI-Lite items
  //   while (this.axi_burst_len > 0) begin
  //     axil_tx[idx] = convert_axi_to_axil();  // Convert each part of the burst to AXI-Lite
  //     idx++;
  //   end
  // endfunction

endclass
